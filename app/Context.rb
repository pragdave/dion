# ----
# Copyright (c) 2003, 2003 David Thomas (dba Thomas Consulting)
# All Rights Reserved.
# The right to use this software is granted by separate license
# between Destination Imagination, Inc and David Thomas.
#
# No part of this program may be reproduced, stored in a retrieval
# system, or transmitted, in any form, or by any means unless 
# explicitly permitted by the license.
# -----

# A context holds information that an application wants to pass back
# to itself when next invoked. Each transition betrween web pages
# generates a new context (so that we hold sufficient state to allow
# us to work correctly with the BACK button). Context also hold their
# parent session key, so that by passing a context ID around we can
# also recover the corresponding session

require 'app/Login'

class Context

  FUDGE = 19037
  # An entry represents an entry point to the application. Each <a href
  # on a page may correspond to an Entry: the URL encodes the entry
  # number in the EntryPoint table, allowing us to recover the
  # entry data itself and dispatch to the correct routine

  Entry = Struct.new(:klass, :action, :params)

  DUMMY_ENTRY = Entry.new(nil, nil, [])

  # Recover a context given a context ID. Return a new context
  # if not found. In either case we grab a new context ID to
  # be used

  def Context.with_id(session_mgr, context_id)
    st = nil
    st = session_mgr.load_session_row(context_id) if context_id
    if st
      c = SessionManager.decode(st.session_data)
      c.expired = st.session_expired
      if c.expired
        c.reset
      end
    else
      c = new
    end

    c.context_id = session_mgr.next_free_id
    c
  end


  #########################################################################
  #
  # Here's the state that we actually save
  # on behalf of the application
  
  attr_accessor :app_data


  # The ID used when next saving us
  attr_accessor :context_id

  # The ID of our session
  attr_accessor :session_id

  # has this context expired
  attr_accessor :expired

  attr_reader :stack
  #
  #
  #########################################################################

  
  # Create a new context. Each context gets a new entry point map, as
  # it corresponds to a new HTML page

  def initialize
    reset_stack
    reset_entry_point_map
  end

  # Return the session object for this context (or a brand new
  # session object if we don't have one
  def session(cgi, session_mgr, check_ip_address)
    session = Session.with_id(cgi, session_mgr, @session_id, self, check_ip_address)
    @session_id = session.session_id
    session
  end


  # Sometimes we want to prohibit folks from using the RELOAD or BACK
  # buttons. To do that, we simply go back and delete all the previous
  # contexts

  def no_going_back
    $store.update_where(SessionTable,
                        "session_expired=TRUE",
                        "session_parent=?",
                        @session_id)
  end

  # Dispatch to the given class and method

  def dispatch(session, klass, action, params)

    # we're starting afresh on a new page, so reset the map
    reset_entry_point_map

    if @expired
      app = Application.default_app
      session.note "RELOAD and BACK buttons were disabled on that page"
    else
      app = Application.valid_application(klass) || Application.default_app
    end

    app = app.new(session, self)
    info = app.type.get_app_info

#    $stderr.puts "Action is #{action.inspect}"

    method = case action
             when String
               if action.empty?
                 nil
               else
                 :action.intern
               end
             else action
             end

#    $stderr.puts "Method is #{method.inspect}"
#    $stderr.puts "Method class is #{method.class}"

    if method.nil? #|| !app.respond_to?(method)
      method = info[:default_handler] || :handle_display
    end

    
    $stderr.puts "App is #{app} (#{app.class})"
    $stderr.puts "Dispatch to #{method}(#{params.inspect})"
    $stderr.puts "Dispatch to #{app} -> #{method}"


    if info[:login_required]
      unless session.user
        push(app, method)
        return dispatch(session, Login, nil, [])
      end
    end

    app.send(method, *params)
  end

  # Save ourselves away to the database. As we always have a fresh
  # (and minty) ID, we can simply do an insert

  def save(store)
    sess = SessionTable.new
    sess.session_id      = @context_id
    sess.session_parent  = @session_id
    sess.session_touched = Time.now
    sess.session_expired = false
    sess.session_data = SessionManager.encode(self)
    store.insert_all(sess)
  end


  # Return a url that encodes our context

  def url(klass, action="", *params)
    index = entry_index(klass, action, *params)
    code = (@context_id*32768 + index)*FUDGE
    code = code.to_s.reverse
#    $stderr.puts "URL: #{@context_id}/#{index} => #{code}"
    Apache::request.construct_url("#{ENV['SCRIPT_NAME']}/#{code}")
#    "#{ENV['SCRIPT_NAME']}/#{@context_id}/#{index}"
  end

  # return a context and an index given a coded url
  def Context.decode_url(url)
    $stderr.puts "Decode #{url}"
    dummy, code = url.split("/")
    return nil, nil if code.nil?
    code = code.reverse if code
    code = Integer(code) 
    base, rem = code.divmod(FUDGE)
    unless rem.zero?
      return nil, nil
    end
    $stderr.puts base.divmod(32768)
    base.divmod(32768)
  rescue
    return nil, nil
  end


  def entry_index(klass, action, *params)
    klass = klass.type if klass.type != Class 
    save_entry_point(klass, action, params)
  end


  def reset_entry_point_map
    @entry_point_map = []
  end


  def reset_stack
    @stack = []
  end

  def reset
    @app_data = nil
    reset_entry_point_map
    reset_stack
  end

  # Save an entry point in the map, returning its index. This
  # index is used as part of the url, so that when we're
  # re-entered we can pick up the correct entry point
  # and continue

  def save_entry_point(klass, method, params)
    i = @entry_point_map.size
    @entry_point_map[i] = Entry.new(klass, method, params)
    i
  end

  # Recover an entry point so we can call it
  def entry_point(i)
    @entry_point_map[i] || DUMMY_ENTRY
  end

  # Push a location to return to. This allows us to do things like
  # notice we're not logged in, log in, and return to the
  # place we started

  def push(klass, action)
    @stack.push [klass.to_s, action, @app_data]
  end

  # Return a klass and action from the stack, or nil, nil if
  # the stack is empty
  
  def pop
    if @stack.empty?
      [nil, nil, nil]
    else
      @stack.pop
    end
  end


  def to_s
    res = "stack: #{@stack.inspect}\n"
    res << "\nURLS:\n"
    @entry_point_map.each_with_index do |e,i|
      res << "\t#{i}: #{e.inspect}\n"
    end
    res
  end
end

