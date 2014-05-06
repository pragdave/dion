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
require 'app/ShippingTemplates'
require 'reports/Reports'
require 'reports/Statements'
require 'bo/DionDate'
require 'bo/User'


require 'bo/ShipInfo'

class Shipping < Application

  app_info(:name            => :Shipping,
           :login_required  => true)

  class AppData
    attr_accessor :display_list
    attr_accessor :label_count
    attr_accessor :ship_count
    
    attr_accessor :start_date
    attr_accessor :end_date

  end

  def app_data_type
    AppData
  end

  ######################################################################
  # These hold information on the items pending shipping. It's organized
  # as
  #    address <- orders <- line items

  class ShipAddress
    attr_reader :add_index
    attr_accessor :make_label
    
    # address includes at least one shipped order
    attr_accessor :ship_order

    def initialize(address, add_index)
      @orders = []
      @fmt_ship_address = address
      @add_index        = add_index
      @make_label       = false
      @ship_order       = false
    end

    def add_order(order)
      @orders << order
    end

    def add_to_hash(values)
      add = values['fmt_ship_address'] = @fmt_ship_address
      name, rest = add.split("\r\n", 2)
      name ||= ''
      rest ||= ''
      values['ship_name'] = name

      rest.sub!(/^(\r\n)+/, '')
      rest.gsub!(/\r\n(\r\n)+/, "\r\n")

      values['ship_rest'] = rest.split("\r\n").join('!newline!')

      add = add.gsub("\r\n", ", ")
      add = add[0,67] + "..." if add.length > 70

      values['abbrev_ship_address'] = add

      values['orders'] = @orders.map {|o| o.add_to_hash({})}

      values['add_index'] = @add_index.to_s
      values["check_label_#{@add_index}"] = @make_label
      values
    end

    def each_order
      @orders.each {|o| yield o}
    end
  end

  class ShipOrder
    attr_reader :order_id
    attr_accessor :ship_order

    def initialize(order_id, a_line_item)
      @order_id = order_id
      tmp = a_line_item.add_to_hash({})
      @fmt_sale_date = tmp['fmt_sale_date']
      @full_passport = tmp['full_passport']
      @mem_name      = tmp['mem_name']
      @ship_order    = false
      @line_items = []
    end

    def add_line_item(line_item)
      @line_items << line_item
    end

    def add_to_hash(values)
      values['order_id']      = @order_id
      values['fmt_sale_date'] = @fmt_sale_date
      values['full_passport'] = @full_passport
      values['mem_name']      = @mem_name

      values["check_ship_#{@order_id}"] = @ship_order
      values['line_items'] = @line_items.map do |li|
        li.add_to_hash({})
      end
      values
    end
  end

  class ShipLineItem
    def initialize(si)
      @li_qty = si.li_qty
      @prd_long_desc = si.prd_long_desc
    end

    def add_to_hash(values)
      values['li_qty'] = @li_qty
      values['prd_long_desc'] = @prd_long_desc
      values
    end
  end

  ######################################################################

  def shipping_summary
    ship_list = ShipInfo.list_pending_shipping

    if ship_list.empty?
      note "Nothing waiting to ship"
      @session.pop
      return
    end

    @data.display_list = list = group_by_address(ship_list)
    values = {
      'address_list' => list.map {|ship_address| ship_address.add_to_hash({})},
      'ok_url'       => url(:print)
    }
    standard_page("Shipping Summary", values, SHIPPING_SUMMARY)
  end


  # See what's needed to be printed, and print it accordingly

  def print
    list = @data.display_list
    @labels = []
    @ship   = []

    @data.label_count, @data.ship_count = update_from_form(list)

    if @data.label_count + @data.ship_count == 0
      note "Nothing to ship"
      @session.pop
      return
    end
    
    values = {}
    if @data.label_count > 0
      labels = print_labels
      if labels
        values['label_url'] = labels
      else
        error "Error producing labels. Call Dave"
        @session.pop
        return
      end
    end
    if @data.ship_count > 0
      statements = print_statements
      if statements
        values['statements_url'] = statements
      else
        error "Error producing Statements. Call Dave"
        @session.pop
        return
      end
    end

    mark_stuff_shipped(values)
  end

  # Print labels for all the nominated addresses
  def print_labels
    list = @data.display_list
    # select addresses that need labels
    label_data = list.select {|address_entry| address_entry.make_label }

    values = { 
      'labels' => label_data.map {|address| address.add_to_hash({}) }
    }
    report_path = print_report(values, Reports::SHIPPING_LABELS)
  end

  # print statements lists for all users that are shipping
  # at least one product, returning the URL

  def print_statements
    orders = []
    list = @data.display_list
    list.each do |address_entry|
      if address_entry.ship_order
        address_entry.each_order do |order|
          if order.ship_order
            orders << order.order_id
          end
        end
      end
    end
    statements =  Statements.new
    statements.print_packing_slips(orders)
  end


  # Last step - mark items as shipped and return to the main menu
  def mark_as_shipped
    @context.no_going_back

    list = @data.display_list
    update_from_form(list)

    list.each do |address_entry|
      address_entry.each_order do |order_info|
        next unless order_info.ship_order

        order = Order.with_id(order_info.order_id)

        if order
          order.mark_as_shipped
        else
          raise "Missing order"
        end

      end
    end
    @session.pop
  end

  private

  # Given a list of everything waiting to ship, produce a list of
  # hashes for the template processor. Each Entry in the list
  # corresponds to a unique address waiting for something to be shipped

  def group_by_address(ship_list)
    res = []
    addresses = {}

    # 1. associate each line item with an address
    ship_list.each do |si|
      add = si.order_ship_address
      addresses[add] ||= []
      addresses[add] << si
    end

    # 2. Now build the sorted list of ShipAddress objects

    addresses.keys.sort.each_with_index do |address, add_index|
      add = ShipAddress.new(address, add_index)
      
      # For each address, build a list of orders
      orders = {}
      addresses[address].each do |si|
        order_id = si.order_id
        orders[order_id] ||= []
        orders[order_id] << si
      end

      # for each order, add it to the address, and add in its
      # line items

      orders.keys.sort.each do |order_id|
        line_items = orders[order_id]
        order = ShipOrder.new(order_id, line_items[0])
        line_items.each do |li|
          order.add_line_item(ShipLineItem.new(li))
        end
        add.add_order(order)
      end
      res << add
    end

    return res

    res = []


    addresses.keys.sort.each do |add|
      si_list = addresses[add]
