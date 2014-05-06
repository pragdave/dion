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

class OrderBase < Application
######################################################################

GET_USER = %{
<h2>Enter %type%</h2>

We're about to enter %type% on behalf of someone else. Enter
that person's e-mail address below to proceed. If the person doesn't
have an e-mail address, click the [NO EMAIL] button (but it really is a
lot, lot better if we can enter an e-mail address here...).
<p>
<form method="post" action="%form_url%">
<table>
<tr>#{Html.tag("User's e-mail")}
 <td>%input:email:40:200%</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr>#{Html.tag("or")}
 <td>[<a href="%no_email_url%">No E-Mail</a>] known.</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="submit" value=" PROCEED "></td></tr>
</table>
</form>
}

######################################################################

UPGRADE_PAGE = %{

<h2>Upgrade TeamPak</h2>
<form method="post" action="%done%">
<table>
!INCLUDE!
</table>
</form>
}

######################################################################

RENEW_PAGE = %{

<h2>Renew TeamPak</h2>
<form method="post" action="%done%">
<table>
!INCLUDE!
</table>
</form>
}


######################################################################

CHECK_CREATOR = %{

<h2>Renew TeamPak - Check Creator</h2>

<form method="post" action="%ok_url%">
<table class="small">
<tr>
  <td class="formtag">TeamPak:</td><td class="formval">%mem_name%</td>
  <td width="20">&nbsp;</td>
  <td class="formtag">Passport:</td><td class="formval">%full_passport%</td>
</tr>
<tr>
  <td class="formtag">School/org:</td><td class="formval">%mem_schoolname%</td>
  <td></td>
  <td class="formtag">Affiliate:</td><td class="formval">%aff_short_name%</td>
</tr>
<tr><td></td><td colspan="3"><hr></td></tr>
START:created_by
!INCLUDE!
END:created_by
<tr><td></td><td colspan="3"><hr></td></tr>
</table>

<p>

If the creator shown above is OK, click <a href="%ok_url%">HERE</a>.
<p>
If the creator is the correct person, but their details have changed,
click <a href="%edit_user_url%">HERE</a>.
<p>
If you need to change the creator to a different person, click
<a href="%change_url%">HERE</a>.
</form>
}

######################################################################

GET_NEW_CREATOR = %{
<h2>Enter New Creator</h2>

Enter the e-mail address of the new creator.
If the person doesn't
have an e-mail address, click the [NO EMAIL] button (but it really is a
lot, lot better if we can enter an e-mail address here...).
<p>
<form method="post" action="%form_url%">
<table>
<tr>#{Html.tag("User's e-mail")}
 <td>%input:email:40:200%</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr>#{Html.tag("or")}
 <td>[<a href="%no_email_url%">No E-Mail</a>] known.</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="submit" value=" PROCEED "></td></tr>
</table>
</form>
}

end

