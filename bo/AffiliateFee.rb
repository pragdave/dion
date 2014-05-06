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

class AffiliateFee < BusinessObject

  def AffiliateFee.put_unassigned_in_cycle(fee_cycle)
    $store.update_where(AffiliateFeeTable,
                        "afee_paid_in_cycle=?",
                        "afee_paid_in_cycle is null",
                        fee_cycle.cycle_id)
  end

  def AffiliateFee.for_line_item(line)
    new($store.select_one(AffiliateFeeTable, "afee_sale_id=?", line.li_id))
  end

  ######################################################################

  def initialize(data_object=nil)
    @data_object = data_object || AffiliateFeeTable.new
  end


  def handle_payment(payment, line, aff_id, amount)
    r = @data_object
    r.afee_sale_id = line.li_id
    r.afee_pay_id  = payment.pay_id
    r.afee_amount  = amount
    r.afee_aff_id  = aff_id
    r.afee_desc    = line.li_desc
    r.afee_date_created = Time.now
  end

end
