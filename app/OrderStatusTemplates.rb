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
class OrderStatus < Application

######################################################################

FIND_ORDER = %{
<h2>Find Order</h2>

Enter either the order number, a user's e-mail address or a teampak
passport below.
<p>
<form method="post" action="%form_url%">
<table>

<tr>#{Html.tag("Order number")}
  <td>%input:order_id:10:10%</td>
</tr>

<tr>#{Html.tag("Passport")}
  <td>%input:passport:10:10%</td>
</tr>

<tr>#{Html.tag("User e-mail")}
  <td>%input:user_email:40:200%</td>
</tr>

<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="submit" value=" FIND ORDER "></td></tr>

</table>
</form>
}

######################################################################



ORDER_STATUS = %{
<h2>Status For Order #%order_id%</h2>

<table>
<tr valign="top">
  #{Html.tag("Date ordered")}<td class="formval">%fmt_order_date%</td>
  <td colspan="3" rowspan="6">
  <table border="0" cellspacing="0" cellpadding="0">
    <tr>#{Html.tag("by")}
      <td class="formval">
IFNOTBLANK:con_email
<a href="mailto:%con_email%">%con_email%</a><br>
ENDIF:con_email
%con_name%<br>
START:mail_add
%M_add_line1%<br>
%M_add_city%, %M_add_zip%, %M_add_state%<br>
%M_add_country%
END:mail_add
      </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>#{Html.tag("ship to")}
      <td class="formval">%fmt_ship_address%
IF:order_ship_add_changed
<br><span style="font-size:small; color: #702020">(Updated from P.O. details)</span>
ENDIF:order_ship_add_changed
      </td>
    </tr>
  </table>
  </td>
</tr>

IFNOTBLANK:order_passport
<tr>#{Html.tag("Passport")}<td class="formval">%order_passport%</td></tr>
<tr>#{Html.tag("TeamPak name")}<td class="formval">%order_mem_name%</td></tr>
ENDIF:order_passport

<tr>#{Html.tag("Status")}<td class="formval">%order_status%</td></tr>
<tr>#{Html.tag("Order total")}<td class="formval">$%grand_total%</td></tr>
<tr>#{Html.tag("Left to pay")}<td class="formval">$%left_to_pay%</td></tr>
<tr>#{Html.tag("Settled")}<td class="formval">$%settled%</td></tr>
<tr>#{Html.tag("Original doc ref")}<td
class="formval">%their_ref%</td></tr>

<tr><td>&nbsp;</td></tr>

<tr><td colspan="2"><a href="%print_statement%">Generate Statement</a></td></tr>

<tr><td>&nbsp;</td></tr>

<tr><td colspan="6" class="simpletableheader">Order Contents</td></tr>
START:product_list
<tr class="portalordertable">
  <td class="portalordercell" colspan="2">&bull; %fmt_desc%</td>
  <td align="right">$%price%</td>
  <td class="portalorderstatus" colspan="2">%status%</td>
IF:total_aff_fee
  <td class="portalordercell">(inc. $%total_aff_fee% aff. fee)</td>
ENDIF:total_aff_fee
</tr>
END:product_list
IF:intl_surcharge
<tr class="portalordertable">
  <td class="portalordercell" colspan="2">&bull; International dispatch</td>
  <td align="right">$%intl_surcharge%</td>
</tr>
ENDIF:intl_surcharge
<tr class="portalordertable">
  <td class="portalordercell" colspan="2">&bull; Shipping</td>
  <td align="right">$%shipping%</td>
  <td></td>
  <td class="totalcell">$%grand_total%</td>
</tr>

IF:pays_list
<tr><td>&nbsp;</td></tr>

<tr><td colspan="5" class="simpletableheader">Payment Details</td></tr>
</table>

<table style="font-size: small">
<tr>
 <th>Date</th>
 <th class="spread">Their ref</th>
 <th class="spread">Trk. no</th>
 <th class="spread">Payor</th>
 <th class="spread" align="right">Payment<br>total</th>
 <th align="right">Amount<br>Applied</th>
</tr>
START:pays_list
<tr>
  <td class="spread">%fmt_processed%</td>
  <td class="spread"><a href="%payment_url%">%ref%</a></td>
  <td align="right" class="spread">%pay_our_ref%</td>
  <td class="spread">%pay_payor%</td>
  <td align="right" class="spread">$%fmt_total_amt%</td>
  <td align="right">$%fmt_applied_amt%</td>
</tr>
END:pays_list

ENDIF:pays_list
</table>

}

