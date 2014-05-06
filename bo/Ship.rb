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

class Ship < BusinessObject

  def Ship.for_line_item(line)
    maybe_return($store.select_one(ShipTable,
                                   "ship_sale_id=?",
                                   line.li_id))
  end

  def Ship.mark_item_shippable(line)
    existing = Ship.for_line_item(line)
    unless existing
      ship = Ship.new
      ship.ship_sale_id = line.li_id
      ship.save
    end
  end

  ######################################################################

  def initialize(data_object = nil)
    @data_object = data_object || fresh_ship
  end

  def fresh_ship
    s = ShipTable.new
    s.ship_created = DBI::Timestamp.new(Time.now)
    s
  end

end
