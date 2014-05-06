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

class SalesSummary < BusinessObject

  def SalesSummary.list
    sql = 
      "select prd_long_desc, COALESCE(sum(li_qty),0) as qty, sum(li_aff_fee), sum(li_total_amt)" +
      "  from products left outer join line_item on li_prd_id=prd_id " +
      " group by prd_long_desc " +
      " order by qty desc"

    $store.raw_select(sql).map do |row|
      new(*row)
   end
  end

  
  def initialize(desc, qty, aff, amt)
    @desc = desc
    @qty = qty
    @aff = aff
    @amt = amt
  end


  def add_to_hash(values)
    values['desc'] = @desc
    values['qty']  = @qty
    values['aff']  = fmt_money(@aff || 0)
    values['amt']  = fmt_money(@amt || 0)
    values
  end
end
