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
require "bo/Payment"

require 'util/hmac/hmac-md5'


class CreditCardTransaction < BusinessObject

  APPROVED = '1'
  DECLINED = '2'
  ERROR    = '3'


  # Helper class to build the attribute list


  class Pairs
    attr_accessor :pairs
    def initialize
      @pairs = []
    end
    def add(k, v)
      @pairs << {'k' => k, 'v' => v}
    end
  end

  ######################################################################

  def CreditCardTransaction.list
    $store.select(CreditCardLogTable).map {|cc| new cc}
  end

  # Remove any references to a specific order
  def CreditCardTransaction.remove_references_to_order(order_id)
    $store.update_where(CreditCardLogTable,
                        "cc_order_id=null",
                        "cc_order_id=?",
                        order_id)
  end


  def CreditCardTransaction.with_id(cc_id)
    maybe_return($store.select_one(CreditCardLogTable, "cc_id=?", cc_id))
  end
  
  def CreditCardTransaction.for_payment(pay_id)
    maybe_return($store.select_one(CreditCardLogTable, "cc_pay_id=?", pay_id))
  end
  
  ######################################################################

  def initialize(data_object = nil)
    @data_object = data_object || fresh_cc_transaction
  end

  def fresh_cc_transaction
    c = CreditCardLogTable.new
    c.cc_date_submitted = Time.now
    c.cc_reason_text    = "Incomplete transaction"
    c
  end

  def new_transaction(order, description, contact)
    c = @data_object
    c.cc_amount = order.grand_total
    c.cc_order_id = order.order_id
    c.cc_description = description
    c.cc_con_id      = contact.con_id
    @contact     = contact
    c
  end


  def add_to_hash(values)
    super
    c = @data_object
    values['fmt_submitted'] = fmt_date_time(c.cc_date_submitted)
    values['fmt_amount']    = fmt_money(c.cc_amount)
    values
  end


  def hash_for_authorize(values, context_id, entry_id)
    add_to_hash(values)
    
    c = @data_object
    p = Pairs.new

    # These fields are also used to generate the hash to
    # authorize,net

    timestamp = Time.now.to_i.to_s
    seq = rand(1_000_000).to_s
    amount = c.cc_amount.to_s

    p.add('x_Login', Config::CREDIT_CARD_ACCOUNT)
    p.add('x_FP_Sequence', seq)
    p.add('x_FP_Timestamp', timestamp)
    p.add('x_Amount', amount)

    hashdata = "#{Config::CREDIT_CARD_ACCOUNT}^#{seq}^#{timestamp}^#{amount}^"

    hashcode = HMAC::MD5.hexdigest(Config::CREDIT_CARD_TRAN_KEY, hashdata)

    p.add('x_FP_Hash', hashcode)

    p.add('x_Description', c.cc_description)
    p.add('x_version', "3.0")
    p.add('x_Show_Form', "PAYMENT_FORM")
    p.add("x_Relay_Response", "True")
    if Config::DEBUG
      my_url = "http://somewhere.in.pragprog.com/dion/dion.rb"
    else
      my_url = Apache::request.construct_url(ENV['SCRIPT_NAME'])
    end
    p.add("x_Relay_URL", my_url)


    # Assume contact address is billing address: they can override on 
    # for form

    p.add("x_First_Name", @contact.con_first_name)
    p.add("x_Last_Name",  @contact.con_last_name)
    p.add("x_Email",      @contact.con_email) if @contact.con_email && !@contact.con_email.empty?

    mail = @contact.mail
    add = mail.add_line1
    if mail.add_line2 && !mail.add_line2.empty?
      add += ", " + mail.add_line2
    end
    p.add("x_Address",    add)
    p.add("x_State",      mail.add_state)
    p.add("x_City",       mail.add_city)
    p.add("x_Zip",        mail.add_zip)
    p.add("x_Country",    mail.add_country)


    # SHIPPING ADDRESS
    ship = @contact.ship

    p.add("x_Ship_To_First_Name", @contact.con_first_name)
    p.add("x_Ship_To_Last_Name",  @contact.con_last_name)
    add = ship.add_line1
    if ship.add_line2 && !ship.add_line2.empty?
      add += ", " + ship.add_line2
    end
    p.add("x_Ship_To_Address",    add)
    p.add("x_Ship_To_State",      ship.add_state)
    p.add("x_Ship_To_City",       ship.add_city)
    p.add("x_Ship_To_Zip",        ship.add_zip)
    p.add("x_Ship_To_Country",    ship.add_country)

    p.add("dion_context", context_id)
    p.add("entry_id",     entry_id)

    values['cc_fields'] = p.pairs
    values['confirm_url'] = Config::CREDIT_CARD_URL
    values
  end

  
  def from_hash(values)
    c = @data_object
    c.cc_response_code = values['x_response_code'] || ERROR
    c.cc_reason_code   = values['x_response_reason_code']
    c.cc_reason_text   = values['x_response_reason_text']
    c.cc_auth_code     = values['x_auth_code']
    c.cc_trans_id      = values['x_trans_id']
    c.cc_avs_code      = values['x_avs_code']
    c.cc_payor         =
      (values['x_first_name'] || '') + " " + (values['x_last_name'] || '')
      

    amt = values['x_amount']
    begin
      amt = Float(amt)
      c.cc_amount = amt
    rescue
      msg = "Invalid amount $'#{amt.inspect}' from Authorize.net"
      $stderr.puts 
      c.cc_response_code = ERROR
      c.cc_reason_code   = 999
      c.cc_reason_text   = msg
    end
    c.cc_date_returned = Time.now
  end



  # generate a payment to tie this credit card transaction to
  # an order
  def apply_to_order(user, order, session)
    cc = @data_object
    cc.cc_order_id = order.order_id
    pay = gen_payment
    $store.transaction do 
      pay.apply_to_order(user, order, cc.cc_amount, session)
      cc.cc_pay_id = pay.pay_id
      save
    end
  end

  private

  # Generate a payment object that corresponds to this credit card
  # transaction

  def gen_payment
    cc = @data_object
    pay = Payment.new
    pay.pay_type    = Payment::CC
    pay.pay_our_ref = "CC:" + sprintf("%06d", cc.cc_id)
    pay.pay_doc_ref = cc.cc_trans_id
    pay.pay_payor   = cc.cc_payor[0, 40]
    pay.pay_amount  = cc.cc_amount
    pay
  end

end
