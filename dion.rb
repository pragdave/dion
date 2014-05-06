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

script_start = Time.now

def timeit(title)
  s = Time.now
  yield
  e = Time.now
  diff = ((e.to_i - s.to_i)*1000000 + (e.usec - s.usec))/1000.0
  printf "<tr><td>%10.2f<td>%s%s</tr>\n", diff, " "*$level, title
end

=begin
module MyReq

$level = 0
def require(string)
$stderr.puts string
  $level += 2
  timeit(string) { super }
  $level -= 2
end
end

puts "<table>"
include MyReq
=end

require 'cgi'
require "db/TableDefinitions"
require 'db/Store'
require "app/Application"
require 'web/Session'
require 'web/SessionManager'
require 'app/Context'

require 'app/AllApplications'

require 'util/Mailer'

require 'Config'

$show_debug = Config::DEBUG
#puts "</table>"

######################################################################
FAIL_MSG = %{
-----
DION Failure: %msg%
-----

START:trace
%line%
END:trace

-----
CGI VALUES:
START:cgis
%key%  =  %value%
END:cgis

-----
REQUEST HEADERS
START:hdrs
%key%  =  %value%
END:hdrs

-----
SESSION

%session%
}

######################################################################


def CGI::x(*args)
#  require 'pp'
  args.each do |a|
#    res = ''
#    PP.pp(a, 79, res)
    res = a.inspect
    puts "<pre>",CGI.escapeHTML(res), "</pre><p><hr><p>" 
  end
end


def mail_exception(e, session)

  cgis = []
  if session
    cgi = session.cgi
    
    cgi.keys.sort.each do |k|
      cgis << {
        'key' => k,
        'value' => cgi.values(k).inspect
      }
    end
  end

  hdrs = []
  Apache::request.headers_in.each do |k,v|
    hdrs << {
      'key' => k, 'value' => v
    }
  end

  msg = e.message.gsub(/%/, "!!")

  values = {
    'msg' => msg,
    'trace' => e.backtrace.map{|line| {'line' => " * #{line}"} },
    'cgis'  => cgis,
    'hdrs'  => hdrs,
    'session' => session.inspect.gsub(/%/, '!!'),
  }

  Mailer.new.send_from_template(Config::FAILURE_RECEIVER || 'dave@pragprog.com',
                                "DION FAIL: #{msg}",
                                values,
                                FAIL_MSG,
                                true)
end

def reportException(e, session)
  mail_exception(e, session) #unless Config::DEBUG

  req = Apache::request
  req.status = Apache::HTTP_INTERNAL_SERVER_ERROR
  req.content_type = 'text/html'
  req.send_http_header

  puts "<html><head><title>An Error Occurred</title></head>"
  puts "<body>"
  puts "<h2>I'm Sorry...</h2>"
  puts "An error occurred processing your request. We've sent a report "
  puts "off to the developers, who should get it all working shortly. In "
  puts "the meantime, you can always return to the " 
  puts "<a href=\"http://www.destinationimagination.org\">Destination "
  puts "Imagination</a> home page.<p>Sorry about this...<p>"

  if Config::DEBUG

    puts "#{CGI.escapeHTML(e.message.dup)}<ul>"
    puts e.backtrace.map {|line|"<li>#{CGI.escapeHTML(line.dup)}"}
    puts "</ul>"

    if session
      puts "<p>CGI Values<p><ul>"
      cgi = session.cgi
      cgi.keys.sort.each do |k|
        puts "<li>#{k} => #{CGI.escapeHTML(cgi.values(k).inspect)}"
      end
      puts "</ul>"
    end
  end

  puts "</font>"
  puts "</body></html>"

end

###################################################################### 


start_time = Time.now

req = Apache::request

$stderr.puts "\n=========================== #{Time.now}"

cfg = Config.current

context = session = nil

req.setup_cgi_env
cgi = CGI.new

begin

  $store ||= Store.new(cfg.db_connect_string, cfg.db_user, cfg.db_pw)

  context_id, entry_id = Context.decode_url(req.path_info)

  check_ip_address = true


  # Possibly this is a credit card response, in which case
  # the context will be in the post data
  if context_id.nil?
    context_id = cgi['dion_context']
    entry_id   = cgi['entry_id']
    context_id = (Integer(context_id) rescue nil) if context_id
    entry_id   = (Integer(entry_id)   rescue 0)
    check_ip_address = false
  end

  mgr = SessionManager.new($store)

  context = Context.with_id(mgr, context_id)

  session = context.session(cgi, mgr, check_ip_address)

$stderr.puts "Context id = #{context.context_id}, Session id = #{context.session_id}"

  entry = context.entry_point(entry_id)

  if false
    req.status = Apache::HTTP_OK
    req.content_type = 'text/html'
    hdrs = req.headers_out
    #  hdrs['Cache-Control'] = 'no-cache'
    #  hdrs['Pragma']        = 'no-cache'
    #  req['Cache-Control'] = 'no-cache'
    #  req['Pragma']        = 'no-cache'
    req.send_http_header
  end

  session.dispatch(entry.klass, entry.action, entry.params)

  session.save($store)
  context.save($store)

#  $stderr.puts context.to_s

  if $show_debug
    end_time = Time.now
    
    diff1 = ((end_time.to_i - script_start.to_i)*1000000 +
      (end_time.usec - script_start.usec))/1000.0
    
    diff2 = ((end_time.to_i - start_time.to_i)*1000000 +
      (end_time.usec - start_time.usec))/1000.0
    
    puts "<hr><p class=\"debuginfo\">"
    puts CGI.escapeHTML("#{entry.klass}/#{entry.action}/#{entry.params.join(',')} " +
                        "(#{diff1}mS, #{diff2}mS)")
    puts "</p>"
  end


rescue Exception => e
  reportException(e, session)
end

