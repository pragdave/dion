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

class TeamPaks < Application

SEARCH_PAGE = %{

<h2>Search For TeamPak</h2>

<form method="post" action="%done%">
<table>
!INCLUDE!
</table>
</form>
}

######################################################################

LIST_MATCHES = %{

<h2>Search Results</h2>

The following TeamPaks matched your criteria.
<p>

<table class="portalteamstable">
<tr>
  <th class="spread">Passport</th>
  <th class="spread">TeamPak Name</th>
  <th class="spread">Contact</th>
  <th class="spread">City</th>
  <th>Status</th>
</tr>
START:list
<tr valign="top">
  <td>%full_passport%</td>
IF:status_url
  <td><a href="%status_url%">%mem_name%</a></td>
ENDIF:status_url
IFNOT:status_url
  <td>%mem_name%</td>
ENDIF:status_url
START:contact
  <td>%con_last_name%</td>
START:mail_add
  <td>%M_add_city%</td>
END:mail_add
END:contact
  <td>%mem_state%</td>
</tr>
END:list
</table>
}

######################################################################

DELETE_PAGE = %{

<h2>Delete TeamPak</h2>
<form method="post" action="%done%">
<table>
!INCLUDE!
</table>
</form>
}

######################################################################

CONFIRM_DELETE = %{

<h2>Confirm Delete</h2>

You are about to delete this TeamPak and its associated orders. Once
deleted, the TeamPak and its orders will be lost forever. They will be
gone. They will be no more. You'll have to type them in again if you
delete one by mistake. So, check the details below before hitting the
button...

<hr>

!INCLUDE!

!INCLUDE!

<p>
<form method="post" action="%do_delete%">
 <input type="submit" value=" DELETE TEAMPAK FOREVER ">
</form>
}


######################################################################


ALTER_FIND = %{

<h2>Alter TeamPak</h2>
<form method="post" action="%done%">
<table>
!INCLUDE!
</table>
</form>
}

######################################################################

ALTER_TEAMPAK = %{

<h2>Alter TeamPak</h2>

<form method="port" action="%do_alter%">
<table>
<tr>#{Html.tag("Passport name")}
    <td>%input:mem_name:30:100%</td>
</tr>

<tr>#{Html.tag("School/organization name")}
     <td>%input:mem_schoolname:30:100%</td>
</tr>

<tr>#{Html.tag("School district/authority")}
     <td>%input:mem_district:30:100%</td>
</tr>

<tr><td>&nbsp;</td></tr>
<tr><td></td>
    <td><input type="submit" value=" ALTER TEAMPAK "></td>
</tr>
</table>
</form>

}

end
