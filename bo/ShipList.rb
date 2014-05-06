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

require 'bo/ShipCycle.rb'
require 'bo/Ship.rb'

class Shipping



  def Shipping.list_pending
    $store.select(ShipTable, "ship_cycle is null").map {|s| Ship.new(s)}
  end

end
