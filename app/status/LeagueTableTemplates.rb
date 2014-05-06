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

class LeagueTable < Application

LEAGUE_TABLE = %{

<h2>Sorted by %sort_type%</h2>

<table class="small">

<tr>
  <th></th>
  <th colspan="2"><a href="%sort_teampaks%">TeamPaks</a></th>
  <th width="20">&nbsp;</th>
  <th colspan="2"><a href="%sort_onepaks%">OnePaks</a></th>
  <th width="20">&nbsp;</th>
  <th colspan="2"><a href="%sort_fivepaks%">FivePaks</a></th>
  <th width="20">&nbsp;</th>
  <th colspan="2"><a href="%sort_teams%">Teams</a></th>
  <th width="20">&nbsp;</th>
  <th colspan="2"><a href="%sort_users%">Users</a></th>
</tr>
START:list
<tr align="right">
  <td align="left">%aff_name%</td>
  <td>%teampak_count%</td><td><i>%teampak_rank%</i></td><td></td>
  <td>%onepak_count%</td><td><i>%onepak_rank%</i></td><td></td>
  <td>%fivepak_count%</td><td><i>%fivepak_rank%</i></td><td></td>
  <td>%team_count%</td><td><i>%team_rank%</i></td><td></td>
  <td>%user_count%</td><td><i>%user_rank%</i></td><td></td>
</tr>
END:list
</table>
}


end
