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

class MaintainRoles < Application

######################################################################

SELECT_TARGET = %{

<h2>Select %what%</h2>

<form method="post" action="%form_url%">
Select %what%: %vsortddlb:an_id:options%
<p>
<input type="submit" value=" CONTINUE ">
</form>
}

######################################################################

MAINTAIN_SPECIFIC_ID = %{

<h2>%title%</h2>

<form method="post" action="%form_url%">
IF:existing_names

Remove existing users by clicking the [Remove] link to the right
of their name.
<p>
<table cellspacing="10">
START:existing_names
<tr>
  <td width="40">&nbsp;</td>
  <td><b>%name% (%user_name%)</b></td>
  <td><a href="%remove_url%">Remove</a></td>
</tr>
END:existing_names
</table>
ENDIF:existing_names

IF:new_names
<p>
Add new users by entering their e-mail address(es) below, then click
[MAKE CHANGES].
</p>
<p style="font-size: small">
<i>(To enter more than two users: enter the e-mail addresses of the first two below
enter, click [MAKE CHANGES], then enter the next two, and so
on. Putting it another way, 
you can enter as many users as you want here, but you have to do it two at
a time.)</p>
<p>
<table>
START:new_names
<tr>#{Html.tag("e-mail")}
  <td>%input:name_%i%:40:100%</td>
</tr>
END:new_names
</table>
ENDIF:new_names
<p>
<input type="submit" name="update" value=" MAKE CHANGES ">
<input type="submit" name="done"   value=" CANCEL ">
</form>

}

######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################

end
