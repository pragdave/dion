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

class AffiliateSummary < Application

AFFILIATE_SUMMARY = %{

<h2>Affiliate Summary</h2>
<table style="font-size: small">
<tr style:font-size: x-small">
  <th>Prefix</th>
  <th>Short</th>
  <th>Full Name</th>
  <th>Regions?</th>
  <th>Intl?</th>
  <th>SA?</th>
  <th>Setup?</th>
</tr>
START:list
<tr>
  <td>%aff_passport_prefix%</em></td>
  <td><a href="%url%">%aff_short_name%</a></td>
  <td>%aff_long_name%</td>

IF:aff_has_regions
  <td align="center">Yes</td>
ENDIF:aff_has_regions
IFNOT:aff_has_regions
  <td>&nbsp;</td>
ENDIF:aff_has_regions

IF:aff_is_foreign
IF:aff_in_canada
  <td align="center">Can.</td>
ENDIF:aff_in_canada
IFNOT:aff_in_canada
  <td>Intl</td>
ENDIF:aff_in_canada
ENDIF:aff_is_foreign
IFNOT:aff_is_foreign
IF:aff_in_canada
  <td align="center">Can.</td>
ENDIF:aff_in_canada
IFNOT:aff_in_canada
  <td>&nbsp;</td>
ENDIF:aff_in_canada
ENDIF:aff_is_foreign
   
   
IF:aff_is_sa
  <td align="center">S.A.</td>
ENDIF:aff_is_sa
IFNOT:aff_is_sa
  <td>&nbsp;</td>
ENDIF:aff_is_sa
   
IF:setup
  <td align="center">&radic;</td>
ENDIF:setup
IFNOT:setup
  <td>No</td>
ENDIF:setup
</tr>
END:list
</table>
}

######################################################################

AFFILIATE_DETAIL = %{

<h2>Status of %aff_short_name%</h2>
<table>
<tr>
<td></td><td colspan="3"><b>%aff_long_name%</b></td>
</tr>

</tr>
<tr>
 #{Html.tag("Prefix")}
 <td class="formval">%aff_passport_prefix%</td>
 #{Html.tag("Short name")}
 <td class="formval">%aff_short_name%</td>
</tr>


<tr>
 #{Html.tag("Has regions")}
 <td class="formval">%aff_has_regions%</td>
 #{Html.tag("Self admin")}
 <td class="formval">%aff_is_sa%</td>
</tr>
<tr>
 #{Html.tag("International")}
 <td class="formval">%aff_is_foreign%</td>
 #{Html.tag("Canadian")}
 <td class="formval">%aff_in_canada%</td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr>
  #{Html.tag("TeamPak registration")}
  <td colspan="3" class="formval">Starts %fmt_reg_start%, ends
  %fmt_reg_end%</td>
</tr>

<tr>
  #{Html.tag("Team registration")}
  <td colspan="3" class="formval">Starts %fmt_team_reg_start%, ends
  %fmt_team_reg_end%</td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr>
   %pair:Direct users:direct_users%
   %pair:Total users associated with %aff_short_name%:total_users%
</tr>
<tr>#{Html.tag("Affiliate Director(s)")}
  <td colspan="3">
IF:ad_list
START:ad_list
%name% (<a href="%url%">%email%</a>)<br>
END:ad_list
ENDIF:ad_list
IFNOT:ad_list
<em>No ADs set up</em>
ENDIF:ad_list
  </td>
</tr>

<tr><td>&nbsp;</td></tr>
<tr>#{Html.tag("Regions")}
IFNOT:region_list
   <td colspan="2"><em>No regions set up</em></td>
ENDIF:region_list
IF:region_list
<td colspan="3">
<table>
START:region_list
<tr>
  <td class="spread">%reg_name%</td>
IF:rd_list
<td>
START:rd_list
%name% (<a href="%url%">%email%</a>)<br>
END:rd_list
</td>
ENDIF:rd_list
END:region_list
</table>
</td>
ENDIF:region_list
</tr>
</table>

<p>

<table style="font-size:small">

<tr class="simpletableheader">
 <td colspan="4">TeamPak Totals</td>
</tr>

<tr align="right">
 <th></th>
 <th class="spread">Active</th>
 <th class="spread">Wait Pay</th>
 <th class="spread">Suspended</th>
</tr>

<tr>
START:teampaks
<tr align="right">
 <td>%name%</td>
 <td>%ACTIVE%</td>
 <td>%WTPAY%</td>
 <td>%SUSPND%</td>
<tr>
END:teampaks

</table>

<p>

<table style="font-size:small">

<tr class="simpletableheader">
 <td colspan="7">What Teams are Doing</td>
</tr>

<tr align="right">
 <th>Challenge</th>
 <th>&nbsp;Prim.</th>
 <th>&nbsp;Elem.</th>
 <th>&nbsp;Mid.</th>
 <th>&nbsp;Sec.</th>
 <th>&nbsp;U/M</th>
 <th>&nbsp;TOTAL</th>
</tr>

<tr>
START:teams
<tr align="right">
 <td>%name%</td>
 <td>%L1%</td>
 <td>%L2%</td>
 <td>%L3%</td>
 <td>%L4%</td>
 <td>%L5%</td>
 <td><b>%total%</b></td>
<tr>
END:teams

</table>

}

end
