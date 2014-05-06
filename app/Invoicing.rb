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
require 'app/InvoicingTemplates'
require 'bo/Invoice'
require 'bo/Pays'

class Invoicing < Application
  app_info(:name            => :Invoicing)

  class AppData
    attr_accessor :payment
    attr_accessor :invoice
    attr_accessor :includes_unapplied
    attr_accessor :inv_no
  end

  def app_data_type
    AppData
  end

  ######################################################################

  # Reprint a given invoice or purchase order

  def select_reprint
    @data.inv_no = ''
    reprint_common
  end

  def reprint_specific(inv)
    @data.invoice = inv
    @data.payment = Payment.with_id(@data.invoice.inv_pay_id)
    print_common
  end

  def reprint_common
    values = {
      'form_url' => url(:handle_reprint),
      'inv_no'   => @data.inv_no
    }
    standard_page("Select Invoice/Receipt to Reprint",
                  values,
                  SELECT_INVOICE)
  end

  def handle_reprint
    @data.inv_no = inv_no = @cgi['inv_no']
    if inv_no.nil? || inv_no.empty?
      error "Please specify an invoice number"
      return reprint_common
    end
    
    @data.invoice = Invoice.with_id(inv_no)
    if @data.invoice
      display_confirmation
    else
      error "Invoice #{inv_no} not found"
      reprint_common
    end
  end

  def display_confirmation
    @data.payment = Payment.with_id(@data.invoice.inv_pay_id)
    if !@data.payment
      error "Can't find payment info"
      @session.pop
    end
    values = {
      'ok_url' => url(:print_common),
      'no_url' => url(:reprint_common)
    }
    @data.invoice.add_to_hash(values)
    @data.payment.add_to_hash(values)
    standard_page("Confirm Reprint", values, CONFIRM_REPRINT)
  end

  ######################################################################


  # Here when an application wants to print either an invoice or
  # a receipt based on a payment

  def print_from_payment(payment)
    case payment.pay_type
    when Payment::PO
      print_invoice_for(payment)
    when Payment::CHECK
      print_receipt_for(payment)
    else
      @session.pop
    end

  end

  # We're called when some other application wants to
  # print an invoice

  def print_invoice_for(payment)
    @data.payment = payment
    @data.invoice = Invoice.create_for_payment(payment, Invoice::INVOICE_TYPE)
    print_common
  end

  # Or when they want a receipt
  # print an invoice

  def print_receipt_for(payment)
    @data.payment = payment
    @data.invoice = Invoice.create_for_payment(payment, Invoice::RECEIPT_TYPE)
    print_common
  end


  def print_common
    pay = @data.payment
    if (pay.pay_amount_applied - pay.pay_amount).abs > .001
      @data.includes_unapplied = true
      @data.invoice.inv_unapp_desc ||= "Amount remaining on #{@data.invoice.counter_type_name}"
    else
      @data.invoice.inv_unapp_desc = nil
    end

    collect_details
  end


  def collect_details
    inv = @data.invoice
    if inv.inv_type == Invoice::INVOICE_TYPE
      uc_name  = 'INVOICE'
      cap_name = 'Invoice'
      lc_name  = 'invoice'
    else
      uc_name  = 'RECEIPT'
      cap_name = 'Receipt'
      lc_name  = 'receipt'
    end

    values = {
      'form_url' => url(:handle_details),
      'cap_name' => cap_name,
      'lc_name'  => lc_name,
      'uc_name'  => uc_name,
    }

    inv.add_to_hash(values)
    standard_page("Invoice details", values, INVOICE_DETAILS)
  end


  def handle_details
    values = hash_from_cgi
    @data.invoice.from_hash(values)
    errs = @data.invoice.error_list
    if @data.includes_unapplied
      unapp = values['inv_unapp_desc']
      if unapp.nil? || unapp.empty?
        errs << "Supply a description for unapplied funds"
      end
    end

    if errs.empty?
      @data.invoice.inv_pay_id = @data.payment.pay_id
      @data.invoice.save
      print_invoice
    else
      error_list errs
      collect_details
    end
  end

  def print_invoice
    $stderr.puts "printing"
    values = @data.invoice.add_to_hash({})
    @data.payment.add_to_hash(values)

    if @data.invoice.inv_type == Invoice::INVOICE_TYPE
      values['doc_name'] = 'Invoice'
      values['is_invoice'] = 1
    else
      values['doc_name'] = 'Receipt'
      values['is_receipt'] = 1
    end

    add = values['inv_billing_address'].dup
    add.gsub!(/\n/, '!newline!')
    values['inv_billing_address'] = add

    values['inv_date']  = Time.now.strftime('%b %d, %Y')

    orders = Pays.orders_paid_in_full_by(@data.payment)

    total = 0.0

    order_list = orders.map do |o|
      total += o.order_grand_total
      res = { 
        'applied' => fmt_money(o.order_grand_total),
        'balance' => '0.00',
      }
      o.add_to_hash(res, true) 
    end

    partials = Pays.partial_payments_for(@data.payment)
    partials.each do |p|
      order = Order.with_id(p.pys_order_id)
      res = order.add_to_hash({}, true)
      res['applied'] = fmt_money(p.pys_amount)
      res['balance'] = fmt_money(order.order_grand_total - order.order_amount_paid)
      total += p.pys_amount
      order_list << res
    end

    pay = @data.payment
    unapplied = pay.pay_amount - total

    if unapplied.abs < 0.001
      values['inv_unapp_desc'] = false
    else
      values['unapp_amt']  = fmt_money(unapplied)
      values['inv_unapp_desc'] ||= "Funds currently unapplied"
    end

    values['orders']    = order_list
    values['total']     = fmt_money(total + unapplied)

    path = generate_pdf(values, Reports::INVOICE)
    
    if path
      values = {
        'report_url' => path,
        'form_url'   => url(:pop_back)
      }
      standard_page("Your Invoice", values, Reports::SHOW_REPORT)
    else
      error "There was an error generating the invoice/receipt. Better call Dave"
      @session.pop
    end
  end

  def pop_back
    @session.pop
  end
end
