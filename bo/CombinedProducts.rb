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

require 'bo/CombinedProduct'

# This class is a wrapper for the collection of products for
# from the CombinedProducts view.

class CombinedProducts

  SHOW_ON_APP = :show_on_app
  SHOW_GENERAL = :show_general
  SHOW_TOURNAMENT = :show_tournament


  TEAMPAK_PRODUCT = proc do |p|
    p.prd_type >= ProductTable::TEAMPAK_MIN && p.prd_type <= ProductTable::TEAMPAK_MAX
  end

  REGULAR_PRODUCT = proc {|p| p.prd_type == ProductTable::REGULAR_PRODUCT }

  UPGRADE_PRODUCT = proc {|p| p.prd_type == ProductTable::UPGRADE_PRODUCT }

  # Return the CombinedPRoductTable for active products for
  # a particular affiliate

  def CombinedProducts.for_affiliate(aff, for_show_on=nil)
    if aff.aff_in_canada || aff.aff_is_foreign
      int_clause = "prd_available_intl=true"
    else
      int_clause = "prd_available_in_us=true"
    end

    show = case for_show_on
           when nil then ""
           when SHOW_ON_APP then "prd_show_on_app=true and "
           when SHOW_GENERAL then "prd_show_general=true and "
           when SHOW_TOURNAMENT then "prd_show_tournament=true and "
           else
             raise "Invalid show parameter"
           end

    clause =  "prd_is_active=true and " + show + int_clause + " order by prd_long_desc"

    products = $store.select(ProductTable, clause)

    res = products.map do |p|
      afp = $store.select_one(AffiliateProductTable,
                              "afp_affiliate=? and afp_product=?", 
                              aff.aff_id, p.prd_id)
      CombinedProduct.new(p, afp)
    end
    new(res)
  end

  def initialize(recs)
    @recs = recs
  end
  private :initialize


  # return a list of the membership-level products 
  def member_products
    @recs.select(&TEAMPAK_PRODUCT)
  end

  # A list of upgrades
  def upgrade_products
    @recs.select(&UPGRADE_PRODUCT)
  end

  # and all products
  def all_products
    @recs
  end

  # and a list of the other products
  def other_products
    @recs.select(&REGULAR_PRODUCT)
  end

  # Return the product with a particular ID
  def with_type(prd_type)
    @recs.find {|p| p.prd_type == prd_type}
  end

  # Return the product with a particular ID
  def with_id(prd_id)
    @recs.find {|p| p.prd_id == prd_id}
  end

  def each
    @recs.each {|r| yield r }
  end
end
