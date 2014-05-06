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

require 'app/Application'
require 'app/DailyPlanet'
require 'app/LoginTemplate'
require 'bo/User'
require "util/Mailer"
require 'errors/DionException'

class Login < Application


  app_info(:name => :Login)

  class AppData
    attr_accessor :user_name
    attr_accessor :user
    attr_accessor :p1, :p2
    attr_accessor :user_email
    attr_accessor :previous_email
  end

  def app_data_type
    AppData
  end

  ##############################################################
  #
  # Display the basic login page

  def handle_display
    display_login(MAIN_LOGIN)
  end



  def handle_login
    @data.user_name = @cgi['user_acc_name']
    pass       = @cgi['user_password']

    if !@data.user_name || @data.user_name.empty?
      error "Please enter your e-mail address"
      return handle_display
    end

    if !pass || pass.empty?
      error "Please enter your password"
      return handle_display
    end

    user = User.login(@data.user_name, pass)
    if user.nil?
      display_login(RETRY_LOGIN)
    else
      log_user_in(user)
    end
  end


  # Log the user in. If the contact details don't have address
  # information, collect it at this point

  def log_user_in(user)
    note "Welcome, #{user.contact.con_name}"

    user.log("Logged in")
    user.user_last_logged_in = Time.now
    user.save

    sm = SessionManager.new($store)
    sm.fork_session(@session, @context)
    @session.user = user
    @session.news = DailyPlanet.top_news_for_user(user)
    if user.contact.mail.empty?
      @data.user = user
      collect_user_info(false, true)
    else
      @session.pop
    end
  end

  ##############################################################
  #
  #    Create account

  def handle_create
    @data.user = User.new

    @session.push(Login, :back_from_create)
    collect_user_info
  end

  def back_from_create
    log_user_in(@data.user)
  end


  ##############################################################
  # Here is where other code calls us to create users for them
  #

  def create_for_third_party(user = User.new, need_email=true)
    @data.user = user
    collect_user_info(false, false, true, need_email)
    @session.push(Login, :back_from_third_party_create)
  end

  def back_from_third_party_create
    @data.user.log("Created by #{@session.user.contact.con_name}")
    email = @data.user.contact.con_email
    if email && !email.empty?
      @data.user.send_new_password(NEW_USER_EMAIL)
    end

    @session.pop
  end

  # They entered a user who we don't know on the main form.
  # Gather whatever information we can

  def collect_user_info(get_password=true, 
                        first_time=false,
                        third_party=false,
                        need_email=true)

    values = {
      "form_target" => url(:handle_collect_user_info, 
                           get_password, 
                           third_party,
                           need_email),
      "user_affiliate_opts" => Affiliate.options,
      "first_time"  => first_time,
      "third_party" => third_party
    }

      
    @data.user.add_to_hash(values)

    standard_page("Create New User",
                  values,
                  Login::EDIT_USER)
  end


  def handle_collect_user_info(get_password, third_party, need_email)
    values = {}
    u = @data.user
    @cgi.keys.each {|k| values[k] = @cgi[k]}
    u.from_hash(values)

    errors = []

    if need_email && (!u.contact.con_email || u.contact.con_email.empty?)
      errors << "Please specify an e-mail addesss"
    end

    errors.concat u.error_list(true)

    if errors.empty?
      begin
        u.save
        u.register_affiliate_role
      rescue DionException => e
        error(e.message)
        collect_user_info(get_password, false, third_party, need_email)
        return
      end

      if get_password
        collect_password
      else
        @session.pop
      end
    else
      error_list(errors)
      collect_user_info(get_password, false, third_party, need_email)
    end
  end



  def collect_password
    values = {
      "form_target" => url(:handle_collect_password),
      "get_old_password" => false,
      "p1" => @data.p1 || '',
      "p2" => @data.p2 || ''
    }

    standard_page("Enter password",
                  values,
                  Login::COLLECT_NEW_PASSWORD)
  end



  def handle_collect_password
    msg = nil
    @data.p1 = @cgi['p1']
    @data.p2 = @cgi['p2']
    unless @data.p1 == @data.p2
      msg = "Passwords do not match"
    end

    if @data.p1.empty?
      msg = "Please enter a new password"
    end

    if msg
      error msg
      collect_password
      return
    end
    
    u = @data.user
    u.set_password(@data.p1)

    begin
      u.save
    rescue DionException => e
      error e.message
      collect_password
      return
    end

    @session.pop
  end


  ##############################################################
  #
  # Menu of changes to a user

  def handle_menu
    values = {
      "change_pw_url" => url(:handle_change_pw),
      "update_det_url" => url(:handle_update_details)
    }
    standard_page("Maintain My Account",
                  values,
                  Login::UPDATE_MENU)
  end


  def handle_change_pw
    @data.user = @session.user
    collect_password
  end

  def handle_update_details
    @data.user = @session.user
    note "Updating #{@data.user.user_acc_name}"
    @session.push(Login, :back_from_update_details)
    collect_user_info(false)
  end

  def back_from_update_details
    @session.user = @data.user
    note "Saved #{@session.user.user_acc_name}"
    @session.user.log("Updated personal details")
    @session.pop
  end


  # As above, but on behalf of a third party

  def handle_update_details_for_third_party(user, need_email=true)
    @data.user = user
    @session.push(Login, :back_from_update_third_party)
    @data.previous_email = user.contact.con_email
    collect_user_info(false, false, true, need_email)
  end

  def back_from_update_third_party
    @data.user.log("Personal details updated by #{@session.user.contact.con_name}")
    @session.user = @data.user if @session.user.user_id == @data.user.user_id

    email = @data.user.contact.con_email
    if email && !email.empty? && email != @data.previous_email
      @data.user.send_new_password(NEW_USER_EMAIL)
    end

    @session.pop
  end

  ##
  # Change a user's password
  def handle_change_password_third_party(user)
    @data.user = user
    values = {
      'form_target' => url(:back_from_change_password_third_party),
      'name' => user.contact.con_name,
      "p1" => '',
      "p2" => ''
    }

    standard_page("Enter New Password",
                  values,
                  Login::COLLECT_CHANGED_PASSWORD)
  end


  def back_from_change_password_third_party
    @data.p1 = @cgi['p1']
    @data.p2 = @cgi['p2']

    msg = nil

    unless @data.p1 == @data.p2
      msg = "Passwords do not match"
    end

    if @data.p1.empty?
      msg = "Please enter a new password"
    end

    if msg
      error msg
      handle_change_password_third_party(@data.user)
      return
    end
    
    u = @data.user
    u.set_password(@data.p1)

    begin
      u.save
    rescue DionException => e
      error e.message
      handle_change_password_third_party(@data.user)
      return
    end

    @context.no_going_back

    @data.user.log("Password changed by #{@session.user.user_acc_name}")

    note "Password changed"

    @session.pop
