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

class MaintainChallenges < Application

######################################################################

HQ_CHALLENGE_LIST = %{

<h2>Maintain Challenges</h2>

<b>WARNING:</b> You probably shouldn't be doing this after the season
starts...
<hr />
<p>
IF:list
<table cellspacing="10">
START:list
<tr>
  <td><b>%name%</b></td>
  <td><a href="%edit_url%">Edit</a></td>
  <td><a href="%delete_url%">Delete</a></td>
</tr>
END:list
</table>
ENDIF:list
<p>
<form method="post" action="%new_url%">
<input type="submit" value=" New Challenge ">
</form>
}

######################################################################

HQ_MAINTAIN_CHALLENGE = %{

<h2>Maintain Challenge</h2>
<form method="post" action="%form_url%">
<table>
<tr>#{Html.tag("Name")}
   <td>%input:chd_name:40:100%</td>
</tr>

<tr>#{Html.tag("Short name")}
   <td>%input:chd_short_name:40:100% (used by scoring program)</td>
</tr>

<tr>#{Html.tag("Description")}
   <td>%text:cdl_desc:50:15%</td>
</tr>

<tr>#{Html.tag("URL of icon")}
   <td>%input:cdl_icon_url:40:200%</td>
</tr>

<tr>#{Html.tag("Available only at levels:")}
  <td>
START:levels
    <label>%check:%name%% %desc%</label><br />
END:levels
  </td>
</tr>
<tr>#{Html.tag("File path of .pdf")}</tr>
<tr><td class="formtag"><b>%cdl_lang_0%</b></td><td>%input:cdl_pdf_path_0:40:200%</td></tr>
<tr><td align="right">%input:cdl_lang_1:15:40%</td><td>%input:cdl_pdf_path_1:40:200%</td></tr>
<tr><td align="right">%input:cdl_lang_2:15:40%</td><td>%input:cdl_pdf_path_2:40:200%</td></tr>
<tr><td align="right">%input:cdl_lang_3:15:40%</td><td>%input:cdl_pdf_path_3:40:200%</td></tr>
<tr><td align="right">%input:cdl_lang_4:15:40%</td><td>%input:cdl_pdf_path_4:40:200%</td></tr>
<tr><td align="right">%input:cdl_lang_5:15:40%</td><td>%input:cdl_pdf_path_5:40:200%</td></tr>
<tr><td align="right">%input:cdl_lang_6:15:40%</td><td>%input:cdl_pdf_path_6:40:200%</td></tr>


<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="submit" value=" UPDATE CHALLENGE"></td></tr>
</table>
}

######################################################################

AD_MAINTAIN_CHALLENGE = %{

<h2>Maintain Affiliate Challenges</h2>

The list on the left is the challenges you'll be offering in your
affiliate. On the right is the list of challenges that you're
not currently offering. Click on the [<<] symbol to move a challenge
in to your list, and the [>>] symbol to remove it from your list.
<p>
To change the levels that can compete for an existing challenge, click
on its name (you can't do this for a primary-only challenge).
<p>
<table border="2" cellpadding="8" align="center">
<tr>
  <th>Offered</th><th>Not Offered</th>
</tr>
<tr valign="top">
<td align="right">
START:mine
IF:change_url
<b><a href="%change_url%">%name%</a></b>&nbsp;<a href="%delete_url%">&gt;&gt;</a>
ENDIF:change_url
IFNOT:change_url
<b>%name%</b>&nbsp;<a href="%delete_url%">&gt;&gt;</a>
ENDIF:change_url
<br />
END:mine
&nbsp;</td>
<td>
START:theirs
&nbsp;<a href="%add_url%">&lt;&lt;</a>&nbsp;<b>%name%</b>
<br />
END:theirs
&nbsp;</td></tr>
</table>
<p>
<form method="post" action="%done_url%">
<input type="submit" value=" FINISHED SETTING UP CHALLENGES ">
</form>
                      
}
######################################################################

AD_CHOOSE_LEVELS = %{
<h2>Choose Levels for Challenge</h2>
<form method="post" action="%form_url%">
<table>
<tr>#{Html.tag("Name")}
   <td>%chd_name%</td>
</tr>

<td><td>&nbsp;</td></tr>

<tr>#{Html.tag("Description")}
   <td>%cdl_desc%</td>
</tr>

<td><td>&nbsp;</td></tr>

<tr>#{Html.tag("Levels")}
  <td>
START:levels
    <label>%check:%name%% %desc%</label><br />
END:levels
  </td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="submit" value=" UPDATE CHALLENGE"></td></tr>
</table>
}

######################################################################

end
