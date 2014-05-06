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
class PaymentStatus < Application

FIND_PAYMENT = %{

<h2>Find Payment</h2>

<form method="post" action="%form_url%">

Enter one of the criteria below to search for a payment:
<p>
<table>
<tr>#{Html.tag("Our tracking no.")}
  <td>%input:track_no:10:10%</td>
</tr>

<tr>#{Html.tag("PO/Check no.")}
  <td>%input:their_ref:10:10%</td>
</tr>

<tr>#{Html.tag("Related to passport")}
  <td>%input:passport:10:10%</td>
</tr>

<tr>#{Html.tag("Payor name contains")}
  <td>%input:payor:20:40%</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="submit" value=" SEARCH "></td></tr>
</table>
</form>

}


######################################################################

PAYMENT_DETAILS = %{
<h2>Payment Details</h2>

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

IFNOTBLANK:pay_paying_check_doc_ref
</table>
<p>
<em>This purchase order has been paid with the
following check</em>
<p>
<table>

<tr>#{Html.tag("Tracking no.")}
  <td class="formval">%pay_paying_check_our_ref%</td>
</tr>

<tr>#{Html.tag("Check no.")}
  <td class="formval">%pay_paying_check_doc_ref%</td>
</tr>

<tr>#{Html.tag("Payor")}
  <td class="formval">%pay_paying_check_payor%</td>
</tr>

<tr>#{Html.tag("Processed")}
  <td class="formval">%pay_paying_processed%</td>
</tr>

ENDIF:pay_paying_check_doc_ref

<tr><td>&nbsp;</td></tr>
<tr>#{Html.tag("%inv_doc_name% no.")}
IF:inv_id
  <td><span class="formval">%inv_id%</span>
IF:inv_print
<a href="%inv_print%">Reprint</a>
ENDIF:inv_print
<br>%inv_internal_notes%</td>
ENDIF:inv_id
IFNOT:inv_id
  <td><span class="formval">none</span>
IF:inv_print
<a href="%inv_print%">Create</a>
ENDIF:inv_print
</td>
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

IF:pays_list
<p>

<table style="font-size: small">
<tr><td colspan="5" class="simpletableheader">Where Payment is Applied</td></tr>
<tr>
 <th>Date</th>
 <th class="spread">Order</th>
 <th class="spread" align="right">Order<br>total</th>
 <th align="right">Amount<br>Applied</th>
</tr>
START:pays_list
<tr>
  <td class="spread">%applied_date%</td>
  <td class="spread"><a href="%order_url%">Order #%order_id%</a></td>
  <td class="spread" align="right">$%order_amt%</td>
  <td align="right">$%applied_amt%</td>
</tr>
END:pays_list
</table>
ENDIF:pays_list

}

######################################################################

PAYMENT_LIST = %{

<h2>Matching Payments</h2>

Click on the payment number to see the details.
<p>
<table style="font-size: small">
<tr>
  <th class="spread">Date</th>
  <th class="spread">Track</th>
  <th class="spread">Their ref</th>
  <th align="right" class="spread">Amount</th>
  <th align="right" class="spread">Applied</th>
</tr>
START:list
<tr style:"font-size: small">
 <td class="spread">%fmt_processed%</td>
 <td class="spread"><a href="%payment_url%">Payment #%pay_our_ref%</a></td>
 <td class="spread">%short_type% #%pay_doc_ref%</td>
 <td align="right" class="spread">$%pay_amount%</td>
 <td align="right" class="spread">$%fmt_amount_applied%</td>
</tr>
END:list
</table>

}
end
