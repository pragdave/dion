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
require 'app/GeneralOrdersTemplates'
require 'bo/PaymentMethod'
require 'bo/PaymentOption'

class GeneralOrders < Application

  app_info(:name => "GeneralOrders")

  class AppData
    attr_accessor :user
    attr_accessor :products
    attr_accessor :product_qty
    attr_accessor :payment_option
    attr_accessor :cc_id

    attr_accessor :order
  end

  def app_data_type
    AppData
  end

  ######################################################################
  # Edit an existing order (called from Orders.rb)

  def edit_existing(order)
    @data.order = order
    @data.user = User.with_id(order.order_user_id)

    order_common(false)
  end

  ######################################################################

  def order_for_user(user_id, user_is_ad=false)
    @data.user = User.with_id(user_id)
    @data.order = nil
    order_common(user_is_ad)
  end

  def order_common(user_is_ad)
    if @data.user.nil?
      error "Unknown user #{user_id.inspect}"
      @session.pop
      return
    end

    setup_products(user_is_ad)

    if @data.products.all_products.empty?
      note "No products available"
      return @session.pop
    end
    @data.payment_option = PaymentOption.new
    if @data.order
      @data.payment_option.pay_method = @data.order.order_pay_type
      @data.payment_option.pay_ref    = @data.order.order_doc_ref
    end
    display_order_form
  end


  def display_order_form
    values = {}
    values['products'] = fill_in_products
    values['pay_options'] = get_payment_options
    values['form_target'] = url(:handle_order_form)
    values['title'] = @data.order ? "Alter Order" : "Order DI Products Online"
    standard_page("Order Form", values, ORDER_FORM)
  end


  def setup_products(user_is_ad)
    which = user_is_ad ?
      CombinedProducts::SHOW_TOURNAMENT :
      CombinedProducts::SHOW_GENERAL

    @data.products = CombinedProducts.for_affiliate(@data.user.affiliate, which)
    @data.product_qty = {}

    @data.products.each {|p| @data.product_qty[p.prd_id] = 0}

    unless @data.order.nil?
      @data.order.each_line do |line|
        @data.product_qty[line.li_prd_id] = line.li_qty
      end
    end
  end

  # Create a displayable list of products
  def fill_in_products
    products = []
    @data.products.all_products.each_with_index do |p, i|
      prod = {}
      prod['index']  = i
      prod['qty']    = @data.product_qty[p.prd_id]
      prod['desc']   = p.prd_long_desc
      prod['price']  = "$" + p.fmt_total_price
      prod['prd_id'] = p.prd_id
      products << prod
    end
    
    products
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


  ######################################################################

  def handle_order_form
    values = Hash.new("")
    @cgi.keys.each {|k| values[k] = @cgi[k]}

    errors = []

    total_count = 0

    99.times do |i|
      qty_key = "prd_qty_" + i.to_s
      id_key  = "prd_id_" + i.to_s
      break unless values.has_key?(qty_key)
      qty = values[qty_key]
      qty = '0' if qty.empty?
      errors << "Invalid quantity '#{qty}'" unless qty =~ /^\d+$/
      prd_id = values[id_key].to_i
      @data.product_qty[prd_id] = qty
      total_count += qty.to_i if errors.empty?
    end

    msg = PaymentMethod.from_form(values, @data.payment_option)
    errors << msg if msg

    if errors.empty?
      if total_count.zero?
        note "Nothing ordered"
        @session.pop
      else
        process_order
      end
    else
      error_list errors
      display_order_form
    end
  end


  ######################################################################

  def process_order(confirmed = false)
    products = get_products_bought

    aff = @data.user.affiliate
    if @data.order
      order = @data.order
      order.delete_all_lines
    else
      order = Order.create(aff)
      order.set_user_id(@data.user.user_id)
    end

    order.set_payment_option(@data.payment_option)

    products.each do |qty, prd|
      order.add(prd, qty)
    end

    if confirmed
      order.set_mem_id(nil)
      order.record_sales
    end

    values = { 
      "aff_short_name" => aff.aff_short_name,
      "order_ship_address" => order.order_ship_address,
    }

    order.add_to_hash(values)
    @data.user.add_to_hash(values)

    pme = PaymentMethod.from_type(@data.payment_option.pay_method)

    unless confirmed
      if pme.pme_is_credit_card
        cc = CreditCardTransaction.new
        cc.new_transaction(order, 
                           "Destination Imagination",
                           @data.user.contact)
        cc.hash_for_authorize(values, 
                              @context.context_id, 
                              @context.entry_index(GeneralOrders, :cc_response))
        cc.save
        @data.cc_id = cc.cc_id
      else
        values['confirm_url'] = url(:process_order, true)
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

    # if this is a confirmation and the order is being entered by HQ
    # staff, don't print the confirmation screen

    if confirmed
      @context.no_going_back 
      if @data.user.user_id != @session.user.user_id && @session.hq_session
        note "Order \##{order.order_id} placed"
        @session.pop
        return
      end
    end

    standard_page("Order Summary",
                  values,
                  ORDER_SUMMARY)
  end


  def cc_response
    values = hash_from_cgi
    cr = CreditCardTransaction.with_id(@data.cc_id)
    if !cr
      fail "Failed to find credit card transaction: #{@data.cc_id}"
    end

    cr.from_hash(values)
    cr.save

    case cr.cc_response_code
    when CreditCardTransaction::APPROVED
      process_order(true)
    when CreditCardTransaction::DECLINED, CreditCardTransaction::ERROR
      error_list(['There was a problem with the credit card purchase:',
                   cr.cc_reason_text])
      display_order_form
    else
      error "Unexpected response from credit card authorization"
      display_order_form
    end
  end

  # return an array of the products actually bought

  def get_products_bought
    res = []

    @data.product_qty.each do |prd_id, qty|
      qty = qty.to_i
      if qty > 0
        res << [ qty, @data.products.with_id(prd_id) ]
      end
    end

    res
  end


end
