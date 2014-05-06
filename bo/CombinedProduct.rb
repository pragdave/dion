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

# Wrap an individual CombinedProduct

class CombinedProduct < BusinessObject

#  def CombinedProduct.with_id(prd_id)
#    maybe_return($store.select_one(CombinedProductTable, "prd_id=?", prd_id))
#  end

  def initialize(prd_rec, aff_rec)
    @data_object = CombinedProductTable.new
    prd_rec.type.fields.each do |f|
      next if f.name == "_version"
      @data_object.send(f.setter_name, prd_rec.send(f.name))
    end
    if aff_rec
      aff_rec.type.fields.each do |f|
        next if f.name == "_version"
        @data_object.send(f.setter_name, aff_rec.send(f.name))
      end
    else
      @data_object.afp_markup_setter(0.0)
    end
  end


  # does this product have an affiliate fee
  def has_affiliate_fee?
    afp_markup > 0.005
  end

  # return the total price (including the affiliate markup)
  def total_price
    res = prd_price
    res += afp_markup if afp_markup
    res
  end

  def desc_with_price
    desc = prd_short_desc
#    if prd_ship_first > 0.0
#      shipping = ", shipping: $#{'%0.2f' % prd_ship_first}"
#      if prd_ship_rest > 0.0
#        shipping += " on first item, $#{'%0.2f' % prd_ship_rest} on rest"
#      end
#    end
    desc += " @ $#{fmt_total_price}"
    if afp_markup && afp_markup > 0.0
      desc += " ($#{fmt_base_price} + $#{fmt_markup_price} affiliate fees)"
    end
    desc
#    desc + " ($#{fmt_total_price})"
  end


  def fmt_total_price
    fmt_money(total_price)
  end

  def fmt_base_price
    fmt_money(prd_price)
  end

  def fmt_markup_price
    fmt_money(afp_markup||0.0)
  end

  
end
