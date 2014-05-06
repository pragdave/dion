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

class SaleParameter < BusinessObject

  def SaleParameter.get
    new($store.select_one(SaleParameterTable))
  end

  def initialize(data_object)
    @data_object = data_object || fresh_sale_parameter
  end

  def fresh_sale_parameter
    p = SaleParameterTable.new
    p.sp_canada_surcharge = 10.00
    p.sp_intl_surcharge   = 15.00
    p.sp_first_stepped_shipping = 4.00
    p.sp_rest_stepped_shipping  = 2.00
    p
  end

  def add_to_hash(values)
    p = @data_object
    values['sp_canada_surcharge']       = fmt_float(p.sp_canada_surcharge)
    values['sp_intl_surcharge']         = fmt_float(p.sp_intl_surcharge)
    values['sp_first_stepped_shipping'] = fmt_float(p.sp_first_stepped_shipping)
    values['sp_rest_stepped_shipping']  = fmt_float(p.sp_rest_stepped_shipping)
    values
  end

  def from_hash(values)
    p = @data_object
    p.sp_canada_surcharge = values['sp_canada_surcharge']
    p.sp_intl_surcharge = values['sp_intl_surcharge']
    p.sp_first_stepped_shipping = values['sp_first_stepped_shipping']
    p.sp_rest_stepped_shipping = values['sp_rest_stepped_shipping']
  end

  def error_list
    errs = []
    p = @data_object
    p.sp_canada_surcharge = check(p.sp_canada_surcharge, errs)
    p.sp_intl_surcharge = check(p.sp_intl_surcharge, errs)
    p.sp_first_stepped_shipping = check(p.sp_first_stepped_shipping, errs)
    p.sp_rest_stepped_shipping = check(p.sp_rest_stepped_shipping, errs)

    if errs.empty?
      if p.sp_first_stepped_shipping < p.sp_rest_stepped_shipping
        errs << "First shipping amount less than subsequent"
      end
    end
    errs
  end   

  def check(field, errs)
    res = field
    begin
      raise "bad" unless field =~ /^\d+(\.\d\d?)?$/
      res = Float(field)
    rescue
      errs << "Invalid amount: #{field}"
    end
    
    res
  end

  private

  def fmt_float(f)
    if f.kind_of? Float
      fmt_money(f)
    else
      f.to_s
    end
  end
end
