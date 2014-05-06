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
require 'app/Login'
require 'app/OrderStatus'
require 'app/RegisterTemplates'
require 'app/RequestChange'
require 'app/Teams'
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
require 'web/Template'

class Register < Application

  app_info(:name            => :Register,
           :login_required  => true,
           :default_handler => :handle_display,
           :default_app     => false)


  class AppData
    attr_accessor :mem
    attr_accessor :renewing
    attr_accessor :products
    attr_accessor :product_qty
    attr_accessor :changing_existing
    attr_accessor :payment_option

    # for NewUserCollector
    attr_accessor :new_user

    # And the actual owner of the teampak
    attr_accessor :owner

    # ID of the credit card transaction
    attr_accessor :cc_id
  end

  def app_data_type
    AppData
  end


  # Return a array of information to be displayed in the 'Your
  # memberships' section of the Portal page

  def Register.portal_data(user, context)
    mems = Membership.list_for_user(user)
    mems.map do |m|
      res = {
        "mem_name"       => m.mem_name,
        "mem_schoolname" => m.mem_schoolname,
        "mem_type"       => m.mem_type,
        "full_passport"  => m.full_passport,
        "mem_state"      => StateName.with_id(m.mem_state),
        "status_url"     => context.url(Register, :handle_status, m.mem_id),
      }
      if m.suspended?
        res['renew_url'] = context.url(Register, :handle_renew, m.mem_id)
        res['suspended'] = true
      else
        res["change_url"] = m.mem_creator == user.user_id ?
                                 context.url(Register, :handle_change, m.mem_id) : nil
        res["team_url"]   = context.url(Teams, :handle_display, m.mem_id)
        res['not_suspended'] = true
      end
      res
    end
  end

  # Initial entry to the application. If the user is logged in, we
  # know their affiliate. Otherwise let's prompt them
  # to log in

  #### IN YEAR ONE THERE ARE NO RENEWALS ###
#   def old_handle_display
#     values = {
#       'form_target' => url(:handle_new_or_renew)
#     }
#     standard_page("Select Registration Type", values, NEW_OR_RENEW_TEMPLATE)
#   end


  def handle_display(owner=@session.user)
    @data.owner = owner
    @data.products = CombinedProducts.for_affiliate(owner.affiliate, 
                                                    CombinedProducts::SHOW_ON_APP)
    @data.changing_existing = false
    create_new_passport
  end


  # Come here to renew a membership from last year
  def handle_renew(mem_id, owner=@session.user)
    @data.owner = owner

    @data.mem = Membership.with_id(mem_id)
      if !@data.mem
        error "I couldn't find that TeamPak"
        @session.pop
      else
        if @data.mem.suspended?
          @data.renewing = true
          @data.changing_existing = false
          @data.payment_option = PaymentOption.new
          setup_products()
          initialize_membership
          @data.mem.creator = @data.owner
          handle_collect_membership_info
        else
          error "That membership has already been renewed"
          @session.pop
        end
      end
  end



  def create_new_passport
    @data.payment_option = PaymentOption.new
    @data.renewing = false
    @data.mem = Membership.new
    initialize_membership
    @data.mem.creator = @data.owner
    @data.mem.admin   = @data.owner
    @data.mem.mem_affiliate = @data.owner.user_affiliate
    @data.mem.mem_passport_prefix = @data.owner.affiliate.aff_passport_prefix

    # Pre-select the highest available teampak
    max_prd_type = '0'
    @data.products.each do |prd|
      if prd.prd_type >= ProductTable::TEAMPAK_MIN && 
          prd.prd_type <= ProductTable::TEAMPAK_MAX &&
          prd.prd_type > max_prd_type
        max_prd_type = prd.prd_type
      end
    end
    
    if max_prd_type == '0'
      error "This affiliate has no passport products set up"
      @session.pop
    end

#    @data.mem.mem_type = max_prd_type # changed by request

    setup_other_products
    
    handle_collect_membership_info
  end


  # The user entered a passport number. See if it's real.
  # If so, display the information as a form. Otherwise,
  # prompt again

#   def handle_renew_passport
#     ms = MemberSearch.new(@session)
#     mem_passport = ms[:mem_passport]
    
