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

# Handle various kinds of lists of payments

class PaymentList

  def PaymentList.unpaid_pos
    res = $store.select(PaymentTable,
                        "pay_type=? and pay_paying_check_our_ref is null " +
                        "order by pay_processed",
                        PaymentMethod::PO)
    new(res)
  end


  def initialize(list)
    @list = list.map {|pe| Payment.new(pe) }
  end

  def empty?
    @list.empty?
  end


  def add_to_hash(values)
    list = []
    @list.each { |pe|  list << pe.add_to_hash({}) }
    values['list'] = list
    values
  end

end
