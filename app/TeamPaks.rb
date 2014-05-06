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

# Maintain TeamPaks (aka memberships)

require 'app/Application'
require 'db/MemberSearch'

require 'app/TeamPaksTemplates'
require 'app/UpdateTeampak'

class  TeamPaks < Application

  app_info(:name => TeamPaks)
  
  class AppData
    attr_accessor :aff_id
  end

  def app_data_type
    AppData
  end

  ######################################################################
  
  # Search:
  #
  # 1. Show form
  # 2. If what comes back matches exactly one teampak, display
  #    it, otherwise display a list
  # 3. Allow selection from the list

  # 1. Set up the search form. If aff_id is specified, then
  #    constraint the search to that affiliate.

  def search_form(aff_id=nil)
    @data.aff_id = aff_id
    ms = MemberSearch.new(@session)
    ms.display_all_fields

    if aff_id
      aff = Affiliate.with_id(aff_id)
      ms.fix_field(:mem_affiliate, aff_id)
#      ms.hide_field(:mem_affiliate)
      ms.fix_field(:mem_passport_prefix, aff.aff_passport_prefix)
    end

    html = ms.to_form(url(:handle_search), 
                      false,
                      "Find matches",
                      '')

    values = {
      'done' => url(:handle_search)
    }

    standard_page("Search for TeamPak",
                  values,
                  SEARCH_PAGE,
                  html)
  end


  # 2. Get the form back and do the initial search. 

  MAX_TO_FETCH = 20 

  def handle_search
    ms = MemberSearch.new(@session)
    where, tables = ms.build_query
    list = Membership.list_from_member_search(where, tables, MAX_TO_FETCH)
    if list.empty?
      note "No matches found"
      search_form(@data.aff_id)
    elsif list.size == 1
      display_membership(list[0])
    else
      display_list(list, MAX_TO_FETCH)
    end
  end


  def display_membership(mem)
    @session.dispatch(Register, :handle_status, [mem.mem_id])
  end

  def display_list(list, max)
    values = {}
    vallist = list.map do |mem|
      res = mem.add_to_hash({})
      if list.size < 30
        res['status_url'] = @context.url(Register, :handle_status, mem.mem_id)
      end
      res
    end
    values['list'] = vallist
    standard_page("List Matches", values, LIST_MATCHES)
  end


  ######################################################################
  #
  # Delete a teampak. We can only delete a teampak if is hasn't participated
  # in any payment (that is there are no PAYS table entries for it)
  
  # Step 1 - prompt for the teampak

  def delete_teampak
    ms = MemberSearch.new(@session)
    ms.display_fields(:mem_passport_prefix, :mem_passport)
    html = ms.to_form(url(:handle_delete), 
                      false,
                      "Find TeamPak",
                      '')

    standard_page("Delete TeamPak",
                  { 'done' => url(:handle_delete)},
                  DELETE_PAGE,
                  html)

  end


  def handle_delete
    ms = MemberSearch.new(@session)
    where, tables = ms.build_query
    list = Membership.list_from_member_search(where, tables, MAX_TO_FETCH)
    if list.empty?
      note "No matches found"
      delete_teampak
    elsif list.size > 1
      note "Please specify the full passport"
      delete_teampak
    else
      confirm_delete(list[0])
    end
  end


  def confirm_delete(mem)
    return delete_teampak unless delete_permitted(mem)

    values = { "do_delete" => url(:do_delete, mem) }

    mem.add_to_hash(values)

    values['text_status'] = StateName.with_id(mem.mem_state)

    unless @orders.empty?
      values['orders'] = @orders.map do |o|
        res = { 'order_url' => @context.url(OrderStatus, :display_from_id, o.order_id) }
        o.add_to_hash(res)
      end
    end

    standard_page("Confirm TeamPak Delete",
                  values,
                  CONFIRM_DELETE,
                  Register::MEMBERSHIP_DETAILS, 
                  Register::CONTACT,
                  Register::CONTACT,
                  Portal::STATUS_ORDERS)
    
  end


  # we can only delete if
  # 1. The membership is awaiting payment or suspended
  # 2. No money has been applied to any orders associated with us
  # 3. No items associated with us have been shipped

  def delete_permitted(mem)
    unless mem.suspended? || mem.mem_state.strip == StateNameTable::WaitPayment
      error "Only TeamPaks awaiting payment can be deleted"
      return false
    end

    @orders = Order.list_for_membership(mem.mem_id)

    @orders.each do |order|
      pays = Pays.for_order(order)
      unless pays.empty?
        error "Cannot delete a TeamPak after orders associated with it have been paid"
        return false
      end
      LineItem.items_for_order(order.order_id) do |li|
        if li.li_date_shipped
          error "Cannot delete: '#{li.li_desc}' has been shipped"
          return false
        end
      end
    end
    true
  end


  def do_delete(mem)
    # lock the database
    
    $store.locked_transaction(MembershipTable, 
                              MembershipHistoryTable,
                              OrderTable,
                              LineItemTable,
                              TeamTable,
                              TeamMemberTable,
                              ChangeRequestTable) do 
      return delete_teampak unless delete_permitted(mem)
      
      MembershipHistory.delete_for_membership(mem.mem_id)
      Role.delete_for_teampak(mem.mem_id)
      Order.delete_for_teampak(mem.mem_id)
      Team.delete_for_teampak(mem.mem_id)
      ChangeRequest.delete_for_teampak(mem.mem_id)

      mem.delete

      mem.log_to_all("deleted by #{@session.user.contact.con_name}",
                     @session.user.user_id)

      note "Teampak #{mem.full_passport} deleted"
      @context.no_going_back
      @session.pop
    end

  end

  ######################################################################
  # Amend teampak details
  #
  # We allow direct change of the names and district, and of the
  # affiliate

  def alter_teampak
    ms = MemberSearch.new(@session)
    ms.display_fields(:mem_passport_prefix, :mem_passport)
    html = ms.to_form(url(:handle_alter), 
                      false,
                      "Find TeamPak")

    standard_page("Alter TeamPak",
                  { 'done' => url(:handle_alter)},
                  ALTER_FIND,
                  html)
  end


  def handle_alter
    ms = MemberSearch.new(@session)
    where, tables = ms.build_query
    list = Membership.list_from_member_search(where, tables, MAX_TO_FETCH)
    if list.empty?
      note "No matches found"
      alter_teampak
    elsif list.size > 1
      note "Please specify the full passport"
      alter_teampak
    else
      @session.dispatch(UpdateTeampak, :edit_existing_teampak, [ list[0] ])
    end
  end



