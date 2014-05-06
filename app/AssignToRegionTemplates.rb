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

class AssignToRegion < Application

######################################################################

NO_WORK_TO_DO = %{

<h2>Every TeamPak has a Home</h2>

 All TeamPaks (that aren't suspended)
 in this affiliate have been assigned to regions. To
 change a particular TeamPak to a different region, visit the
 TeamPak maintenance screen. Otherwise click below to return to
 the main menu.
}

######################################################################

DISPLAY_LIST = %{

<h2>Assign TeamPaks to Regions</h2>

<span class="small">Select a region next to one or more of the memberships below, then
press the [assign] button at the bottom to assign those regions to the
corresponding memberships</span>
<p>
<span style="color: #900000"><b>**WARNING**</b></span>
<span class="small">Be careful when using the scroll wheel or arrow keys to scroll down
through this page. If you do this after you've picked a region for
a TeamPak, you'll find that some browsers
don't scroll the page, but instead scroll that TeamPak to a new
region. <b>The result could be that TeamPaks get assigned to the wrong
region.</b> The best way to get around this browser issue is to click
somewhere else on the page after you assign a TeamPak to a region and
before you try to scroll the page.</span>

<p>

<form method="post" action="%form_target%">
<table border="2" cellpadding="10">
<tr>
 <th>Passport</th>
 <th>School/<br>TeamPak</th>
 <th>Coordinator</th>
 <th>City/<br>Zip</th>
 <th>Region</th>
</tr>

START:list
<tr>
 <td>%full_passport%</td>
 <td>%mem_schoolname%<br>%mem_name%</td>
 <td>%coordinator%</td>
 <td>%con_city%<br>%con_zip%</td>
 <td>%vsortddlb:reg_%i%:reg_opts%</td>
</tr>
END:list
</table>
<p>
<input type="submit" value="Assign Teams">
</form>
}

######################################################################

SEARCH_PAGE = %{

<h2>Search For TeamPaks to Reassign</h2>

<form method="post" action="%done%">
<table>
!INCLUDE!
</table>
</form>
}

######################################################################
######################################################################

end
