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

# Wrap the PaysOrder view

class PaysOrder < BusinessObject

  def PaysOrder.list_for_payment(payment)
    $store.select(PaysOrderView, "pys_pay_id=?", payment.pay_id) .map {|p| new(p)}
  end


  def initialize(data_object)
    @data_object = data_object
  end

  def add_to_hash(values)
    p = @data_object
    super
    values['applied_date'] = fmt_date(p.pys_date)
    values['order_amt']    = fmt_money(p.order_grand_total)
    values['applied_amt']  = fmt_money(p.pys_amount)
    values
  end


end
