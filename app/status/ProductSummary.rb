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
require 'app/status/ProductSummaryTemplates'

require 'bo/SalesSummary'

class ProductSummary < Application

  app_info(:name => "ProductSummary")

  class AppData
  end

  def app_data_type
    AppData
  end

  ######################################################################


  def display(aff_id=nil)

    if aff_id
      display_for_affiliate(Affiliate.with_id(aff_id))
    else
      display_for_all
    end
  end


  def display_for_affiliate(aff)
    values = {
      'prd_list' => prd_list(aff)
    }
    standard_page("Product List", values, PRODUCT_LIST)
  end


  def display_for_all
    aff_list =  Affiliate.list.map do |aff|
      res = {
        'aff_long_name' => aff.aff_long_name,
        'prd_list'      => prd_list(aff, false)
      }
    end
    values = { 'aff_list' => aff_list }
    standard_page("Affiliate Product Markup", values, AFFILIATE_PRODUCT_LIST)
  end

  # format up either all roducts, or only those with a markup
  def prd_list(aff, all=true)
    prds = CombinedProducts.for_affiliate(aff)
    prd_list = []
    prds.each do |prd|
      if prd.prd_aff_can_markup || all
        res = prd.add_to_hash({})
        res['fmt_base_price']   = prd.fmt_base_price
        res['fmt_markup_price'] = prd.fmt_markup_price
        res['fmt_total_price']  = prd.fmt_total_price
        prd_list << res
      end
    end
    prd_list
  end

  ######################################################################
  
  def sales_breakdown
    sales = SalesSummary.list
    lines = sales.map { |line|  line.add_to_hash({}) }

    values = Order.breakdown

    values['list'] = lines 
    standard_page("Sales Summary", values, SALES_SUMMARY)
  end
end
