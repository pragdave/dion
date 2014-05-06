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
class Invoicing < Application

######################################################################

INVOICE_DETAILS = %{

<h2>%cap_name% Details</h2>

If you want, you can skip %lc_name% generation by clicking
<a href="%main_menu_url%">here</a>. You can always generate it
later from the Payments/Find menu.
<p>

<form method="post" action="%form_url%">
<table>

IF:inv_unapp_desc
<tr><td></td><td class="formexplain">This %lc_name% is for a payment
with an unapplied amount. This amount will appear as a separate line
item on the %lc_name%. Enter the description to be used for this line
item (often this can be taken from the wording on an
order).</td>
</tr>
<tr>#{Html.tag('Unapplied desc')}
  <td>%text:inv_unapp_desc:40:4%</td>
<tr>
<tr><td>&nbsp;</td></tr>
ENDIF:inv_unapp_desc

Enter details for the %lc_name%:
<tr>#{Html.tag('Billing address')}
  <td>%text:inv_billing_address:40:6%
</tr>
<tr>#{Html.tag('Comments on %lc_name%')}
  <td>%text:inv_notes:40:6%
</tr>
<tr>#{Html.tag('Private notes')}
  <td>%text:inv_internal_notes:40:6%
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td>
    <td><input type="submit" value=" GENERATE %uc_name% "></td>
</tr>
</table>
</form>
}

######################################################################

SELECT_INVOICE = %{

<h2>Select Invoice/Receipt to Reprint</h2>
<p>
<form method="post" action="%form_url%">
<table>
<tr>#{Html.tag('Invoice/receipt number')}
 <td>%input:inv_no:10:10%</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr>
  <td></td><td><input type="submit" value=" FIND "></td>
</tr>
</table>
</form>
}

######################################################################

CONFIRM_REPRINT = %{
<h2>Confirm Reprint</h2>

<table>
<tr>#{Html.tag('Number')}
  <td class="formval">%inv_id%</td>
</tr>

<tr>#{Html.tag('Our ref')}
  <td class="formval">%pay_our_ref%</td>
</tr>

<tr>#{Html.tag('Their ref')}
  <td class="formval">%pay_doc_ref%</td>
</tr>

<tr>#{Html.tag('Payor')}
  <td class="formval">%pay_payor%</td>
</tr>

<tr>#{Html.tag('Amount')}
  <td class="formval">%pay_amount%</td>
</tr>

<tr>#{Html.tag('Processed')}
  <td class="formval">%fmt_processed%</td>
</tr>

IFNOTBLANK:inv_internal_notes
<tr>#{Html.tag('Internal notes')}
  <td class="formexplain">%inv_internal_notes%</td>
</tr>
ENDIF:inv_internal_notes


<tr><td>&nbsp</td></tr>
<tr>
  <td>
    <form method="post" action="%ok_url%">
      <input type="submit" value=" REPRINT ">
    </form>
  </td>
  <td>
    <form method="post" action="%no_url%">
      <input type="submit" value=" FIND ANOTHER ">
    </form>
  </td>
</tr>
</table>
}
end
