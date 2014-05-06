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

# -*- text -*-

require "web/Html"

class MaintainAffiliates < Application

######################################################################

MAINTAIN_AFFILIATES = %{
<h2>Maintain Affiliates</h2>

<form method="post" action="%form_url%">
Either:
<ul>
<li><input type="submit" name="create" value=" CREATE "> a new affiliate,
or</li>
<p>
<li><input type="submit" name="edit" value=" EDIT "> details for
affiliate: %ddlb:aff_id:aff_opts%</li>
</ul>
</form>
}

######################################################################

EDIT_AFFILIATE = %{

<h2>Edit Affiliate Information</h2>

<form method="post" action="%form_url%">
<table>
<tr>#{Html.tag("Short name")}
   <td>%input:aff_short_name:20:20%</td>
</tr>

<tr>#{Html.tag("Long name")}
   <td>%input:aff_long_name:40:100%</td>
</tr>

<tr>#{Html.tag("Three digit passport prefix")}
   <td>%input:aff_passport_prefix:3:3%</td>
</tr>

<tr>#{Html.tag("Number of digits after the '-'")}
   <td>%input:aff_passport_length:1:1%</td>
</tr>

<tr>#{Html.tag("Options")}
  <td>
    <label>%check:aff_has_regions% Affiliate has regions</label><br>
    <label>%check:aff_in_canada% Affiliate is in Canada</label><br>
    <label>%check:aff_is_foreign% Affiliate is foreign</label><br>
    <label>%check:aff_is_sa% Affiliate is self-administered</label>
  </td>
</tr>

<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="submit" value=" UPDATE ">
</table>
</form>

}

######################################################################
######################################################################
######################################################################
######################################################################

end
