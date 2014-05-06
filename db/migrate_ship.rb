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

require 'app/Application'
require 'db/TableDefinitions'
require 'bo/User'
require 'bo/Contact'
require 'bo/Order'
require 'db/Store'

$store = Store.new(*ARGV)

orders = $store.select(OrderTable).map {|o| Order.new(o)}

orders.each do |o|
  user = User.with_id(o.order_user_id)
  contact = user.contact
  ship = contact.ship

  add =
    contact.con_name + "\r\n" +
    ship.add_line1 + "\r\n"

  unless ship.add_line2.empty?
    add << ship.add_line2 << "\r\n"
  end

  add << ship.add_city << ", " << ship.add_state << " " << ship.add_zip << "\r\n" <<
    ship.add_country << "\r\n"

  o.order_ship_address = add
  o.order_ship_add_changed = false
  o.save
  puts contact.con_name
end


