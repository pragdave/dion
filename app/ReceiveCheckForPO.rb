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

# We have a check that pays off a PO. We have to match it to
# the correct PO and then pay it off

require 'app/ReceiveCheckForPOTemplates.rb'
require 'bo/POMatcher'
require 'bo/Pays'
require 'bo/PaymentActions'
require 'bo/Order'

class ReceiveCheckForPO < Application
  
  app_info(:name            => :ReceivePayment,
           :login_required  => true,
           :default_app     => false)
  
  
  class AppData
    attr_accessor :check_details
    attr_accessor :matcher
  end
  
  def app_data_type
    AppData
  end


  ######################################################################
  # Step one - get the check details
  #

  def handle_rec_check_for_po
    @data.check_details = Payment.new
    @data.check_details.pay_type = Payment::CHECK
    @data.matcher = POMatcher.new

    get_check_details
  end

  def get_check_details
    c = @data.check_details
    values = {
      'done_url' => url(:validate_check_details)
    }
    c.add_to_hash(values)
    standard_page("Enter Check Details", values, ENTER_CHECK_DETAILS)
  end


  def validate_check_details
    values = hash_from_cgi
    @data.check_details.from_hash(values)
    errors = @data.check_details.error_list
    if errors.empty?
      get_match_details
    else
      error_list(errors)
      get_check_details
    end
  end

  ######################################################################
  # 
  # Step 2: try to find a match for the check amount our unpaid
  # purchase orders

  def get_match_details
    values = {
      'done_url' => url(:validate_match_details)
    }
    @data.matcher.add_to_hash(values)
    standard_page("Enter Match Details", values, GET_MATCH_DETAILS)
  end


  def validate_match_details
    values = hash_from_cgi
    @data.matcher.from_hash(values)
    errors = @data.matcher.error_list
    if errors.empty?
      search_for_match
    else
      error_list errors
      get_match_details
    end
  end


  ######################################################################
  # Step 3: Search for purchase orders to apply this check to
  
  def search_for_match
    list = @data.matcher.find_payments

    if list.empty?
      error "No purchase orders match"
      get_match_details

    elsif list.size > 1
      show_multiple_matches(list)
      
    else
      show_single_match(list[0])
    end
  end


  def show_multiple_matches(pay_list)
    values = {
      'again' => url(:get_match_details)
    }

    values['show_all'] = true unless @data.matcher.specific_search

    list = pay_list.map do |payment|
      {
        "pay_type"           => PaymentMethod.from_type(payment.pay_type).pme_desc,
        "processed"          => payment.fmt_processed,
        "pay_our_ref"        => payment.pay_our_ref,
        "pay_doc_ref"        => payment.pay_doc_ref,
        "pay_payor"          => payment.pay_payor,
        "pay_amount"         => payment.fmt_amount,
        "pay_amount_applied" => payment.fmt_amount_applied,
        "use_url"            => url(:select_payment, payment.pay_id),
      }
    end
    values['list'] = list
    standard_page("SELECT Matching PO", values, SELECT_MATCHING_PO)
  end


  def select_payment(pay_id)
    show_single_match(Payment.with_id(pay_id))
  end



  def show_single_match(payment)
    unless payment.pay_paying_check_our_ref.empty?
      return report_already_paid(payment)
    end

    unless payment.pay_amount == @data.check_details.pay_amount
      error "Purchase order total ($#{payment.fmt_amount}) different to check"
      get_match_details
      return
    end

    values = {
      'again_url' => url(:get_match_details),
      'apply_url' => url(:finally_do_apply, payment.pay_id)
    }

    pays = Pays.for_payment(payment)
    unless pays.empty?
      pay_details = []
      pays.map do |pys|
        order = Order.with_id(pys.pys_order_id)
        if order.order_mem_id
          mem = Membership.with_id(order.order_mem_id)
          pay_details << { 
            "desc" => "TeamPak: #{mem.full_passport} - #{mem.mem_name}/#{mem.mem_schoolname}" }
        end
        items = LineItem.items_for_order(pys.pys_order_id)
        items.each do |item|
          pay_details << { "desc" => item.li_desc }
        end
      end
      
      values['pays'] = pay_details
    end

    payment.add_to_hash(values)
    standard_page("Apply Check to PO", values, APPLY_CHECK_TO_PO)
  end



  def report_already_paid(payment)
    error_list [
      "Purchase order has already been paid:",
      "check: #{payment.pay_paying_check_doc_ref}",
      "date: #{payment.pay_paying_processed}",
      "payor: #{payment.pay_paying_check_payor}"
    ]
    get_match_details
    
  end

  # We've got a check, and we've got a PO. Let's make whooppee!
  def finally_do_apply(pay_id)
    
    $store.transaction do
      payment = Payment.with_id(pay_id)

      if  !(payment.pay_paying_check_doc_ref.empty? &&
            payment.pay_paying_check_payor.empty?   &&
            payment.pay_paying_check_our_ref.empty?)
        
        error "Payment has already been settled"
      else

        @context.no_going_back

        payment.pay_with_check(@data.check_details)
        
        pays = Pays.for_payment(payment)

        pays.each do |pay|
          order = Order.with_id(pay.pys_order_id)
          raise "Missing order" unless order
          order.settle_with(pay.pys_amount)
          order.save

          if order.fully_settled
            order.lines.each do |line|
              PaymentActions.process_settlement(@session, payment, line, order)
            end
          end
        end

        note "Check applied"
      end
    end

    @session.pop
  end

end