#     if mem_passport.empty?
#       error "Please enter a passport number below"
#       collect_renew_passport_number
#     else
#       @data.mem = Membership.withPassport(ms[:mem_passport_prefix], ms[:mem_passport])
#       if !@data.mem
#         error "I couldn't find passport #{ms[:mem_passport_prefix]}-" +
#           ms[:mem_passport]
#         collect_renew_passport_number
#       else
#         if @data.mem.suspended?
#           @data.renewing = true
#           initialize_membership
#           handle_collect_membership_info
#         else
#           error "That membership has already been renewed"
#           handle_display
#         end
#       end
#     end
#   end
  
  # Collect the information we need to populate a membership. This may
  # either be a new membership or an existing one

  def handle_collect_membership_info
    collect_common
  end



  # THe user has completed the form. Check for errors, then
  # see if the contact is a valid user. If not, capture
  # some details. If the form calls for shipped materials,
  # we ensure the contact has an address specified

  def handle_filled_in_form

    errors = capture_form

    unless errors.empty?
      error_list errors
      return collect_common
    end


    if @data.mem.admin_is_in_different_affiliate?
      warn_different_affiliate(@data.mem, 
                               :check_product_and_finish,
                               :collect_common)
      return
    end

    check_product_and_finish
  end

  def check_product_and_finish
    unless @data.product_qty.empty?
      @data.product_qty.each_key {|k| @data.product_qty[k] = @data.product_qty[k].to_i}
      
      if @data.product_qty.values.max > 0 && @data.mem.admin.contact.mail.empty?
        note "You'll need to specify an address to receive the materials " +
          "you've ordered"
        collect_user_info_on(@data.mem.admin, true, false)
        return
      end
    end

    if @data.mem.admin_is_new?
      collect_user_info_on(@data.mem.admin)
    else
      finish_transaction
    end
  end



  # Display the status of a teampak
  def handle_status(mem_id)

    mem = Membership.with_id(mem_id)
    raise "Missing membership" unless mem

    values = {}

    mem.add_to_hash(values)

    values['text_status'] = StateName.with_id(mem.mem_state)

    orders = Order.list_for_membership(mem_id)
 
    unless orders.empty?
      values['orders'] = orders.map do |o|
        res = { 'order_url' => @context.url(OrderStatus, :display_from_id, o.order_id) }
        o.add_to_hash(res)
      end
    end

    teams = TeamList.count_for_membership(mem_id)
    if teams.zero?
      values['team_count'] = 'None'
    else
      values['team_count'] = teams.to_s
      values['teams_url']  = @context.url(Teams, 
                                          :handle_display,
                                          mem_id)
    end


    history_list = MembershipHistory.list_for_membership(mem_id)
    users = {}

    unless history_list.empty?
      values['history_list'] = history_list.map do |h|

        time = h.mh_when.to_time
        
        users[h.mh_user] ||= User.with_id(h.mh_user)

        { 'when'  => time.strftime("%d-%b-%y %H:%M"),
          'notes' => h.mh_notes,
          'from'  => h.mh_inet,
          'user'  => users[h.mh_user].user_acc_name
        }
      end
      
    end


    standard_page("TeamPak Status",
                  values,
                  TEAMPAK_STATUS,
                  Register::MEMBERSHIP_DETAILS, 
                  Register::CONTACT,
                  Register::CONTACT,
                  Portal::STATUS_ORDERS,
                  HISTORY_LIST)

  end

  # Handle the updating of a teampak
  
  def handle_change(mem_id)
    @data.mem = Membership.with_id(mem_id)
    @data.changing_existing = true

    raise "Missing membership" unless @data.mem
    change_common
  end


  # OK, the contact name needs changing. 
  
  def handle_change_contact(anon=false)
    raise "Bad state" unless @data.mem

    if anon
      new_email = ''
    else
      new_email = @cgi['con_email']
    end

    if !new_email.empty? && new_email == @data.mem.admin.contact.con_email
      note "No change to contact details..."
      return @session.dispatch(Portal)
    end

    err = @data.mem.set_admin_from_email(new_email)

    if err
      error(err)
      change_common
      return
    end
    
    if @data.mem.admin_is_new?
      collect_user_info_on(@data.mem.admin)
      return
    end

    if @data.mem.admin_is_in_different_affiliate?
      warn_different_affiliate(@data.mem, :save_changed_contact, :change_common)
    else
      save_changed_contact
    end
  end

  def update_anon_contact
    collect_user_info_on(@data.mem.admin)
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
                  WARNING_DIFFERENT_AFFILIATE)
  end


  def handle_upgrade_onepak_third_party(mem, owner)
    @data.mem = mem
    handle_upgrade_onepak(owner)
  end

  def handle_upgrade_onepak(owner=@session.user)
    @data.owner = owner
    @data.payment_option = PaymentOption.new
    common_upgrade_onepak
  end

  def common_upgrade_onepak
    raise "Bad state" unless @data.mem
    raise "not onepak" unless @data.mem.mem_type == Membership::OnePak

    aff = Affiliate.with_id(@data.mem.mem_affiliate)
    @data.products = CombinedProducts.for_affiliate(aff)

    upgrade = get_upgrade_product
    @session.dispatch(Portal) unless upgrade

    values = {
      'upgrade_desc'  => upgrade.prd_long_desc,
      'upgrade_price' => upgrade.fmt_total_price,
      'pay_options'   => get_payment_options,
      'cancel_url'    => @context.url(Portal),
      'purchase_url'  => url(:confirm_purchase_upgrade)
    }

    standard_page('Upgrade OnePak',
                  values,
                  UPGRADE_ONEPAK)
  end

  def confirm_purchase_upgrade
    values = {}

    @cgi.keys.each {|k| values[k] = @cgi[k]}
    
    msg = PaymentMethod.from_form(values, @data.payment_option)

    if msg
      error msg
      common_upgrade_onepak
    else
      upgrade = get_upgrade_product
      @session.dispatch(Portal) unless upgrade
      
      aff = Affiliate.with_id(@data.mem.mem_affiliate)
      order = Order.create(aff)
      order.set_payment_option(@data.payment_option)
      order.set_user_id(@data.owner.user_id)
      order.set_mem_id(@data.mem.mem_id)

      order.add(upgrade, 1)

      order.add_to_hash(values)

      pme = PaymentMethod.from_type(@data.payment_option.pay_method)

      if pme.pme_is_credit_card
        $stderr.puts "It's a credit card"
        cc = CreditCardTransaction.new
        cc.new_transaction(order, 
                           "Destination Imagination: up #{@data.mem.full_passport}",
                           @data.mem.admin.contact)
        cc.hash_for_authorize(values, 
                              @context.context_id, 
                              @context.entry_index(Register, :cc_response, true))
        cc.save
        @data.cc_id = cc.cc_id
        $stderr.puts values['x_Relay_Response'].inspect
      else
        values['confirm_url'] = url(:finish_upgrade_transaction)
      end

      @data.mem.add_to_hash(values)

      standard_page("Upgrade Summary", values, UPGRADE_SUMMARY)
    end
  end


  def finish_upgrade_transaction

    if @data.mem.mem_upgrade_pending 
      note "Upgrade already processed"
      @session.pop
      return
    end

    values = Hash.new("")

    @cgi.keys.each {|k| values[k] = @cgi[k]}
    
    upgrade = get_upgrade_product
    @session.dispatch(Portal) unless upgrade
      
    aff = Affiliate.with_id(@data.mem.mem_affiliate)
    order = Order.create(aff)
    order.set_payment_option(@data.payment_option)
    order.set_user_id(@data.owner.user_id)
    order.set_mem_id(@data.mem.mem_id)

    order.add(upgrade, 1)

    $store.transaction do
      order.record_sales
      
      msg = "Ordered: #{upgrade.prd_long_desc}"
      @data.mem.log(@data.owner, msg)
      if @data.owner == @session.user
        @data.owner.log("Ordered: #{upgrade.prd_long_desc}")
      else
        @data.owner.log("Ordered: #{upgrade.prd_long_desc} by " +
                        @session.user.contact.con_name)
        @session.user.log("Ordered: #{upgrade.prd_long_desc} for " +
                          @data.owner.contact.con_name)
        
      end
      @data.mem.mem_upgrade_pending = true
      @data.mem.save
      notify_clarification_system(@data.mem)

      pme = PaymentMethod.from_type(@data.payment_option.pay_method)
      if pme.pme_is_credit_card && @data.cc_id
        cc = CreditCardTransaction.with_id(@data.cc_id)
        cc.apply_to_order(@session.user, order, @session)
        cc.save
      end

    end
    
    note "Upgrade puchased"
    @context.no_going_back
    @session.dispatch(Portal)
  end

  #


  # Common code when setting up to change a teampak

  def change_common
    setup_products()

    values = {
      'change_contact' => url(:handle_change_contact),
      'cancel_url'     => @context.url(Portal),
      'req_change_url' => @context.url(RequestChange, :request_change, @data.mem.mem_id),
      'add_anon_contact' => url(:handle_change_contact, true),
      'update_anon_contact' => url(:update_anon_contact),
    }

    @data.mem.add_to_hash(values)

    if @data.mem.mem_type == Membership::OnePak && !@data.mem.mem_upgrade_pending
      values['upgrade_url'] = url(:handle_upgrade_onepak)
    end

    standard_page("Update TeamPak",
                  values,
                  UPDATE_TEAMPAK)
  end

  def setup_products
    aff = Affiliate.with_id(@data.mem.mem_affiliate)
    @data.products = CombinedProducts.for_affiliate(aff,
                                                    CombinedProducts::SHOW_ON_APP)
    @data.product_qty = {}
    @data.products.other_products.each {|p| @data.product_qty[p.prd_id] = 0}
  end


  # Ask for the passport number. If we don't know the
  # affiliate prefix, we must be operating in HQ,
  # so we let them type it in

