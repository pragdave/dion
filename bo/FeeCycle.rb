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

class FeeCycle < BusinessObject

  def FeeCycle.latest_cycle
    res = $store.select_one(FeeCycleTable,
                            "cycle_id = (select max(cycle_id) from fee_cycle)");
    maybe_return(res)
  end

  ######################################################################

  def initialize(data_object = nil)
    @data_object = data_object || fresh_fee_cycle
  end

  def fresh_fee_cycle
    d = FeeCycleTable.new
    d.cycle_date = DBI::Timestamp.new(Time.now)
    d
  end


  def fmt_date
    @data_object.cycle_date.to_time.strftime("%d-%b-%y %H:%M")
  end
end
