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

require "web/View"

class AddressView < View

  def initialize(prefix = "ADD")
    @prefix = prefix
  end

  def from_db(id)
#    @contact = Contact.with_id(id)
  end

  def to_db
#    @contact.save  # returns ID
  end

  def to_form(address, in_own_table=false)

    res = ""

    e = Html::Echoer.new(@prefix, res, address)

    e.echo "<table>" if in_own_table
    $stderr.puts ">>>>>> #{address.inspect}"
    e.text_row("Address line 1:",        :add_line1,   40, 100)
    e.text_row("Address line 2:",        :add_line2,   40, 100)
    e.text_row("City:",                  :add_city,    40, 100)
    e.text_row("State/Province/Region:", :add_state,   20, 20)
    e.text_row("Zip/postal code:",       :add_zip,     12, 12)
    e.text_row("Country:",               :add_country, 40, 100)
    e.echo("</td></tr>\n")

    e.echo "</table>" if in_own_table

    res
  end

  def from_form(contact)
    if false
    f = Html::FormGetter(@prefix)

    contact.con_id      = f.get(:con_id)
    contact.con_name    = f.get(:con_name)
    contact.con_day_tel = f.get(:con_day_tel)
    contact.con_eve_tel = f.get(:con_eve_tel)
    contact.con_fax     = f.get(:con_fax)
    contact.con_email   = f.get(:con_email)

    contact.con_mail    = @mail_address_view.from_form(AddressTable.new)
    contact.con_ship    = @ship_address_view.from_form(AddressTable.new)

    contact.con_id
    end
  end
    
end
