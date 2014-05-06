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

# We represent a join across Ship, Sale, and Product
# which serves as a useful summary of what's being shipped

class ShipInfo < BusinessObject

  def ShipInfo.list_pending_shipping
    $store.select(ShipInfoTable,
                  "li_date_shipped is null order by order_date").map do |si|
      new(si)
    end
  end

  ######################################################################

  def initialize(data_object)
    @data_object = data_object
  end

  def add_to_hash(values)
    super
    values['fmt_sale_date'] = @data_object.order_date.to_time.strftime("%d-%b-%y")
    if @data_object.order_mem_id
      mem = Membership.with_id(@data_object.order_mem_id)
      if mem
        values['full_passport'] = mem.full_passport
        values['mem_name']      = mem.mem_name
      end
    end

    ship_add = @data_object.order_ship_address

    name, rest = ship_add.split("\r\n", 2)

    values['ship_name'] = name
    values['ship_rest'] = rest

    values
  end

end