#   def present_existing_data(mem)
#     values = mem.add_to_hash({})
#     values['creator_email'] = mem.creator.contact.con_email
#     values['creator_name']  = mem.creator.contact.con_name
#     values['contact_email'] = mem.admin.contact.con_email
#     values['contact_name']  = mem.admin.contact.con_name

#     alter_common(values, mem)
#   end
  
#   def alter_common(values, mem)
#     opts = Affiliate.options
#     opts.delete(Affiliate::NONE)

#     values['aff_opts'] = opts
#     values['do_alter'] = url(:do_alter, mem)

#     standard_page("Alter TeamPak", values, ALTER_TEAMPAK)
#   end


#   def do_alter(mem)
#     changes = []
#     errors = []

#     values = {
#       'mem_name'       => @cgi['mem_name'],
#       'mem_schoolname' => @cgi['mem_schoolname'],
#       'mem_district'   => @cgi['mem_district'],

#     }
    
#     name = values['mem_name'] || ''

#     if name != mem.mem_name
#       if name.empty?
#         errors << "Passport name must be specified"
#       else
#         changes << "Passport name changed from '#{mem.mem_name}' to '#{name}'"
#         mem.mem_name = name
#       end
#     end

#     school = values['mem_schoolname'] || ''
#     if school != mem.mem_schoolname
#       if school.empty?
#         errors << "Schoolname must be specified"
#       else
#         changes << "School name changed from '#{mem.mem_schoolname}' to '#{school}'"
#         mem.mem_schoolname = school
#       end
#     end

#     district = values['mem_district'] || ''
#     if district != mem.mem_district
#       if district.empty?
#         errors << "District must be specified"
#       else
#         changes << "District changed from '#{mem.mem_district}' to '#{district}'"
#         mem.mem_district = district
#       end
#     end

#     unless errors.empty?
#       error_list(errors)
#       return alter_common(values, mem)
#     end

#     if changes.empty?
#       note "No changes made"
#       return @session.pop
#     end

#     mem.save
#     changes.each do |c|
#       mem.log(@session.user, c)
#       @session.user.log("TeamPak #{mem.full_passport}: #{c}")
#     end

#     note "TeamPak updated"

#     @session.pop
#   end

end
