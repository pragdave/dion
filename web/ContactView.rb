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

require 'bo/Address'
require "web/View"
require "web/AddressView"

class ContactView < View

  def initialize(prefix = "CON")
    @prefix = prefix
    @mail_address_view = AddressView.new("MAD")
    @ship_address_view = AddressView.new("SAD")
  end

  def from_db(id)
    @contact = Contact.with_id(id)
    @mail_address_view.from_db(@contact.con_mail)
    @ship_address_view.from_db(@contact.con_ship)
  end

  def to_db
    @contact.con_mail = @mail_address_view.to_db
    @contact.con_ship = @ship_address_view.to_db
    @contact.save  # returns ID
  end

  def to_form(contact, in_own_table = false)
    $stderr.puts("!!!!! #{contact.con_mail}")
    res = ""
    e = Html::Echoer.new(@prefix, res, contact)

    e.echo "<table>" if in_own_table
    
    e.text_row("Name",            :con_name,    40, 100, Html::Required)

    e.echo("<tr><td class=\"formtag\">Telephone -- Day:</td><td>")
    e.simple_input(               :con_day_tel, 14, 20)

    e.echo("&nbsp; Night: ")
    e.simple_input(               :con_eve_tel, 14, 20)
    e.echo("</td></tr>\n")

    e.text_row("Fax:",            :con_fax_tel, 14, 20)
    e.text_row("E-mail address:", :con_email,   30, 60, Html::Required)
    
    $stderr.puts("??? #{contact.con_mail}")
    mail_add = Address.with_id(contact.con_mail)
    add_html = AddressView.new.to_form(mail_add)

    e.echo(add_html)

#    ship_add = Address.with_id(contact.con_ship)
#    AddressView.new.to_form(ship_add, sink)

    e.echo "</table>" if in_own_table
    
    res
  end

  def from_form(contact)
    f = Html::FormGetter(@prefix)

    contact.con_id      = f.get(:con_id)
    contact.con_name    = f.get(:con_name)
    contact.con_day_tel = f.get(:con_day_tel)
    contact.con_eve_tel = f.get(:con_eve_tel)
    contact.con_fax     = f.get(:con_fax_tel)
    contact.con_email   = f.get(:con_email)

    contact.con_mail    = @mail_address_view.from_form(AddressTable.new)
    contact.con_ship    = @ship_address_view.from_form(AddressTable.new)

    contact.con_id
  end
    
end
