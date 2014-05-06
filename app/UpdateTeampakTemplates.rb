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

class UpdateTeampak < Application

#######################################################################


UPDATE_TEAMPAK= %{
<h2>Update TeamPak Information</h2>


<form method="post" action="%form_target%">
<table cellspacing="0" cellpadding="0">

<tr><td></td><td class="formexplain">Use this form to update the
details of a TeamPak. You won't be able to change the teampak type,
nor any ordered products, if this TeamPak has had payments applied to
it or goods shipped.</td></tr>

<tr><td>&nbsp</td></tr>

<tr>#{Html.tag("Passport name")}
     <td>%input:mem_name:30:100%</td></tr>

<tr>#{Html.tag("School/organization name")}
    <td>%input:mem_schoolname:30:100%</td></tr>

<tr>#{Html.tag("School district/authority")}
    <td>%input:mem_district:30:100%</td></td>

<tr><td>&nbsp;</td></tr>

<tr>#{Html.tag("Creator e-mail")}<td>%input:creator_email:30:100% (%creator_name%)</td></tr>
<tr><td>&nbsp;</td></tr>

START:contact
<tr>#{Html.tag("Contact e-mail")}<td>%input:con_email:30:100% (%con_name%)</td></tr>
<tr><td>&nbsp;</td></tr>
END:contact

IFNOT:order_fixed
<tr><td>&nbsp;</td></tr>
<tr>#{Html.tag("TeamPak type")}<td>%radio:mem_type:mem_type_opts%
<span style="font-size:small"><i>(price may include affiliate fees)</i></span></td></tr>
<tr><td>&nbsp;</td></tr>

IF:other_products
<tr>#{Html.tag("Other services")}
 <td>
   <table>
     <tr class="groupline">
       <th>Qty</th>
       <th>Description</th>
       <th>Price</th>
     </tr>
START:other_products
     <tr class="groupline"><td><input type="text" name="prd_qty_%index%"
              value="%qty%" size="3" maxsize="3" />
             <input type="hidden" name="prd_id_%index%" value="%prd_id%" /></td>
         <td class="spread">%desc%</td>
         <td class="spread" align="right">%price%</td>
     </tr>
END:other_products
   </table>
 </td>
</tr>
ENDIF:order_fixed


<tr><td>&nbsp;</td></tr>

<tr><td></td>
    <td><input type="submit" value=" UPDATE TEAMPAK "></td>
</tr>


</table>
</form>

<p>
IF:order_fixed
You cannot change the TeamPak type or any other ordering details
associated with this TeamPak because %order_fixed%.
ENDIF:order_fixed


IF:orders
<h3>This TeamPak's Order</h3>

<p class="formexplain">If you want to change both the details
<b>and</b> the order details, you'll need to do it in two steps. First
change the details and click [UPDATE TEAMPAK], then come back to this
screen and change the order</p>

<table class="portalordertable">
START:orders
<form method="post" action="%change_order_url%">
<tr>
  <td>%fmt_order_date%</td>
  <td class="portalordercell">%order_passport%</td>
  <td class="portalordercell">Order #%order_id%</td>
  <td></td>
  <td colspan="2" align="right"><input type="submit" value=" CHANGE ORDER "></td>
</tr>
</form>
START:product_list
<tr>
  <td></td><td class="portalordercell" colspan="2">&bull; %fmt_desc%</td>
  <td align="right">$%price%</td>
</tr>
END:product_list
IF:intl_surcharge
<tr>
  <td></td><td class="portalordercell" colspan="2">&bull; International dispatch</td>
  <td align="right">$%intl_surcharge%</td>
</tr>
ENDIF:intl_surcharge
<tr>
  <td></td><td class="portalordercell" colspan="2">&bull; Shipping</td>
  <td align="right">$%shipping%</td>
  <td></td>
  <td class="totalcell">$%grand_total%</td>
</tr>
<tr><td>&nbsp;</td></tr>
END:orders
</table>
ENDIF:orders

}
end

