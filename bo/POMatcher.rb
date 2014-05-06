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

# This is a little helper class that attempts to match
# purchase orders against criteria given by the user

require 'bo/BusinessObject'
require 'bo/Payment'


class POMatcher

  attr_reader :match_po_ref
  attr_reader :match_inv_num
  attr_reader :match_their_po_ref

  attr_reader :specific_search

  PO = PaymentMethodTable::PO

  COMMON_WHERE = "pay_paying_check_doc_ref is null and pay_type='#{PO}' "


  def add_to_hash(values)
    values['match_po_ref']       = @match_po_ref
    values['match_inv_num']      = @match_inv_num
    values['match_their_po_ref'] = @match_their_po_ref
  end

  def from_hash(values)
    @match_po_ref       = values['match_po_ref'] 
    @match_inv_num      = values['match_inv_num']
    @match_their_po_ref = values['match_their_po_ref']
  end


  def error_list
    count = 0
    count += 1 unless @match_po_ref.empty?
    count += 1 unless @match_inv_num.empty?
    count += 1 unless @match_their_po_ref.empty?

    if count > 1
      return [ "Please specify just one item to match" ]
    else
      return []
    end
  end


  # Return the list of payments that we match

  def find_payments
    @specific_search = true
    @match_po_ref.empty?       or return do_pay_ref
    @match_inv_num.empty?      or return do_inv_num
    @match_their_po_ref.empty? or return do_their_po
     
    @specific_search = false
    return do_all_pos
  end


  private

  def do_all_pos
    $store.select(PaymentTable, COMMON_WHERE).map {|p| Payment.new(p)}
  end

  def do_pay_ref
    $store.select(PaymentTable, COMMON_WHERE +
                  "and pay_our_ref=?",
                  @match_po_ref).map {|p| Payment.new(p)}
  end

  def do_inv_num
    $store.select_complex(PaymentTable, [InvoiceTable],
                          COMMON_WHERE + 
                          "and inv_pay_id=pay_id " +
                          "and inv_id=?",
                          @match_inv_num).map {|p| Payment.new(p)}
  end

  def do_their_po
    $store.select(PaymentTable, COMMON_WHERE +
                  "and pay_doc_ref=?",
                  @match_their_po_ref).map {|p| Payment.new(p)}
  end

end
