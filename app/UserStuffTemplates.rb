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

class UserStuff < Application

######################################################################

SEARCH_PAGE = %{

<h2>Search For User</h2>
<p style="font-size: small">Fill in the fields below to tell the
system what you're looking for. For example, if you were looking for someone
called 'Bill' (or possibly 'William') in the West region, you could
enter 'ill' in the first-name field, and set the region field to
'West'. Because both Bill and William contain the text 'ill', the
search will find him whichever name he used.</p>

<p style="font-size: small">If your criteria match more than one
person, a list of those matches will be returned, and you can pick the
person you want from that list. Leave all the fields blank to return a
list of all users.</p>
<hr>
<form method="post" action="%done%">
<table>
!INCLUDE!
</table>
</form>
}

######################################################################

SEARCH_FOR_USER = %{

<h2>Search for User</h2>
<form method="post" action="%form_url%">

<table>
<tr>#{Html.tag("User e-mail")}
  <td>%input:user_email:40:200%</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td>
   <td><input type="submit" value=" SEARCH "></td>
</tr>
</table>
</form>
}


######################################################################

LIST_MATCHES = %{

<h2>Matching Users</h2>


The following users matched your criteria.
<p>

<table class="portalteamstable">
<tr>
  <th class="spread">Name</th>
  <th class="spread">EMail</th>
  <th class="spread">City</th>
  <th>State</th>
</tr>
START:list
<tr valign="top">
  <td><a href="%status_url%">%con_name%</a></td>
  <td>%con_email%</td>
START:mail_add
  <td>%M_add_city%</td>
  <td>%M_add_state%</td>
END:mail_add
</tr>
END:list
</table>

}

######################################################################

ROLE_DETAIL = %{
<table>
START:roles
<tr class="historyline">
<td class="spread">%name%</td>
<td class="spread">%affiliate%</td>
<td class="spread">%region%</td>
<td>%target_name%</td>
IF:viewer
<td><a href="%viewer%">%target_info%</a></td>
ENDIF:viewer
IFNOT:viewer
<td>%target_info%</td>
ENDIF:viewer
</tr>
END:roles
</table>
}
######################################################################

USER_INFORMATION = %{

<h2>User Information</h2>

<table>

<tr>
 #{Html.tag("Name")}
 <td class="formval">%con_name%</td>
</tr>

<tr>
 #{Html.tag("E-Mail (nickname)")}
 <td class="formval"><a href="mailto:%con_email%">%con_email%</a>
IF:user_acc_name
(%user_acc_name%)
ENDIF:user_acc_name
</td></tr>

<tr>
  #{Html.tag("Last logged in")}
  <td class="formval">%last_logged_in%</td>
</tr>

<tr>
  #{Html.tag("First logged in")}
  <td class="formval">%first_logged_in%</td>
</tr>

<tr>
  #{Html.tag("Default affiliate")}
  <td class="formval">%affiliate%</td>
</tr>

<tr>
  #{Html.tag("Default region")}
  <td class="formval">%region%</td>
</tr>

<tr>
 #{Html.tag("Telephone")}
 <td>
<span class="formval">%con_day_tel%</span>
IFNOTBLANK:con_eve_tel
&nbsp;&nbsp;<span class="formtag">Eve:</span>&nbsp;<span
    class="formval">%con_eve_tel%</span>
ENDIF:con_eve_tel
IFNOTBLANK:con_fax_tel
&nbsp;&nbsp;<span class="formtag">Fax:</span>&nbsp;<span
                  class="formval">%con_fax_tel%</span>
ENDIF:con_fax_tel
 </td>
</tr>

<tr valign="top">#{Html.tag("Mail/Ship")}
<td>
<table>
<tr valign="top"><td>
START:mail_add
%M_add_line1%<br>
IFNOTBLANK:M_add_line2
%M_add_line2%<br>
ENDIF:M_add_line2
%M_add_city%,
IFNOTBLANK:M_add_county
<br>%M_add_county% County,
ENDIF:M_add_county
%M_add_state% %M_add_zip%<br>
%M_add_country%
END:mail_add
</td>
<td width="15">&nbsp;</td>
<td>
START:ship_add
%S_add_line1%<br>
IFNOTBLANK:S_add_line2
%S_add_line2%<br>
ENDIF:S_add_line2
%S_add_city%,
IFNOTBLANK:S_add_county
<br>%S_add_county% County,
ENDIF:S_add_county
%S_add_state% %S_add_zip%<br>
%S_add_country%
END:ship_add
</td></tr>
</table>
</td>
</tr>
</table>


<table cellspacing="0" cellpadding="0" width="100%">
<tr class="portalnewstitlerow">
 <td class="portalnewstitlecell">Roles</td>
</tr>
</table>

IF:role_summary
<p class="small">This is a summary of your various roles. A
<a target="popup" href="%role_list%">complete list</a> is also available.</p>

<table class="historyline">
<tr><th>Role</th><th>Count</th></tr>
START:role_summary
<tr>
 <td>%role_name%</td><td align="right">%count%</td>
</tr>
END:role_summary
</table>
ENDIF:role_summary

IFNOT:role_summary
} + ROLE_DETAIL + %{
ENDIF:role_summary


<p>
<table cellspacing="0" cellpadding="0" width="100%">
<tr class="portalnewstitlerow">
 <td class="portalnewstitlecell">Recent Activity</td>
IF:extra_history
 <td class="portalnewstitleoptions">
   <a class="portaltitlelink" target="popup"
            href="%extra_history_url%">%extra_history%</a>
 </td>
ENDIF:extra_history
</table>

<table>
START:history_list
<tr class="historyline">
  <td class="spread">%uh_when%</td>
  <td class="spread">[%uh_inet%]</td>
  <td class="historynotes">%uh_notes%</td>
</tr>
END:history_list
</table>
<p>

IF:edit_user_url
<form method="post" action="%edit_user_url%">
<input type="submit" value=" EDIT USER'S DETAILS ">
</form>
&nbsp;
<form method="post" action="%change_pw_url%">
<input type="submit" value=" CHANGE USER'S PASSWORD ">
</form>
<p>
ENDIF:edit_user_url

IF:form_url
<form method="post" action="%form_url%">
<input type="submit" value=" FIND ANOTHER ">
</form>
ENDIF:form_url
}


######################################################################

FULL_USER_HISTORY = %{
<h2>Full User History</h2>

<table>
START:history_list
<tr class="historyline">
  <td class="spread">%uh_when%</td>
  <td class="spread">[%uh_inet%]</td>
  <td class="historynotes">%uh_notes%</td>
</tr>
END:history_list
</table>
}
######################################################################

ALL_ROLES = "<h2>All Roles</h2>" + ROLE_DETAIL

######################################################################
######################################################################
######################################################################
######################################################################

end