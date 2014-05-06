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
class CreditCards < Application

CREDIT_CARD_LOG = %{

<h2>Credit Card Transactions</h2>

<table>
<tr>
  <th>Date</th>
  <th>Amount</th>
  <th>Resp/Reason</th>
  <th>Auth. code</th>
  <th>AVC Code</th>
  <th>Trans. ID</th>
</tr>
START:list
<tr>
 <td>%fmt_submitted%</td>
 <td>$%fmt_amount%</td>
 <td>%cc_response_code%/%cc_reason_code%</td>
 <td>%cc_auth_code%</td>
 <td>%cc_avs_code%</td>
 <td>%cc_trans_id%</td>
</tr>
<tr><td></td><td colspan="3">%cc_reason_text%</td></tr>
<tr><td></td><td colspan="3">%cc_payor%</td></tr>
<tr><td></td><td colspan="3">%cc_description%</td></tr>
<tr><td>&nbsp;</td></tr>
END:list
</table>
}
end
