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
require "bo/Address"

class Contact < BusinessObject


  def Contact.with_id(id)
    maybe_return($store.select_one(ContactTable, "con_id=?", id))
  end

  def Contact.with_email(email)
    maybe_return($store.select_one(ContactTable, "con_email=?", id))
  end

  def initialize(data_object = nil)
    @data_object = data_object || fresh_contact_table
  end

  def mail
    @mail ||= get_address(@data_object.con_mail)
  end

  def ship
    @ship ||= get_address(@data_object.con_ship)
  end

  def fresh_contact_table
    c = ContactTable.new
    c.con_first_name = ''
    c.con_last_name  = ''
    c.con_email      = ''
    c.con_day_tel    = ''
    c.con_eve_tel    = ''
    c.con_fax_tel    = ''
    c.con_ship_to_mail = false
    c
  end

  def add_to_hash(hash)
    super
    hash['con_name'] = con_name

    tels = []
    tels << "Day: #{con_day_tel}" unless con_day_tel.nil? || con_day_tel.empty?
    tels << "Eve: #{con_eve_tel}" unless con_eve_tel.nil? || con_eve_tel.empty?
    tels << "Fax: #{con_fax_tel}" unless con_fax_tel.nil? || con_fax_tel.empty?

    hash['con_tel_list'] = tels.join(", ")

    mail_add = {}
    mail.add_to_hash(mail_add, "M_")
    hash['mail_add'] =  [ mail_add ]

    ship_add = {}
    ship.add_to_hash(ship_add, "S_")
    hash['ship_add'] =  [ ship_add ]
    
    hash['ship_empty'] = true if ship.empty?

    hash
  end

  def from_hash(values)
    @data_object.con_first_name = values['con_first_name']
    @data_object.con_last_name  = values['con_last_name']
    @data_object.con_email      = values['con_email']
    @data_object.con_day_tel    = values['con_day_tel']
    @data_object.con_eve_tel    = values['con_eve_tel']
    @data_object.con_fax_tel    = values['con_fax_tel']
    @data_object.con_ship_to_mail = bool(values['con_ship_to_mail'])

    mail.from_hash(values, "M_")
    ship.from_hash(values, "S_")
  end

  # return any validaton errors in this contact. If the 'strict'
  # parameter is set, we insist on an address
  def error_list(strict = false)
    c = @data_object
    res = []

    res << "Missing name" if c.con_first_name.empty? || c.con_last_name.empty?

    if strict
      if c.con_day_tel.empty? && c.con_eve_tel.empty? && c.con_fax_tel.empty? 
        res << "Must supply at least one contact telephone number" 
      end
    end

    check_length(res, c.con_first_name, 50, "first name")
    check_length(res, c.con_last_name,  50, "first name")
    check_length(res, c.con_day_tel,    20, "daytime telephone number")
    check_length(res, c.con_eve_tel,    20, "evening telephone number")
    check_length(res, c.con_fax_tel,    20, "fax telephone number")
    check_length(res, c.con_email,      60, "e-mail address")

    unless c.con_email.empty?
      msg = Mailer.invalid_email_address?(c.con_email)
      res << msg if msg 
    end

    res.concat mail.error_list(strict, "mailing")
    res.concat ship.error_list(strict, "shipping")

    if strict && @mail.empty?
      res << "Please specify a mailing address"
    end

    if strict && !c.con_ship_to_mail && ship.empty?
      res << "Please specify a shipping address (or click box to indicate" +
        " that your mailing address is your shipping address"
    end

    res
  end


  # Save the contact back to the database, returning
  # the database ID
  def save
    c = @data_object

    c.con_mail = mail.save

    if c.con_ship_to_mail

      c.con_ship = c.con_mail
      @ship = get_address(c.con_mail)

    else

      # if they were previously the same, but aren't now, force the
      # shipping address to we written out independently
      if ship.add_id == mail.add_id && ship.existing_record?
        ship.force_insert
      end

      c.con_ship = ship.save
    end

    if c.con_ship.nil?
      c.con_ship = c.con_mail
      c.con_ship_to_mail = true
    end

    super
  end

  #################################################################
  #
  #     A C C E S S O R S
  #

  def con_name
    @data_object.con_first_name.to_s +
      " " +
      @data_object.con_last_name.to_s
  end

  def name_given?
    @data_object.con_first_name && 
      !@data_object.con_first_name.empty? &&
    @data_object.con_last_name && 
      !@data_object.con_last_name.empty?
  end

  private

  def get_address(add_id)
    if add_id
      Address.with_id(add_id)
    else
      Address.new
    end
  end

end
