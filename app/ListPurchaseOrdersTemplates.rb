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

class ListPurchaseOrders < Application

######################################################################

OUTSTANDING_POS = %{
<h2>Unpaid Purchase Orders</h2>

<table boder="2">
<tr>
  <th>Date</th>
  <th class="spread">Our ref</th>
  <th class="spread">Their ref</th>
  <th class="spread">Payor</th>
  <th>Amount</th>
</tr>
START:list
<tr>
  <td class="spread">%fmt_processed%</td>
IF:detail_url
  <td class="spread"><a href="%detail_url%">%pay_our_ref%</a></td>
ENDIF:detail_url
IFNOT:detail_url
  <td class="spread">%pay_our_ref%</td>
ENDIF:detail_url
  <td class="spread">%pay_doc_ref%</td>
  <td class="spread">%pay_payor%</td>
  <td align="right">$%pay_amount%</td>
</tr>
END:list
</table>
<p>
<form method="post" action="%ok_url%">
<input type="submit" value="  OK  ">
</form>

}

######################################################################
######################################################################
######################################################################
######################################################################

end