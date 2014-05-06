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

class PaysPayment < BusinessObject

  def PaysPayment.list_for_order(order)
    $store.select(PaysPaymentView, "pys_order_id=?", order.order_id) .map {|p| new(p)}
  end


  def initialize(data_object)
    @data_object = data_object
  end

  def add_to_hash(values)
    p = @data_object
    super
    values['fmt_processed'] = fmt_date(p.pay_processed)
    values['fmt_total_amt'] = fmt_money(p.pay_amount)
    values['fmt_applied_amt'] = fmt_money(p.pys_amount)
    values['ref']           = short_type_name + " #" + pay_doc_ref
    values
  end


  def short_type_name
    PaymentMethod.short_name_from_type(@data_object.pay_type)
  end
                          
end
