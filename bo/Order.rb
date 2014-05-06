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

# An order is a list of products and quantities

require 'bo/BusinessObject'
require 'bo/LineItem'
require 'bo/SaleParameter'
require 'util/Formatters'

class Order < BusinessObject

  include Formatters


  ######################################################################
  # A class to hold information on adjustments

  class Adjustment
    include Formatters

    attr_reader :reason, :amount, :prd_id

    def initialize(line_item)
      if line_item
        @reason = line_item.li_desc
        @amount = line_item.li_total_amt
        @fmt_amount = fmt_money(@amount)
        @prd_id = line_item.li_prd_id
      else
        product = Product.get_adjustment_product
        if product
          @reason = product.prd_long_desc
          @prd_id = product.prd_id
          @amount = 0.0
        else
          raise "No adjustment product defined"
        end
      end
    end

    def add_to_hash(values)
      values['amount'] = @fmt_amount
      values['reason'] = @reason
      values
    end

    def from_hash(values)
      @fmt_amount = values['amount']
      @reason = values['reason']
    end

    def error_list
      errs = []
      errs << "Missing reason" if @reason.nil? || @reason.empty?

      begin
        @amount = unfmt_negative_money(@fmt_amount)
      rescue
        errs << "Invalid amount"
      end
      errs
    end

  end
  
  ######################################################################


  def Order.with_id(order_id)
    maybe_return($store.select_one(OrderTable, "order_id=?", order_id))
  end
  
  def Order.list_for_membership(mem_id)
    $store.select(OrderTable, "order_mem_id=?", mem_id).map {|s| new(s)}
  end

  def Order.list_for_user(user_id)
    $store.select(OrderTable, "order_user_id=?", user_id).map {|s| new(s)}
  end

  def Order.list_partially_paid()
    $store.select(OrderTable, "order_grand_total>order_amount_paid " +
                  "order by order_date").map {|s| new(s)}
  end

  def Order.list_partially_paid_and_shipped()
    $store.select(OrderTable, 
                  "order_grand_total>order_amount_paid " +
                  "and exists (select 1 from line_item " +
                  "            where li_date_shipped is not null " +
                  "              and li_order_id=order_id) " +
                  "order by order_date").map {|s| new(s)}
  end


  # Return a list of orders that match a given payment
  def Order.list_that_matches_payment(pay)
    $store.select(OrderTable,
                  "order_doc_ref=? and " +
                  "order_pay_type=? and " +
                  "order_amount_paid < order_grand_total and " +
                  "order_grand_total - order_amount_paid <= ?",
                  pay.pay_doc_ref,
                  pay.pay_type,
                  (pay.pay_amount+.99).to_i).map do |s|
      new(s)
    end
  end


  # Break down orders, showing where the money is partitioned
  def Order.breakdown
    sql = 
      "select sum(order_shipping), sum(order_intl_surcharge), sum(order_grand_total) from orders"
    row = $store.raw_select(sql)[0]
    shipping = row[0].to_f
    intl     = row[1].to_f
    grand_total = row[2].to_f

    pct = proc {|amt| fmt_money(100*amt/grand_total)}

    sql = 
      "select prd_type, sum(li_total_amt) " +
      "  from line_item, products " +
      " where li_prd_id=prd_id " +
      " group by prd_type"

    rows = $store.raw_select(sql)

    values = {
      "shipping"       => fmt_money(shipping), "shipping_pct" => pct[shipping],
      "intl_surcharge" => fmt_money(intl),     "intl_pct"     => pct[intl],
      "grand_total"    => fmt_money(grand_total),
      "products"       => rows.map do |row|
        amt = row[1].to_f
        {
          "type" => Product.prd_type_opts[row[0]],
          "amount" => fmt_money(amt), "pct" => pct[amt],
        }
      end
    }
  end

      
  # 
  # return all orders paid with a given payment
