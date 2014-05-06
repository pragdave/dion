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

require 'bo/BusinessObject'
require 'bo/PaymentActions'
require 'bo/PaymentMethod'
require 'bo/Pays'

# We represent a payment (check or PO) received at HQ. We 
# are used simply to record the details: we're tied with sales
# via the Pays join table

class Payment < BusinessObject
  
  CHECK = PaymentMethodTable::CHECK
  PO    = PaymentMethodTable::PO
  CC    = PaymentMethodTable::CC

  #############################################################################

  def Payment.list_of_unapplied
    res = $store.select(PaymentTable, "pay_amount > pay_amount_applied order by pay_processed")
    res.map {|p| new(p) }
  end

  def Payment.with_id(pay_id)
    maybe_return($store.select_one(PaymentTable, "pay_id=?", pay_id))
  end

  def Payment.with_track_no(track_no)
    res = $store.select_one(PaymentTable, "pay_our_ref ilike ?", track_no)
    if res.nil?
      res = $store.select_one(PaymentTable, "pay_paying_check_our_ref ilike ?", track_no)
    end
    maybe_return(res)
  end

  def Payment.list_with_their_ref(ref)
    $store.select(PaymentTable, "pay_doc_ref=?", ref).map {|p| new(p)}
  end

  def Payment.list_for_membership(mem_id)
    res = $store.select_complex(PaymentTable, 
                                [PaysTable, OrderTable],
                                "pys_pay_id=pay_id and " +
                                "pys_order_id=order_id and " +
                                "order_mem_id=?",
                                mem_id)
    res.map {|p| new(p)}
  end

  def Payment.list_with_payor(payor)
    payor = "%#{payor}%"
    $store.select(PaymentTable, "pay_payor ilike ?", payor).map {|p| new(p)}
  end

  # return an array of the total payments received and the total applied
  def Payment.totals
    sql = "select sum(pay_amount), sum(pay_amount_applied) from payment"
    res = $store.raw_select(sql)
    res[0]
  end

  # And return a summary of how they paid
  def Payment.type_summary
    sql = "select pme_short_desc, count(*), sum(pay_amount) " +
      "from payment,payment_method where pay_type=pme_id group by pme_short_desc"
    rows = $store.raw_select(sql)
    res = rows.map do |row|
      {
        "type"   => row[0],
        "count"  => row[1],
        "amount" => fmt_money(row[2].to_f),
      }
    end
    res
  end

  #############################################################################

  def Payment.daily_report(from, to, pay_type)
    $store.select(PaymentTable, 
                  "pay_type=? and " +
                  "date_trunc('day', pay_processed) between ? and ?",
                  pay_type, from.date, to.date).map {|r| new(r)}
                  
  end

  #############################################################################

  def Payment.daily_checks_paying_pos(from, to)
    $store.select(PaymentTable, 
                  "pay_type='#{PaymentMethod::PO}' and " +
                  "date_trunc('day', pay_paying_processed) between ? and ?",
                  from.date, to.date).map {|r| new(r)}
                  
  end
  
  #############################################################################

  def initialize(data_object = nil)
    if data_object
      @data_object = data_object
    else
      @data_object = PaymentTable.new
      @data_object.pay_processed = DBI::Timestamp.new(Time.now)
      @data_object.pay_amount_applied = 0.0
    end
  end

  
  def add_to_hash(values)
    super
    d = @data_object
    if d.pay_amount.kind_of? Float
      values['pay_amount'] = fmt_money(d.pay_amount)
    end
    if d.pay_amount_applied.kind_of? Float
      values['fmt_amount_applied'] = fmt_money(d.pay_amount_applied)
    end
    if d.pay_amount.kind_of?(Float) && d.pay_amount_applied.kind_of?(Float)
      values['fmt_amount_left']    = fmt_money(amount_left)
    end
    values['fmt_processed'] = fmt_processed
    values['fmt_paying_processed'] = fmt_paying_processed
    values['short_type'] = short_type_name
    values
  end


  def from_hash(hash)
    d = @data_object
    d.pay_our_ref = hash['pay_our_ref']
    d.pay_doc_ref = hash['pay_doc_ref']
    d.pay_payor   = hash['pay_payor']
    d.pay_amount  = hash['pay_amount']
    d.pay_ship_address = hash['pay_ship_address'] 
  end

  # read the paying_check specific values from a hash. Used by Payments.rb

  def check_from_hash(hash)
    d = @data_object
    
    d.pay_paying_check_doc_ref = hash['pay_paying_check_doc_ref']
    d.pay_paying_check_payor   = hash['pay_paying_check_payor']
    d.pay_paying_check_our_ref = hash['pay_paying_check_our_ref']
  end
  
  def error_list
    res = []
    d = @data_object
    res << "Missing check/PO reference number" if d.pay_doc_ref.empty?
    
    if d.pay_amount.empty?
      res << "Missing amount" 
    else
      begin
        d.pay_amount = unfmt_money(d.pay_amount)
      rescue
        res << "Invalid amount #{d.pay_amount}"
      end
    end

    res << "Missing our reference" if d.pay_our_ref.empty?
    res << "Missing payor" if d.pay_payor.empty?

    d.pay_our_ref = d.pay_our_ref.upcase

    if res.empty? && d.changed?(:pay_our_ref)
      tmp = Payment.with_track_no(d.pay_our_ref)
      res << "Duplicate tracking number" if tmp
    end

    check_length(res, d.pay_our_ref,   40, "our reference")
    check_length(res, d.pay_doc_ref,   40, "document reference")
    check_length(res, d.pay_payor,     40, "payor")
    check_length(res, d.pay_paying_check_our_ref,   40, "our reference")
    check_length(res, d.pay_paying_check_doc_ref,   40, "document reference")
    check_length(res, d.pay_paying_check_payor,     40, "payor")

    res
  end


  # the eerror list for paying_check specific fields
  def check_error_list
    res = []
    d = @data_object

    res << "Missing paying check number"          if d.pay_paying_check_doc_ref.empty?
    res << "Missing paying check tracking number" if d.pay_paying_check_our_ref.empty?
    res << "Missing paying check payor"           if d.pay_paying_check_payor.empty?

    res
  end


  def amount_left
    @data_object.pay_amount - @data_object.pay_amount_applied
  end

  def used_up
    (@data_object.pay_amount_applied - @data_object.pay_amount).abs < 0.001
  end

  # Format up the processed date
  def fmt_processed
    @data_object.pay_processed.to_time.strftime("%d-%b-%y")
  end

  # Format up the processed date
  def fmt_paying_processed
    date = @data_object.pay_paying_processed
    if date
      date.to_time.strftime("%d-%b-%y")
    else
      ''
    end
  end

  def fmt_amount
    fmt_money(@data_object.pay_amount)
  end

  def fmt_amount_applied
    fmt_money(@data_object.pay_amount_applied)
  end


  def type_name
    PaymentMethod.name_from_type(@data_object.pay_type)
  end

  def short_type_name
    PaymentMethod.short_name_from_type(@data_object.pay_type)
  end


  # OK - here's where the fun starts. Someone somewhere has matched
  # this payment to one or more orders. They call us to
  # handle the fact. We
  #
  # 1. Create a PAYS record for the transaction. 
  #
  # 2. Deduct the amount from the payment, and from the amount pending in
  #    the order
  #
  # 3. Then, if the order is now paid in full:
  # a. Honor any pay actions in the line item record. For example,
  #    a pay action might be to activate a membership
  # b. If this payment is also a settlement (for example payment by
  #    check) then honor the settlement actions

  def apply_to_order(user, order, amount, session)
    p = @data_object
    $store.transaction do 
      if order.left_to_pay < amount
        raise "Order pending #{order.left_to_pay} > #{amount}"
      end

      p.pay_amount_applied += amount

      raise "Payment overapplied" if p.pay_amount_applied > p.pay_amount

      # Save ourselves away

      save

      # Create a Pays object linking the payment to the order
      pays = Pays.new
      pays.record(order, self, amount)
      pays.save

      # Deduct from the payment
      order.pay_off(user, self, amount)

      common_apply_processing(user, order, amount, session)
    end
  end

  def common_apply_processing(user, order, amount, session)
    p = @data_object
    
    # this is settled if it isn't a PO, or if it is a PO and
    # the PO has already been paid
    
    if p.pay_type != PaymentMethod::PO || 
        (p.pay_paying_check_our_ref && !p.pay_paying_check_our_ref.empty?)
      order.settle_with(amount)
    end
    
    # Override the shipping address if there's one set
    if p.pay_ship_address && !p.pay_ship_address.empty?
      order.order_ship_address = p.pay_ship_address
      order.order_ship_add_changed = true
      
      mem_id = order.order_mem_id
      if mem_id
        mem = Membership.with_id(mem_id)
        if mem
          msg = 
            "Shipping address on order #{order.order_id} overridden by P.O. #{p.pay_doc_ref}"
          mem.log(user, msg)
        end
      end
    end
    
    order.save
    

    # If the order is now fully paid, we have to do things like
    # mark it for shipping. If it _was_ fully paid, but
    # is no longer, then we may have to claw back affiliate fees
    # and so on

    if order.fully_paid
      order.lines.each do |line|
        PaymentActions.process_payment(session, line, order)
      end
      
      if order.fully_settled
        order.lines.each do |line|
          PaymentActions.process_settlement(session, self, line, order)
        end
      end
    elsif order.was_fully_paid
      if order.was_fully_settled
        order.lines.each do |line|
          PaymentActions.process_undo_settlement(session, self, line, order)
        end
      end

      order.lines.each do |line|
        PaymentActions.process_undo_payment(session, line, order)
      end
    end
  end
  

  # This is kind of 'orrible. HQ staff can change the amount applied to an order
  # after the payment is initially processed. This may involve changing a
  # fair amount of state

  def reapply_to_order(user, order, amount, session)
    p = @data_object

    # find the original payment
    pays = Pays.for_order_and_payment(order, self)

    difference = amount - pays.pys_amount

    # adjust the order

    order.adjust_payment(user, self, difference)

    common_apply_processing(user, order, difference, session)

    # adjust the amount applied. Do it in two steps so we don't leave the object
    # inconsistent
    if p.pay_amount_applied + difference > p.pay_amount
      raise "Too much applied"
    end
    p.pay_amount_applied += difference

    save

    if amount.abs < 0.001
      pays.delete
    else
      pays.pys_amount = amount
      pays.save
    end

  end

  # Pay a purchase order with a check. The 'check' parameter is itself
  # a payment object

  def pay_with_check(check)
    d = @data_object
    d.pay_paying_check_doc_ref = check.pay_doc_ref
    d.pay_paying_check_payor   = check.pay_payor
    d.pay_paying_check_our_ref = check.pay_our_ref
    d.pay_paying_processed     = Time.now
    save
  end


  # If it is OK to delete this payment, then return nil, otherwise rturn
  # a string saying why it isn't OK
  #
  # For now we can delete any payment that hasn't been applied

  def reason_not_to_delete
    if @data_object.pay_amount_applied > 0.0
      "Cannot delete a payment after it has been applied to an order"
    elsif @data_object.pay_paying_check_doc_ref && 
        !@data_object.pay_paying_check_doc_ref.empty?
      "Cannot delete a purchase order after it has been paid"
    else
      nil
    end
  end

end

