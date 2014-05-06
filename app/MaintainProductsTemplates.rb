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

class MaintainProducts < Application

MAINTAIN_PRODUCTS = %{
<h2>Maintain Products</h2>
<p>
<table>
<tr>
 <th>Active?</th>
 <th>SKU</th>
 <th>Description</th>
</tr>
START:list
<tr>
  <td>%active%</td>
  <td class="spread">%prd_sku%</td>
  <td class="spread">%prd_long_desc%</td>
  <td><a href="%edit_url%">Edit</a></td>
</tr>
END:list
<tr><td>&nbsp;</td></tr>
<tr><td></td><td>
<form method="post" action="%form_url%">
<input type="submit" value=" ADD NEW PRODUCT ">
</form>
</table>
}

######################################################################

EDIT_PRODUCT = %{

<H2>Edit Product</h2>

<form method="post" action="%form_url%">
<table>
<tr>#{Html.tag("Product category")}
  <td>%radio:prd_type:prd_type_opts%</td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr>#{Html.tag("Short description")}
  <td>%input:prd_short_desc:20:20%</td>
</tr>

<tr>#{Html.tag("Long description")}
  <td>%input:prd_long_desc:40:100%</td>
</tr>

<tr>#{Html.tag("SKU")}
  <td>%input:prd_sku:20:20%</td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr>#{Html.tag("Product is active")}
  <td>%check:prd_is_active%</td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr>#{Html.tag("Price")}
  <td>
     %input:prd_price:20:20%<br>
     <label>%check:prd_aff_can_markup% Affiliate can mark up</label>
  </td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr>#{Html.tag("Availability")}
  <td>
     <label>%check:prd_available_in_us% Available to customers in the
     US</label><br>
     <label>%check:prd_available_intl% Available internationally</label>
  </td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr>#{Html.tag("Where listed")}
  <td>
     <label>%check:prd_show_on_app% On TeamPak application</label><br>
     <label>%check:prd_show_general% On general order form</label><br>
     <label>%check:prd_show_tournament% On AD/RD order form</label>
  </td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr>#{Html.tag("Shipping surcharges")}
  <td>
     <label>%check:prd_use_stepped_shipping% Use stepped shipping
     rates</label><br>
     <label>%check:prd_use_intl_surcharge% Apply international surcharge</label>
  </td>
</tr>

<tr>#{Html.tag("ACTIONS")}
  <td>MISSING</td>
</tr>

<tr><td></td><td><input type="submit" value=" UPDATE "></td></tr>
</table>
</form>
}
end
