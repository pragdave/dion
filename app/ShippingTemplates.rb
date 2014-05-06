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

class Shipping < Application

######################################################################

SHIPPING_SUMMARY = %{
<h2>Shipping Summary</h2>

<form method="post" action="%ok_url%">
<table class="small" cellspacing="0" border="0">
<tr>
 <th colspan="4"></th>
 <th colspan="2" align="right">Ship?</th>
 <th>Label?</th>
<tr>

START:address_list
<tr class="palebackground">
  <td colspan="5"><b>%abbrev_ship_address%</b>
</b>
</td>
  <td></td>
  <td align="center">%check:check_label_%add_index%%</td>
</tr>
START:orders
<tr class="lesspalebackground">
  <td class="palebackground" width="20">&nbsp</td>
  <td>Order #%order_id%</td>
  <td>%fmt_sale_date%</td>
IF:full_passport
  <td colspan="2">%full_passport%</td>
ENDIF:full_passport

IFNOT:full_passport
  <td colspan="2"></td>
ENDIF:full_passport

  <td align="center">%check:check_ship_%order_id%%</td>
  <td></td>
</tr>
START:line_items
<tr style="font-size: x-small">
  <td class="palebackground"></td>
  <td colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;%li_qty% x&nbsp;%prd_long_desc%</td>
</tr>
END:line_items
<tr><td class="palebackground"></td></tr>
END:orders
<tr><td>&nbsp;</td></tr>
END:address_list
</table>
<p>
<input type="submit" value=" PRINT LABELS / PACKING LISTS ">
</form>

}


######################################################################

CONFIRM_SHIPPING = %{
<h2>Process Shipping</h2>

Follow the simple steps below to complete the shipping. (Remember to
scroll down, as this page might be long...)

<ol>
IF:label_url
<li><b>Print the labels you requested...</b>
<p>
<object
  classid="clsid:CA8A9780-280D-11CF-A24D-444553540000" 
  width="100%" height="200" id=Pdf1> 
      <param name="SRC" value="%label_url%">
      <embed src="%label_url%" height="200" width="100%">
      <noembed>Sorry - Couldn't load the labels</noembed>
</object>
<p>
If the labels do not appear above, click
<a target="report" href="%label_url%">here</a> to view them.
<p>
<hr>
<p>
ENDIF:label_url

IF:statements_url
<li><b>Print the packing slips...</b>
<p>
<object
  classid="clsid:CA8A9780-280D-11CF-A24D-444553540000" 
  width="100%" height="200" id=Pdf1> 
      <param name="SRC" value="%statements_url%">
      <embed src="%statements_url%" height="200" width="100%">
      <noembed>Sorry - Couldn't load the statements</noembed>
</object>
<p>
If the packing slips do not appear above, click
<a target="report" href="%statements_url%">here</a> to view them.
<p>
<hr>
<p>
ENDIF:statements_url


<li>Now we need to mark off those things that have been shipped. Put a
tick by each item actually shipped, then click the [UPDATE] button.
<p>
<form method="post" action="%update_url%">
<table class="small" cellspacing="0">
<tr>
 <th colspan="5"></th>
 <th>Shipped?</th>
<tr>

START:address_list
<tr class="palebackground">
  <td colspan="6" class="small"><b>%fmt_ship_address%</b></td>
</tr>
START:orders
<tr class="lesspalebackground">
  <td class="palebackground" width="20">&nbsp</td>
  <td>Order #%order_id%</td>
  <td>%fmt_sale_date%</td>
IF:full_passport
  <td colspan="2">%full_passport%</td>
ENDIF:full_passport

IFNOT:full_passport
  <td colspan="2"></td>
ENDIF:full_passport

  <td align="center">%check:check_ship_%order_id%%</td>
</tr>
START:line_items
<tr style="font-size: x-small">
  <td class="palebackground"></td>
  <td colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;%li_qty% x&nbsp;%prd_long_desc%</td>
</tr>
END:line_items
<tr><td class="palebackground"></td></tr>
END:orders
<tr><td>&nbsp;</td></tr>
END:address_list
</table>
<p>
<input type="submit" value=" UPDATE ">
</form>
</ul>
}

######################################################################

SHIPPING_REPORT_DATES = %{

<h2>Shipping Report</h2>

<form method="post" action="%form_url%">
<table>
  <tr><td class="formval">Start date:</td><td>%date:start%</td></tr>
  <tr><td class="formval">End date:</td><td>%date:end%</td></tr>
  <tr><td>&nbsp;</td></tr>
  <tr><td></td><td><input type="submit" value=" REPORT ">
</table>
</form>
}

######################################################################

SHIPPING_REPORT = %{

<h2>Shipped Items: %from% to %to%</h2>

<table class="small">
START:product_list
<tr class="palebackground">
 <td>%prd_sku%</td><td colspan="4"><b>%prd_long_desc% @
 $%prd_price% ea.</b></td></tr>
</tr>
<tr align="left" style="font-size: x-small">
 <th>Ship date</th>
 <th>User's Name</th>
 <th>Order</th>
 <th>Order date</th>
 <th>Qty</th>
</tr>
START:lines
<tr>
 <td>%fmt_date_shipped%</td>
 <td>%user%</td>
 <td><a href="%order_url%">Order #%order_id%</a></td>
 <td>%order_date%</td>
 <td align="right">%qty%</td>
</tr>
END:lines
<td><td colspan="4" align="right"><b>Total items shipped: %count%</td></tr>
<td><td colspan="4" align="right"><b>Total value shipped<sup>*</sup>: $%ts%</td></tr>
<tr height="30"><td>&nbsp;</td></tr>

END:product_list

</table>
<p class="small"><sup>(*)</sup>Calculated as units shipped times today's unit price.</p>

IF:not_used
<p>&nbsp;<p>&nbsp;<p>
The following orders contained items that were shipped:
<p>
<table class="small">
<tr align="right">
 <th align="left">Order</th>
 <th>Total</th>
 <th colspan="2">Ship+Intl</td>
 <th>Grand Total</th>
</tr>

START:order_list
<tr align="right">
 <td align="left"><a name="order%order_id%"><a
 href="%order_url%">Order
       #%order_id%</a></a></td>
 <td>$%total%</td>
 <td>$%shipping%</td>

IF:intl_surcharge
  <td>$%intl_surcharge%</td>
ENDIF:intl_surcharge

IFNOT:intl_surcharge
  <td></td>
ENDIF:intl_surcharge

  <td>%grand_total%</td>
</tr>
START:pays
<tr style="color: green">
  <td></td>
  <td>%label%</td>
  <td>%short_type% %pay_doc_ref%</td>
  <td>%fmt_processed%</td>
  <td align="right">%pay_amount%</td>
</tr>
END:pays

<tr><td></td></tr>
END:order_list

ENDIF:not_used

</table>

<p>
<hr>
<table class="small">
   <tr><td>Total net:</td><td align="right">$%total_net%</td></tr>
<!--   <tr><td>Total affiliate fees:</td><td
align="right">$%total_aff_fee%</td></tr> -->
<!--   <tr><td>Total gross:</td><td
align="right">$%total_order%</td></tr> -->
   <tr><td>Total ship/surcharge:</td><td align="right">$%total_ship%</td></tr>
<!--   <tr><td>Grand total:</td><td align="right">$%grand_total%</td></tr>-->
</table>
<hr>
<i class="small">Note that these figures are totals for
the items shipped, and do
not necessarily represent money actually received by DI (as some items
may have been force-shipped). These
figures should not be used for
accounting purposes</i>
}
end
