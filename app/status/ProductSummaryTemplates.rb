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

class ProductSummary < Application

######################################################################

PRD_INFO = %{

 <td>%prd_long_desc%</td>
 <td align="right" class="spread">$%fmt_base_price%</td>
IF:prd_aff_can_markup 
 <td align="right" class="spread">$%fmt_markup_price%</td>
ENDIF:prd_aff_can_markup 
IFNOT:prd_aff_can_markup 
 <td></td>
ENDIF:prd_aff_can_markup 
 <td align="right">$%fmt_total_price%</td>
}

######################################################################

PRODUCT_LIST = %{
<h2>List of Available Products</h2>

<table style="font-size: small">

<tr>
 <th align="left">Description</th>
 <th align="right" class="spread">Base<br>Price</th>
 <th align="right" class="spread">Affiliate<br>Fee</th>
 <th align="right">Total<br>Price</th>
</tr>

START:prd_list
<tr>
} + PRD_INFO + %{
</tr>
END:prd_list
</table>
}

######################################################################

AFFILIATE_PRODUCT_LIST = %{

<h2>Affiliate Product Fees</h2>

<table style="font-size: small">
START:aff_list
<tr><td colspan="5"><b>%aff_long_name%</b></td></tr>

START:prd_list
<tr>
 <td width="20">&nbsp;</td>
} +
PRD_INFO +
%{
</tr>
END:prd_list

<tr><td>&nbsp;</td></tr>
END:aff_list
</table>
}

######################################################################

SALES_SUMMARY = %{
<h2>Sales Sumary</h2>

<p class="small">Breakdown of all orders by product.</p>
<table style="font-size: small">
<tr>
 <th>Description</th>
 <th>Qty</th>
 <th>Aff fee</th>
 <th>Total</th>
</tr>
START:list
<tr>
 <td>%desc%</td>
 <td align="right">%qty%</td>
 <td align="right">$%aff%</td>
 <td align="right">$%amt%</td>
</tr>
END:list
</table>

<p><hr><p class="small">Where the money is:</p>
<table class="small">
START:products
<tr><td>%type%</td><td align="right">$%amount%</td><td align="right">%pct%%</td></tr>
END:products
<tr><td>Shipping</td><td align="right">$%shipping%</td><td align="right">%shipping_pct%%</td></tr>
<tr><td>Intl. surcharge</td><td align="right">$%intl_surcharge%</td><td align="right">%intl_pct%%</td></tr>
<tr><td align="right"><b>TOTAL</b></td><td align="right">$%grand_total%</td></tr>

</table>
}

end