#   def collect_renew_passport_number

#     ms = MemberSearch.new(@session)

#     affiliate = @data.owner.affiliate

#     if affiliate && affiliate.aff_passport_prefix != "000"
#       prefix = affiliate.aff_passport_prefix
#       ms.fix_field(:mem_passport_prefix, prefix)
#     else
#       prefix = nil
#     end

#     ms.display_fields(:mem_passport)
#     search_form = ms.to_form(url(:handle_renew_passport)) 

#     values = { 
#       "fixup_target"        => missing("fixup user region url"),
#       "aff_passport_prefix" => prefix,
#       "aff_long_name"       => affiliate.aff_long_name,
#       "aff_short_name"      => affiliate.aff_short_name,
#     }
#     standard_page("Enter existing passport", values, GET_RENEW_PASSPORT, search_form)
#   end


  # Set up to display the common collection form for a teampak

  def collect_common

    values = {}
    @data.mem.add_to_hash(values)

    values['renewing'] = @data.renewing
    values['form_target'] = url(:handle_filled_in_form)

    # Build a list of the membership-level products (eg onepak and
    # fivepak)

    mem_type_names = {}

    include_aff_fees = false
    @data.products.member_products.each do |p|
      include_aff_fees ||= p.has_affiliate_fee?
      mem_type_names[p.prd_type] = p.desc_with_price
    end

    values['no_aff_fees'] = !include_aff_fees

    values['mem_type_opts'] = mem_type_names

    values['other_products'] = fill_in_other_products

    values['pay_options'] = get_payment_options

    values['nnnn'] = 'n' * @data.owner.affiliate.aff_passport_length

    standard_page("Enter TeamPak Information",
                  values,
                  MEMBERSHIP_APP)
  end


  # Format up payment options for display

  def get_payment_options
    
    po = @data.payment_option

    options = PaymentMethod.options
    options.each do |option|
      method = option['pay_method']
      if po.pay_method == method
        option['checked'] = ' checked'
        option["pay_ref_#{method}"] = po.pay_ref
      else
        option['checked'] = ''
        option["pay_ref_#{method}"] = ""
      end
    end
    options
  end


  # Pick all the fields out of the form and store them back in our 
  # persistent state. Return any errors as an array of
  # strings

  def capture_form
    errors = []
    
    values = Hash.new("")

    @data.mem.add_to_hash(values)
    @cgi.keys.each {|k| values[k] = @cgi[k]}

