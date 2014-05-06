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

require 'app/MaintainProductsTemplates'
require 'bo/Product'

class MaintainProducts < Application

  app_info(:name => :MaintainProducts)

  class AppData
    attr_accessor :products
    attr_accessor :prd
  end
  
  def app_data_type
    AppData
  end


  # Display the list of products and let the user edit and add
  def maintain_products
    products = @data.products = Product.list
    values = {}
    list = []

    products.each_with_index do |prd, i|
      pinfo = {
        'prd_long_desc' => prd.prd_long_desc,
        'prd_sku'       => prd.prd_sku,
        'active'        => prd.prd_is_active ? "Y" : "N",
        "edit_url"      => url(:edit_existing_product, i),
      }
      list << pinfo
    end

    values = {
      'list' => list,
      'form_url' => url(:add_product),
    }

    standard_page("Maintain Products", values, MAINTAIN_PRODUCTS)
  end

  def add_product
    @data.prd = Product.new
    edit_product
  end

  def edit_existing_product(i)
    @data.prd = @data.products[i]
    edit_product
  end


  def edit_product
    prd = @data.prd
    values = {
      'prd_type_opts' => Product.prd_type_opts,
      'form_url' => url(:handle_edit_product)
    }
    prd.add_to_hash(values)
    standard_page("Edit Product", values, EDIT_PRODUCT)
  end


  def handle_edit_product
    prd = @data.prd
    values = hash_from_cgi
    prd.from_hash(values)
    errs = prd.error_list
    if errs.empty?
      prd.save
      note "#{prd.prd_long_desc} updated"
      maintain_products
    else
      error_list(errs)
      edit_product
    end
  end

end
