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

# The flow goes
#
# 1. Prompt for payment info
#
# 2. Try to match. If any matches found, go to 4.
#
# 3. Display the manual match screen and let user choose.
#
# 4. Display list of matches. User uses checkbox to select ones
#    to apply payments to
#
# 5. Apply payment to selected sales
#
# 6. Potentially go back to 3
#
# 7. If PO, prompt for invoice information
#

require 'bo/Payment'
require 'bo/Product'
require 'bo/Order'
require 'app/Invoicing'
require 'app/ReceivePaymentTemplates'
require 'db/OrderSearch'

class ReceivePayment < Application
  app_info(:name            => :ReceivePayment,
           :login_required  => true,
           :default_app     => false)


  class AppData
    attr_accessor :payment
    attr_accessor :payment_type
#    attr_accessor :orders
#    attr_accessor :matching_orders

    # list of what we're actually applying to each order
    attr_accessor :apply_details
  end

  def app_data_type
    AppData
  end

  ######################################################################

  # This structure contains the information on what we're actually
  # applying to each order

  class ApplyDetail < BusinessObject

    attr_accessor :order, :pay_in_full, :partial_pay
    
    # force ship is a saying whether this order should be shipped even
    # if the order is not fully paid

    attr_reader   :force_ship

    def initialize(order)
      @order = order
      @order_id = order.order_id
      @pay_in_full = false
      @partial_pay = 0.0
      @fmt_partial_pay = "0.00"

      @force_ship  = false
    end


    def amount
      if @pay_in_full
        @order.left_to_pay
      else
        @partial_pay
      end
    end


    def add_to_hash(values, include_pay_in_full)
      if include_pay_in_full
        values['activate_full_ok'] = true
        values["pay_in_full_#@order_id"] = @pay_in_full
      end
      values["partial_pay_#@order_id"] = @fmt_partial_pay
      values['force_ship'] = @force_ship
    end

    def from_hash(values)
      @pay_in_full =  bool(values["pay_in_full_#@order_id"])
      @fmt_partial_pay = values["partial_pay_#@order_id"]
      if @fmt_partial_pay.nil? || @fmt_partial_pay.empty?
        @fmt_partial_pay = "0.00"
      end

      @force_ship = bool(values["force_ship"])
    end

    def error_list
      errs = []
      begin
        @partial_pay = Float(@fmt_partial_pay)
        if @partial_pay < 0.0
          errs << "Can't apply a negative amount for order #@order_id"
        end
      rescue
        errs << "Invalid amount: '#@fmt_partial_pay' for order #@order_id"
      end
      errs
    end

  end

  ######################################################################



  PO_NAME = "P.O."
  CHECK_NAME = "Check"

  ###################################################################
  #
  # Step 1: capture payment details
  #

  # Here to receive payment by direct check
  def handle_rec_check
    @data.payment = Payment.new
    @data.payment.pay_type = Payment::CHECK
    @data.payment_type = CHECK_NAME
    handle_payment
  end
  
  # Here to receive payment by direct check
  def handle_rec_po
    @data.payment = Payment.new
    @data.payment.pay_type = Payment::PO
    @data.payment_type = PO_NAME
    handle_payment
  end
  
  # common code to capture details
  def handle_payment
    pay = @data.payment

    values = {
      'payment_type' => @data.payment_type,
      'match_url'    => url(:get_payment_details),
      'po'           => @data.payment.pay_type == Payment::PO,
    }
    
    pay.add_to_hash(values)
    
    standard_page("Enter Payment Details",
                  values,
                  GET_PAYMENT_DETAILS)
  end


  def get_payment_details
    values = hash_from_cgi
    @data.payment.from_hash(values)

    errors = @data.payment.error_list

    if errors.empty?
      @data.payment.save
      @context.no_going_back
      look_for_match
    else
      error_list errors
      handle_payment
    end
  end

  # Step 2. Look for a match with the payment details

  def look_for_match
    pay = @data.payment

    orders = Order.list_that_matches_payment(pay)

    if orders.empty?
      display_search_form
    else
      @data.apply_details = orders.map { |o| ApplyDetail.new(o) }
      display_matching_orders
    end
  end

  # We looked for an easy match on the document reference and
  # failed to find it, so display a search form to let them match
  # manually.

  def display_search_form
    os = OrderSearch.new(@session)
    os.display_all_fields_except(:mem_region)
    html = os.to_form(url(:look_for_memberships), 
                      true,
                      "Find matches",
                      '')

    values = {
      'done' => url(:tidy_up)
    }

    @data.payment.add_to_hash(values)

    standard_page("Search for Matching Payment",
                  values,
                  SEARCH_PAGE,
                  PAYMENT_SUMMARY,
                  html)
  end

  # The user has filled in the search criteria - see what we can find
  
  def look_for_memberships
    os = OrderSearch.new(@session)
    where, tables = os.build_query
    orders = Order.list_from_order_search(where, tables)
    if orders.empty?
      note "No matches found"
      display_search_form
    else
      @data.apply_details = orders.map { |o| ApplyDetail.new(o) }
      display_matching_orders
    end
  end



  def display_matching_orders
    details = @data.apply_details
    pmt = @data.payment

    order_list = details.map do |ad|
      o = ad.order
      res = {}
      o.add_to_hash(res)
