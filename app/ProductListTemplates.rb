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

class ProductList < Application

PRODUCT_LIST = %{

<h2>All Products</h2>

<table style="font-size:small">
START:list

<tr>
IF:prd_is_active
 <td style="color: #00a000" class="underline">
ENDIF:prd_is_active
IFNOT:prd_is_active
 <td style="color: #a00000" class="underline">
ENDIF:prd_is_active
    <b>%prd_sku%&nbsp;&nbsp;</b>
</td>
<td colspan="3"  class="underline"><b>%prd_long_desc% [%prd_short_desc%]</b></td>
<td align="right"  class="underline"><b>$%prd_price%</b></td>
</tr>

<tr>
 <td></td>
 <td class="formtag">Type:</td><td> %type%</td>
</tr>

<tr>
 <td></td>
 <td class="formtag">Active:</td>
 <td>
IF:prd_is_active
 Yes
ENDIF:prd_is_active
IFNOT:prd_is_active
 No
ENDIF:prd_is_active
 </td>
</tr>

<tr>
 <td></td>
 <td class="formtag">Markup:</td>
  <td>
IF:prd_aff_can_markup
 Affiliate can markup
ENDIF:prd_aff_can_markup
IFNOT:prd_aff_can_markup
 Affiliate can not markup
ENDIF:prd_aff_can_markup
 </td>
</tr>

<tr>
 <td></td>
 <td class="formtag">Show on:</td><td>%showon%</td>
</tr>

<tr>
 <td></td>
 <td class="formtag">Available:</td><td>%available%</td>
</tr>

<tr>
 <td></td>
 <td class="formtag">Ship fees:</td><td>%shipping%</td>
</tr>

<tr><td>&nbsp;</td></tr>
END:list
</table>
}

end
