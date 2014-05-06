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

require 'bo/Payment'
require 'bo/PaymentList'
require 'app/ListPurchaseOrdersTemplates'

class ListPurchaseOrders < Application

  app_info(:name            => :ListPurchaseOrders,
           :login_required  => true)

  class AppData
  end

  def app_data_type
    AppData
  end

  ######################################################################

  def summary_of_unpaid
    list = PaymentList.unpaid_pos
    if list.empty?
      note "No unpaid purchase orders"
      @session.pop
      return
    end

    values = {
      'ok_url' => @context.url(Portal)
    }
    list.add_to_hash(values)

    values['list'].each do |po_entry|
      pay_id = po_entry['pay_id']
      if pay_id
        po_entry['detail_url'] = @context.url(PaymentStatus, :display_from_id, pay_id)
      end

    end

    standard_page("Oustanding Purchase Orders", values, OUTSTANDING_POS)
  end
    
end
