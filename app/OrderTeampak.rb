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
require 'app/Register'

require 'app/OrderTeampakTemplates'
require 'db/MemberSearch'

class OrderBase < Application
  app_info(:name => 'OrderBase')

  class AppData
    attr_accessor :email
    attr_accessor :user
    attr_accessor :aff_id
    attr_accessor :mem
  end

  def app_data_type
    AppData
  end

  ######################################################################
  # Upgrade an existing teampak

  def upgrade_third_party
    ms = MemberSearch.new(@session)
    ms.display_fields(:mem_passport_prefix, :mem_passport)
    html = ms.to_form(url(:handle_delete), 
                      false,
                      "Find TeamPak",
                      '')

    standard_page("Upgrade TeamPak",
                  { 'done' => url(:handle_upgrade)},
                  UPGRADE_PAGE,
                  html)

  end


  def handle_upgrade
    ms = MemberSearch.new(@session)
    where, tables = ms.build_query
    list = Membership.list_from_member_search(where, tables, 2)
    if list.empty?
      note "No matches found"
      upgrade_third_party
    elsif list.size > 1
      note "Please specify the full passport"
      upgrade_third_party
    else
      mem = list[0]
      if mem.mem_type != Membership::OnePak
        error "You can only upgrade an individual TeamPak"
      elsif mem.mem_upgrade_pending
        error "This TeamPak already has an upgrade pending"
      else
        @context.dispatch(@session,
                          Register,
                          :handle_upgrade_onepak_third_party, 
                          [ mem, mem.creator ])
      end
    end
  end


  ######################################################################
  # Renew an existing teampak

  def renew_third_party(aff_id=nil)
    ms = MemberSearch.new(@session)
    ms.display_fields(:mem_passport_prefix, :mem_passport)
    @data.aff_id=aff_id
    if aff_id
      aff = Affiliate.with_id(aff_id)
      unless aff
        error "Missing affiliate"
        return @session.pop
      end
      ms.fix_field(:mem_affiliate, aff_id)
      ms.fix_field(:mem_passport_prefix, aff.aff_passport_prefix)
    end

    html = ms.to_form(url(:handle_renew), 
                      false,
                      "Find TeamPak",
                      '')

    standard_page("Renew TeamPak",
                  { 'done' => url(:handle_renew)},
                  RENEW_PAGE,
                  html)

  end


  def handle_renew
    ms = MemberSearch.new(@session)
    where, tables = ms.build_query
    list = Membership.list_from_member_search(where, tables, 2)
    if list.empty?
      note "No matches found"
      renew_third_party(@data.aff_id)
    elsif list.size > 1
      note "Please specify the full passport"
      renew_third_party(@data.aff_id)
    else
      @data.mem = mem = list[0]
      if mem.suspended?
        aff = Affiliate.with_id(mem.mem_affiliate)
        raise "Missing affiliate" unless aff
        if ok_to_order(aff, true)
          display_current_creator
        end
      else
        error "You can only renew a suspended TeamPak from last year. " +
          "#{mem.full_passport} has status '#{StateName.with_id(mem.mem_state)}'."
        renew_third_party(@data.aff_id)
      end
    end
  end


  # When renewing on behalf of a third party, we allow them to change the 
  # creator details

  def display_current_creator
    mem = @data.mem

    values = {
      "ok_url" => url(:continue_to_renew),
      "change_url" => url(:change_creator),
      'edit_user_url' => url(:change_existing_user)
    }
    mem.add_to_hash(values)
    standard_page("Check Creator", values, CHECK_CREATOR, Register::CONTACT)
  end


  # change details for an existing user
  def change_existing_user
    mem = @data.mem
    creator = mem.creator
    email = creator.contact.con_email
    need_email = email && !email.empty?

    @session.push(self.class, :continue_to_renew)
    @session.dispatch(Login,
                      :handle_update_details_for_third_party, 
                      [ creator, need_email ])
  end

  # Is's OK to renew with the current creator
  def continue_to_renew
    note "Please check the renewal teampak details, update the payment " +
      "method, then press continue"

    @context.dispatch(@session,
                      Register,
                      :handle_renew, 
                      [ @data.mem.mem_id, @data.mem.creator ])
  end


  # Come here if the creator is a different person
  def change_creator
    @data.email ||= ''
    values = {
      'form_url'     => url(:handle_renew_finding_user),
      'no_email_url' => url(:renew_no_email),
      'email'        => @data.email
    }
    standard_page("Specify New Creator", values, GET_NEW_CREATOR)
  end

  def handle_renew_finding_user
    email = @data.email = @cgi['email']
    if email.empty?
      error "Please enter an e-mail address, or click '[No E-Mail]' " +
        "if not known"
      return change_creator
    end

    user = @data.user = User.with_email(email)

    if user
      if @data.aff_id && @data.aff_id != user.user_affiliate
        note "Warning: That user is not in your affiliate. You can " + 
          "continue to register the TeamPak, or you can go back " +
          "and select another user"
      end
      @data.mem.creator = user
      continue_to_renew
    else
      renew_create_user(email)
    end
  end


  def renew_create_user(email)
    user = @data.user = User.new
    user.contact.con_email = email
    user.user_affiliate    = @data.aff_id
    @session.push(type, :renew_back_from_creating_user)
    @session.dispatch(Login, :create_for_third_party, 
                      [ user, email != nil ] )
  end

  def renew_no_email
    renew_create_user(nil)
  end

  def renew_back_from_creating_user
    @data.mem.creator = @data.user
    continue_to_renew
  end

  ######################################################################

  # Ask for the user to order on behalf of
  
  def order_third_party(aff_id=nil)
    @data.email ||= ''
    @data.aff_id  = aff_id
    values = {
      'form_url'     => url(:handle_finding_user),
      'no_email_url' => url(:no_email),
      'email'        => @data.email,
      'type'         => order_type,
    }
    standard_page("Create TeamPak", values, GET_USER)
  end

  def handle_finding_user
    email = @data.email = @cgi['email']
    if email.empty?
      error "Please enter an e-mail address, or click '[No E-Mail]' " +
        "if not known"
      return order_third_party(@data.aff_id)
    end

    user = @data.user = User.with_email(email)

    if user
      if @data.aff_id && @data.aff_id != user.user_affiliate
        note "Warning: That user is not in your affiliate. You can " + 
          "continue to register the TeamPak, or you can go back " +
          "and select another user"
      end
      do_order(user)
    else
      create_user(email)
    end
  end


  def create_user(email)
    user = @data.user = User.new
    user.contact.con_email = email
    user.user_affiliate    = @data.aff_id
    @session.push(type, :back_from_creating_user)
    @session.dispatch(Login, :create_for_third_party, 
                      [ user, email != nil ] )
  end

  def no_email
    create_user(nil)
  end


  def back_from_creating_user
    do_order(@data.user)
  end

  def ok_to_order(aff, registration_order)
    unless aff.is_set_up?
      error "This user's affiliate (#{aff.aff_short_name}) is not yet set up. " +
      "Contact the Affiliate Director for details"
      @session.pop
      return false
    end

    if registration_order && !aff.registration_open?
      error "Registration for #{aff.aff_short_name} is open between " +
          "#{aff.fmt_reg_start} and #{aff.fmt_reg_end}. " +
      "Contact the Affiliate Director for details"
      @session.pop
      return false
    end

    return true
  end
    
end


    

class OrderTeampak < OrderBase
  app_info(:name => 'OrderTeampak')

  def order_type
    "a TeamPak order"
  end

  def do_order(user)
    if ok_to_order(user.affiliate, true)
      @session.dispatch(Register, :handle_display, [ user ] )
    end
  end

end



class OrderGeneral < OrderBase
  app_info(:name => 'OrderGeneral')

  def order_type
    "an order"
  end

  def do_order(user)
    if ok_to_order(user.affiliate, false)
      @session.dispatch(GeneralOrders, :order_for_user, [ user.user_id ] )
    end
  end

end