#  def Order.list_paid_with_payment(payment)
#    $store.select(OrderTable, "order_pay_id=?", payment.pay_id).map {|s| new(s)}
#  end



  # A MemberSearch returns a where-clause and a list of tables that
  # will search the member database. Join this to the Sale table
  # to return a list of matching sales

  def Order.list_from_member_search(where, tables)
    tables = tables.reject {|t| t == OrderTable}
    $store.select_complex(OrderTable, tables,
                          "order_mem_id = mem_id and " + where).map {|s| new(s)}
  end

  # A OrderSearch returns a where-clause and a list of tables that
  # will search the member database. Join this to the Sale table
  # to return a list of matching sales

  def Order.list_from_order_search(where, tables)
    tables = tables.reject {|t| t == OrderTable}
    $store.select_complex(OrderTable, tables, where).map {|s| new(s)}
  end


  ######################################################################

  def Order.delete_for_teampak(mem_id)
    list_for_membership(mem_id).each do |order|
      LineItem.delete_for_order(order.order_id)
      order.delete
    end
  end

  ######################################################################

  def Order.create(aff)
    order = new
    order.set_affiliate(aff)
    order
  end

  ######################################################################

  attr_reader :lines

  attr_reader :was_fully_paid, :was_fully_settled

  def initialize(data_object = nil)
    @data_object = data_object || fresh_order
    if @data_object.order_id
      @lines = LineItem.items_for_order(@data_object.order_id)
      @was_fully_paid = fully_paid
      @was_fully_settled = fully_settled
    else
      @lines = []
      @was_fully_paid    = false
      @was_fully_settled = false
    end
    @deleted_lines = []
    @params = SaleParameter.get
  end

  def each_line
    @lines.each {|line| yield line}
  end

  def set_affiliate(aff)
    @affiliate = aff
    @data_object.order_aff_id = aff.aff_id
  end

  def set_payment_option(po)
    @data_object.order_pay_type = po.pay_method
    @data_object.order_doc_ref  = po.pay_ref
  end

  def get_payment_option
    po = PaymentOption.new
    po.pay_method = @data_object.order_pay_type 
    po.pay_ref    = @data_object.order_doc_ref
    po
  end

  # An adjustment is simply a line item with a special product ID
  # However, it's wrapped in an Adjustment object to make it easier
  # to manipulate
  def get_adjustment_line
    prd = Product.get_adjustment_product
    raise "Missing adjustment product: please add using Maintain/Products function" unless prd
    @lines.find {|li| li.li_prd_id == prd.prd_id }
  end

  def get_adjustment
    Adjustment.new(get_adjustment_line)
  end

  def set_adjustment(adjustment)
    $stderr.puts "Setting adjustment"
    old_adj_line = get_adjustment_line
    if old_adj_line
      $stderr.puts "Deleting adjustment"
      delete_line(old_adj_line)
    end
    if adjustment.amount.abs > 0.001
      prd = Product.with_id(adjustment.prd_id)
      raise "Can't find adjustment product" unless prd
      li = LineItem.new
      li.li_qty       = 1
      li.li_total_amt = li.li_unit_price = adjustment.amount
      li.li_aff_fee   = 0.0
      li.li_prd_id    = prd.prd_id
      li.li_desc      = adjustment.reason
      li.li_use_stepped_shipping  = false
      li.li_use_intl_surcharge    = false
      @lines << li
    end
  end

  # return the total affiliate fee for our line items
  def total_affiliate_fee
    total = 0.0
    @lines.each {|line| total += (line.li_aff_fee * line.li_qty) }
    total
  end

  # Set the user id for an order, and extract that user's shipping
  # address as our own

  def set_user_id(user_id)
    @data_object.order_user_id = user_id
    user = User.with_id(user_id)
    if user
      contact = user.contact
      ship = contact.ship
      
      add =  contact.con_name + "\r\n" + ship.to_s

      @data_object.order_ship_address = add
    end
  end

  def set_mem_id(mem_id)
    @data_object.order_mem_id = mem_id
  end

  def fresh_order
    o = OrderTable.new
    o.order_date = DBI::Timestamp.new(Time.now)
    o.order_shipping = 0.0
    o.order_intl_surcharge = 0.0
    o.order_lines_total = 0.0
    o.order_grand_total = 0.0
    o.order_amount_paid = 0.0
    o.order_amount_settled = 0.0
    o.order_ship_address   = ''
    o.order_ship_add_changed = false
    o
  end

  # Add a new line item based on a product
  def add(product, qty)
    l = LineItem.new
    l.set_from_product(product, qty)
    @lines << l
  end

  # Remove a particular line item
  def delete_line(line)
    raise "Can't find line item to delete" unless @lines.delete(line)
    @deleted_lines << line
  end

  # delete all line items
  def delete_all_lines
    @deleted_lines.concat @lines
    @lines.clear
  end

  # Find a order for a particular product and quantity
  def find_match(prd, qty)
    each_line do |line|
      return line if line.li_prd_id == prd.prd_id && line.li_qty == qty
    end
    raise "Couldn't find #{prd.prd_short_desc} in order"
  end

  # We assume we're called in the context of a transaction
  def record_sales
    @deleted_lines.each {|l| l.delete}
    @deleted_lines.clear
    calc_values
    save
    @lines.each do |li|
      li.li_order_id = @data_object.order_id
      li.save
    end
  end


  # Force an order to be shipped. This really means forcing each of
  # its line items to be shiped

  def force_ship(session)
    each_line do |line|
      PaymentActions.process_payment(session, 
                                     line,
                                     self)
    end
  end


  # Mark an order as shipped by delegating to all the line items
  def mark_as_shipped
    each_line {|li| li.mark_as_shipped}
  end


  # return true if this order is already marked for shipping
  def shipping?
    each_line do |line|
      # has it shipped?
      return true if line.li_date_shipped
      # or is it queued up for shipping?
      return true if Ship.for_line_item(line)
    end
    return false
  end

  # Pay off this sale with a payment
