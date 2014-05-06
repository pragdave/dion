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

class Teams < Application

####################################################################

SPECIFY_TEAMPAK = %{
<h2>Manage a Team</h2>
<form method="post" action="%form_url%">
<table>
<tr><td></td>
<td><p style="font-size: small">Each team belongs to a TeamPak.
Please specify the passport number of the TeamPak whose teams you want
to change. If you don't have that number, please contact the
administrator who initially created the TeamPak. 
</p>
<p style="font-size: small">
The TeamPak number typically looks like
IF:passport_prefix
%passport_prefix%-<i>NNNNN</i>.
ENDIF:passport_prefix
IFNOT:passport_prefix
<i>NNN-NNNNN</i>.
ENDIF:passport_prefix
The DIONline system will automatically allocate the numbers for teams
within this TeamPak.
</p>
</td></tr>
<tr>#{Html.tag("TeamPak Passport")}
  <td>
IF:passport_prefix
    <b>%passport_prefix%-%input:passport:15:15%
ENDIF:passport_prefix

IFNOT:passport_prefix
    %input:passport:15:15%
ENDIF:passport_prefix

  </td>
</tr>
<tr><td></td><td><input type="submit" value=" FIND "></td></tr>
</table>
</form>
}

####################################################################
####################################################################

MAINTAIN_TEAMS = %{

<h2>Add/Alter Teams</h2>
<h3>TeamPak Details</h3>
<table class="small">
<tr>
  <td class="formtag">TeamPak:</td><td class="formval">%mem_name%</td>
  <td width="20">&nbsp;</td>
  <td class="formtag">Passport:</td><td class="formval">%full_passport%</td>
</tr>
<tr>
  <td class="formtag">School/org:</td><td class="formval">%mem_schoolname%</td>
  <td></td>
  <td class="formtag">Affiliate:</td><td class="formval">%aff_short_name%</td>
IF:reg_name
  <td class="formtag">Region:</td><td class="formval">%reg_name%</td>
ENDIF:reg_name
</tr>
<tr>
  <td class="formtag">District:</td><td  class="formval"
  colspan="4">%mem_district%</td>
</tr>
IF:text_status
<tr>
  <td class="formtag">Status:</td><td  class="formval" colspan="4">%text_status%</td>
</tr>
ENDIF:text_status

<tr><td>&nbsp;</td></tr>

START:created_by
<tr>
  <td class="formtag">%label%:</td>
  <td colspan="4" class="formval">%con_name%
IFNOTBLANK:con_email
(<a href="mailto:%con_email%">%con_email%</a>)
ENDIF:con_email
IFBLANK:con_email
(no e-mail address registered)
ENDIF:con_email
%con_tel_list%
</td>
</tr>
END:created_by

START:contact
<tr>
  <td class="formtag">%label%:</td>
  <td colspan="4" class="formval">%con_name%
IFNOTBLANK:con_email
(<a href="mailto:%con_email%">%con_email%</a>).
ENDIF:con_email
IFBLANK:con_email
(no e-mail address registered).
ENDIF:con_email
%con_tel_list%
</td>
</tr>
END:contact

</table>

<hr />
<h3>Current Teams</h3>

IF:team_list
<table class="portalteamstable">
<tr>
 <th class="spread">Team Passport</th>
 <th class="spread">Level--Name</th>
 <th class="spread">Challenge</th>
 <th class="spread">Manager(s)</th>
</tr>

START:team_list
IF:update_allowed
<tr valign="top">
 <td  class="spread">
    <a href="%passport_url%">%team_passport%</a></td>
 <td class="spread">
     %short_level_name%-<a href="%team_status_url%"><b>%team_name%</b></a></td>
 <td class="spread">%challenge%</td>
 <td class="spread">
START:managers
%manager%<br>
END:managers
 </td>

IFNOT:reg_closed_msg
 <td><a href="%change_url%">Change</a></td>
 <td><a href="%delete_url%">Delete</a></td>
ENDIF:reg_closed_msg
ENDIF:update_allowed

IFNOT:update_allowed
<tr valign="top">
 <td  class="spread">%team_passport%</td>
 <td class="spread">
     %short_level_name%-<b>%team_name%</b></td>
 <td class="spread">%challenge%</td>
 <td class="spread">
START:managers
%manager%<br>
END:managers
 </td>
ENDIF:update_allowed

</tr>
END:team_list
</table>
<hr>
ENDIF:team_list

IFNOT:team_list
<em>No teams have yet been registered
for this TeamPak.</em>
ENDIF:team_list

IF:reg_closed_msg
<em>%reg_closed_msg%</em>
ENDIF:reg_closed_msg

<table cellspacing="20">
<tr>
IF:add_team_target        
 <td>
   <form method="POST" action="%add_team_target%">
     <input type="submit" value=" ADD TEAM ">
   </form>
 </td>
ENDIF:add_team_target
IF:add_primary_team_target        
 <td>
   <form method="POST" action="%add_primary_team_target%">
     <input type="submit" value=" ADD RISING STAR TEAM ">
   </form>
 </td>
ENDIF:add_primary_team_target
</tr>
</table>

}

