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

class RequestChange < Application

REQUEST_CHANGE = %{

<h2>Request Change to TeamPak</h2>

Requests to change the names
associated by a teampak must be approved centrally. Enter the changes
you'd like below and it will be processed as soon as possible.
<p>
<form method="post" action="%form_url%">
<table>

<tr>
  <td><b>TeamPak Name</b></td>
</tr>
<tr>#{Html.tag("Original value")}
  <td>%o_mem_name%</td>
</tr>
<tr>#{Html.tag("Change to")}
  <td>%input:mem_name:40:100%</td>
</tr>

<tr>
  <td><b>School Name</b></td>
</tr>
<tr>#{Html.tag("Original value")}
  <td>%o_mem_schoolname%</td>
</tr>
<tr>#{Html.tag("Change to")}
  <td>%input:mem_schoolname:40:100%</td>
</tr>

<tr>
  <td><b>School District</b></td>
</tr>
<tr>#{Html.tag("Original value")}
  <td>%o_mem_district%</td>
</tr>
<tr>#{Html.tag("Change to")}
  <td>%input:mem_district:40:100%</td>
</tr>

<tr>
  <td></td>
  <td><input type="submit" value=" REQUEST CHANGE "></td>
</tr>

</table>
</form>
}

######################################################################

LIST_PENDING = %{

<h2>Pending Changes</h2>

Here's a list of all changes requested by users. You can choose to
accept or deny one or more of them. Any that you leave will simply get
put back in the queue and will appear next time you access this list.
<p>
<form method="post" action="%form_url%">
<table>
START:list
<tr class="pctitle">
  <td colspan="2" class="spread">%cr_date_requested%</td>
  <td class="spread">%user%</td>
  <td>%mem_passport%</td>
  <td width="30">&nbsp;</td>
  <td rowspan="3">
    %radio:action_%i%:action_opts%
  </td>
</tr>
START:changes
<tr class="pcchange">
  <td width="20">&nbsp;</td>
  <td align="right"><i>%field%<i></td>
  <td align="right">from:&nbsp;</td><td>%from%</td>
</tr>
<tr class="pcchange">
  <td></td><td></td>
  <td align="right">to:&nbsp;</td><td>%to%</td>
</tr>
END:changes
<tr><td colspan="4"><hr></td></tr>
END:list
<tr><td>&nbsp;</td></tr>
<tr><td colspan="4"><input type="submit" value=" MAKE REQUESTED CHANGES "></tr></tr>
</table>

}
end