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
require 'app/ProductListTemplates'
require 'bo/Product'

class ProductList < Application
  app_info(:name => "ProductList")
  
  class AppData
  end

  def app_data_type
    AppData
  end

  ######################################################################


  def list_products
    list = Product.list.map do |prd|

      shows = []
      shows << "Application" if prd.prd_show_on_app
      shows << "General order form" if prd.prd_show_general
      shows << "AD/RD form"         if prd.prd_show_tournament
      shows << "Nowhere!"           if shows.empty?

      available = []
      available << "U.S."            if prd.prd_available_in_us
      available << "Internationally" if prd.prd_available_intl
      available << "Nowhere!"        if available.empty?
      
      special_shipping = []
      special_shipping << "Stepped"          if prd.prd_use_stepped_shipping
      special_shipping << "Intl. surcharge"  if prd.prd_use_intl_surcharge
      special_shipping << "None"             if special_shipping.empty?
      
      values = {
        'showon' => shows.join(", "),
        'available' => available.join(", "),
        'shipping'  => special_shipping.join(", "),
      }
      prd.add_to_hash(values)
      values
    end

    values = {
      'list' => list
    }

    standard_page("Product List", values, PRODUCT_LIST)
  end
end
