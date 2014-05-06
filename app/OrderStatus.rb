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
require 'app/OrderStatusTemplates'
require 'app/PaymentStatus'
require 'bo/Order'
require 'bo/PaysPayment'
require 'bo/User'

class OrderStatus < Application

  app_info(:name => "OrderStatus")
  
  class AppData
  end

  def app_data_type
    AppData
  end

  ######################################################################

  def find_order
    @passport = ""
    @user_email = ""
    @order_id   = ""
    find_common
  end


  def find_common
    values = {
      'form_url'   => url(:handle_find),
      'passport'   => @passport,
      'order_id'   => @order_id,
      'user_email' => @user_email,
    }
    standard_page("Find Order", values, FIND_ORDER)
  end


  def handle_find
    @order_id = @cgi['order_id']
    return find_by_order_id if @order_id && !@order_id.empty?

    @passport = @cgi['passport']
    return find_by_passport if @passport && !@passport.empty?

    @user_email = @cgi['user_email']
    return find_by_email if @user_email  && !@user_email.empty?

    error "Please specify search criteria"
    find_common
  end


  def find_by_order_id
    begin
      @order_id = Integer(@order_id)
    rescue
      error "Order-id must be numeric"
      return find_common
    end

    order = Order.with_id(@order_id)
    if order
      display_order_status(order)
    else
      error "Order #@order_id not found"
      find_common
    end
  end


  def find_by_passport
    mem = Membership.with_full_passport(@passport)
    if mem
      orders = Order.list_for_membership(mem.mem_id)
      display_orders(@passport, orders)
    else
      error "Unknown passport"
      find_common
    end
  end


  def find_by_email
    user = User.with_email(@user_email)
    if user
      orders = Order.list_for_user(user.user_id)
      display_orders(@user_email, orders)
    else
      error "Unknown user"
      find_common
    end
  end


  def display_orders(criteria, orders)
    if orders.size == 0
      note "No orders for #{criteria}"
      return find_common
    end
    if orders.size == 1
      display_order_status(orders[0])
    else
      display_order_list(orders)
    end
  end


  # Display an individual order
  def display_order_status(order)
    values = order.add_to_hash({})

    user = User.with_id(order.order_user_id)
    if user
      user.add_to_hash(values)
    else
      error "Unknown user"
      find_common
    end

    pays_list = PaysPayment.list_for_order(order)
    unless pays_list.empty?
      values['pays_list'] = pays_list.map do |p| 
        res = {
          'payment_url' => @context.url(PaymentStatus, :display_from_id, p.pys_pay_id)
        }
        p.add_to_hash(res)
      end
    end

    values['print_statement'] = url(:print_statement, order.order_id)

    standard_page("Order Status", values, ORDER_STATUS)
  end

  # print a statement 
  def print_statement(order_id)
    stmt = Statements.new
    values = {
      'stmt_url' => stmt.print_statements([order_id])
    }
    standard_page("Statement", values, SHOW_STATEMENT)
  end

  # Display a summary list of orders, and let them pick
  # one to see details
  def display_order_list(orders)
    list = orders.map do |o| 
      res = { 'order_url' => url(:display_from_id, o.order_id) }
      o.add_to_hash(res)
      res
    end
    
    standard_page("Matching Orders", {'list' => list}, ORDER_LIST)
  end

  # And when we come back from the list, pick up the order and
  # display it

  def display_from_id(order_id)
    order = Order.with_id(order_id)
    if order
      display_order_status(order)
    else
      error "Missing order"
      @session.pop
    end
  end


  ######################################################################

  def list_partially_paid
    orders = Order.list_partially_paid
    if orders.empty?
      note "No partially-paid orders"
      @session.pop
    else
      list = orders.map do |o|
        res = { 
          'order_url' => url(:display_from_id, o.order_id),
        }
        res['force_url'] = url(:force_ship, o.order_id) unless o.shipping?

        o.add_to_hash(res)
      end
      standard_page("Partially paid orders",
                    { 'list' => list },
                    PARTIALLY_PAID_ORDERS,
                    PARTIALLY_PAID_COMMON)
    end
  end

  ######################################################################

  def list_partially_paid_and_shipped
    orders = Order.list_partially_paid_and_shipped
    if orders.empty?
      note "No partially-paid shipped orders"
      @session.pop
    else
      list = orders.map do |o|
        res = { 
          'order_url' => url(:display_from_id, o.order_id),
        }
        o.add_to_hash(res)
      end
      standard_page("Partially paid shipped orders",
                    {
                      'list'      => list, 
                      'dun_url'   => url(:dunning_statements),
                      'days_ago'  => '30', 
                    },
                    PARTIALLY_PAID_SHIPPED,
                    PARTIALLY_PAID_COMMON)
    end
  end

  ######################################################################

  def force_ship(order_id)
    order = Order.with_id(order_id)
    if order
      order.force_ship(@session)
      note "Order \##{order_id} marked for shipping"
      list_partially_paid
    else
      error "Order missing"
      @session.pop
    end
  end

  ######################################################################

  def dunning_statements
    days_ago = @cgi['days_ago'].to_i
    if days_ago <= 0
      error "'Days Ago' must be a number greater than zero"
      list_partially_paid_and_shipped
      return
    end

    orders = Order.list_partially_paid_and_shipped
    res = []
    now = Date.today

    orders.each do |order|
      date = order.order_date.to_date
      res << order.order_id if now - date >= days_ago
    end

    if res.empty?
      note "No orders are #{days_ago} or more days old"
      list_partially_paid_and_shipped
      return
    end

    stmt = Statements.new
    values = {
      'stmt_url' => stmt.print_statements(res)
    }
    standard_page("Statement", values, SHOW_STATEMENT)
    
  end

end
