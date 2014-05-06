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

class Cycles < Application

######################################################################
FEE_SUMMARY = %{
<h2>Affiliate Fee Summary</h2>
<table cellspacing="3">
<tr>
 <th align="left">Affiliate</th>
 <th>Previous<br>Total</th>
 <th class="palebackground">This<br>Cycle</th>
 <th>YTD<br>Total</th>
</tr>

START:summary
<tr>
  <td>%popup:display_url:aff_long_name%</td>
  <td align="right">%prev_total%</td>
  <td align="right"  class="palebackground">%this_cycle%</td>
  <td align="right">%ytd_total%</td>
</tr>
END:summary

<tr>
  <td><b>TOTAL</b>
  <td align="right" class="totalcell">%sum_prev_total%</td>
  <td align="right" class="totalcell">%sum_this_cycle%</td>
  <td align="right" class="totalcell">%sum_ytd_total%</td>
</tr>

</table>
}
######################################################################

FEE_DETAILS = %{
<h2>%aff_long_name%</h2>

<table cellspacing="0" cellpadding="0">
<tr class="portaltitle"><td colspan="4"><b>Fees Collected</b></td></tr>

IF:fees
START:fees
<tr class="grouphdr">
 <td>&nbsp;&nbsp;</td>
 <td align="right">%qty% x</td>
 <td colspan="2">%prd_desc%</td>
 <td></td>
 <td align="right">$%total%</td>
</tr>
START:details
<tr class="groupline">
  <td></td>
  <td></td>
  <td class="spread">%date%</td>
  <td class="spread">%fee_desc%</td>
  <td class="spread" align="right">$%amount%</td>
</tr>
END:details
<tr><td>&nbsp;</td></tr>
END:fees
ENDIF:fees

IFNOT:fees
<tr><td></td><td></td><td colspan="2">None</td></tr>
ENDIF:fees


<tr class="portaltitle"><td colspan="4"><b>Refunds</b></td></tr>
IF:refunds
START:refunds
<tr class="grouphdr">
 <td>&nbsp;&nbsp;</td>
 <td align="right">%qty% x</td>
 <td colspan="2">%prd_desc%</td>
 <td></td>
 <td align="right">$%total%</td>
</tr>
START:details
<tr class="groupline">
  <td></td>
  <td></td>
  <td class="spread">%date%</td>
  <td class="spread">%fee_desc%</td>
  <td class="spread" align="right">$%amount%</td>
</tr>
END:details
<tr><td>&nbsp;</td></tr>
END:refunds
ENDIF:refunds

IFNOT:refunds
<tr><td></td><td></td><td colspan="2">None</td></tr>
ENDIF:refunds

</table>
}

######################################################################

OK_TO_RUN_FEES = %{
<h2>Produce Affiliate Fees</h2>

You have asked to finish a cycle of affiliate fees. If you press [OK]
below, we'll close out the current cycle, produce statements for the
affiliates, and start a new cycle. If you press [CANCEL], nothing will
be done.
<p>
IF:last_date
You last completed an affiliate fee cycle on %last_date%.
ENDIF:last_date

IFNOT:last_date
This is the first cycle for affiliate fees.
ENDIF:last_date

<table cellpadding="10">
<tr><td><form method="post" action="%ok_url%">
        <input type="submit" value=" OK ">
        </form>
    </td>
    <td><form method="post" action="%cancel_url%">
        <input type="submit" value=" CANCEL ">
        </form>
    </td>
</tr>
</table>
}

######################################################################

MAYBE_PRINT_STATEMENTS = %{
<h2>Finish Fee Processing</h2>

You have successfully closed off cycle %cycle_id%.
<p>
You can print statements now, or come back later and print, specifying
the cycle number.
<p>
<form method="post" action="%print_url%">
%check:include_empty% include affiliates with no activity
<br>
<input type="submit" value="PRINT STATEMENTS">
</form>

<hr>

<form method="post" action="%cancel_url%">
<input type="submit" value="DO NOT PRINT">
</form>

}


######################################################################
######################################################################
end