#      user = User.with_id(user_id)
      values = {}
=begin
      values['fmt_ship_address'] = add
      name, rest = add.split("\r\n", 2)
      name ||= ''
      rest ||= ''
      values['ship_name'] = name

      rest.sub!(/^(\r\n)+/, '')
      rest.gsub!(/\r\n(\r\n)+/, "\r\n")

      values['ship_rest'] = rest.split("\r\n").join('\\\\')

      add = add.gsub("\r\n", ", ")
      add = add[0,67] + "..." if add.length > 70

      values['abbrev_ship_address'] = add
      values['add_index'] = add_index.to_s
#      user.add_to_hash(values)
      values["check_label_#{add_index}"] = false

      values['orders'] = orders_from_shipinfo(si_list)
=end

#       values['line_items'] = si_list.map do |se|
#         li = se.add_to_hash({})
#         li
#       end

      res << values
      add_index += 1
    end

    #puts CGI.escapeHTML(res.inspect)

#    while res.size < 200
#      res << res[0].dup
#    end
    res
  end

  # A shipinfo list contains information on each line item. We need to group
  # these instead into line items within orders
  def orders_from_shipinfo(si_list)
    orders = {}
    si_list.each do |si|
      orders[si.order_id] ||= []
      orders[si.order_id] << si
    end

    # return the hash for the template
    orders.keys.sort.map do |order_id|
      sis = orders[order_id]
      res = sis[0].add_to_hash({})
      res["check_ship_#{order_id}"] = false
      res['line_items'] = sis.map do |si|
        si.add_to_hash({})
      end
      res
    end
  end


  def update_from_form(list)
    label_count = 0
    ship_count  = 0
    list.each do |address_entry|
      add_index = address_entry.add_index
      label = "check_label_#{add_index}"
      state = @cgi[label].downcase == "on"
      address_entry.make_label = state
      label_count += 1 if state

      address_entry.each_order do |order|
        order_id = order.order_id
        label = "check_ship_#{order_id}"
        state = @cgi[label].downcase == "on"
        order.ship_order = state
        address_entry.ship_order = true if state
        ship_count += 1 if state
      end

    end
    [ label_count, ship_count ]
  end


  # Show the user the list of all stuff they selected and
  # ask them if we should mark it as shipped

  def mark_stuff_shipped(values)
    values['address_list']   = @data.display_list.map do |address|
      address.add_to_hash({})
    end

    values['update_url']  = url(:mark_as_shipped)
    standard_page("Confirm Shipping", values, CONFIRM_SHIPPING)
  end


  public

  ######################################################################
  #
  # Produce the daily shipping report

  def shipping_report
    @data.start_date = DionDate.new("start", Time.now)
    @data.end_date   = DionDate.new("end",   Time.now)
    shipping_report_common
  end

  def shipping_report_common
    values = { 'form_url' => url(:produce_report) }

    @data.start_date.add_to_hash(values)
    @data.end_date.add_to_hash(values)

    standard_page("Shipping Report", values, SHIPPING_REPORT_DATES)
  end


  def produce_report
    values = hash_from_cgi

    @data.start_date.from_hash(values)
    @data.end_date.from_hash(values)
    
    errors = @data.start_date.error_list + @data.end_date.error_list

    if errors.empty? && @data.start_date > @data.end_date
      errors = [ "Start date is after end date" ]
    end

    unless errors.empty?
      error_list(errors)
      return shipping_report_common
    end

    do_report
  end

  def do_report
    line_items = LineItem.shipped_between(@data.start_date, @data.end_date)
    if line_items.empty?
      note "Nothing shipped in this date range"
      return @session.pop
    end

    products = {}
    orders = {}

    Product.list.each {|p| products[p.prd_id] = p}

    shipped_by_product = {}

    total_net     = 0.0
    total_order   = 0.0
    total_aff_fee = 0.0
    total_ship    = 0.0
    grand_total   = 0.0

    line_items.each do |line|
      prd_id = line.li_prd_id
      shipped_by_product[prd_id] ||= []
      shipped_by_product[prd_id] << line

      orders[line.li_order_id] ||= Order.with_id(line.li_order_id)
    end

    orders.each do |order_id, order|
      total_order += order.order_lines_total
      total_ship += order.order_shipping + order.order_intl_surcharge
      grand_total += order.order_grand_total
    end

    # ordered list of products actually shipped, sorted by name

    shipped_products = shipped_by_product.keys.sort do |a,b|
      products[a].prd_long_desc <=> products[b].prd_long_desc
    end

    product_list = shipped_products.map do |prd_id|
      values = products[prd_id].add_to_hash({})

      qty = 0
      product_total = 0.0

      lines = shipped_by_product[prd_id].map do |li|
        order = orders[li.li_order_id]
        user  = User.with_id(order.order_user_id)

        uname = user.contact.con_name

        if order.order_mem_id
          mem = Membership.with_id(order.order_mem_id)
          uname = "#{uname} (#{mem.full_passport})"
        end

        qty += li.li_qty

        if products[prd_id].prd_type == ProductTable::ADJUSTMENT_PRODUCT
	  product_total += li.li_total_amt
	end

        total_net += li.li_unit_price * li.li_qty
        total_aff_fee += li.li_aff_fee * li.li_qty

        {
          'fmt_date_shipped' => li.fmt_date_shipped,
          'user'             => uname,
          'qty'              => li.li_qty,
          'order_id'         => order.order_id,
          'order_date'       => order.fmt_order_date,
          'order_url'        => @context.url(OrderStatus,
                                             :display_from_id,
                                             li.li_order_id),
        }
      end

      values['lines'] = lines
      values['count'] = qty
      if products[prd_id].prd_type == ProductTable::ADJUSTMENT_PRODUCT
        values['ts']    = product_total
      else
        values['ts']    = fmt_money(qty * products[prd_id].prd_price)
      end
      values
    end

    # Now produce a summary of all orders associated with shipped items


=begin
    order_list = orders.keys.sort.map do |order_id|
      order = orders[order_id]

      total_net   += order.order_lines_total
      total_ship  += order.order_shipping + order.order_intl_surcharge
      grand_total += order.order_grand_total

      values = order.add_to_hash({})
      pays = Pays.for_order(order)
      label = "Paid with:"
      values['pays'] = pays.map do |pys|
        pay = Payment.with_id(pys.pys_pay_id)
        res = pay.add_to_hash({ 'label' => label})
        label = ''
        res
      end
      values['order_url'] = @context.url(OrderStatus,
                                         :display_from_id,
                                         order_id) 
      values
    end
=end

    values = {
      'from' => @data.start_date.to_s,
      'to'   => @data.end_date.to_s,
      'product_list' => product_list,
#     'order_list'   => order_list,
      'total_net'     => fmt_money(total_net),
      'total_aff_fee' => fmt_money(total_aff_fee),
      'total_order'   => fmt_money(total_order),
      'total_ship'    => fmt_money(total_ship),
      'grand_total'   => fmt_money(grand_total),
    }

    standard_page("Shipping Report", values, SHIPPING_REPORT)
  end

end
