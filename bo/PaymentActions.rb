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

# We're responsible for handling the various actions that
# are triggered by the payment or settlement of a sale
#
# For example, when a membership is paid, it is activated,
# and when it's settled, a rebate is credited to
# the affiliate

require 'bo/Product'
require 'bo/AffiliateFee'
require 'bo/Ship'

class PaymentActions

  # Settlements and payments are handled pretty much
  # the same (the differences are driven by the action codes in
  # the database, and not here). The only special case
  # is that every settlement for a sale with an affiliate
  # rebate adds an entry to the rebate journal

  def PaymentActions.process_settlement(session, payment, line, order)
    if line.li_aff_fee > 0
      handle_rebate(payment, line, order)
    end

    product = Product.with_id(line.li_prd_id)

    process_common(session, product.prd_settlement_actions, line, order)
  end

  
  def PaymentActions.process_payment(session, line, order)
    product = Product.with_id(line.li_prd_id)

    process_common(session, product.prd_payment_actions, line, order)
  end


  # Most of the processing is in common
  def PaymentActions.process_common(session, actions, line, order)
    return if actions.nil?
    actions.split('').each do |action|
      case action

      when ProductTable::PA_ACTIVATE_MEMBERSHIP
        mem = Membership.with_id(order.order_mem_id)
        mem.activate(session)

      when ProductTable::PA_UPGRADE_MEMBERSHIP
        mem = Membership.with_id(order.order_mem_id)
        mem.upgrade(session)

      when ProductTable::PA_SHIP
        ship(line)

      else
        raise "Unknown action '#{action.inspect}' (#{actions.inspect}) " +
          "in product #{line.li_prd_id}"
      end
    end
  end

  ######################################################################


  # If we change a payment, we may end up undoing the pamen or settlement
  # If so, we have have some work to do

  def PaymentActions.process_undo_settlement(session, payment, line, order)
    if line.li_aff_fee > 0
      handle_undo_rebate(payment, line, order)
    end

    product = Product.with_id(line.li_prd_id)

    process_undo_common(session, product.prd_settlement_actions, line, order)
  end


  def PaymentActions.process_undo_payment(session, line, order)
    product = Product.with_id(line.li_prd_id)

    process_undo_common(session, product.prd_payment_actions, line, order)
  end


  # Most of the processing is in common
  def PaymentActions.process_undo_common(session, actions, line, order)

    actions.split('').each do |action|
      case action

      when ProductTable::PA_ACTIVATE_MEMBERSHIP
        mem = Membership.with_id(order.order_mem_id)
        mem.undo_activate(session)

      when ProductTable::PA_UPGRADE_MEMBERSHIP
        mem = Membership.with_id(order.order_mem_id)
        mem.undo_upgrade(session)

      when ProductTable::PA_SHIP
        # ship(line)

      else
        raise "Unknown action '#{action.inspect}' (#{actions.inspect}) " +
          "in product #{line.li_prd_id}"
      end
    end
  end

  ######################################################################


  # Generate an affiliate fee

  def PaymentActions.handle_rebate(payment, line, order)
    fee = AffiliateFee.new
    fee.handle_payment(payment, line, order.order_aff_id, line.li_aff_fee)
    fee.save
  end

  # Undo an affiliate rebate. If it hasn't yet been processed,
  # we can simply delete it. Otherwise, we need to generate
  # a refund

  def PaymentActions.handle_undo_rebate(payment, line, order)
    fee = AffiliateFee.for_line_item(line)
    raise "Can't find affiliate fee for line item id #{line.li_id}" unless fee
    if fee.afee_paid_in_cycle.nil?
      fee.delete
    else
      fee = AffiliateFee.new
      fee.handle_payment(payment, line, order.order_aff_id, -line.li_aff_fee)
      fee.save
    end
  end


  # Arrange to ship the product
  def PaymentActions.ship(line)
    Ship.mark_item_shippable(line)
  end

end
