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

require "bo/BusinessObject"

class PaymentMethod < BusinessObject

  CHECK =  PaymentMethodTable::CHECK
  PO    =  PaymentMethodTable::PO
  CC    =  PaymentMethodTable::CC

  @@list = nil

  def PaymentMethod.list
    @@list ||= $store.select(PaymentMethodTable).map {|a| new(a)}
  end

  def PaymentMethod.from_type(typ)
    list
    maybe_return(list.find {|a| a.pme_id == typ})
  end

  
  def PaymentMethod.name_from_type(typ)
    pme = from_type(typ)
    if pme
      pme.pme_desc
    else
      "unknown"
    end
  end

  def PaymentMethod.short_name_from_type(typ)
    pme = from_type(typ)
    if pme
      pme.pme_short_desc
    else
      "Pmt"
    end
  end

  # Return the payment method as a set of options for
  # template display
  def PaymentMethod.options
    @options ||= list

    @options.map do |option|
      {
        "pay_method"     => option.pme_id,           
        "desc"           => option.pme_desc,
        "is_credit_card" => option.pme_is_credit_card,
        "note"           => option.pme_form_note
        
      }
    end
  end

  # and return the list as a hash for ddlb processing
  def PaymentMethod.ddlb_options
    @options ||= list
    res = {}
    @options.each do |o|
      res[o.pme_id] = o.pme_desc
    end
    res
  end

  def PaymentMethod.from_form(values, payment_option)
    msg = nil

    if values['pay_method'].empty?
      return "No payment method specified"
    end
    
    method =  values['pay_method']
    payment_option.pay_method = method

    ref_key = "pay_ref_" + method
    payment_option.pay_ref = values[ref_key]

    if values[ref_key] && values[ref_key].size > 40
      msg = "Payment reference too long (40 characters maximum)"
    end

    msg
  end

  def initialize(data_object)
    @data_object = data_object
  end
end
