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

# We handle editing and deleting payments

require 'app/OrdersTemplates'

class Orders < Application

  app_info(:name => "Orders")
  
  class AppData
    attr_accessor :order_id
    attr_accessor :handler
    attr_accessor :label
    attr_accessor :order
    attr_accessor :adjustment
  end

  def app_data_type
    AppData
  end


  ######################################################################
  # delete a specified order

  def delete_order
    @data.order_id = ''
    @data.handler = :handle_delete
    @data.label   = 'deleted'
    get_order
  end

  ######################################################################
  # Edit a specified order

  def edit_order
    @data.order_id = ''
    @data.handler = :handle_edit
    @data.label   = 'edited'
    get_order
  end

  ######################################################################
  # make an adjustment to the total amount on an order

  def adjust_order
    @data.order_id = ''
    @data.handler = :handle_adjust
    @data.label   = 'adjusted'
    get_order
  end
  
  ######################################################################
  # Prompt for a order number, then vector to the appropriate handler

  def get_order
    standard_page("Maintain Order",
                  {
                    'done_url'  => url(@data.handler),
                    'action'    => @data.label,
                    'order_id'  => @data.order_id,
                  },
                  IDENTIFY_ORDER);
  end

  ######################################################################
  # check that the payment is found. If so, check that it is OK to
  # delete it. If so, display a summary for confirmation

  def handle_delete
    @data.order_id = @cgi['order_id']
    return unless order_found

    # if this is a teampak order, handle it specially
    if @data.order.order_mem_id
      mem = Membership.with_id(@data.order.order_mem_id)
      raise "Membership disappeared" unless mem
      @session.dispatch(TeamPaks, :confirm_delete, [mem])
      return
    end

    reason = @data.order.reason_not_to_delete
    if reason
      error reason
      get_order
      return
    end

    values = @data.order.add_to_hash({}, true)

    values['confirm_delete'] = url(:confirm_delete)
    values['dont_delete']    = url(:get_order)

    standard_page("Confirm Delete", values, CONFIRM_DELETE)
  end


  def confirm_delete
    @data.order.delete
    @session.user.log("Deleted order \##{@data.order_id}")
    note "Order \##{@data.order_id} deleted"
    @session.pop
  end

  ######################################################################
  # Fetch the requested payment, then arrange for it to be displayed
  # for editing

  def handle_edit
    @data.order_id = @cgi['order_id']
    return unless order_found

    reason = @data.order.reason_not_to_edit
    if reason
      error reason
      get_order
    else
      @session.dispatch(GeneralOrders, :edit_existing, [ @data.order ])
    end
  end


  ######################################################################
  # Make an adjustment to the total on an order

  def handle_adjust
    @data.order_id = @cgi['order_id']
    return unless order_found

    @data.adjustment = @data.order.get_adjustment
    adjust_common
  end

  def adjust_common
    values = @data.order.add_to_hash({})
    values['adjustment'] = [ @data.adjustment.add_to_hash({}) ]
    values['adjust_url'] = url(:do_adjustment)
    standard_page("Adjust Order Total", values, GET_ADJUSTMENT)
  end

  def do_adjustment
    adj = @data.adjustment
    values = hash_from_cgi
    adj.from_hash(values)

    errors = adj.error_list
    if errors.empty?
      @data.order.set_adjustment(adj)
      @data.order.record_sales
      if @data.order.left_to_pay < 0
        error "Warning: order is now overpaid. You may want to reapply payments"
      else
        note "Order adjusted"
      end
      @context.dispatch(@session, OrderStatus, :display_order_status, [ @data.order ] )
    else
      error_list errors
      adjust_common
    end
  end

  #######
  private
  #######

  def order_found
    unless @data.order_id =~ /^\d+$/
      error "Invalid order ID"
      get_order
      return
    end

    @data.order = Order.with_id(@data.order_id)
    unless @data.order
      error "Can't find order with id '\##{@data.order_id}'"
      get_order
    end
    @data.order
  end
  

end
