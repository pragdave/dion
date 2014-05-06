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

require 'bo/Pays'
require 'reports/Reports'
require 'util/Formatters'

# Orchestrate the printing of statements given an order id (or
# a group of order ids')

class Statements

  include Formatters

  # print the statements for a set of orders
  def print_statements(orders, packing_list=false)
    values = {
      'statement_date' => fmt_date(Time.now)
    }

    values['statements'] = orders.map do |order_id|
      order_amount = 0.0
      total_paid = 0.0

      res = {}
      order = Order.with_id(order_id)
      order_amount += order.order_grand_total

      user = User.with_id(order.order_user_id)
      if user
        contact = user.contact
        address = contact.con_name + "\r\n" + contact.mail.to_s
      else
        address = ""
      end

      pays = Pays.for_order(order)

      unless pays.empty?
        res['payments'] = pays.map do |pay|
          payment = Payment.with_id(pay.pys_pay_id)

          total_paid += pay.pys_amount
          payment.add_to_hash({
                                'applied_amount' => fmt_money(pay.pys_amount)
                              })
        end
        res['total_payments'] = fmt_money(total_paid)
      end

      order.add_to_hash(res, true)

      aff_fee = order.total_affiliate_fee
      if aff_fee > 0
        res['order_aff_fee'] = fmt_money(aff_fee)
      end

      res['order_contact'] = address.gsub(/\r\n/, '\\\\\\')
      res['ship_address']  = order.order_ship_address.gsub(/\r\n/, '\\\\\\')
      res['total_paid']    = fmt_money(total_paid)
      res['amount_due']    = fmt_money(order_amount - total_paid)
      res
    end

    r = Reports.new
    r.generate(values, packing_list ? Reports::PACKING_LIST : Reports::STATEMENT)
  end

  # A packing list is a statement with no numbers
  def print_packing_slips(orders)
    print_statements(orders, true)
  end
end
