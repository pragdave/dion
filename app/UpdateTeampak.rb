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

require 'date'

require 'app/CreditCardResponse'
#require 'app/Login'
#require 'app/OrderStatus'
require 'app/UpdateTeampakTemplates'
#require 'app/Teams'
require 'bo/Affiliate'
require 'bo/CombinedProducts'
require 'bo/CreditCard'
require 'bo/Membership'
require 'bo/Order'
require 'bo/PaymentMethod'
require 'bo/PaymentOption'
require 'bo/StateName'
require 'bo/User'
require 'db/MemberSearch'
require 'util/Mailer'
#require 'web/Template'

class UpdateTeampak < Application

  app_info(:name => :UpdateTeampak)

  class AppData
    attr_accessor :mem

    attr_accessor :new_user

    attr_accessor :creator_email
    attr_accessor :creator_name

    attr_accessor :products
    attr_accessor :product_qty
    attr_accessor :original_product_qty

    attr_accessor :orders

    # ID of the credit card transaction
    attr_accessor :cc_id
  end

  def app_data_type
    AppData
  end


  ######################################################################
  # Edit an existing membership (only available at the HQ level)

  def edit_existing_teampak(mem)
    @data.mem = mem
    @data.creator_email = mem.creator.contact.con_email
    @data.creator_name  = mem.creator.contact.con_name
    @data.products = CombinedProducts.for_affiliate(mem.creator.affiliate, 
                                                    CombinedProducts::SHOW_ON_APP)
    @data.product_qty = {}
    @data.orders = Order.list_for_membership(mem.mem_id)
    edit_common
  end

  def edit_common
    mem = @data.mem
    values = {}
    mem.add_to_hash(values)

    values['creator_email'] = @data.creator_email
    values['creator_name']  = @data.creator_name

    msg = too_late_to_change_order?

    if msg
      values['order_fixed'] = msg
    else
      setup_products(values)
    end

    values['form_target'] = url(:handle_filled_in_form)

    standard_page("Update TeamPak Information",
                  values,
                  UPDATE_TEAMPAK)
  end


  def setup_products(values)
    mem_type_names = {}

    @data.products.member_products.each do |p|
      mem_type_names[p.prd_type] = p.desc_with_price
    end

    values['mem_type_opts'] = mem_type_names

    qty = @data.product_qty
    @data.products.other_products.each {|p| qty[p.prd_id] = 0}

    @data.orders.each do |order|
      order.each_line do |item|
        if qty.has_key?(item.li_prd_id)
          qty[item.li_prd_id] = item.li_qty
        end
      end
    end

    @data.original_product_qty = qty.dup

    values['other_products'] = fill_in_other_products
  end

  def fill_in_other_products
    other_products = []
    @data.products.other_products.each_with_index do |p, i|
      prod = {}
      prod['index']  = i
      prod['qty']    = @data.product_qty[p.prd_id]
      prod['desc']   = p.prd_long_desc
      prod['price']  = "$" + p.fmt_total_price
      prod['prd_id'] = p.prd_id
      other_products << prod
    end
    other_products
  end


  ######################################################################  

  # The user has completed the form. Check for errors, then
  # see if the contact is a valid user. If not, capture
  # some details. If the form calls for shipped materials,
  # we ensure the contact has an address specified

  def handle_filled_in_form

    errors = capture_form

    unless errors.empty?
      error_list errors
      return edit_common
    end

    if @data.mem.admin_is_in_different_affiliate?
      warn_different_affiliate(@data.mem, 
                               :check_admin,
                               :edit_common)
      return
    end

    check_admin
  end



  def check_admin
    if @data.mem.admin_is_new?
      collect_user_info_on(@data.mem.admin)
    else
      finish_transaction
    end
  end




  def warn_different_affiliate(mem, ok_method, cancel_method)
    user_aff = Affiliate.with_id(mem.admin.user_affiliate).aff_long_name
    mem_aff  = Affiliate.with_id(mem.mem_affiliate).aff_long_name

    values = {
      "con_name" => mem.admin.contact.con_name,
      "user_aff" => user_aff,
      "mem_aff"  => mem_aff,
      "ok_url"   => url(ok_method),
      "cancel_url" => url(cancel_method)
    }
    standard_page("Warning: Different Affiliate",
                  values,
                  Register::WARNING_DIFFERENT_AFFILIATE)
  end



  # Pick all the fields out of the form and store them back in our 
  # persistent state. Return any errors as an array of
  # strings

  def capture_form
    errors = []
    
    mem = @data.mem

    values = Hash.new("")

    mem.add_to_hash(values)
    @cgi.keys.each {|k| values[k] = @cgi[k]}

    mem.mem_name       = values['mem_name']
    mem.mem_schoolname = values['mem_schoolname']
    mem.mem_district   = values['mem_district']

    mem.mem_type       = values['mem_type']

    if mem.mem_name.empty?
      errors << "The passport name cannot be empty"
    end


    if mem.mem_schoolname.empty?
      errors << "The school name cannot be empty"
    end

    if mem.mem_district.empty?
      errors << "The school district cannot be empty"
    end


    
    email = values['creator_email']

    if email != @data.creator_email
      @data.creator_email = email

      if email.empty?
        errors << "Must specify a TeamPak creator"
      end
      
      user = User.with_email(email)
      unless user
        errors << "TeamPak creator must be an existing user"
      else
        mem.creator = user
        @data.creator_name = user.contact.con_name
      end
    end

    email = values['con_email']

    unless email.empty?
      msg = Mailer.invalid_email_address?(email)
      errors << msg if msg 
    end

    res =  @data.mem.set_admin_from_email(email)
    errors << res if res


    99.times do |i|
      qty_key = "prd_qty_" + i.to_s
      id_key  = "prd_id_" + i.to_s
      break unless values.has_key?(qty_key)
      qty = values[qty_key]
      qty = '0' if qty.empty?
      errors << "Invalid quantity '#{qty}'" unless qty =~ /^\d+$/
      prd_id = values[id_key].to_i
      @data.product_qty[prd_id] = qty.to_i
    end

    errors
  end




  def finish_transaction

    mem = @data.mem

    changes = []

    creator_changed = false

    updated_orders = []

    mem.changed_fields.each do |f|
      case f
      when :mem_name
        changes << "Passport name changed to '#{mem.mem_name}'"
      when :mem_schoolname
        changes << "School name changed to '#{mem.mem_schoolname}'"
      when :mem_district
        changes << "District changed to '#{mem.mem_district}'"
      when :mem_admin
        admin_name = mem.admin.contact.con_name
        changes << "Contact changed to '#{admin_name}'"
      when :mem_creator
        creator_name = mem.creator.contact.con_name
        changes << "Creator changed to '#{creator_name}'"
        creator_changed = true
      when :mem_type
        changes << "TeamPak type changed to #{Product.prd_type_opts[mem.mem_type]}"
        updated_orders << change_teampak_type
      else
        puts "Unknown change #{f}<p>"
      end
    end


    @data.product_qty.each_key do |prd_id|
      old_qty = @data.original_product_qty[prd_id]
      new_qty = @data.product_qty[prd_id]

      begin
        if old_qty != new_qty
          order = get_teampak_order
          prd = @data.products.with_id(prd_id)
          updated_orders << order
          
          if old_qty.zero?
            order.add(prd, new_qty)
            changes << "Added order for #{prd.prd_short_desc}"
          elsif new_qty.zero?
            item = order.find_match(prd, old_qty)
            order.delete_line(item)
            changes << "Removed order for #{prd.prd_short_desc}"
          else
            item = order.find_match(prd, old_qty)
            item.set_from_product(prd, new_qty)
            changes << "Changed number of #{prd.prd_short_desc} from #{old_qty} to #{new_qty}"
          end
        end
      rescue Exception => e
        error e.message
        return @session.pop
      end
    end

    if changes.empty?
      note "No changes made"
    else
      
      $store.transaction do
        mem.save
        updated_orders.uniq.each do |order|
          order.record_sales
        end
        if creator_changed
          update_order_owners(mem)
        end
      end
      
      name = @session.user.contact.con_name

      changes.each do |c|
        mem.log(@session.user, c + " by #{name}")
        @session.user.log("TeamPak #{mem.full_passport}: #{c}")
      end
      
      @context.no_going_back
      note "TeamPak updated"
    end

    @session.pop
  end


  # Search all the orders for 'mem' to find the one that
  # contains the teampak order

  def update_order_owners(mem)
    @data.orders.each do |order|
      order.set_user_id(mem.creator.user_id)
      order.save
    end
  end

  ###################### user stuff ################################

  # Pick up the information on a new user

  def handle_collect_user_info(strict, new_user)
    values = Hash.new("")

    u = @data.new_user

