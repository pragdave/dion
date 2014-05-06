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

class Payments < Application

IDENTIFY_PAYMENT = %{
<h2>Identify Payment</h2>

Please specify the tracking number of the payment to be %action%.
<p>
<form method="post" action="%done_url%">
Tracking number: %input:our_ref:20:20%
<p>
<input type="submit" value=" FIND PAYMENT ">
</form>
}

######################################################################

CONFIRM_DELETE = %{
<h2>Confirm Delete Payment</h2>
You are about to delete the following payment:<p>

<table>
<tr>#{Html.tag("Payment")}
  <td class="formval">%short_type% #%pay_doc_ref%</td>
</tr>

<tr>#{Html.tag("Tracking no.")}
  <td class="formval">%pay_our_ref%</td>
</tr>

<tr>#{Html.tag("Payor")}
  <td class="formval">%pay_payor%</td>
</tr>

<tr>#{Html.tag("Date")}
  <td class="formval">%fmt_processed%</td>
</tr>

<tr>#{Html.tag("Amount")}
  <td align="right" class="formval">$%pay_amount%</td>
</tr>

<tr>#{Html.tag("Applied")}
  <td align="right" class="formval">$%fmt_amount_applied%</td>
</tr>

<tr>#{Html.tag("Remaining")}
  <td align="right" class="formval">$%fmt_amount_left%</td>
</tr>

<tr>#{Html.tag("Date")}
  <td class="formval">%fmt_processed%</td>
</tr>

<tr><td>&nbsp;</td></tr>
<tr>#{Html.tag("%inv_doc_name% no.")}
IF:inv_id
  <td><span class="formval">%inv_id%</span>
ENDIF:inv_id
IFNOT:inv_id
  <td><span class="formval">none</span></td>
ENDIF:inv_id
</tr>


IF:cc_id
</table>
<p>
<table>
<tr><td>&nbsp;</td></tr>
<tr><td colspan="3" class="simpletableheader">Credit Card Payment</td></tr>
<tr>
  #{Html.tag("Auth. code")}
  <td class="formval">%cc_auth_code%</td>
</tr>
<tr>
  #{Html.tag("Trans. id")}
  <td class="formval">%cc_trans_id%</td>
</tr>
<tr>
  #{Html.tag("Response")}
  <td class="formval">%cc_response_code%/%cc_reason_code%: %cc_reason_text%</td>
</tr>
ENDIF:cc_id

</table>

<p>
<table>
<tr valign="top"><td>Do you want to delete this payment?</td>
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
  <td>%input:pay_amount:20:20%
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


IF:orders

<tr><td colspan="2">Orders paid or partially paid using this
payment</td></tr>

<tr><td></td><td>
<table>
<tr>
 <th>ID</th>
 <th colspan="3">Status</th>
 <th>Total</th>
 <th>Current<br />Applied</th>
 <th>New<br />Applied</th>
</tr>
START:orders
<tr>
  <td>%order_id%</td>
  <td colspan="3">%order_status%</td>
  <td align="right">$%grand_total%</td>
  <td align="right">$%currently_applied%</td>
  <td align="right">$%input:applied_%order_id%:10:10%</td>
</tr>
IFNOTBLANK:order_passport
<tr>
  <td></td>
  <td colspan="4" class="portalordertable">%order_passport% (%order_mem_name%),
  %order_school%</td>
</tr>
</tr>
ENDIF:order_passport
START:product_list
<tr class="portalordertable">
  <td></td>
  <td class="portalordercell" colspan="2">&bull; %fmt_desc%</td>
  <td align="right">$%price%</td>
  <td class="portalorderstatus" colspan="2">%status%</td>
</tr>
END:product_list
END:orders
</table>
</td></tr>

<tr><td>&nbsp;</td></tr>
ENDIF:orders
<tr><td colspan="3" align="right">
   <b>Total currently applied: $%fmt_amount_applied%,
   new amount applied: $%fmt_new_applied%</b></td>
</tr>
</table>

<input type="submit" value=" UPDATE ">

</form>

<form method="post" action="%cancel_url%">
  <input type="submit" value=" CANCEL ">
</form>

}
end
