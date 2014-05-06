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

require 'web/Html'

class DailyPlanet < Application

######################################################################

EDITORS_DESK = %{
<h2>Editor's Desk</h2>

This is where you get to create those messages that appear at the top
of folk's screens.
<p>
<form method="post" action="%handle_url%">
IF:news_list
<table>
START:news_list
<tr>
 <td class="spread">[%news_byline%] %news_summary%</td>
 <td><input type="submit" value=" EDIT " name="edit_%news_id%"></td>
 <td><input type="submit" value=" DELETE " name="delete_%news_id%"></td>
</tr>
END:news_list
</table>
ENDIF:news_list
<p>
<input type="submit" value=" CREATE NEW STORY " name="create">
</form>
}
######################################################################

DISPLAY_NEWS = %{

<h2>%news_summary%</h2>
<p>
<div class="newsstory">
%news_story%
</div>
}

######################################################################

######################################################################

DISPLAY_ALL_NEWS = %{

<h2>All The News</h2>
START:news
<h3>%title%</h3>
<blockquote>
START:stories
<h4>%news_byline%: %news_summary%</h4>
<blockquote>
<div class="newsstory">
%news_story%
</div>
</blockquote>
END:stories
</blockquote>
END:news
}

######################################################################

EDIT_ARTICLE = %{

<h2>Edit a News Story</h2>
<p>
<form method="post" action="%ok_url%">

IF:include_distro
<fieldset>
<legend>Distribution list:</legend>
  <label>
     <input type="radio" name="audience" value="all" %all_checked%>
     for everyone %everyone%
  </label>
IF:aff_options
<p>
  <label>
     <input type="radio" name="audience" value="aff" %aff_checked%>
     for affiliate
     %ddlb:aff_id:aff_options%
  </label>
ENDIF:aff_options
IF:reg_options
<p>
  <label>
     <input type="radio" name="audience" value="reg" %reg_checked%>
     for region
     %ddlb:reg_id:reg_options%
  </label>
ENDIF:reg_options
<p>
  <label>
     <input type="radio" name="audience" value="user" %user_checked%>
     for user
  </label>
   %input:con_email:30:200%
</fieldset>
<p />
ENDIF:include_distro

<table>
<tr>#{Html.tag("Start displaying article on")}
    <td>%date:start_date%</td>
</tr>
<tr>#{Html.tag("and stop on")}
    <td>%date:end_date%</td>
</tr>
</table>
<p>
Title:<br>%input:news_summary:50:200%
<p>
Full Story:
<br>
%text:news_story:50:10%
<p>
<input type="submit" value=" SAVE ARTICLE ">
</form>
}


######################################################################
######################################################################
######################################################################
######################################################################
######################################################################


end
