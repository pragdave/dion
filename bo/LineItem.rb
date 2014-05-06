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

class LineItem < BusinessObject

  def LineItem.with_id(li_id)
    maybe_return($store.select_one(LineItemTable, "li_id=?", li_id))
  end


  def LineItem.items_for_order(order_id)
    $store.select(LineItemTable, "li_order_id=?", order_id).map{|l| new(l)}
  end

  ######################################################################

  def LineItem.shipped_between(from, to)
    $store.select(LineItemTable, 
                  "date_trunc('day', li_date_shipped) between ? and ?",
                  from.date, to.date).map {|l| new(l)}
  end

  ######################################################################

  def LineItem.delete_for_order(order_id)
    $store.delete_where(LineItemTable, "li_order_id=?", order_id)
  end

  ######################################################################

  def initialize(data_object=nil)
    @data_object = data_object || fresh_line_item
  end

  def fresh_line_item
    l = LineItemTable.new
    l.li_desc = ''
    l.li_qty = 0
    l.li_unit_price = 0.0
    l.li_aff_fee    = 0.0
    l.li_total_amt  = 0.0
    l
  end

  def set_from_product(prd, qty)
    l = @data_object
    l.li_desc = prd.prd_long_desc
    l.li_qty  = qty
    l.li_unit_price = prd.prd_price
    l.li_aff_fee    = prd.afp_markup
    l.li_total_amt  = qty*(l.li_unit_price + l.li_aff_fee)
    l.li_prd_id     = prd.prd_id
    l.li_use_stepped_shipping  = prd.prd_use_stepped_shipping
    l.li_use_intl_surcharge    = prd.prd_use_intl_surcharge
  end

  def fmt_total_amt
    fmt_money(@data_object.li_total_amt)
  end

  def fmt_total_aff_fee
    fmt_money(@data_object.li_qty * @data_object.li_aff_fee)
  end

  def fmt_aff_fee
    fmt_money(@data_object.li_aff_fee)
  end

  def fmt_unit_price
    fmt_money(@data_object.li_unit_price + @data_object.li_aff_fee)
  end

  def fmt_net_price
    fmt_money(@data_object.li_unit_price)
  end

  def fmt_date_shipped
    fmt_date(@data_object.li_date_shipped)
  end

  # Mark this item as shipped
  def mark_as_shipped
    @data_object.li_date_shipped = Time.now
    save
  end
    
end
