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
require 'app/Login'
require 'app/UserStuffTemplates.rb'
require 'bo/UserHistory'
require 'db/UserSearch'

class UserStuff < Application
  app_info(:name => :UserStuff, :login_required  => true)

  class AppData
    attr_accessor :user_email
    attr_accessor :aff_id
  end

  def app_data_type
    AppData
  end

  ######################################################################

  def create_user
    @session.dispatch(Login, :create_for_third_party)
  end

  ######################################################################

  
  def search_for_user(aff_id=nil)
    @data.aff_id = aff_id
    us = UserSearch.new(@session)
    us.display_all_fields
    if aff_id
      us.fix_field(:role_affiliate, aff_id)
    end

    html = us.to_form(url(:handle_user_search), 
                      false,
                      "Find matches",
                      '')

    values = {
      'done' => url(:handle_user_search)
    }

    standard_page("Search for User",
                  values,
                  SEARCH_PAGE,
                  html)
  end

  MAX_TO_FETCH = 100000

  def handle_user_search
    us = UserSearch.new(@session)
    begin
      where, tables = us.build_query
    rescue Exception => e
      note e.message
      return search_for_user(@data.aff_id)
    end

    list = User.list_from_user_search(where, tables, MAX_TO_FETCH)
    if list.empty?
      note "No matches found"
      search_for_user(@data.aff_id)
    elsif list.size == 1
      display_user_details(list[0], true)
    else
      display_list(list, MAX_TO_FETCH)
    end
  end

  def display_list(list, max)
    values = {}
    vallist = list.map do |user|
      res = user.add_to_hash({})
      contact = user.contact
      contact.add_to_hash(res)
      res['status_url'] = url(:display_details_for_id, user.user_id, true)
      res
    end
    values['list'] = vallist
    standard_page("List Matches", values, LIST_MATCHES)
  end


  def display_details_for_id(user_id, show_search=false)
    user = User.with_id(user_id)
    if user
      display_user_details(user, show_search)
    else
      note "User disappeared"
      search_for_user(@data.aff_id)
    end
  end



  def display_user_details(user, show_search)
    if user.user_affiliate
      aff = Affiliate.with_id(user.user_affiliate)
      affiliate = aff.aff_long_name
    else
      affiliate = "Not set"
    end

    if user.user_region
      reg = Region.with_id(user.user_region)
      region = reg.reg_name
    else
      region = "Not set"
    end
    
    values = {
      'affiliate' => affiliate,
      'region'    => region,
    }

    if @session.ad_session || @session.hq_session
      email = user.contact.con_email
      need_email = email && !email.empty?
      values['edit_user_url'] = 
        @context.url(Login,
                     :handle_update_details_for_third_party, 
                     user,
                     need_email)
      values['change_pw_url'] = 
        @context.url(Login, :handle_change_password_third_party, user)
    end

    values['form_url'] = url(:search_for_user, @data.aff_id) if show_search

    user.add_to_hash(values)

    add_roles(user, values)
    add_history(user, values)
    
    standard_page("User Information", values, USER_INFORMATION)
  end


  ######################################################################

  def add_roles(user, values)
    count_hash = RoleList.counts_for_user(user.user_id)
    sum = 0
    count_hash.each_value {|count| sum += count}
    if sum > 15
      res = []
      count_hash.keys.sort.each do |role|
        res << { 'role_name' => role, 'count' => count_hash[role] }
      end
      values['role_summary'] = res
      values['role_list']    = url(:show_all_roles, user.user_id)
    else
      values['roles'] = role_data(user.user_id)
    end
  end

  def role_data(user_id)
    roles = RoleList.for_user(user_id).map do |role|
      info =  {
        "name" => role.name,
      }
      if role.role_affiliate
        info['affiliate'] = role.affiliate.aff_short_name 
      else
        info['affiliate'] = ''
      end
      if role.role_region
        info['region'] = role.region.reg_name 
      else
        info['region'] = ''
      end
      
      if role.role_target_type
        info['target_name'] = role.target_name
        ti = role.target_info
        info['target_info'] = ti.name
        
        if ti.viewer_class
          info['viewer'] = @context.url(ti.viewer_class,
                                        ti.viewer_method,
                                        ti.target_id)
        end
      else
        info['target_name'] = ''
        info['target_info'] = ''
      end
      info
    end
    roles
  end

  def show_all_roles(user_id)
    values = {
      'roles' => role_data(user_id)
    }
    popup_page("All Roles", values, ALL_ROLES)
  end

  
  MAX_HISTORY = 15

  def add_history(user, values)
    list = UserHistory.list_for_user(user.user_id, MAX_HISTORY)
    count = UserHistory.count_for_user(user.user_id)

    if count > MAX_HISTORY
      values['extra_history'] = "See all #{count} history entries"
      values['extra_history_url'] = url(:show_extra_history, user.user_id)
    end

    values['history_list'] = list.map {|uh| uh.add_to_hash({}) }
  end
    

  def show_extra_history(user_id)
    list = UserHistory.list_for_user(user_id, 999999)
    values = {
      'history_list' => list.map{|uh| uh.add_to_hash({}) }
    }

    popup_page("Full User History", values, FULL_USER_HISTORY)
  end

  ######################################################################

end
