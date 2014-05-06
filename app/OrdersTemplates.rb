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

class Orders < Application

IDENTIFY_ORDER = %{
<h2>Identify Order</h2>

Please specify the order number to be %action%.
<p>
<form method="post" action="%done_url%">
Order number: %input:order_id:20:20%
<p>
<input type="submit" value=" FIND ORDER ">
</form>
}

######################################################################

CONFIRM_DELETE = %{
<h2>Confirm Delete Order</h2>
You are about to delete the following Order:<p>

<table>
<tr>#{Html.tag("Order")}
  <td class="formval">#%order_id%</td>
</tr>

<tr>#{Html.tag("Date")}
  <td class="formval">%fmt_order_date%</td>
</tr>

IFNOTBLANK:order_passport
<tr>#{Html.tag("Passport")}
  <td class="formval">%order_passport% (%order_school%)</td>
</tr>
ENDIF:order_passport

<tr>#{Html.tag("Line items")}</tr>

START:product_list
<tr><td></td>
<td>&bull;&nbsp;%desc%</td><td>%status%</td><td align="right">$%price%</td>
</tr>
END:product_list

<tr>#{Html.tag("Grand total")}
  <td></td><td></td><td class="formval" align="right">$%grand_total%</td>
</tr>

</table>

<p>
<table>
<tr valign="top"><td>Do you want to delete this order?</td>
<td>
  <form method="post" action="%confirm_delete%">
  <input type="submit" value=" YES ">
  </form>
</td>
<td>
  <form method="post" action="%dont_delete%">
  <input type="submit" value=" NO ">
  </form>
</td>
</tr>
</table

}

######################################################################

EDIT_PAYMENT = %{
<h2>Edit Payment</h2>

Please use this form only to correct errors in the information entered
about a payment. If, for example, the original check was for too much
money, then this screen should not be used. Instead a refund should be
issued.
<p>
<form method="post" action="%done_url%">
<table>

<tr>#{Html.tag("Tracking no.")}
  <td>%input:pay_our_ref:20:40%</td>
</tr>

<tr>#{Html.tag("Their ref")}
  <td>%input:pay_doc_ref:20:40%</td>
</tr>

<tr>#{Html.tag("Payor")}
  <td>%input:pay_payor:40:40%</td>
</tr>

<tr>#{Html.tag("Amount")}
  <td>%input:pay_amount:20:20% (must not be less that $%fmt_amount_applied%)</td>
</tr>

<tr>#{Html.tag("Ship address")}
  <td>%text:pay_ship_address:60:6%</td>
</tr>

<tr><td>&nbsp;</td></tr>

IFNOTBLANK:pay_paying_check_our_ref

<tr><td colspan="2">The following fields contain information about the
check that was used to pay this purchase order.</td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr>#{Html.tag("Check track no.")}
  <td>%input:pay_paying_check_our_ref:20:40%</td>
</tr>

<tr>#{Html.tag("Check number")}
  <td>%input:pay_paying_check_doc_ref:20:40%</td>
</tr>

<tr>#{Html.tag("Check payor")}
  <td>%input:pay_paying_check_payor:40:40%</td>
</tr>

<tr><td>&nbsp;</td></tr>

ENDIF:pay_paying_check_our_ref

</table>

<input type="submit" value=" UPDATE ">

</form>

<form method="post" action="%cancel_url%">
  <input type="submit" value=" CANCEL ">
</form>

}

######################################################################

GET_ADJUSTMENT = %{

<h2>Adjust Order Total</h2>

<table>
<tr>#{Html.tag("Order")}
  <td class="formval">#%order_id%</td>
</tr>

<tr>#{Html.tag("Date")}
  <td class="formval">%fmt_order_date%</td>
</tr>

IFNOTBLANK:order_passport
<tr>#{Html.tag("Passport")}
  <td class="formval">%order_passport% (%order_school%)</td>
</tr>
ENDIF:order_passport

<tr>#{Html.tag("Line items")}</tr>

START:product_list
<tr><td></td>
<td>&bull;&nbsp;%desc%</td><td>%status%</td><td align="right">$%price%</td>
</tr>
END:product_list

<tr>#{Html.tag("Grand total")}
  <td></td><td></td><td class="formval" align="right">$%grand_total%</td>
</tr>

</table>
<p>
<b>Enter details of the adjustment:</b>
<p>
<form method="post" action="%adjust_url%">
START:adjustment
<table>
<tr>#{Html.tag("Reason")}<td colspan="2">%input:reason:40:100%</td></tr>
<tr>#{Html.tag("Amount")}<td>%input:amount:10:10%</td>
<td class="small">A negative adjustment reduces the order total, a positive
adjustment increases it.</td>
</tr>
<tr><td></td><td><input type="submit" value=" ADJUST ORDER " /></td></tr>
</table>
END:adjustment
</form>

}
end
