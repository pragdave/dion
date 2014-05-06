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

require 'app/PaymentStatusTemplates'
require 'bo/CreditCard'
require 'bo/PaysOrder'

class PaymentStatus < Application

  app_info(:name => "PaymentStatus")
  
  class AppData
  end

  def app_data_type
    AppData
  end

  ######################################################################

  def find_payment
    find_common
    @track_no = @their_ref = @passport = @payor = ""
  end


  def find_common
    values = {
      "track_no" => @track_no,
      "their_ref" => @their_ref,
      "passport"  => @passport,
      "payor"     => @payor,
      "form_url" => url(:handle_find)
    }
    standard_page("Find Payment", values, FIND_PAYMENT)
  end


  def handle_find
    @track_no = @cgi["track_no"]
    return find_by_track_no if @track_no && !@track_no.empty?

    @their_ref = @cgi["their_ref"]
    return find_by_their_ref if @their_ref && !@their_ref.empty?

    @passport = @cgi["passport"]
    return find_by_passport if @passport && !@passport.empty?

    @payor = @cgi["payor"]
    return find_by_payor if @payor && !@payor.empty?

    error "Please specify a search criterion"
    find_common
  end



  def find_by_track_no
#    begin
#      @track_no = Integer(@track_no)
#    rescue
#      error "Tracking number must be numeric"
#      return find_common
#    end

    payment = Payment.with_track_no(@track_no)
    if payment
      display_payment_status(payment)
    else
      error "Payment with tracking number #@track_no not found"
      find_common
    end
  end



  def find_by_their_ref
    payments = Payment.list_with_their_ref(@their_ref)
    display_payments("their reference #@their_ref", payments)
  end



  def find_by_passport
    unless @passport =~ /^(\d\d\d)-?(\d+)$/
      error "Invalid passport number"
      return find_common
    end
    mem = Membership.withPassport($1, $2)
    if mem
      payments = Payment.list_for_membership(mem.mem_id)
      display_payments("passport #@passport", payments)
    else
      error "Unknown passport"
      find_common
    end
  end



  def find_by_payor
    payments = Payment.list_with_payor(@payor)
    display_payments("payor name containing #@payor", payments)
  end



  def display_payments(criteria, payments)
    if payments.size == 0
      note "No payments with #{criteria}"
      return find_common
    end
    if payments.size == 1
      display_payment_status(payments[0])
    else
      display_payment_list(payments)
    end
  end


  ######################################################################

  def display_payment_status(payment)
    values = payment.add_to_hash({})

    if payment.pay_type == Payment::CC
      cc = CreditCardTransaction.for_payment(payment.pay_id)
      cc.add_to_hash(values) if cc
    end

    pays = PaysOrder.list_for_payment(payment)
    unless pays.empty?
      values['pays_list'] = pays.map do |p|
        res = {
          'order_url' => @context.url(OrderStatus, 
                                      :display_from_id, 
                                      p.order_id)
        }
        
        p.add_to_hash(res) 
        res
      end
    end


    inv = Invoice.for_payment(payment)

    if inv 
      values['inv_id'] = inv.inv_id
      if @session.hq_session
        values['inv_internal_notes'] = inv.inv_internal_notes
      else
        values['inv_internal_notes'] = ''
      end
    end

    if @session.hq_session
      values['inv_print']   = @context.url(Invoicing, :print_from_payment, payment)
    end

    values['inv_doc_name'] =
      payment.pay_type == Payment::PO ? "Invoice" : "Receipt"

    standard_page("Payment Details", values, PAYMENT_DETAILS)
  end

  def display_payment_list(payments)
    list = payments.map do |p| 
      res = { 'payment_url' => url(:display_from_id, p.pay_id) }
      p.add_to_hash(res)
      res
    end
    
    standard_page("Matching Payments", {'list' => list}, PAYMENT_LIST)
  end


  def display_from_id(pay_id)
    payment = Payment.with_id(pay_id)
    if payment
      display_payment_status(payment)
    else
      error "Missing payment"
      @session.pop
    end
  end
end
