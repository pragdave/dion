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

class Lists < Select


######################################################################
REPORT = %{

<h2>Report Generated: %when%</h2>

<table style="font-size:small">
!INCLUDE!
</table>

}

######################################################################

TEAMPAK_HEADER = %{

<thead>

IF:mem_passport
<tr>
 <th>Passport</th>
 <th align="left">TeamPak Name</th>
 <th>Type</th>
 <th>Status</th>
</tr>
ENDIF:mem_passport

</thead>
}


######################################################################

TEAMPAK_TEMPLATE = %{

IF:mem_passport
<tr>
 <td>%mem_passport_prefix%-%mem_passport%&nbsp;</td>
 <td><a href="%url%"><b>%mem_name%</b></a>&nbsp;</td>
 <td>%mem_type% Pak&nbsp;</td>
 <td>%mem_state%</td>
</tr>
ENDIF:mem_passport

IF:mem_schoolname
<tr>
 <td class="replab">school:</td>
 <td colspan>%mem_schoolname%</td>
</tr>
<tr>
 <td class="replab">district:</td>
 <td colspan>%mem_district%, %reg_name%</td>
</tr>
ENDIF:mem_schoolname

IF:c2_con_first_name
<tr>
 <td class="replab">contact:</td>
 <td>%c2_con_first_name% %c2_con_last_name% (%c2_con_email%)<br>
Tel
IFNOTBLANK:c2_con_day_tel
day: %c2_con_day_tel%,
ENDIF:c2_con_day_tel
IFNOTBLANK:c2_con_eve_tel
eve: %c2_con_eve_tel%,
ENDIF:c2_con_eve_tel
IFNOTBLANK:c2_con_fax_tel
fax: %c2_con_fax_tel%
ENDIF:c2_con_fax_tel
<br>
%a2m_add_line1%
IFNOTBLANK:a2m_add_line2
%a2m_add_line2%
ENDIF:a2m_add_line2
%a2m_add_city%, %a2m_add_state%, %a2m_add_zip%,<br>
IFNOTBLANK:a2m_add_county
%a2m_add_county% County<br>
ENDIF:a2m_add_county
%a2m_add_country%
</td></tr>
ENDIF:c2_con_first_name

IF:c1_con_first_name
<tr>
 <td class="replab">creator:</td>
 <td>%c1_con_first_name% %c1_con_last_name% (%c1_con_email%)<br>
Tel
IFNOTBLANK:c1_con_day_tel
day: %c1_con_day_tel%,
ENDIF:c1_con_day_tel
IFNOTBLANK:c1_con_eve_tel
eve: %c1_con_eve_tel%,
ENDIF:c1_con_eve_tel
IFNOTBLANK:c1_con_fax_tel
fax: %c1_con_fax_tel%
ENDIF:c1_con_fax_tel
<br>
%a1m_add_line1%
IFNOTBLANK:a1m_add_line2
%a1m_add_line2%
ENDIF:a1m_add_line2
%a1m_add_city%, %a1m_add_state%, %a1m_add_zip%,<br>
IFNOTBLANK:a1m_add_county
%a1m_add_county% County<br>
ENDIF:a1m_add_county
%a1m_add_country%
</td></tr>
ENDIF:c1_con_first_name

}

######################################################################


TEAM_HEADER = %{

<thead>

IF:team_name
<tr>
 <th>Passport</th>
 <th align="left">Team Name, School Name</th>
 <th>Challenge</th>
 <th>Level</th>
</tr>
ENDIF:team_name

</thead>
}

######################################################################

