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
require 'app/AffiliateProductsTemplates'

require 'bo/Product'
require 'bo/AffiliateProduct'

class AffiliateProducts < Application

  app_info(:name => :AffiliateProduct)

  class AppData
    attr_accessor :aff
    attr_accessor :products
  end
  
  def app_data_type
    AppData
  end

  ######################################################################

  def maintain_products(aff_id)
    aff = @data.aff = Affiliate.with_id(aff_id)
    products = @data.products = CombinedProducts.for_affiliate(aff)
    
    values = {}
    list = []
    products.all_products.each_with_index do |cp, i|
      pinfo = {
        'desc'       => cp.prd_long_desc,
        'base_price' => cp.fmt_base_price,
      }
      if cp.prd_aff_can_markup
        pinfo['markup_index'] = i
        pinfo["markup_#{i}"] = cp.fmt_markup_price
      end
      list << pinfo
    end

    values = {
      'list' => list,
      'form_url' => url(:handle_maintain_products),
      'aff_short_name' => aff.aff_short_name
    }

    standard_page("Administer Products", values, ADMIN_PRODUCTS)
  end


  def handle_maintain_products

    @data.products.all_products.each_with_index do |prd, i|
      markup = @cgi["markup_#{i}"]

      next unless markup &&!markup.empty?

      begin
        markup = Float(markup)
        raise "x" if markup < 0
      rescue
        error "Invalid markup: #{markup}"
        return maintain_products(@data.aff.aff_id)
      end

      afp = AffiliateProduct.for_affiliate(@data.aff.aff_id, prd.prd_id)
      
      if afp
        if (afp.afp_markup - markup).abs > 0.001
          afp.afp_markup = markup
          afp.save
        end
      else
        if markup.abs > 0.001
          afp = AffiliateProduct.new
          afp.afp_affiliate = @data.aff.aff_id
          afp.afp_product   = prd.prd_id
          afp.afp_markup    = markup
          afp.save
        end
      end
    end

    @data.aff.mark_as_done(Affiliate::TODO_FEES)
    @data.aff.save
    @session.user.log("Completed setting affiliate fees")
    @session.pop
  end

end
