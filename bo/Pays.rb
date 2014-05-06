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
require 'bo/Order'

class Pays < BusinessObject

  # Return a list of all the 'pays' for a payment

  def Pays.for_payment(payment)
    res = $store.select(PaysTable, "pys_pay_id=?", payment.pay_id)
    res.map {|p| new(p)}
  end

  # Return a list of all the 'pays' for an order

  def Pays.for_order(order)
    res = $store.select(PaysTable, "pys_order_id=?", order.order_id)
    res.map {|p| new(p)}
  end

  # Return the 'pays' for an order and payment

  def Pays.for_order_and_payment(order, payment)
    new($store.select_one(PaysTable, 
                          "pys_order_id=? and pys_pay_id=?",
                          order.order_id, payment.pay_id))
  end


  # Return a list of orders that were paid in full by a particular
  # payment--that is every order where the Pays amount equals
  # the order total

  def Pays.orders_paid_in_full_by(payment)
    res = $store.select_complex(OrderTable, 
                                [PaysTable],
                                "pys_pay_id=? " +
                                "and pys_order_id=order_id " +
                                "and order_grand_total=pys_amount",
                                payment.pay_id)

    res.map {|o| Order.new(o)}
  end

  # Return a list of Pays objects that represent partal payments for orders

  def Pays.partial_payments_for(payment)
    res = $store.select_complex(PaysTable, 
                                [OrderTable],
                                "pys_pay_id=? " +
                                "and pys_order_id=order_id " +
                                "and order_grand_total>pys_amount",
                                payment.pay_id)

    res.map {|o| Pays.new(o)}
  end

  ######################################################################

  def initialize(data_object = nil)
    @data_object = data_object || fresh_pays
  end

  def fresh_pays
    p = PaysTable.new
    p.pys_amount = 0.0
    p.pys_date = DBI::Timestamp.new(Time.now)
    p
  end


  def record(order, payment, amount)
    p = @data_object
    p.pys_order_id = order.order_id
    p.pys_pay_id   = payment.pay_id
    p.pys_amount = amount
  end
end