#    u.add_to_hash(values)
    values = hash_from_cgi
    values['user_affiliate'] = u.user_affiliate

#    @cgi.keys.each {|k| values[k] = @cgi[k]}

    u.from_hash(values)

    errors = u.error_list(strict)

    if errors.empty?
      if new_user
        email = u.contact.con_email
        pass = u.create_new_password unless email.empty?
        u.save
        notify_newly_created_user(pass) unless email.empty?
      else
        u.save
      end
      finish_collecting_user_info
    else
      error_list errors
      collect_user_info_on(u, strict, new_user)
    end
  rescue Exception => e
    error e.message
    collect_user_info_on(u, strict, new_user)
  end


  # They entered a user who we don't know on the main form.
  # Gather whatever information we can

  def collect_user_info_on(user, strict=false, new_user=true)
    @data.new_user = user

    values = {
      "form_target" => url(:handle_collect_user_info, strict, new_user),
      "contact_type" => "contact",
      "cap_contact_type" => "Contact",
      
    }

    user.add_to_hash(values)

    standard_page("Update User",
                  values,
                  Register::NEW_USER)
  end


  # called when collect_user_info returns
  def finish_collecting_user_info
    @data.mem.admin = @data.new_user
    
    finish_transaction
  end




  # tell a newly created user that 
  # 1. they've been created, and
  # 2. they are associate with this affiliate

  def notify_newly_created_user(pass)
    
    mailer = Mailer.new

    name = @data.mem.admin.user_acc_name
    if !name || name.empty?
      name = @data.mem.admin.contact.con_email
    end

    values = { 
      "original_user_name" => @session.user.contact.con_name,
      "mem_name"  => @data.mem.mem_name,
      "user_name" => name,
      "password"  => pass
    }

    mailer.send_from_template(@data.mem.admin.contact.con_email,
                              "Your DION Registration Information",
                              values,
                              Register::NEW_USER_EMAIL)
  end



  ######################################################################



  #######
  private
  #######


  # We can only update the order side of a teampak if 
  # 1. The membership is awaiting payment
  # 2. No money has been applied to any orders associated with us
  # 3. No items associated with us have been shipped

  def too_late_to_change_order?
    mem = @data.mem
    unless mem.mem_state.strip == StateNameTable::WaitPayment
      return "active and suspended TeamPaks cannot be changed"
    end

    @data.orders.each do |order|
      pays = Pays.for_order(order)
      unless pays.empty?
        return "orders associated with it have been paid"
      end
      order.each_line do |li|
        if li.li_date_shipped
          return "'#{li.li_desc}' has been shipped"
        end
      end
    end
    nil
  end


  # Change a teampak from a one-pak to a five-pak (or vice-versa)

  def change_teampak_type
    @data.orders.each do |order|
      order.each_line do |item|
        prd = Product.with_id(item.li_prd_id)
        if prd.is_membership?
          order.delete_line(item)
          mem_prd = @data.products.with_type(@data.mem.mem_type)
          order.add(mem_prd, 1)
          return order
        end
      end
    end
    raise "Couldn't find membership product"
  end

  # return the order that matches this teampak
  def get_teampak_order
    @data.orders.each do |order|
      order.each_line do |item|
        prd = Product.with_id(item.li_prd_id)
        return order if prd.is_membership?
      end
    end
    raise "Couldn't find membership product"
  end
end