#    values.keys.sort.each do |k|
#      $stderr.puts "#{k} => #{values[k].inspect}"
#    end


    if values['mem_name'].empty?
      errors << "The passport name cannot be empty"
    else
      @data.mem.mem_name = values['mem_name']
    end


    if values['mem_schoolname'].empty?
      errors << "The school name cannot be empty"
    else
      @data.mem.mem_schoolname = values['mem_schoolname']
    end

    if values['mem_district'].empty?
      errors << "The school district cannot be empty"
    else
      @data.mem.mem_district = values['mem_district']
    end


    passport = values['mem_passport']

    if passport.empty?
      @data.mem.mem_passport = nil
    else
      aff = @data.owner.affiliate
      if passport.length < aff.aff_passport_length
        passport = "0"*(aff.aff_passport_length-passport.length) + passport
      end

      unless aff.passport_is_valid(passport)
        errors << "Passport number is not valid " +
          "(it must be #{aff.aff_passport_length+3} " +
          "digits including the prefix)"
      end
      unless @data.renewing || aff.passport_is_free(passport)
        errors << "Sorry, but passport #{passport} is already taken"
      end
      @data.mem.mem_passport = passport
    end

      
    if values['mem_type'].empty?
      errors << "Specify a membership type (Individual or FivePak)"
    else
      @data.mem.mem_type = values['mem_type']
    end

    99.times do |i|
      qty_key = "prd_qty_" + i.to_s
      id_key  = "prd_id_" + i.to_s
      break unless values.has_key?(qty_key)
      qty = values[qty_key]
      qty = '0' if qty.empty?
      errors << "Invalid quantity '#{qty}'" unless qty =~ /^\d+$/
      prd_id = values[id_key].to_i
      @data.product_qty[prd_id] = qty
    end

    msg = PaymentMethod.from_form(values, @data.payment_option)
    errors << msg if msg

    email = values['con_email']

    unless email.empty?
      msg = Mailer.invalid_email_address?(email)
      errors << msg if msg 
    end

