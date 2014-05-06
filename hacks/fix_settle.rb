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

require "db/TableDefinitions"
require "bo/Order"
require "bo/Payment"
require 'db/Store'
require 'bo/Pays'
require 'bo/AffiliateFee'

$store = Store.new(*ARGV)

class AffiliateFee
  def AffiliateFee.all
    $store.select(AffiliateFeeTable).map {|a| new(a)}
  end
end

class Pays
  def Pays.for_order(order_id)
    res = $store.select(PaysTable, "pys_order_id=?", order_id)
    res.map {|p| new(p)}
  end
end

class Order
  def Order.all
    $store.select(OrderTable).map {|o| new(o) }
  end
end


def maybe_fix(order)
  pays = Pays.for_order(order.order_id)
  pay_amount = 0.0
  settle_amount = 0.0
  pays.each do |pys|
    payment = Payment.with_id(pys.pys_pay_id)
    pay_amount += pys.pys_amount
    if payment.pay_type != 'P' || (payment.pay_paying_check_our_ref && !payment.pay_paying_check_our_ref.empty?)
      settle_amount += pys.pys_amount
    end
  end

  if (order.order_amount_settled - settle_amount).abs > 0.001
    puts "Order #{order.order_id}\tpaid: #{order.order_amount_paid}/#{pay_amount}\t" +
      "settled: #{order.order_amount_settled}/#{settle_amount}"
    order.order_amount_settled = settle_amount
    order.save
  end
end

Order.all.each do |order|
  if order.order_amount_settled > 0
    maybe_fix(order)
  end
end


puts "Processing fees"
AffiliateFee.all.each do |a|
  payment = Payment.with_id(a.afee_pay_id)
  next unless payment.pay_type == 'P'
  if payment.pay_paying_check_our_ref.nil? || payment.pay_paying_check_our_ref.empty?
    puts "Deleting fee #{a.inspect}"
    a.delete
  end
end

