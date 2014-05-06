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

class Select < Application

######################################################################

SELECTION_TYPE = %{
<h2>%function%s</h2>

<form method="post" action="%form_url%">
<table cellspacing="10">
<tr valign="top"><td><h3>Step 1. %function% type</h3></td>
 <td>%radio:selection_type:type_opts%</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td>
   <td><input type="submit" value=" CONTINUE ">
</td></tr>
</table>
</form>
}

######################################################################

SEARCH_CRITERIA = %{

<h2>Which Things to %function%</h2>

<p style="font-size: small">Now you need to tell me which entries
include. Select one of the pre-defined criteria, or select
'custom' to make up your own.</p>
<hr>
<form method="post" action="%form_url%">
<table cellspacing="10">
<tr valign="top"><td><h3>Step 2. Search Criteria</h3></td>
 <td>%radio:criteria:criteria_opts%</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td>
  <td><input type="submit" value=" CONTINUE "></td>
</tr>
</table>
</form>
}

######################################################################

SEARCH_PAGE = %{

<h2>%function% Criteria</h2>

<p style="font-size: small">Fill in the fields below to tell the
system what you're looking for. If you leave everything blank, the
system will match all the data.</p>
<hr>

<form method="post" action="%done%">
<table>
!INCLUDE!
</table>
</form>
}

######################################################################

WHAT_TO_DO = %{

<h2>What to %function%</h2>

<p style="font-size: small">The search criteria you have chosen will
generate <b>approximately %count% data records</b>. If this doesn't sound
correct, you can go back now and change the criteria.</p>

<p style="font-size: small">Otherwise, select one or more categories
from the list below
the category or categories of data to be included in the %function%.</p>

IF:warn
<p style="font-size:small; color: #a02020"><b>WARNING:</b> as your selection
is fairly large, we're having to work the little gerbils extra hard at
this end. The data may take a while to start downloading. Please be
patient.</p>
ENDIF:warn


<hr>
<form method="post" action="%form_url%">
<table cellspacing="10">
<tr valign="top"><td><h3>Step 3. Data to %function%</h3></td>
 <td>
<table style="font-size:small">
START:dl_list
<tr valign="top"><td>%check:%opt%%</td><td>%desc%</td></tr>
END:dl_list
</table>
</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td>
  <td><input type="submit" value=" %function% "></td>
</tr>
</table>
</form>

}

end
