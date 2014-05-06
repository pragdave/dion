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

class Product < BusinessObject

  def Product.prd_type_opts
    {
      '1' => 'OnePak',
      '5' => 'FivePak',
      ProductTable::REGULAR_PRODUCT => 'Regular product',
      ProductTable::UPGRADE_PRODUCT => 'TeamPak Upgrade',
      ProductTable::ADJUSTMENT_PRODUCT => 'Adjustment to Order Total',
    }
  end

  def Product.highest_sku
    res = $store.raw_select("select max(prd_sku) from products")
    res[0][0] || '100000'
  end

  def Product.with_id(prd_id)
    maybe_return($store.select_one(ProductTable, "prd_id=?", prd_id))
  end

  def Product.with_short_desc(desc)
    maybe_return($store.select_one(ProductTable, "prd_short_desc=?", desc))
  end

  def Product.with_long_desc(desc)
    maybe_return($store.select_one(ProductTable, "prd_long_desc=?", desc))
  end

  def Product.with_sku(sku)
    maybe_return($store.select_one(ProductTable, "prd_sku=?", sku))
  end

  def Product.get_adjustment_product
    maybe_return($store.select_one(ProductTable, "prd_type=?", ProductTable::ADJUSTMENT_PRODUCT))
  end

  def Product.list
    sql = "select %columns% from products order by prd_is_active, prd_sku"
    $store.basic_select_with_columns(ProductTable, sql).map {|p| new(p)}
  end


  def initialize(data_object=nil)
    @data_object = data_object || fresh_product
  end

  def fresh_product
    p = ProductTable.new
    p.prd_short_desc = ''
    p.prd_long_desc = ''
    p.prd_sku = Product.highest_sku.succ
    p.prd_aff_can_markup = false
    p.prd_type = ProductTable::REGULAR_PRODUCT
    p.prd_show_on_app = false
    p.prd_show_general = true
    p.prd_show_tournament = false
    p.prd_available_in_us = true
    p.prd_available_intl = true
    p.prd_use_stepped_shipping = false
    p.prd_use_intl_surcharge = false
    p.prd_is_active = true
    p.prd_price = 0.00
    p.prd_settlement_actions = ''
    p
  end


  def add_to_hash(values)
    super
    p = @data_object
    values['prd_price'] = fmt_money(p.prd_price)
    values['type'] = Product.prd_type_opts[p.prd_type]
    values
  end

  def from_hash(values)
    p = @data_object
    p.prd_short_desc      = values['prd_short_desc']
    p.prd_long_desc       = values['prd_long_desc']
    p.prd_sku             = values['prd_sku']
    p.prd_aff_can_markup  = bool(values['prd_aff_can_markup'])
    p.prd_type            = values['prd_type']
    p.prd_show_on_app     = bool(values['prd_show_on_app'])
    p.prd_show_general    = bool(values['prd_show_general'])
    p.prd_show_tournament = bool(values['prd_show_tournament'])
    p.prd_available_in_us = bool(values['prd_available_in_us'])
    p.prd_available_intl  = bool(values['prd_available_intl'])
    p.prd_use_stepped_shipping = bool(values['prd_use_stepped_shipping'])
    p.prd_use_intl_surcharge   = bool(values['prd_use_intl_surcharge'])
    p.prd_is_active = bool(values['prd_is_active'])
    p.prd_price     = values['prd_price']

    p.prd_payment_actions = ProductTable::PA_SHIP
    p.prd_settlement_actions = ''
  end

  def error_list
    p = @data_object
    errs = []

    check_unique(p, p.prd_short_desc, "short description", :with_short_desc, errs)
    check_unique(p, p.prd_long_desc,  "long description",  :with_long_desc, errs)
    check_unique(p, p.prd_sku,        "SKU",               :with_sku, errs)

    if /^\d+(\.\d\d?)?$/ =~ p.prd_price
      begin
        p.prd_price = Float(p.prd_price)
      rescue
        errs << "Invalid price"
      end
    else
      errs << "Invalid price"
    end

    unless p.prd_type == ProductTable::REGULAR_PRODUCT
      if p.prd_use_stepped_shipping || p.prd_use_intl_surcharge
        errs << "Cannot apply shipping to TeamPak products"
      end
    end

    if p.prd_short_desc.length > 20
      errs << "Short description should be up to 20 characters long"
    end

    if p.prd_long_desc.length > 100
      errs << "Long description should be up to 100 characters long"
    end

    if p.prd_sku.length > 20
      errs << "SKU should be up to 20 characters long"
    end


    errs
  end


  def save
    p = @data_object
    case p.prd_type
      # Memberships get shipped (as a CD)
    when ProductTable::TEAMPAK_MIN..ProductTable::TEAMPAK_MAX
      p.prd_payment_actions = 
        ProductTable::PA_ACTIVATE_MEMBERSHIP + ProductTable::PA_SHIP
    when ProductTable::UPGRADE_PRODUCT
      p.prd_payment_actions = ProductTable::PA_UPGRADE_MEMBERSHIP
    when ProductTable::REGULAR_PRODUCT
      p.prd_payment_actions = ProductTable::PA_SHIP
    when ProductTable::ADJUSTMENT_PRODUCT
      p.prd_aff_can_markup  = false
      p.prd_show_on_app     = false
      p.prd_show_general    = false
      p.prd_show_tournament = false
      p.prd_available_in_us = true
      p.prd_available_intl  = true
      p.prd_use_stepped_shipping = false
      p.prd_use_intl_surcharge   = false
      p.prd_is_active = true
      p.prd_price     = 0.0
      p.prd_payment_actions = ''
    else
      raise "Unknown product type '#{p.prd_type}'"
    end
    p.prd_settlement_actions = nil
    super
  end

  def is_membership?
    t = @data_object.prd_type.to_s
    t >= ProductTable::TEAMPAK_MIN && t <= ProductTable::TEAMPAK_MAX
  end

  private

  def bool(v)
    v.downcase == "on"
  end

  def check_unique(prd, val, desc, getter, errs)
    if val.empty?
      errs << "Missing #{desc}"
    else
      p = Product.send(getter, val)
      if p && prd.prd_id != p.prd_id
        errs << "A product with that #{desc} already exists"
      end
    end
  end


end