end

  ##############################################################
  #
  #    Forgotten password

  # Having forgotten their account details, we prompt the
  # user for their e-mail address

  def handle_forgotten
    values = {
      'form_target' => url(:handle_forgotten_2),
      'email'       => @cgi['email'] || @data.user_name
    }
    standard_page("Retrieve user information", values, RETRIEVE_USER)
  end

  # They respond with their address. We look it up, and if
  # found allocate them a new password and send it to them

  def handle_forgotten_2
    email = @cgi['email'] || ''
    return handle_forgotten if email.empty? 

    user = User.with_email(email)

    if user.nil?
      error "I don't know anyone with that e-mail address"
      return handle_forgotten
    end

    user.send_new_password(FORGOT_PASSWORD)

    user.log("New password e-mailed to user")

    standard_page("Thank You", 
                  {'name' => user.contact.con_name,
                    'email' => user.contact.con_email 
                  },
                  PASSWORD_SENT)
  end




  def display_login(form)
    values = {
      'form_target'   => url(:handle_login),
      'user_acc_name' => @cgi['user_acc_name'] || '',
      'forgot_ref'    => url(:handle_forgotten),
      'create_ac'     => url(:handle_create)
    }
    front_page("Please Login", values, form)
  end



  ######################################################################

  def become_user
    @data.user_email ||= ''
    values = {
      'user_email' => @data.user_email,
      'form_url'   => url(:handle_become_user)
    }

    standard_page("Search for User", values, SEARCH_FOR_USER)
  end


  def handle_become_user
    email = @data.user_email = @cgi['user_email']
    if email.nil? || email.empty?
      error "Specify an e-mail address"
      become_user
      return
    end

    user = User.with_email(email)
    if !user
      error "User not found"
      become_user
      return
    end

    @context.no_going_back
    @session.user.log("Became user #{user.contact.con_name}")
    user.log("#{@session.user.user_acc_name} became this user")

    log_user_in(user)
  end


end