#  def pay_with(payment)
#    @data_object.order_date_paid = Time.now
#    @data_object.order_pay_id    = payment.pay_id
#    save
#  end

  # Record paying off against this order. In addition, log the payment to
  # the membership (if any)

  def pay_off(user, payment, amount)
    @data_object.order_amount_paid += amount
    if fully_paid
      @data_object.order_date_paid = DBI::Timestamp.new(Time.now)
    end

    log_payment_to_mem(user, payment, amount)
  end

  def log_payment_to_mem(user, payment, amount, flag="")
    mem_id = @data_object.order_mem_id
    if mem_id
      mem = Membership.with_id(mem_id)
      if mem
        msg = 
          "#{payment.type_name} (ref: #{payment.pay_doc_ref}) "+
          "#{flag}applied $#{fmt_money(amount)} to order #{order_id}"
        mem.log(user, msg)
      end
    end
  end

  # adjust the amount applied to this order by 'amount'
  # This is used when HQ staff edit a payment and change
  # the amount applied

  def adjust_payment(user, payment, amount)
    o = @data_object
    o.order_amount_paid += amount
    if o.order_amount_paid < 0
      raise "Cannot adjust payment to a negative amount"
    end
    if o.order_amount_paid > o.order_grand_total
      raise "Cannot apply more than pending amount to order"
    end

    if fully_paid
      if o.order_date_paid.nil?
        o.order_date_paid = DBI::Timestamp.new(Time.now)
      end
    else
      if o.order_date_paid
        o.order_date_paid = nil
      end
    end

    log_payment_to_mem(user, payment, amount, "re")
  end



  def left_to_pay
    o = @data_object
    o.order_grand_total - o.order_amount_paid
  end

  def fully_paid
    o = @data_object
    (o.order_grand_total - o.order_amount_paid).abs < 0.001
  end


  def settle_with(amount)
    o = @data_object
    o.order_amount_settled += amount
    if o.order_amount_settled - o.order_grand_total > 0.001
      raise "Over settled: order #{o.order_id}, amount #{amount}"
    end
  end



  def fully_settled
    o = @data_object
    (o.order_grand_total - o.order_amount_settled).abs < 0.001
  end


  def add_to_hash(values, include_shipping=false)
    o = @data_object
    if o.record_changed?
      calc_values
    end

    list = @lines.map do |li|
      res = {
        "li_id" => li.li_id,
        "qty"   => li.li_qty,
        "desc"  => li.li_desc,
        "net"   => li.fmt_net_price,
        "unit"  => li.fmt_unit_price,
        "aff_fee" => li.fmt_aff_fee,
        "price" => li.fmt_total_amt, 
      }
      if li.li_aff_fee > 0.0
        res["total_aff_fee"] = li.fmt_total_aff_fee
      end
      if li.li_qty == 1
        res['fmt_desc'] = li.li_desc
      else
        res['fmt_desc'] = "#{li.li_qty} x #{li.li_desc}"
      end
      if li.li_date_shipped
        res['status'] = "Sent #{fmt_date(li.li_date_shipped)}"
      else
        ship = Ship.for_line_item(li)
        if ship
          res['status'] = "Shipping"
        else
          res['status'] = ''
        end
      end

      res
    end

    if include_shipping
      if o.order_shipping > 0.0001
        list << dummy_line_item("Shipping", o.order_shipping)
      end
      if o.order_intl_surcharge > 0.0001
        list << dummy_line_item("International surcharge", o.order_intl_surcharge)
      end
    end

    values["order_id"]        = o.order_id
    values["fmt_order_date"]  = fmt_order_date

    values["order_pay_type"]  = o.order_pay_type
    values["order_doc_ref"]   = o.order_doc_ref

    their_ref = PaymentMethod.short_name_from_type(o.order_pay_type) + " #"

    if o.order_doc_ref && !o.order_doc_ref.empty?
      their_ref += o.order_doc_ref
    else
      their_ref += "Unknown"
    end

    values["their_ref"] = their_ref

    mem = Membership.with_id(o.order_mem_id)
    if mem
      values['order_passport'] = mem.full_passport
      values['order_school']   = mem.mem_schoolname
      values['order_mem_name'] = mem.mem_name
    else
      values['order_passport'] = ''
      values['order_school']   = ''
      values['order_mem_name'] = ''
    end

    values['order_status'] = if  fully_settled
                               "Paid #{fmt_date(o.order_date_paid)}"
