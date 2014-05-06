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

require 'web/Html'

class ReceivePayment < Application

######################################################################

GET_PAYMENT_DETAILS = %{
<h2>Receive Payment</h2>

Enter details of the payment:
<p>
<form method="post" action="%match_url%">
<table>
<tr valign="bottom">#{Html.tag("Payment type")}
  <td class="formval">%payment_type%</td>
</tr>

<tr>#{Html.tag("%payment_type% number")}
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

<tr><td width="20%">&nbsp;</td></tr>

IF:po
<tr><td></td><td class="formexplain">Some purchase orders
<b>insist</b> that goods be sent to a certain address. If this is one
of these, enter the address (exactly as you'd like it to appear on the
shipping label) below. If you don't enter an address below, the orders
will ship to the user's shipping address (which is probably OK most of
the time...).</td></tr>
<tr>#{Html.tag("Shipping address")}
<td>%text:pay_ship_address:60:6%</td>
</tr>

ENDIF:po

<tr><td>&nbsp;</td></tr>
<tr><td></td>
  <td><input type="submit" value="Look for Match">
</tr>
</table>

}

######################################################################


APPLY_TO_ORDER = %{
<h2>Apply Payment to Orders</h2>

!INCLUDE!

<p>
If this payment matches one or more of the orders listed below, click
on the activate box next to each match, then click the [APPLY] button.
<p>
<form method="post" action="%search_url%">
If none of the orders matches, you can do a general
<input type="submit" value="SEARCH">.
</form>
<p>
<form method="post" action="%apply_url%">
<table>
<tr>
 <th colspan="4"></th>
 <th class="palebackground" style="font-size: small">Pay in full?</th>
 <th>&nbsp;</th>
 <th class="palebackground" style="font-size: small">Or partial amt.</th>
</tr>

START:order_list
<tr class="palebackground" style="font-size: small">
  <td class="portalordercell">%fmt_order_date%</td>
  <td class="portalordercell">%order_passport%</td>
  <td class="portalordercell">Order #%order_id%</td>
  <td class="portalordercell">%their_ref%</td>
IF:activated
  <td align="center"><b>Yes</b></td>
ENDIF:activated
IFNOT:activated
IF:activate_full_ok
  <td align="center">%check:pay_in_full_%order_id%%</td>
ENDIF:activate_full_ok
IFNOT:activate_full_ok
  <td align="center">n/a</td>
ENDIF:activate_full_ok
  <td style="background: transparent"></td>
  <td align="center">$%input:partial_pay_%order_id%:10:10%</td>
ENDIF:activated
</tr>
<tr valign="top" style="font-size: small">
  <td colspan="2" class="lesspalebackground">%mem_name%<br>%mem_schoolname%<br>%mem_district%</td>

START:contact
  <td colspan="2" class="lesspalebackground">%con_name%
START:ship_add
<br>%S_add_city%<br>%S_add_state%</td>
END:ship_add
END:contact
<td></td>
<td></td>
<td class="portalordercell">Force ship: %check:force_ship%</td>
</tr>

START:product_list
<tr style="font-size: small">
  <td class="portalordercell" colspan="3">&bull; %desc%</td>
  <td align="right">$%price%</td>

IF:li_id
  <td colspan="3" class="portalordercell">%status%</td>
ENDIF:li_id

</tr>
END:product_list
IF:intl_surcharge
<tr style="font-size: small">
  <td class="portalordercell" colspan="3">&bull; International dispatch</td>
  <td align="right">$%intl_surcharge%</td>
</tr>
ENDIF:intl_surcharge
<tr style="font-size: small">
  <td class="portalordercell" colspan="3">&bull; Shipping</td>
  <td align="right">$%shipping%</td>
</tr>
<tr style="font-size: small">
  <td colspan="3"></td>
  <td class="totalcell">$%grand_total%</td>
<td colspan="2" align="right">Owed:</td>
<td class="totalcell">$%left_to_pay%</td>
</tr>
<tr><td>&nbsp;</td></tr>

END:order_list


</table>
</p>
<input type="submit" value="APPLY PAYMENT TO MARKED ORDERS">
</form>
<p>
}

######################################################################

SEARCH_PAGE = %{
<h2>Search for Orders to Match Payment</h2>

<table align="center">
<tr><td>
!INCLUDE!
</td></tr>
</table>
<p>

<table align="center">
<tr><td>
!INCLUDE!
</td></tr>
</table>

<form method="post" action="%done%">
The orders covered by this payment may not yet have been entered into
DION. If that's the case, press
<input type="submit" value=" HERE ">
and we'll leave the rest of this payment unapplied. You'll be able to
apply it later.
</form>
}

######################################################################

PAYMENT_SUMMARY = %{

<table class="palebackground" style="font-size: small" align="center">
<tr><td>Payment ref:</td><td>%short_type% #%pay_doc_ref%</td></tr>
<tr><td>Payment amount:</td><td align="right">$%pay_amount%</td></tr>
<tr><td>Applied amount:</td><td align="right">$%fmt_amount_applied%</td></tr>
<tr><td>Amount left:</td><td align="right">$%fmt_amount_left%</td></tr>
</table>

}

######################################################################

NOT_FULLY_APPLIED =%{

<h2>Payment not Fully Applied</h2>

<table align="center">
<tr><td>
!INCLUDE!
</td></tr>
</table>
<p>
There are still some funds on this payment that have not yet been
applied to sales.
<p>
This isn't a problem: we may have received a purchase order for
TeamPaks that have not yet registered.
<p>
If you choose [FINISH] below, we'll keep the excess from the payment in
the system and you can apply it at a later date. Otherwise you can
press <a href="%back%">search</a> to go back and look for more
matches.
<p>
<form method="post" action="%done%">
<input type="submit" value=" FINISH ">
</form>

}

######################################################################

CHOOSE_EXISTING_PAYMENT = %{
<h2>Choose Existing Payment to Apply</h2>

You are about to apply an existing check or purchase order to some new
memberships. This happens when you receive a check or P.O. before all
the corresponding memberships have registered. When you entered the
P.O. and reconciled it against the memberships that were present at
that time, you found that some money was left over. This screen lets
you apply that excess.
<p>
First, chose a check or purchase order to apply:

<table cellpadding="5" style="font-size: small">
<tr>
 <th>Type</th>
 <th>Date</th>
 <th>Tracking</th>
 <th>Their ref</th>
 <th>Payor</th>
 <th>Amount</th>
 <th>Amount<br>applied</th>
</tr>

START:list
<tr>
  <td><a href="%pay_url%">%pay_type%</a></td>
  <td>%processed%</td>
  <td>%pay_our_ref%</td>
  <td>%pay_doc_ref%</td>
  <td>%pay_payor%</td>
  <td align="right">%pay_amount%</td>
  <td align="right">%pay_amount_applied%</td>
</tr>
END:list
</table>
}

######################################################################
######################################################################
######################################################################

end
