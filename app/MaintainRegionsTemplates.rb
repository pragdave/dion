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

require "web/Html"

class MaintainRegions < Application

######################################################################

MAINTAIN_REGIONS = %{
<h2>Maintain Regions</h2>

<form method="post" action="%form_url%">
Either:
<ul>
<li><input type="submit" name="create" value=" CREATE "> a new region,
IF:regions
or</li>
<p>
<li>Maintain existing regions...
<p>
<table>
START:regions
<tr>
  <td><b>%name%</b>&nbsp;&nbsp;&nbsp;</td>
  <td><a href="%alter%">Change Name</a>&nbsp;&nbsp;</td>
  <td><a href="%rds%">Update RDs</a>&nbsp;&nbsp;</td>
  <td><a href="%delete%">Delete Region</a>&nbsp;&nbsp;</td>
END:regions
</tr>
</table>
</li>
ENDIF:regions
</ul>
</form>
<p>
<form method="post" action="%toggle_rds%">
In your affiliate, Regional Directors <b>can %rds_can_assign%</b>assign
TeamPaks to regions. Click&nbsp;<input type="submit" value="here">&nbsp;to
change that.
</form>

IF:setup_regions
<hr>
When you've finished setting up the regions for your affiliate,
press the button below and we'll stop nagging you about it...
<form method="post" action="%done_url%">
<input type="submit" value=" DONE MAINTAINING REGIONS ">
</form>
ENDIF:setup_regions
}

######################################################################

EDIT_REGION = %{

<h2>Edit Region Information</h2>

<form method="post" action="%form_url%">
<table>
<tr>#{Html.tag("Region name")}
   <td>%input:reg_name:40:100%</td>
</tr>

<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="submit" value=" UPDATE ">
</table>
</form>

}

######################################################################

REASSIGN_REGION = %{

<h2>Reassign Region</h2>

<p style="font-size: small">You've asked to delete region
'%reg_name%', but that region still has %klingons% associated with
it. If you don't want to delete this region, hit your browser's BACK
button. Otherwise pick a region from the list below and I'll reassign
everything from the region your deleting in to this region.</p>

<p style="font-size: small"><span style="font-size: large;
color=#a00000">WARNING!</span>You are about to do something
irreversible. Once you press [REASSIGN and DELETE] below, %reg_name%
will disappear, and everything in it will be moved into the new region
you select. There is no going back...</p>

<p>
<form method="post" action="%reassign%">
Reassign %klingons% from %reg_name% to %ddlb:reg_id:reg_opts%
<p>
<input type="submit" value=" REASSIGN and DELETE ">
</form>
}

######################################################################

CANT_DELETE = %{

<h2>Can't Delete %reg_name%</h2>

You've asked to delete '%reg_name%', but that region still has
%klingons% associated with it. As '%reg_name%' is the last region in
your affiliate, I have nowhere to put them if I delete it.
<p>
If you just want to rename this region, then you can use the 'Change
Name' option from the region setup menu. Otherwise you might
want to contact the support folks in Destination Imagination for more
information.

}


######################################################################
######################################################################

end