#                             elsif po_pending
#                               "Awaiting #{po_pending} PO payment"
#                             elsif left_to_pay < o.order_grand_total
#                               "$#{fmt_money(left_to_pay)} left to pay"
                             else
                               "Await payment"
                             end

    values['product_list']   = list
    values["total"]          = fmt_money(o.order_lines_total)
    values["shipping"]       = fmt_money(o.order_shipping)
    values["intl_surcharge"] = fmt_money(o.order_intl_surcharge) if o.order_intl_surcharge > 0.0
    values['grand_total']    = fmt_money(o.order_grand_total)
    values['left_to_pay']    = fmt_money(left_to_pay)
    values['settled']        = fmt_money(o.order_amount_settled)

    values['order_ship_address'] = o.order_ship_address
    values['order_ship_add_changed'] = o.order_ship_add_changed
    values['fmt_ship_address']   = o.order_ship_address.gsub("\r\n", Template::BR)
    values
  end

  def grand_total
    @data_object.order_grand_total
  end


  def fmt_order_date
    fmt_date(@data_object.order_date)
  end

  # return an string containing a reason why this order can't be deleted, or
  # nil if it can

  def reason_not_to_delete
    d = @data_object
    if d.order_amount_paid > 0.0
      return "Cannot delete an order after it has been partially paid"
    end

    pays = Pays.for_order(self)
    unless pays.empty?
      return "Cannot delete an order after payments have been applied"
    end

    each_line do |line|
      if line.li_date_shipped
          return "Cannot delete: '#{line.li_desc}' has been shipped"
      end
    end

    nil
  end

  # return an string containing a reason why this order can't be edited, or
  # nil if it can
  def reason_not_to_edit
    d = @data_object
    if d.order_amount_paid > 0.0
      return "Cannot edit an order after it has been partially paid"
    end

    pays = Pays.for_order(self)
    unless pays.empty?
      return "Cannot edit an order after payments have been applied"
    end

    each_line do |line|
      if line.li_date_shipped
          return "Cannot edit: '#{line.li_desc}' has been shipped"
      end
    end

    nil
  end


  # delete this order and its associated line items
  def delete
    LineItem.delete_for_order(order_id)
    CreditCardTransaction.remove_references_to_order(order_id)
    super
  end

  #######
  private
  #######


  def dummy_line_item(desc, price)
    res = {
      "desc"     => desc,
      "fmt_desc" => desc,
      "price"    => fmt_money(price),
      "status"   => ''
    }
    res
  end

  def calc_values
    o = @data_object

    o.order_lines_total    = 0.0
    o.order_shipping       = 0.0
    o.order_intl_surcharge = 0.0

    stepped_count = 0
    add_canadian_surcharge = false
    add_international_surcharge = false

    @lines.each do |line|
      o.order_lines_total += line.li_total_amt
      
      if line.li_use_stepped_shipping
        stepped_count += line.li_qty
      end
      if line.li_use_intl_surcharge
        add_canadian_surcharge = true if affiliate.aff_in_canada
        add_international_surcharge = true if affiliate.aff_is_foreign
      end
    end

    if stepped_count > 0
      o.order_shipping = @params.sp_first_stepped_shipping
      if stepped_count > 1
        o.order_shipping += (stepped_count-1)*@params.sp_rest_stepped_shipping
      end
    end

    if add_canadian_surcharge
      o.order_intl_surcharge = @params.sp_canada_surcharge
    elsif add_international_surcharge
      o.order_intl_surcharge = @params.sp_intl_surcharge
    end

    o.order_grand_total = o.order_lines_total + o.order_shipping + o.order_intl_surcharge
  end

  def affiliate
    return @affiliate if @affiliate
    @affiliate = Affiliate.with_id(@data_object.order_aff_id)
  end


end