TEAM_TEMPLATE = %{

IF:team_name
<tr>
 <td>%mem_passport_prefix%-%mem_passport%-%team_passport_suffix%</td>
 <td><a href="%url%"><b>%team_name%, %mem_schoolname%</b></a></td>
 <td>%chd_name%</td>
 <td>%team_level%</td>
</tr>
ENDIF:team_name

IF:Name_1
<tr>
<td class="replab">Members:</td>
<td>
<table>
<tr><td>%Name_1%</td><td>%Dob_1%</td><td>%Grade_1%</td></tr>
IFNOTBLANK:Name_2
<tr><td>%Name_2%</td><td>%Dob_2%</td><td>%Grade_2%</td></tr>
ENDIF:Name_2
IFNOTBLANK:Name_3
<tr><td>%Name_3%</td><td>%Dob_3%</td><td>%Grade_3%</td></tr>
ENDIF:Name_3
IFNOTBLANK:Name_4
<tr><td>%Name_4%</td><td>%Dob_4%</td><td>%Grade_4%</td></tr>
ENDIF:Name_4
IFNOTBLANK:Name_5
<tr><td>%Name_5%</td><td>%Dob_5%</td><td>%Grade_5%</td></tr>
ENDIF:Name_5
IFNOTBLANK:Name_6
<tr><td>%Name_6%</td><td>%Dob_6%</td><td>%Grade_6%</td></tr>
ENDIF:Name_6
IFNOTBLANK:Name_7
<tr><td>%Name_7%</td><td>%Dob_7%</td><td>%Grade_7%</td></tr>
ENDIF:Name_7
</table>
</td>
</tr>
ENDIF:Name_1

IF:X1st_TM_First_Name
<tr>
 <td class="replab">1st manager:</td>
 <td>%X1st_TM_First_Name% %X1st_TM_Last_Name% (%X1st_TM_E_Mail%)<br>
Tel
IFNOTBLANK:X1st_TM_Day_Tel
day: %X1st_TM_Day_Tel%,
ENDIF:X1st_TM_Day_Tel
IFNOTBLANK:X1st_TM_Eve__Tel
eve: %X1st_TM_Eve__Tel%,
ENDIF:X1st_TM_Eve__Tel
IFNOTBLANK:X1st_TM_Fax
fax: %X1st_TM_Fax%
ENDIF:X1st_TM_Fax
<br>
%X1st_TM_Add_Line1%
IFNOTBLANK:X1st_TM_Add_Line2
%X1st_TM_Add_Line2%
ENDIF:X1st_TM_Add_Line2
%X1st_TM_City%, %X1st_TM_State%, %X1st_TM_Zip%,<br>
IFNOTBLANK:X1st_TM_County
%X1st_TM_County% County<br>
ENDIF:X1st_TM_County
%X1st_TM_Country%
</td></tr>
ENDIF:X1st_TM_First_Name

IF:TM_1__First_name
<tr><td class="replab">Managers:</td>
<td>
%TM_1__First_name% %TM_1__Last_name% (%TM_1__E_Mail%)<br>
IFNOTBLANK:TM_2__First_name
%TM_2__First_name% %TM_2__Last_name% (%TM_2__E_Mail%)<br>
ENDIF:TM_2__First_name
IFNOTBLANK:TM_3__First_name
%TM_3__First_name% %TM_3__Last_name% (%TM_3__E_Mail%)<br>
ENDIF:TM_3__First_name
IFNOTBLANK:TM_4__First_name
%TM_4__First_name% %TM_4__Last_name% (%TM_4__E_Mail%)<br>
ENDIF:TM_4__First_name
IFNOTBLANK:TM_5__First_name
%TM_5__First_name% %TM_5__Last_name% (%TM_5__E_Mail%)<br>
ENDIF:TM_5__First_name
</td>
</tr>
ENDIF:TM_1__First_name
}

######################################################################

USER_HEADER = %{

<thead>

IF:con_email
<tr>
 <th>Name</th>
 <th align="left">E-Mail</th>
 <th>Nickname</th>
 <th>Affiliate</th>
</tr>
ENDIF:con_email

</thead>
}

######################################################################

USER_TEMPLATE = %{

IF:con_email
<tr>
 <td><a href="%url%"><b>%con_first_name% %con_last_name%</b></a></td>
 <td>%con_email%</td>
 <td>%user_acc_name%</td>
 <td>%aff_short_name%</td>
</tr>
ENDIF:con_email

IF:con_day_tel
<tr>
 <td class="replab">telephone:</td>
<td>
IFNOTBLANK:con_day_tel
day: %con_day_tel%,
ENDIF:con_day_tel
IFNOTBLANK:con_eve_tel
eve: %con_eve_tel%,
ENDIF:con_eve_tel
IFNOTBLANK:con_fax_tel
fax: %con_fax_tel%
ENDIF:con_fax_tel
</td>
</tr>
ENDIF:con_day_tel

IF:mail_add_line1
<tr>
 <td class="replab">mail address:</td>
<td>
%mail_add_line1%
IFNOTBLANK:mail_add_line2
%mail_add_line2%
ENDIF:mail_add_line2
%mail_add_city%, %mail_add_state%, %mail_add_zip%,<br>
IFNOTBLANK:mail_add_county
%mail_add_county% County<br>
ENDIF:mail_add_county
%mail_add_country%
</td>
</tr>
ENDIF:mail_add_line1

IF:ship_add_line1
<tr>
 <td class="replab">ship address:</td>
<td>
%ship_add_line1%
IFNOTBLANK:ship_add_line2
%ship_add_line2%
ENDIF:ship_add_line2
%ship_add_city%, %ship_add_state%, %ship_add_zip%,<br>
IFNOTBLANK:ship_add_county
%ship_add_county% County<br>
ENDIF:ship_add_county
%ship_add_country%
</td>
</tr>
ENDIF:ship_add_line1
}

end
