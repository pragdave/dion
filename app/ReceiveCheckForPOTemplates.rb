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

class ReceiveCheckForPO < Application

######################################################################

ENTER_CHECK_DETAILS = %{

<h2>Enter Check Details</h2>

We're about to apply a check to a purchase order. Because we're
a system of very little brain, we can only deal with situations,
where the check amount agrees exactly with the P.O. amount.
<p>

<p>
<form method="post" action="%done_url%">
<table>

<tr>#{Html.tag("Check number")}
  <td>%input:pay_doc_ref:20:40%</td>
</tr>

<tr>#{Html.tag("Amount")}
  <td>%input:pay_amount:20:20%</td>
</tr>

<tr>#{Html.tag("Tracking no")}
  <td>%input:pay_our_ref:20:40%</td>
</tr>

<tr>#{Html.tag("Payor")}
  <td>%input:pay_payor:40:40%</td>
</tr>

<td><td>&nbsp;</td></tr>
<tr><td></td>
  <td><input type="submit" value="CONTINUE">
</tr>
</table>
</form>
}


######################################################################

GET_MATCH_DETAILS = %{

<h2>Find Matching PO</h2>

We need to identify the corresponding purchase order.<p>
If you know it, the best way is to use our reference number (the
number we stamped on the P.O. when we received it). Failing that,
use our invoice number, and failing that use their P.O. number.
(this is the worst choice because PO numbers need not be unique
across different organizations).
<p>

Enter just one of the following, or leave all fields blank to list
all pending purchase orders.

<p>

<form method="post" action="%done_url%">
<table>

<tr>#{Html.tag("Our PO tracking num")}
   <td>%input:match_po_ref:20:40%</td>
</tr>

<tr>#{Html.tag("Invoice number")}
   <td>%input:match_inv_num:20:40%</td>
</tr>

<tr>#{Html.tag("Their P.O. num")}
   <td>%input:match_their_po_ref:20:40%</td>
</tr>

<tr><td></td><td><input type="submit" value=" FIND PURCHASE ORDER ">
</table>
</form>
}

######################################################################

SELECT_MATCHING_PO = %{

<h2>Select Matching P.O.</h2>

IF:show_all
Here's a list of all outstanding purchase orders.
ENDIF:show_all

IFNOT:showall
Multiple purchase orders matched your criteria.
ENDIF:showall

<p>

<form method="post" action="%again%">
<table cellspacing="5" style="font-size: small">

<tr>
 <th class="spread">Type</th>
 <th class="spread">Date</th>
 <th class="spread">Tracking</th>
 <th class="spread">Their PO no.</th>
 <th class="spread">Payor</th>
 <th  class="spread" align="right">Amount</th>
 <th  class="spread" align="right">Amount<br>applied</th>
</tr>

START:list
<tr>
  <td class="spread"><a href="%use_url%">%pay_type%</a></td>
  <td class="spread">%processed%</td>
  <td class="spread">%pay_our_ref%</td>
  <td class="spread">%pay_doc_ref%</td>
  <td class="spread">%pay_payor%</td>
  <td class="spread" align="right">%pay_amount%</td>
  <td class="spread" align="right">%pay_amount_applied%</td>
</tr>
END:list

<tr><td></td>
  <td>
    <input type="submit" value="TRY DIFFERENT MATCH">
  </td>
</tr>

</table>
</form>


}

######################################################################

APPLY_CHECK_TO_PO = %{

<h2>Apply Check to P.O.</h2>

<table cellspacing="5">
<tr>#{Html.tag("Tracking")}<td class="formval"><td>%pay_our_ref%</td></tr>
<tr>#{Html.tag("PO number")}<td class="formval"><td>%pay_doc_ref%</td></tr>
<tr>#{Html.tag("Amount")}   <td class="formval"><td>%pay_amount%</td></tr>
<tr>#{Html.tag("Applied")}  <td class="formval"><td>%pay_amount_applied%</td></tr>
<tr>#{Html.tag("Processed")}<td class="formval"><td>%fmt_processed%</td></tr>
</table>
<p>
IFNOT:pays
This PO has not yet been applied to any orders.
ENDIF:pays

IF:pays
This PO has been applied to the following orders:
<ul>
START:pays
<li>%desc%</li>
END:pays
</ul>
ENDIF:pays
<p>
Apply check to the this P.O.?
<p>
<table cellspacing="10">
<tr><td>
<form method="post" action="%again_url%">
<input type="submit" value=" NO ">
</form>
</td><td>
<form method="post" action="%apply_url%">
<input type="submit" value=" YES ">
</form>
</td></tr>
</table>
}

######################################################################
######################################################################

end
