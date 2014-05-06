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

require "app/Context"
require "cgi"

class NilClass
  def empty?
    true
  end
end

class CGI
  module QueryExtension
    alias_method :values, :[]
    
    def [](name)
      res = values(name)[0].to_s
      res.strip
    end
  end
end


class Session

  # SessionData is the actual class persisted out to the database.
  # It holds all values that span a session. Individual HTML page
  # transitions also have data passed between them: this is done
  # using class Context (see Context.rb)

  class SessionData
    # if we're logged in, the user object, else nil
    attr_accessor :user
    attr_accessor :news
    attr_accessor :remote_ip
    
    # some booleans controlling the session level (rarely used)
    attr_accessor :hq_session
    attr_accessor :ad_session
    attr_accessor :rd_session
  end

  # Return a session object with a given ID. If the remote IP
  # doesn't match, force a new session

  def Session.with_id(cgi, session_mgr, session_id, context, check_ip)
    sess = nil

    unless session_id.nil?
      sess = session_mgr.load_session_row(session_id)
    end

    remote_ip = Apache::request.connection.remote_ip

    session = nil
    if sess
      session = Session.new(cgi, context, session_id, sess)
#      if check_ip
#	if session.remote_ip != remote_ip
#	  $stderr.puts "Remote IP #{remote_ip} doesn't match " +
#	    "session ip #{session.remote_ip}"
#	  session = nil
#	  context.reset
#	end
#      end
    end

    if session.nil?
      session = Session.new(cgi, context, session_mgr.next_free_id)
      session.remote_ip = remote_ip
    end

    session
  end

#  def Session.tidy_old_sessions
#    res = $store.delete_where(SessionTable, 
#                              "age(now(), session_touched) > interval'12 hour'")
#    $stderr.puts "Tidied #{res} session rows"
#  end


  ######################################################################

  attr_reader   :request, :cgi, :session_id
  attr_accessor :error_msg, :note_msg, :error_list


  def initialize(cgi, context, session_id, session_table = nil)
    @context    = context
    @session_id = session_id
    @request    = Apache::request
    @cgi        = cgi
    @session_table = session_table

    @new_session = session_table.nil?

    if @new_session
      @sd = SessionData.new
      @session_table = SessionTable.new
    else
      @sd = SessionManager.decode(session_table.session_data)
    end

  end
  private :initialize

  #################################################################
  #
  # Accessors to session data

  def user
    @sd.user
  end

  def user=(u)
    @sd.user = u
  end

  def news
    @sd.news
  end

  def news=(n)
    @sd.news = n
  end

  def remote_ip
    @sd.remote_ip
  end

  def remote_ip=(n)
    @sd.remote_ip = n
  end

  def hq_session
    @sd.hq_session
  end

  def hq_session=(b)
    @sd.hq_session = b
  end

  def ad_session
    @sd.ad_session
  end

  def ad_session=(b)
    @sd.ad_session = b
  end

  def rd_session
    @sd.rd_session
  end

  def rd_session=(b)
    @sd.rd_session = b
  end


  def set_session_id(sess_id)
    @session_id = sess_id
    @new_session = true
  end

  #################################################################

  def dispatch(klass, action=nil, params=[])
    @context.dispatch(self, klass, action, params)
  end

  # We store both the session (whose ID remains te same for the
  # duration of a session) and the app_data (whose ID changes
  # for every HTML page handled

  def save(store)

    @session_table.session_id      = session_id
    @session_table.session_data    = SessionManager.encode(@sd)
    @session_table.session_touched = Time.now
    @session_table.session_expired = false

    if @new_session
      store.insert_all(@session_table)
    else
      store.update(@session_table)
    end
  end



  # Push a location to return to. This allows us to do things like
  # notice we're not logged in, log in, and return to the
  # place we started

  def push(klass, action)
    @context.push(klass, action)
  end

  # Pop ourselves back to a location, doing an immediate dispatch.
  
  def pop(*args)
    klass, action, app_data = @context.pop
    @context.app_data = app_data
    dispatch(klass, action, args)
  end

  def to_s
    "Session:   #{@session_id}\n" + @context.to_s
  end

  def error(txt)
    @error_msg = txt
  end

  def note(txt)
    @note_msg = txt
  end

  def log(msg)
    Apache::request::server.log_notice(msg)
  end


  private
  

end
