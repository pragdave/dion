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

class Invoice < BusinessObject

  INVOICE_TYPE = 'I'
  RECEIPT_TYPE = 'R'

  def Invoice.with_id(inv_id)
    maybe_return($store.select_one(InvoiceTable, "inv_id=?", inv_id))
  end

  # Return any existing invoice for a payment, or a fresh one otherwise
  def Invoice.create_for_payment(payment, inv_type)
    inv = $store.select_one(InvoiceTable, "inv_pay_id=?", payment.pay_id)
    if inv
      raise "Incorrect invoice type" unless inv.inv_type == inv_type
      res = new(inv)
    else
      res = new
      res.inv_type = inv_type
    end
    res
  end

  # Return any existing invoice for a payment, or nil if not found
  def Invoice.for_payment(payment)
    maybe_return($store.select_one(InvoiceTable, "inv_pay_id=?", payment.pay_id))
  end


  ######################################################################


  def initialize(data_object = nil)
    @data_object = data_object || fresh_invoice
  end

  
  def fresh_invoice
    i = InvoiceTable.new
    i.inv_billing_address = ''
    i.inv_notes = ''
    i.inv_internal_notes = ''
    i.inv_unapp_desc = nil
    i.inv_amount = 0.0
    i.inv_paid = false
    i
    end

  def from_hash(hash)
    i = @data_object

    i.inv_billing_address = hash['inv_billing_address']
    i.inv_notes           = hash['inv_notes']
    i.inv_internal_notes  = hash['inv_internal_notes']
    i.inv_unapp_desc      = hash['inv_unapp_desc']
  end

  def error_list
    errs = []
    i = @data_object
    if i.inv_billing_address.nil? || i.inv_billing_address.empty?
      errs << "Missing billing address"
    end
    errs
  end


  def save
    @data_object.inv_notes ||= ''
    @data_object.inv_internal_notes ||= ''
    super
  end


  def type_name
    case @data_object.inv_type
    when Invoice::INVOICE_TYPE then "Invoice"
    when Invoice::RECEIPT_TYPE then "Receipt"
    else 
      "Unknown"
    end
  end

  def counter_type_name
    case @data_object.inv_type
    when Invoice::INVOICE_TYPE then "Purchase Order"
    when Invoice::RECEIPT_TYPE then "Check"
    else 
      "Unknown"
    end
  end
end
