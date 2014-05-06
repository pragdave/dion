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

class MaintainSales < Application

SALES_PARAMETERS = %{

<h2>Sales Parameters</h2>

Use this form to update the extra charges associated with shipping
internationally and with heavy items (such as books).
<p>
<form method="post" action="%form_url%">

<table>
<tr>#{Html.tag("Canadian order surcharge")}
  <td>%input:sp_canada_surcharge:15:15%</td>
</tr>
<tr>#{Html.tag("International surcharge")}
  <td>%input:sp_intl_surcharge:15:15%</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td><td class="formexplain">Some items have 'stepped shipping', where the first
item is shipped for one fee, and subsequent ones for another, reduced,
fee. For example, in 2002/3, the shipping on books was $4 for the
first, and $2 for each subsequent. Use the fields below to set these
values.
</td></tr>

<tr>#{Html.tag("First item shipping")}
  <td>%input:sp_first_stepped_shipping:15:15%</td>
</tr>

<tr><td>&nbsp;</td></tr>
<tr>#{Html.tag("Remaining item shipping")}
  <td>%input:sp_rest_stepped_shipping:15:15%</td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr><td></td><td><input type="submit" value=" UPDATE "></td></tr>
</table>

</form>
}

end
