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

# We handle editing and deleting payments

require 'app/PaymentsTemplates'

class Payments < Application

  app_info(:name => "Payments")
  
  class AppData
    attr_accessor :our_ref
    attr_accessor :handler
    attr_accessor :label
    attr_accessor :payment
    attr_accessor :applied_amounts
    attr_accessor :original_pays
  end

  def app_data_type
    AppData
  end


  ######################################################################
  # delete a specified payment

  def delete_payment
    @data.our_ref = ''
    @data.handler = :handle_delete
    @data.label   = 'deleted'
    get_payment
  end

  ######################################################################
  # Edit a specified payment

  def edit_payment
    @data.our_ref = ''
    @data.handler = :handle_edit
    @data.label   = 'edited'
    get_payment
  end
  
  ######################################################################
  # Prompt for a payment, then vector to the appropriate handler

  def get_payment
    standard_page("Maintain Payment",
                  {
                    'done_url' => url(@data.handler),
                    'action'   => @data.label,
                    'our_ref'  => @data.our_ref,
                  },
                  IDENTIFY_PAYMENT);
  end

  ######################################################################
  # check that the payment is found. If so, check that it is OK to
  # delete it. If so, display a summary for confirmation

  def handle_delete
    @data.our_ref = @cgi['our_ref']
    return unless payment_found

    reason = @data.payment.reason_not_to_delete
    if reason
      error reason
      get_payment
      return
    end

    values = @data.payment.add_to_hash({})

    if @data.payment.pay_type == Payment::CC
      cc = CreditCardTransaction.for_payment(@data.payment.pay_id)
      cc.add_to_hash(values) if cc
    end

    inv = Invoice.for_payment(@data.payment)

    if inv 
      values['inv_id'] = inv.inv_id
    end

    values['inv_doc_name'] =
      @data.payment.pay_type == Payment::PO ? "Invoice" : "Receipt"

    values['confirm_delete'] = url(:confirm_delete)
    values['dont_delete']    = url(:get_payment)

    standard_page("Confirm Delete", values, CONFIRM_DELETE)
  end


  def confirm_delete
    inv = Invoice.for_payment(@data.payment)
    inv.delete if inv
    @data.payment.delete

    msg = "Deleted payment #{@data.our_ref}"
    msg << " and invoice #{inv.inv_id}" if inv

    @session.user.log(msg)
    note msg
    @session.pop
  end

  ######################################################################
  # Fetch the requested payment, then arrange for it to be displayed
  # for editing

  def handle_edit
    @data.our_ref = @cgi['our_ref']
    return unless payment_found
    find_applied_amounts
    edit_common
  end


  def edit_common
    values = @data.payment.add_to_hash({})
    add_payments_orders(values)
    values['done_url'] = url(:do_edit)
    values['cancel_url'] = url(:edit_payment)
    standard_page("Edit Payment", values, EDIT_PAYMENT)
  end


  def do_edit
    pay = @data.payment
    values = hash_from_cgi
    pay.from_hash(values)
    errs = pay.error_list
    
    if pay.pay_paying_check_our_ref && !pay.pay_paying_check_our_ref.empty?
      pay.check_from_hash(values)
      errs.concat pay.check_error_list
    end

    errs.concat get_applied_amounts(values)

    if errs.empty?
      total_applied = 0
      @data.applied_amounts.each {|order_id, amt| total_applied += unfmt_money(amt) }
      
      if pay.pay_amount < total_applied
        errs << "The payment amount can not be less that the amount " +
          "applied ($#{fmt_money(total_applied)})"
      end
    end
    
    if errs.empty?
      begin
        $store.transaction do
          update_orders
          pay.save
          note "Payment #{pay.pay_our_ref} updated"
          @session.pop
        end
      rescue Exception => e
        errs << e.message
      end
    end

    unless errs.empty?
      error_list(errs)
      edit_common
    end
  end


  #######
  private
  #######

  def payment_found
    @data.payment = Payment.with_track_no(@data.our_ref)
    unless @data.payment
      error "Can't find payment with tracking number '#{@data.our_ref}'"
      get_payment
    end
    @data.payment
  end
  

  # Fill in the list of amounts applied to each order
  def find_applied_amounts
    pays = Pays.for_payment(@data.payment)
    @data.applied_amounts = {}
    @data.original_pays = {}
    pays.each do |pys|
      @data.original_pays[pys.pys_order_id] = pys.pys_amount
      @data.applied_amounts[pys.pys_order_id] = fmt_money(pys.pys_amount)
    end
  end

  # Add in the orders paid by a particular payment to a values hash
  def add_payments_orders(values)
    pays = Pays.for_payment(@data.payment)
    total_new_applied = 0.0
    if pays.empty?
      values['fmt_new_applied'] = fmt_money(total_new_applied)
      return
    end
    values['orders'] = pays.map do |pys|
      order = Order.with_id(pys.pys_order_id)
      res = {
        "currently_applied" => fmt_money(pys.pys_amount),
        "applied_#{order.order_id}" => @data.applied_amounts[order.order_id],
      }
      total_new_applied  += (Float(@data.applied_amounts[order.order_id]) rescue 0)
      order.add_to_hash(res, true)
    end
    values['fmt_new_applied'] = fmt_money(total_new_applied)
  end

  # get the applied amounts from the form
  def get_applied_amounts(values)
    errs = []
    @data.applied_amounts.each_key do |order_id|
      amt = @data.applied_amounts[order_id] = values["applied_#{order_id}"] || "0"
      begin 
        amt = unfmt_money(amt)
        @data.applied_amounts[order_id] = fmt_money(amt)
      rescue ArgumentError
        errs << "Invalid amount to apply: '#{amt}'"
      end
    end
    errs
  end


  # update each of the orders if the amount applied has changed
  def update_orders
    @data.applied_amounts.each do |order_id, applied|
      applied = unfmt_money(applied)
      if (@data.original_pays[order_id] - applied).abs > 0.001
        update_order(order_id, applied)
      end
    end
  end

  # update an individual order. Throw an exception if the amount applied
  # will now exceed 
  def update_order(order_id, applied)
    order = Order.with_id(order_id)
    @data.payment.reapply_to_order(@session.user, order, applied, @session)
  end
end
