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

class GeneralOrders < Application

######################################################################

ORDER_FORM = %{
<h2>%title%</h2>

<form method="post" action="%form_target%">
<table cellspacing="0" cellpadding="0">


<tr>#{Html.tag("Products")}
 <td>
   <table>
     <tr class="groupline">
       <th>Qty</th>
       <th>Description</th>
       <th>Price</th>
     </tr>
START:products
     <tr class="groupline"><td><input type="text" name="prd_qty_%index%"
              value="%qty%" size="3" maxsize="3" />
             <input type="hidden" name="prd_id_%index%" value="%prd_id%" /></td>
         <td class="spread">%desc%</td>
         <td class="spread" align="right">%price%</td>
     </tr>
END:products
   </table>
 </td>
</tr>
<tr><td>&nbsp;</td></tr>

<tr>
#{Register::PAY_OPTIONS}
</tr>
<tr><td>&nbsp;</td></tr>

<tr>#{Html.tag("Next...")}
 <td class="formexplain">Click on the button below to 
  continue<p>
  <input type="submit" value=" CONTINUE " />
</td></tr>

</table>
</form>
}

######################################################################

ORDER_SUMMARY = %{
IF:confirm_url
<h2>Order Summary</h2>

You're just one click away from placing your order. Please check
the details below. If you find an error, click your browser's [BACK]
button and correct them. Otherwise click on [PLACE ORDER] below to place
your order.
ENDIF:confirm_url


IFNOT:confirm_url
<h2>Thank you!</h2>
<blink style="font-size: large; color: #a02020">IMPORTANT!</blink>

<table cellspacing="10">
IF:pay_detail
<tr valign="top">
 <td><img src="/images/check.gif" height="26" width="25"></td>
 <td>Please print off this page and <b>send it</b>, along with your %pay_detail% for
$%grand_total%, made out to Destination ImagiNation, Inc, to
<blockquote>
Destination ImagiNation Headquarters<br>
PO Box 547<br>
Glassboro, NJ 08028
</blockquote></td>
</tr>
ENDIF:pay_detail
<tr valign="top">
 <td><img src="/images/check.gif" height="26" width="25"></td>
 <td>You might want to <b>print a copy</b> of this page for your
 records.</td>
</tr>
</table>
ENDIF:confirm_url

<p>

<table class="small">
<tr valign="top">
  <th>Qty</th>
  <th>Description</th>
  <th>Unit<br />Price</th>
  <td>&nbsp;</td>
  <th>Total</th>
</tr>
START:product_list
<tr><td>%qty%</td>
<td class="spread">%desc%</td>
<td align="right">$%unit%</td>
  <td>&nbsp;</td>
<td align="right">$%price%</td>
</tr>
END:product_list
<tr>
 <td></td>
 <td>Subtotal</td>
 <td></td>
 <td></td>
 <td class="totalcell">$%total%</td>
</tr>

<tr>
 <td></td>
 <td>Shipping</td>
 <td></td>
 <td></td>
 <td align="right">$%shipping%</td>
</tr>

IF:intl_surcharge
<tr>
 <td></td>
 <td>International dispatch</td>
 <td></td>
 <td></td>
 <td align="right">$%intl_surcharge%</td>
</tr>
ENDIF:intl_surcharge


<tr class="totalline">
 <td></td>
 <td>ORDER TOTAL</td>
 <td></td>
 <td></td>
 <td class="totalcell">$%grand_total%</td>
</tr>

</table>

<p>
Current shipping address:
<p>
<blockquote>
<pre>
%order_ship_address%
</pre>
</blockquote>
<p>
IF:confirm_url
<form method="POST" action="%confirm_url%">
IF:cc_fields
START:cc_fields
<input type="hidden" name="%k%" value="%v%">
END:cc_fields
ENDIF:cc_fields
<input type="submit" value=" PLACE ORDER ">
</form>
ENDIF:confirm_url


}


end