####################################################################

EDIT_TEAM = %{
<form method="post" action="%form_target%">
<h2>Team Information</h2>
<table>
<tr>#{Html.tag("Team name")}
    <td colspan="2">%input:team_name:40:100%</td>
</tr>

IF:level_fixed
<tr>#{Html.tag("Level")}<td colspan="2" class="formval">%fixed_level_name%</td></tr>
ENDIF:level_fixed
IF:team_level_opts
<tr>#{Html.tag("Level")}
    <td colspan="2">%ddlb:team_level:team_level_opts%</td>
</tr>
ENDIF:team_level_opts

<tr>#{Html.tag("Challenge")}
    <td colspan="2">%ddlb:team_challenge:team_challenge_opts%</td>
</tr>

<tr><td colspan="3">&nbsp;</td></tr>

<tr><td></td><td colspan="2" class="formexplain">Enter the e-mail address(es) of the
       Team Manager(s) for this team (<b>this should include your own DION
       e-mail address if you're one of the Team Managers</b>). If you don't
       know the e-mail address of a Team Manager, check the box to the
       right and you'll be asked for other contact details on the next
       screen.
</td>
</tr>

<tr><td colspan="3" class="formlefttag">Team Manager(s)</td></tr>

IF:existing_names
START:existing_names
<tr>
  <td></td>
  <td>%name%</td>
  <td>
IF:remove_url
    <a href="%remove_url%">Remove</a>
ENDIF:remove_url
IF:change_url
    <a href="%change_url%">Change</a>
ENDIF:change_url
  </td>
  </tr>
END:existing_names
ENDIF:existing_names

IF:new_names
START:new_names
<tr>#{Html.tag("e-mail")}
  <td>%input:name_%i%:40:100%</td><td>%check:dont_know_%i%%&nbsp;don't&nbsp;know&nbsp;e-mail</td>
</tr>
END:new_names
ENDIF:new_names


IF:email_warning
<tr><td></td><td colspan="2" class="formexplain">(%email_warning%)</td></tr>
ENDIF:email_warning

</table>

<h2>Team members</h2>
<p class="small">Specify team members here. You'll need to give their name, sex, and
grade. You can also specify a date of birth. The system will try to
validate that the team members meet the Rules of the Road regulations
for eligibility for the level at which they're competing. If you're
competing based on grade level (or if you're a DI Later team),
then the system doesn't need you to
specify your team members' dates of birth. If you're competing based on
age, you'll need to enter the date of birth for all team members.</p>
<p class="small">To remove a team member from the list, just delete
their name below.</p>
<table>
<tr>
  <th>Name</th>
  <th>Sex</th>
  <th>Grade</th>
  <th colspan="5">D.O.B.</th><th type="text/css" style="font-size:
  small" align="right">(Age next</th>
</tr>
<tr>
  <th></th><th></th><th></th><th>M</th><th>/</th><th>D</th><th>/</th><th>Y</th>
  <th type="text/css" style="font-size: small" align="right">June 15)</th>
</tr>
START:members
<tr>
<td>%input:tm_name:30:100%</td>
<td>%ddlb:tm_sex:sex_opts%</td>
<td>%ddlb:tm_grade:tm_grade_opts%</td>
<td>%input:tm_dob_mon:2:2%</td>
<td>/</td>
<td>%input:tm_dob_day:2:2%</td>
<td>/</td>
<td>%input:tm_dob_year:4:4%</td>
<td class="formtag">%tm_age_next_j15%</td>
</tr>
END:members
</table>
<input type="submit" value="Update Team">
</form>
<p>
<form method="post" action="%cancel_target%">
<input type="submit" value="Cancel">
</form>
}

####################################################################

STATUS_COMMON = %{
<table>
<tr>#{Html.tag("TeamPak")}
  <td class="formval">%mem_name% (%full_passport%)</td>
</tr>
<tr>#{Html.tag("Team name")}
  <td class="formval">%team_name% (%team_passport%)</td></tr>
<tr>#{Html.tag("Level")}<td class="formval">%level_name%</td></tr>
<tr>#{Html.tag("Challenge")}<td class="formval">%challenge%</td></tr>
<tr>#{Html.tag("Created")}<td class="formval">%team_dt_created%</td></tr>
<tr valign="top">#{Html.tag("Manager(s)")}
<td>
<table>
START:managers
<tr>
  <td colspan="3" class="formval">%con_name%
IFNOTBLANK:con_email
(<a href="mailto:%con_email%">%con_email%</a>)
ENDIF:con_email
IFBLANK:con_email
(no e-mail address registered)
ENDIF:con_email
</td>
</tr>
<tr>
  <td class="formtag">Telephone:</td>
  <td class="formval" colspan="3">%con_tel_list%</td>
</tr>
<tr>
  <td class="formtag">Mail:</td>
  <td class="formval">
START:mail_add
%M_add_line1%<br>
IFNOTBLANK:M_add_line2
%M_add_line2%<br>
ENDIF:M_add_line2
%M_add_city%, %M_add_state%  %M_add_country% %M_add_zip%<br>
END:mail_add
</td></tr>
END:managers
</table>
</td>
</tr>
</table>

<h2>Team members</h2>
IF:members
<table cellspacing="5">
<tr>
  <th>Name</th>
  <th>Sex</th>
  <th>Grade</th>
  <th>D.O.B.</th><th align="right" type="text/css" style="font-size: small">Age next<br>June 15</th>
</tr>
START:members
<tr>
<td>%tm_name%</td>
<td>%tm_sex%</tm>
<td>%tm_grade_short%</td>
IF:tm_dob_mon
<td>%tm_dob_mon%/%tm_dob_day%/%tm_dob_year%</td>
ENDIF:tm_dob_mon
IFNOT:tm_dob_mon
<td></td>
ENDIF:tm_dob_mon
<td align="center">%tm_age_next_j15%</td>
</tr>
END:members
</table>
ENDIF:members
IFNOT:members
<blockquote><em>No members given</em></blockquote>
ENDIF:members
}

TEAM_STATUS = %{
<h2>Team Information</h2>
} +
STATUS_COMMON +
%{
IF:ok_to_update
<p>
<form method="post" action="%change_url%">
<input type="submit" value=" UPDATE TEAM INFORMATION ">
</form>
ENDIF:ok_to_update
IF:unused
<form method="post" action="%clari_url%">
  <input name="back_url" value="%back_url%" type="hidden">
  <input name="full_passport" value="%full_passport%" type="hidden">
  <input type="submit" value=" TEAM CLARIFICATIONS ">
</form>
ENDIF:unused
}

DELETE_TEAM = %{
<h2>DELETE TEAM?</h2>
} +
STATUS_COMMON +
%{
<hr>
Do you really want to delete this team? <table>
<tr><td><a href="%no_target%">No</a></td>
<td><a href="%do_delete_url%">Yes</a></td>
</tr></table>
}

############################################################

WARNING_DIFFERENT_AFFILIATE = %{

<h2>Warning: Different Affiliate</h2>

The team manager you have selected, %con_name%, is in the %user_aff%
affiliate, while this team is in %team_aff%.
Is this OK?
<p>
<table><tr>
<td>
  <form method="post" action="%ok_url%">
    <input type="submit" value="Yes">
   </form>
</td>
<td>
  <form method="post" action="%cancel_url%">
    <input type="submit" value="No">
  </form>
</td>
</tr>
</table>
}


####################################################################
NEW_TEAM_MGR_EMAIL = %{
%original_user_name% recently created a Destination Imagination
team (called %team_name%) for the TeamPak '%mem_name%'.

You were given as the team manager.

As a convenience we've created an account for you on the Destination
Imagination ONline system. Using this you can use the web to check the
status of your TeamPak, add and alter team information, download
challenges, and request clarifications.

You can log in to your personal account by visiting http://dionline.org/dion. 

Your user name is:    %user_name%
and your password is: %password%


(This e-mail is automatically generated)
}

####################################################################
EXISTING_TEAM_MGR_EMAIL = %{
%original_user_name% has added you as the Team Manager for the
team called %team_name% in the TeamPak "%mem_name%."

You can log in to your personal account by visiting
http://dionline.org/dion using %user_name% as your user name.  From
there you can check the status of your TeamPak, add and alter team
information, download challenges, and request clarifications.


(This e-mail is automatically generated)
}
####################################################################

end
