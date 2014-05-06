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

class Status < Application

######################################################################
# Status menu

STATUS_MENU = %{
<h2>What's Going On...</h2>

<table>
<tr valign="top">
 <td>
    <dl>
    <dt class="adminmenuhead">Summary</dt>
     <dd>
      <ul>
        <li><a href="%big_picture%">The Big Picture</a></li>
        <li><a href="%aff_summary%">Affiliate Setup</a></li>
        <li><a href="%league_table%">League Table</a></li>
        <li><a href="%sales_breakdown%">Sales</a></li>
      </ul>
     </dd>
    </dl>
    <dl>
    <dt class="adminmenuhead">Challenges</dt>
     <dd>
      <ul>
        <li><a href="%cha_down%">Downloads</a></li>
        <li>For an affiliate</li>
      </ul>
     </dd>
    </dl>
  </td>
</tr>
</table>

}

######################################################################
# Simple tabular report

TWOCOL_TABLE = %{
<h2>%title%</h2>
<p>
<table align="center">
<tr class="simpletableheader">
 <td>%h1%</td>
 <td>%h2%</td>
</tr>
START:data
<tr>
  <td>%v1%</td>
  <td align="right">%v2%</td>
</tr>
END:data
</table>

}


######################################################################

BIG_PICTURE = %{

<h2>The Big Picture</h2>
<p>

<table style="font-size:small">
  <tr valign="top">
  <td align="left">
     <table>

     <tr><td colspan="3" class="simpletableheader">Passports:</td></tr>
     <tr><td width="20">&nbsp;</td>
         <td>registered:</td><td align="right">%reg_passports%</td>
     </tr>
     <tr><td></td>
         <td>active:</td><td align="right">%act_passports%</td>
     </tr>
     <tr><td></td>
         <td>suspended:</td><td align="right">%susp_passports%</td>
     </tr>

     <tr><td>&nbsp;</td></tr>
     <tr><td colspan="3" class="simpletableheader">Other counts:</td></tr>
     <tr><td></td><td>Teams:</td><td align="right">%teamcount%</tr>
     <tr><td></td><td>Users:</td><td align="right">%users%</tr>
     <tr><td></td><td>Challenge d/l:</td><td align="right">%chal_dl%</tr>
    </table>

    <p>


   <table cellspacing="5">
   <tr><td colspan="3" class="simpletableheader">Payments:</td></tr>
   <tr><td></td>
       <td>received:</td><td align="right">$%pay_received%</td>
   </tr>
   <tr><td></td>
       <td>applied:</td><td align="right">$%pay_applied%</td>
   </tr>
  </table>

  <p>

   <table cellspacing="5">
   <tr><td colspan="3" class="simpletableheader">How They
   Paid:</td></tr>
   <tr><th align="left">Type</th><th align="left">Count</th><th align="right">Amount</th></tr>
START:type_summary
     <tr><td>%type%</td><td align="right">%count%</td><td align="right">$%amount%</td></tr>
END:type_summary

   </table>

   <p>

   <table cellspacing="5">
   <tr><td colspan="3" class="simpletableheader">Affiliate fees:</td></tr>
   <tr><td></td>
       <td>previously paid:</td><td align="right">$%aff_paid%</td>
   </tr>
   <tr><td></td>
       <td>owed to affs:</td><td align="right">$%aff_unpaid%</td>
   </tr>
   </table>

    <p>

    <table style="font-size:small">

      <tr class="simpletableheader">
        <td colspan="4">TeamPak Totals</td>
      </tr>

      <tr align="right">
        <th></th>
        <th align="right">Act.</th>
        <th align="right">WTPAY</th>
        <th align="right">Susp.</th>
      </tr>

      <tr>
START:teampaks
      <tr align="right">
       <td>%name%&nbsp;</td>
       <td>%ACTIVE%</td>
       <td>%WTPAY%</td>
       <td>%SUSPND%</td>
      <tr>
END:teampaks

    </table>
    
  </td>
  <td width="20">&nbsp;</td>
  <td>
    <img src="/images/signup_rate.png" alt="Signup Rate Graph">
    <p />&nbsp;<p />
    <img src="/images/compare.png" alt="Signup Rate Graph">
  </td>
  </tr>
</table>

<p>
<hr>
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

