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

class PaymentReports < Application

###################################################################### 

DAILY_MONEY_REPORT_DATES = %{

<h2>Money Report</h2>

<form method="post" action="%form_url%">
<table>
  <tr><td class="formval">Start date:</td><td>%date:start%</td></tr>
  <tr><td class="formval">End date:</td><td>%date:end%</td></tr>
  <tr><td>&nbsp;</td></tr>
  <tr><td></td><td><input type="submit" name="type" value="   DIRECT CHECKS   "></td></tr>
  <tr><td></td><td><input type="submit" name="type" value="   CREDIT CARDS    "></td></tr>
  <tr><td></td><td><input type="submit" name="type" value="  PURCHASE ORDERS  "></td></tr>
  <tr><td></td><td><input type="submit" name="type" value=" CHECKS PAYING POs "></td></tr>
  <tr><td></td><td><input type="submit" name="type" value=" ALL CHECKS AND CCs "></td></tr>
</table>
</form>
}

######################################################################

DAILY_SUMMARY = %{

<h2>%type% Summary: %start% to %end%</h2>

<table class="small">
<tr align="left">
  <th>Date</th>
  <th>%type% ref.</th>
  <th>Our trk no.</th>
  <th>Payor</th>
  <th align="right">Amount</th>
</tr>
START:list
<tr>
  <td>%fmt_processed%</td>
  <td>%pay_doc_ref%</td>
  <td>%pay_our_ref%</td>
  <td>%pay_payor%</td>
  <td align="right">$%pay_amount%</td>
</tr>
END:list
<tr align="right" class="totalline">
 <td></td>
 <td colspan="3">Item count: %count%.  Total:</td>
 <td class="totalcell">$%total%</td>
</tr>
</table>
}

######################################################################

DAILY_SUMMARY_TWOLINE = %{

<h2>%type% Summary: %start% to %end%</h2>

<table class="small">
<tr align="left">
  <th>Check Date</th>
  <th>Check ref.</th>
  <th>Our trk no.</th>
  <th>Payor</th>
  <th align="right">Amount</th>
</tr>
<tr align="left" style="color: green">
  <th>PO Date</th>
  <th>PO ref.</th>
  <th>Our trk no.</th>
  <th>Payor</th>
</tr>
START:list
<tr height="8"><td></td></tr>
<tr>
  <td>%fmt_paying_processed%</td>
  <td>%pay_paying_check_doc_ref%</td>
  <td>%pay_paying_check_our_ref%</td>
  <td>%pay_paying_check_payor%</td>
  <td align="right">$%pay_amount%</td>
</tr>
<tr style="color: green">
  <td>%fmt_processed%</td>
  <td>%pay_doc_ref%</td>
  <td>%pay_our_ref%</td>
  <td>%pay_payor%</td>
</tr>
END:list
<tr align="right" class="totalline">
 <td></td>
 <td colspan="3">Item count: %count%.  Total:</td>
 <td class="totalcell">%total%</td>
</tr>
</table>
}

######################################################################

OVERALL_SUMMARY = %{

IF:checks
START:checks
!INCLUDE!
END:checks
ENDIF:checks

<p>

IF:ccs
START:ccs
!INCLUDE!
END:ccs
ENDIF:ccs
}

end