######################################################################

ORDER_LIST = %{

<h2>Matching Orders</h2>
Click on the order number to see the details.
<p>
<table style="font-size: small">
<tr>
  <th>Date</th>
  <th>Order</th>
  <th>TeamPak</th>
  <th>Total</th>
  <th>Status</th>
</tr>
START:list
<tr style:"font-size: small">
 <td class="spread">%fmt_order_date%</td>
 <td class="spread"><a href="%order_url%">Order #%order_id%</a></td>
 <td class="spread">%order_passport%</td>
 <td align="right" class="spread">$%grand_total%</td>
 <td>%order_status%</td>
</tr>
<tr style="font-size: x-small">
 <td></td>
 <td colspan="3">
START:product_list
&bull;&nbsp;%desc%<br>
END:product_list
 </td>
</tr>
<tr style="font-size: x-small"><td>&nbsp;</td></tr>
END:list
</table>
}

######################################################################      

PARTIALLY_PAID_ORDERS = %{

<h2>All Partially Paid Orders</h2>

!INCLUDE!
}

PARTIALLY_PAID_SHIPPED = %{
<h2>Shipped Partially Paid Orders</h2>

!INCLUDE!

<form action="%dun_url%" method="post">
(optional)
<p>
Generate statements for orders shipped more than
%input:days_ago:3:3% days ago.
<p>
<input type="submit" value=" GO ">
</form>
}


PARTIALLY_PAID_COMMON = %{
Click on the order number to see the details.
<p>
<table style="font-size: small">
<tr>
  <th>Date</th>
  <th>Order</th>
  <th>TeamPak</th>
  <th>Total</th>
  <th>Status</th>
</tr>
START:list
<tr style:"font-size: small">
 <td class="spread">%fmt_order_date%</td>
 <td class="spread"><a href="%order_url%">Order #%order_id%</a></td>
 <td class="spread">%order_passport%</td>
 <td align="right" class="spread">$%grand_total%</td>
 <td>%order_status%</td>
IF:force_url
 <td>&nbsp;&nbsp;<a href="%force_url%">Force ship</a>
ENDIF:force_url
IFNOT:force_url
 <td>&nbsp;&nbsp;<i>Shipping</i></a>
ENDIF:force_url
</tr>
<tr style="font-size: x-small">
 <td></td>
 <td colspan="3">
START:product_list
&bull;&nbsp;%desc%<br>
END:product_list
 </td>
</tr>
<tr style="font-size: x-small"><td>&nbsp;</td></tr>
END:list
</table>
}

######################################################################

SHOW_STATEMENT = %{
<h2>Order Statement</h2>

Your statement should appear in the box below (this requires that you
have Adobe Acrobat installed on your computer. Click
<a HREF="http://www.adobe.com/products/acrobat/readstep.html">here</a>
to install it if nothing appears).
<p>
<object
  classid="clsid:CA8A9780-280D-11CF-A24D-444553540000" 
  width="100%" height="200" id=Pdf1> 
      <param name="SRC" value="%stmt_url%">
      <embed src="%stmt_url%" height="200" width="100%">
      <noembed>Sorry - Couldn't load the labels</noembed>
</object>
<p>
If the statement does not appear above, click
<a target="report" href="%stmt_url%">here</a> to view it.
<p>
To print the statement, click on the small icon of the printer in the
title bar of the box above. Do not use your browser's File|Print menu
option, or you'll lose some of the statement.
}

end