#    if errors.empty?
      res =  @data.mem.set_admin_from_email(email)
      errors << res if res
#    end

    errors
  end

  # return an array of the products actually bought

  def get_products_bought
    res = []
    mem_prd = @data.products.with_type(@data.mem.mem_type)
    raise "Can't find product #{@data.mem.mem_type.inspect}" unless mem_prd
    res << [ 1, mem_prd ]

    @data.product_qty.each do |prd_id, qty|
      if qty > 0
        res << [ qty, @data.products.with_id(prd_id) ]
      end
    end

    res
  end

  # called when collect_user_info returns
  def finish_collecting_user_info
    @data.mem.admin = @data.new_user
    
    if @data.changing_existing
      @data.mem.save
      log_contact_changed
      @session.pop
    else
      finish_transaction
    end
  end


  # We're a double-barrelled method. The first time we're called,
  # we display a form for confirming the order. Once confirmed,
  # we then commit it

  def finish_transaction(confirmed = false)
    unless @data.mem.mem_passport
      @data.mem.mem_passport = @data.owner.affiliate.free_passport_number
      if !@data.mem.mem_passport
        error "Couldn't find a free passport number"
        @session.pop
        return
      end
    end

    products = get_products_bought

    aff = Affiliate.with_id(@data.mem.mem_affiliate)
    order = Order.create(aff)
    order.set_payment_option(@data.payment_option)
    order.set_user_id(@data.owner.user_id)

    products.each do |qty, prd|
      order.add(prd, qty)
    end

    if confirmed
      $store.transaction do 
        save_membership
        order.set_mem_id(@data.mem.mem_id)
        order.record_sales
      end
    end

    values = { 
      "aff_short_name" => aff.aff_short_name,
      "register_another_target"    => url(:handle_display, @data.owner),
    }

    order.add_to_hash(values)

    pme = PaymentMethod.from_type(@data.payment_option.pay_method)

    unless confirmed
      if pme.pme_is_credit_card
        cc = CreditCardTransaction.new
        cc.new_transaction(order, 
                           "Destination Imagination: #{@data.mem.full_passport}",
                           @data.mem.admin.contact)
        cc.hash_for_authorize(values, 
                              @context.context_id, 
                              @context.entry_index(Register, :cc_response))
        cc.save
        @data.cc_id = cc.cc_id
      else
        values['confirm_url'] = url(:finish_transaction, true)
      end
    end

    if confirmed && pme.pme_is_credit_card && @data.cc_id
      cc = CreditCardTransaction.with_id(@data.cc_id)
      cc.apply_to_order(@session.user, order, @session)
      cc.save
    end

    unless pme.pme_is_credit_card
      pay_detail = pme.pme_desc
      pay_ref = @data.payment_option.pay_ref
      if pay_ref && !pay_ref.empty?
        pay_detail += " (number #{pay_ref})"
      end
      values["pay_detail"] = pay_detail
    end

    @data.mem.add_to_hash(values)


    # if this is a confirmation and the order is being entered by HQ
    # staff, don't print the confirmation screen

    # We do the strange stuff with "no going back" because
    # sometimes PostGres breaks and that particular statement can take
    # 10's of seconds. By moving it after the response, we allow
    # authorize.net to get their response back within the timeout period

    if confirmed && 
        @data.owner.user_id != @session.user.user_id && 
        @session.hq_session

      note "TeamPak #{@data.mem.full_passport} created"
      @session.pop
      @context.no_going_back 
      return
    end

    standard_page("TeamPak Summary",
                  values,
                  MEMBERSHIP_SUMMARY,
                  MEMBERSHIP_DETAILS, 
                  CONTACT,
                  CONTACT)

    if confirmed
      @context.no_going_back 
    end
  end


  def cc_response(from_upgrade=false)
    values = hash_from_cgi
    cr = CreditCardTransaction.with_id(@data.cc_id)
    if !cr
      fail "Failed to find credit card transaction: #{@data.cc_id}"
    end

    $stderr.puts "Got CC response for #{@data.cc_id}"
    $stderr.puts cr.inspect

    cr.from_hash(values)

    cr.save

    case cr.cc_response_code
    when CreditCardTransaction::APPROVED
      if from_upgrade
        finish_upgrade_transaction
      else
        finish_transaction(true)
      end
    when CreditCardTransaction::DECLINED, CreditCardTransaction::ERROR
      error_list(['There was a problem with the credit card purchase:',
                   cr.cc_reason_text])
      if from_upgrade
        common_upgrade_onepak
      else
        collect_common
      end
    else
      error "Unexpected response from credit card authorization"
      if from_upgrade
        common_upgrade_onepak
      else
        collect_common
      end
    end
  end



  # Save away a membership
  def save_membership
    @data.mem.mem_dt_created = Time.now 
    
    @data.mem.save
    
    did = @data.renewing ? "renewed" : "created"
    
    @data.mem.log(@session.user, "TeamPak #{did}")

    if @session.user == @data.owner
      @session.user.log("TeamPak #{@data.mem.full_passport} #{did}")
    else
      @data.owner.log("TeamPak #{@data.mem.full_passport} #{did} by " +
                      @session.user.contact.con_name)
      @session.user.log("TeamPak #{@data.mem.full_passport} #{did} for " +
                        @data.owner.contact.con_name)
    end
    
    @session.user.role_set(@data.mem.mem_affiliate,
                           @data.mem.mem_region,
                           RoleNameTable::TEAMPAK_CREATOR,
                           TargetTable::MEMBERSHIP,
                           @data.mem.mem_id)

    notify_clarification_system(@data.mem)

  end



  # Set up a shiny new membership
  def initialize_membership
    @data.mem.mem_is_active = false
    @data.mem.mem_upgrade_pending = false
    @data.mem.mem_state = StateNameTable::WaitPayment
  end


  # Inform the clarification system that a membership has been created
  
  def notify_clarification_system(mem)
    values = {
      'full_passport' => mem.full_passport,
      'type_flag'     => (mem.mem_type == '5' || @data.mem.mem_upgrade_pending) ? '1' : '0',
      'mem_name'      => mem.mem_name
    }

    mailer = Mailer.new

    mailer.send_from_template(Config::CLARIFICATION_ADDRESSES,
                              "[DION data] #{Date.today} #{mem.mem_id}",
                              values,
                              CLARIFICATION_SYSTEM_EMAIL)

  end
=begin
  # Tell the user's associated with this this affiliate
  # that it has been created

  def notify_users_of_creation
    mailer = Mailer.new

    mailer.send_from_template(wibble,
                              "Your DION Registration Information",
                              values,
                              NEW_MEMBERSHIP_EMAIL)

  end
=end

  # Called when the contact has changed

  def save_changed_contact
    @data.mem.save
    log_contact_changed
    @session.dispatch(Portal)
  end

  def log_contact_changed
    msg = "Contact changed to #{@data.mem.admin.contact.con_name}"
    note(msg)
    @data.mem.log(@session.user, msg)
  end


  def setup_other_products
    @data.product_qty = {}
    @data.products.other_products.each {|p| @data.product_qty[p.prd_id] = 0}
  end

  def fill_in_other_products
    # And a list of the other available products
    
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
  
  def get_upgrade_product
    upgrades = @data.products.upgrade_products
    
    if upgrades.empty?
      error "Sorry, no upgrades available"
      return nil
    end
    if upgrades.size > 1
      error "Sorry, more than one upgrade defined for this product"
      return nil
    end
      
    upgrades[0]
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



end
