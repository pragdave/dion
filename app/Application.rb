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

require 'cgi'

require "app/ApplicationTemplate"
require 'reports/Reports.rb'
require 'util/Formatters'

class Application

  include Formatters

  @@all_apps = []
  @@default_app = nil

  def Application.app_info(info)
    @app_info = info
    @@default_app = self if info[:default_app]
  end

  def Application.get_app_info
    @app_info
  end

  def Application.inherited(app)
    @@all_apps << app
  end

  def Application.default_app
    raise "No default application" unless @@default_app
    @@default_app
  end

  def Application.valid_application(name)
    name = name.to_s
    @@all_apps.find {|app_class| name == app_class.to_s}
  end

  def initialize(session, context)
    @session = session
    @context = context
    @request = session.request
    @cgi     = session.cgi

    if context.app_data && context.app_data.type == app_data_type
      @data = context.app_data
    else
      @data = context.app_data = app_data_type.new
    end
  end

  def url(action, *args)
    @context.url(self.type, action, *args)
  end

  def log(msg)
    @session.log(msg)
  end

  def missing(what)
    log "Missing #{what}"
    "missing"
  end

  def aff
    @affiliate ||= Affiliate.with_id(@session.user.user_affiliate)
  end


  def handle_display(*args)
    fail "Application #{self.type} failed to implement 'handle_display'"
  end

  def error(txt)
    @session.error(txt)
  end

  def note(txt)
    @session.note(txt)
  end

  def error_list(list)
    @session.error_list = list
  end

  def write_template(values, *templates)
    Template.new(*templates).write_html_on(@request, values)
  end

  # returns the relative path to the .pdf file generated
  def print_report(values, *templates)
    r = Reports.new
    r.generate(values, *templates)
  end

  def generate_pdf(values, *templates)
    print_report(values, *templates)
  end

  def send_header
    @request.status = Apache::HTTP_OK
    @request.content_type = 'text/html'
    @request.send_http_header
  end

  def page(title, values, layout, *templates)
    send_header

    values['title'] = title
    values['error_msg'] = @session.error_msg if @session.error_msg
    values['note_msg']  = @session.note_msg  if @session.note_msg
    values['main_menu_url'] ||= @context.url(Portal)
    values['main_menu']     ||= "Main Menu"
    values['extra_css'] = Config::DEBUG ? "/debug.css" : "/live.css"
    values['http']      = Apache::request.construct_url('')

    if @session.error_list
      if @session.error_list.size == 1
        values['error_msg'] = @session.error_list[0]
      else
        list = []
        @session.error_list.each do |msg|
          list << { 'error' => msg }
        end
        values['error_list'] = list
      end
    end

    write_template(values, layout, *templates)
  end

  def standard_page(title, values, *templates)
    page(title, values, PAGE_LAYOUT, *templates)
  end

  def front_page(title, values, *templates)
    page(title, values, FRONT_LAYOUT, *templates)
  end

  def popup_page(title, values, *templates)
    send_header
    values['title'] = title
    values['extra_css'] = Config::DEBUG ? "/debug.css" : "/live.css"
    write_template(values, POPUP_LAYOUT, *templates)
  end

  
  # get a hash of the values on a CGI form
  def hash_from_cgi
    values = Hash.new("")
    @cgi.keys.each {|k| values[k] = @cgi[k]}
    values
  end

  # Display an error and return to the portal
  def page_error(msg)
    error(msg)
    @session.dispatch(Portal)
  end

end

require 'app/Login'
require 'app/Portal'

