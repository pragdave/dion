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

class MaintainAffiliateDates < Application

######################################################################

MAINTAIN_DATES = %{

<h2>Affiliate Dates</h2>
<p style="font-size: small">This screen lets you set the start and end
dates for TeamPak and for indivual Team registration. The system won't
accept registrations from your members before or after these dates.
<hr>
<form method="post" action='%form_url%'>
<table>
<tr><td colspan="2"><b>TeamPak Registration Dates (mm/dd/yyyy)</b></td></tr>
<tr>
 #{Html.tag("Start")}
 <td>%date:reg_start%</td>
</tr>
<tr>
 #{Html.tag("End")}
 <td>%date:reg_end%</td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr><td colspan="2"><b>Team Registration Dates</b></td></tr>
<tr>
 #{Html.tag("Start")}
 <td>%date:team_reg_start%</td>
</tr>
<tr>
 #{Html.tag("End")}
 <td>%date:team_reg_end%</td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr><td></td><td><input type="submit" value=" UPDATE "></td></tr>
</table>
</form>
}

end