#      prd = Product.with_id(s.sale_prd_id)
#      prd.add_to_hash(res)
      if o.order_mem_id
        mem = Membership.with_id(o.order_mem_id)
        mem.add_to_hash(res)
      else
        res['mem_name'] = res['mem_schoolname'] = res['mem_district'] = ''
        user = User.with_id(o.order_user_id)
        res['contact'] = [ user.add_to_hash({}) ]
      end
      ad.add_to_hash(res, pmt.amount_left >= o.left_to_pay)
      res
    end

    values = {
      'order_list' => order_list,
      'apply_url'  => url(:apply_to_orders),
      'search_url' => url(:display_search_form),
    }

    @data.payment.add_to_hash(values)

    standard_page("Apply #{@data.payment_type} to Order",
                  values,
                  APPLY_TO_ORDER,
                  PAYMENT_SUMMARY)
  end


  # Step 5. Apply payment to selected orders

  def apply_to_orders

    values = hash_from_cgi

    @data.apply_details.each do |ad|
      ad.from_hash(values)
      errs = ad.error_list
      unless errs.empty?
        error_list(errs)
        return display_matching_orders
      end
    end

    if validate_amount_applied
      apply_payments
    end
  end

  


  # Go through the user's selections and make sure that
  # 1. They haven't applied more than the order amount
  #    to any one order
  # 2. They haven't applied more than the payment amount in total

  def validate_amount_applied

    total_matched = 0

    matched = []

    @data.apply_details.each do |ad|
      order = ad.order

      if ad.pay_in_full
        apply_amount =  order.left_to_pay
        total_matched += apply_amount
      else
        apply_amount = ad.partial_pay
        if apply_amount > order.left_to_pay
            error "Can't apply more than amount outstanding on order #{order.order_id}"
            display_matching_orders
            return false
          end
        total_matched += apply_amount
      end

      if (total_matched - @data.payment.amount_left) > 0.0001
        error "Selected items exceed payment amount"
        display_matching_orders
        return false
      end
    end
    return true
  end


  # Payments are probably valid (although we could still bomb out if other
  # people have been updating paymets in parallel with us). Go through and
  # apply them all

  def apply_payments

    @context.no_going_back

    @data.apply_details.each do |ad|
      if ad.amount > 0.0
        @data.payment.apply_to_order(@session.user, ad.order, ad.amount, @session)
      end

      if ad.force_ship
        ad.order.force_ship(@session)
      end
    end

    if @data.payment.used_up
      tidy_up_for_real
    else
      look_for_match
    end
  end




  # Tidy up at end. If there is an unapplied amount, warn the punter
  
  def tidy_up
    if @data.payment.used_up
      tidy_up_for_real
    else
      values = {
        'done' => url(:tidy_up_for_real),
        'back' => url(:look_for_match)
      }
      @data.payment.add_to_hash(values)
      standard_page("Not Fully Applied", values, NOT_FULLY_APPLIED, PAYMENT_SUMMARY)
    end
  end

  # OK to finish up. See if an invoice is needed.

  def tidy_up_for_real
    @data.payment.save
    @session.dispatch(Invoicing, :print_from_payment, [ @data.payment ])
  end


  ##############################################################################
  # Come here to apply an existing partially user PO/check to new memberships
  #
  # Display a list of pending POs, let them chose one. 

  def apply_existing_payment
#    @data.matching_orders = {}
    list = Payment.list_of_unapplied
    if list.empty?
      note "No payments are currently pending"
      @session.pop
      return
    end

    values = {}
    
    values['list'] = list.map do |payment|
      {
        "pay_type"           => PaymentMethod.from_type(payment.pay_type).pme_desc,
        "processed"          => payment.fmt_processed,
        "pay_our_ref"        => payment.pay_our_ref,
        "pay_doc_ref"        => payment.pay_doc_ref,
        "pay_payor"          => payment.pay_payor,
        "pay_amount"         => payment.fmt_amount,
        "pay_amount_applied" => payment.fmt_amount_applied,
        "pay_url"            => url(:apply_a_payment, payment.pay_id),
      }
    end

    standard_page("Choose Existing Payment",
                  values,
                  CHOOSE_EXISTING_PAYMENT)

  end


  # Apply this particular payment. Basically we load it up and then
  # enter the normal processing loop
  def apply_a_payment(pay_id)
    @data.payment = Payment.with_id(pay_id)
    look_for_match
  end

end
