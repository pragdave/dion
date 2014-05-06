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

class Portal < Application

######################################################################
# Normal User's Menu

STD_MENU_TEMPLATE = %{

<h2>Welcome, %name%</h2>

IF:aff_is_sa
Welcome to DI Online. As your affiliate is self-administered, you will
have to register TeamPaks directly with them, rather than using this
system. You can find your affiliate's information on the
<a
href="http://www.destinationimagination.org/learn/affiliates.html">affiliate
index</a>.
You can still use DI Online to access facilities of DI and the latest affiliate
news.
ENDIF:aff_is_sa
IFNOT:aff_is_sa
Welcome to DI Online, where you can download challenges, 
register TeamPaks and Teams, track the status of your
orders, and get the latest breaking DI news.
IFNOT:reg_open
<p><b>%reg_open_msg%</b>
ENDIF:reg_open
ENDIF:aff_is_sa
<p>
Keep coming back to this site: we're adding new features and content
all the time.
<p>
<ul>
IF:dl_url
<li><p><a href="%dl_url%">Download</a> this year's
challenges.</p>
ENDIF:dl_url
<!--
IFNOT:dl_url
<li><p>This year's challenges are not yet available.</p>
ENDIF:dl_url
-->
IFNOT:aff_is_sa
IF:reg_open
<li><p><a href="%reg_url%">Buy</a> a TeamPak online.
IF:explain_teams
<span class="hint">(What's a
TeamPak? <a href="#explain">See below</a>)</span>
ENDIF:explain_teams
</p></li>
ENDIF:reg_open
ENDIF:aff_is_sa
<li><p>Purchase <a href="http://www.shopdi.org">other products</a></li></p>
<li><p>Update your <a href="%pd_url%">personal details</a>.</p>
</ul>
And, of course, you can return to the main <a
href="http://www.destinationimagination.org">Destination
ImagiNation</a> web site.

IF:explain_challenges
<hr>
<p class="hint">
<a name="challenges"><b>Challenge Q&A:<b></a>
<br /><i>Q: Where can I download this year's challenges?</i>
<br />A: This year, the callenges are only available for download
once you have paid for at least one TeamPak. Once payment is
received, the download link will appear when you log in to DIONline.
<p />
ENDIF:explain_challenges
IF:explain_teams
<p class="hint">
<a name="explain"><b>TeamPak Q&A:<b></a>
<br /><i>Q: What's the difference between a
TeamPak and a Team?</i>
<br />A: When you purchase a passport from Destination ImagiNation, Inc. you
are purchasing a TeamPak Ð either an Individual (if you plan on
registering only one competitive team ) or a 5-Pak (for up to five
competitive teams).  When you purchase a TeamPak you will get an
INCOMPLETE passport number.  You must register TEAMS into your
TeamPaks to get a complete passport number (A TEAM is defined as a
group of up to seven students who will work together to solve one of
the DI Challenges).  Let me explain...
<p />
<p class="hint">
Every passport number is really composed of three numbers:

<ol class="hint">
<li> The first three digits are the AFFILIATE IDENTIFIER, and they
will be the same for every team in your State/Province/International
Country.  For example an Affiliate Identifier might be "123".

<li>The next five digits are your TEAMPAK IDENTIFIER.  All teams in a
TeamPak will use the same TEAMPAK IDENTIFIER.  For example a TeamPak
Identifier for all teams from the "Smith Elementary TeamPak" might be
"45678".

<li>Finally there is a TEAM IDENTIFIER SUFFIX.  If your membership
purchased an Individual TeamPak, your Team Identifier suffix will be a
"1".  If your membership purchased a 5-Pak your team identifier suffix
will be assigned by DIONline consecutively when you register Teams
into your TeamPak using the DIONline system.  Your Team Identifier
Suffix might be any digit from 1 through 5 - additional numbers,
beginning with 6 will be used for Rising Stars (ages 4-7) Teams. For
example a Team Identifier Suffix for the "Smith Elementary UpBeat
Improv Team" might be "3".
</ol>
</p>
<p class="hint">
So - a COMPLETE Passport number might look like this example:
123-45678-3. Note: you must have a COMPLETE passport number in order
to ask for "Clarifications" or to compete in a tournament.
</p>
ENDIF:explain_teams

}

######################################################################
# RD's BIG menu

RD_MENU_TEMPLATE = %{

<p class="portaltitle">RD Functions: %reg_name%</p>

IF:ass_to_reg_url
IF:unassigned_cities
<h4>TeamPaks need a Home!</h4>
TeamPaks in the following cities have not yet been assigned to
regions. If you know where any of these belong, click
<a href="%ass_to_reg_url%">here</a>.
<blockquote>
%unassigned_cities%
</blockquote>
<p>
ENDIF:unassigned_cities
ENDIF:ass_to_reg_url

<dl>
<dt class="adminmenuhead">Snapshot</dt>
 <dd>
   <ul>
     <li>%aff_short_name% has %active_1%, %active_5%, and %waitpay% waiting to pay.</li>
IF:empty_teampaks_url
<li><a
href="%empty_teampaks_url%">%empty_teampaks%</a>
in %reg_name% currently have no teams registered.</li>
ENDIF:empty_teampaks_url

IFNOT:empty_teampaks_url
<li>All active TeamPaks in %reg_name% have at least one team registered.</li>
ENDIF:empty_teampaks_url
</ul></dd>
<dt class="adminmenuhead">Access Information</dt>
 <dd>
  <ul>
    <li>A <a href="%affiliate_summary%">summary of the status</a>
        of %aff_short_name%</li>
     <li><a href='%user_search%'>Find</a> an individual</li>
     <li>Produce <a href="%lists%">reports</a> on teampaks, teams, and individuals</li>
     <li><a href="%download%">Download</a> data to your PC</li>
  </ul>
 </dd>
<dt class="adminmenuhead">TeamPak Maintenance</dt>
 <dd>
  <ul>
IF:ass_to_reg_url
    <li><a href="%ass_to_reg_url%">Assign</a> TeamPaks to Regions</li>
    <li><a href="%reass_to_reg_url%">Reassign</a> TeamPaks to
    different regions</li>
ENDIF:ass_to_reg_url
    <li>Add and maintain <a href="%change_teams%">teams</a> for an existing
        TeamPak</li>
    <li><a href="%teampak_search%">Search</a> for TeamPaks and
    display their status</li>
  </ul>
 </dd>
<dt class="adminmenuhead">Communicate</dt>
 <dd>
  <ul>
    <li><a href="%update_news%">Add a news</a> item</li>
    <li><a href="../doc/userguides/RD%20DION%20Manual.pdf">RD User's Guide</a></li>
  </ul>
 </dd>
</dl>

}

######################################################################
# AD's BIG menu

AD_MENU_TEMPLATE = %{

<p class="portaltitle">AD Functions: %aff_short_name%</p>

IF:unassigned_cities
<h4>TeamPaks need a Home!</h4>
TeamPaks in the following cities have not yet been assigned to
regions. If you know where any of these belong, click
<a href="%ass_to_reg_url%">here</a>.
<blockquote>
%unassigned_cities%
</blockquote>
<p>
ENDIF:unassigned_cities

IF:not_set_up
<table width="100%" border="5" bordercolor="red">
<tr><td>Your affiliate is not yet fully set up. Before folks
can register online, you'll need to do the following:
<p>
<ul>
IF:setup_chall
<li>Set up your affiliate's <a href="%maint_chall%">challenges</a>
ENDIF:setup_chall
IF:setup_reg
<li>Create the list of your affiliate's <a href="%maint_reg%">regions</a>.
ENDIF:setup_reg
IF:setup_fees
<li>Set up any <a href="%maint_prod%">affiliate fees</a>.
ENDIF:setup_fees
IF:setup_dates
<li>Set up registration <a href="%maint_dates%">dates</a>.
ENDIF:setup_dates
</ul>
</table>
ENDIF:not_set_up

<dl>
<dt class="adminmenuhead">Snapshot</dt>
 <dd>
   <ul>
     <li>%aff_short_name% has %active_1%, %active_5%, and %waitpay% waiting to pay.</li>

IF:empty_teampaks_url
<li><a
href="%empty_teampaks_url%">%empty_teampaks%</a>
currently have no teams registered.</li>
ENDIF:empty_teampaks_url

IFNOT:empty_teampaks_url
<li>All active TeamPaks have at least one team registered.</li>
ENDIF:empty_teampaks_url
</ul></dd>
<dt class="adminmenuhead">Access Information</dt>
 <dd>
  <ul>
    <li>A <a href="%affiliate_summary%">summary of the status</a>
        of %aff_short_name%</li>
     <li><a href='%user_search%'>Find</a> an individual (and optionally
     update their information)</li>
     <li>Produce <a href="%lists%">reports</a> on teampaks, teams, and individuals</li>
     <li><a href="%download%">Download</a> data to your PC</li>
     <li>List information on <a href="%product_summary%">products</a>
     in your affiliate.</li>
  </ul>
 </dd>
<dt class="adminmenuhead">TeamPaks and Maintenance</dt>
 <dd>
  <ul>
IF:aff_has_regions
    <li><a href="%ass_to_reg_url%">Assign</a> TeamPaks to
    regions, or <a href="%reass_to_reg_url%">reassign</a> TeamPaks to
    different regions</li>
ENDIF:aff_has_regions
    <li><a href="%teampak_search%">Search</a> for TeamPaks and
    display their status</li>
    <li><a href="%order_teampak%">Create</a> or
           <a href="%renew_teampak%">Renew</a> a TeamPak on behalf of
       another user</a></li>
    <li><a href="%order_general%">Order</a> other DI products on behalf of
       another user</a></li>
    <li>Maintain <a href="%change_teams%">teams</a> for an existing
        TeamPak</li>
    <li>Order <a href="%order_ad%">affiliate supplies</a></li>
  </ul>
 </dd>
<dt class="adminmenuhead">Communicate</dt>
 <dd>
  <ul>
    <li><a href="%update_news%">Add a news</a> item</li>
    <li><a href="../doc/userguides/AD%20DION%20Manual.pdf">AD
    User's Guide</a></li>
  </ul>
 </dd>
<dt class="adminmenuhead">Setup %aff_short_name%</dt>
 <dd>
   <ul>
     <li><a href="%maint_chall%">Challenges</a></li>
     <li><a href="%maint_reg%">Regions</a></li>
     <li><a href="%maint_prod%">Products</a></li>
     <li><a href="%maint_dates%">Dates</a></li>
   </ul>
  </dd>
</dl>

}

######################################################################
# Headquarters staff menu

HQ_MENU_TEMPLATE = %{
<!--
<p class="portaltitle">HQ Administration Functions</p>
-->
<table>
<tr valign="top">
 <td>
    <dl>
    <dt class="adminmenuhead">Information</dt>
     <dd>
      <ul class="portalsublist">
        <li><a href="%status_menu%">Status reports</a></li>
        <li><a href="%lists%">Reports</a> on teampaks,<br>teams, and
        individuals</li>
        <li><a href="%prd_list%">Product list</a> (or
             <a href="%product_summary%">affiliate fees</a>)</li>
        <li><a href="%download%">Download</a> data to your PC</li>
      </ul>
     </dd>
    <dt class="adminmenuhead">Maintain</dt>
     <dd>
      <ul class="portalsublist">
        <li><a href="%maint_aff%">Affiliates</a></li>
        <li><a href="%maint_chall%">Challenges</a></li>
        <li><a href="%maint_prod%">Products</a></li>
        <li><a href="%maint_sales%">Shipping Charges</a></li>
      </ul>
     </dd>
    <dt class="adminmenuhead">Users</dt>
     <dd>
      <ul class="portalsublist">
        <li><a href="%user_search%">Find/Change</a></li>
        <li><a href="%user_create%">Create</a></li>
        <!--        <li><a href="%become_user%">Become</a>...</li> -->
        <li>Roles:<br>
            &bull;&nbsp;<a href="%role_ad%">ADs</a>
            &bull;&nbsp;<a href="%role_icm%">ICMs</a><br>
            &bull;&nbsp;<a href="%role_hq%">HQ staff</a>
            &bull;&nbsp;<a href="%role_hqo%">Observer</a>
        </li>
        <li><a href="%update_news%">Communicate</a></li>
      </ul>
     </dd>
    <dt class="adminmenuhead">TeamPaks</dt>
     <dd>
      <ul class="portalsublist">
        <li><a href="%teampak_search%">Find</a>,
            <a href="%delete_teampak%">Delete</a>, or
            <a href="%alter_teampak%">Alter</a></li>
        <li>Maintain <a href="%change_teams%">teams</a></li>
IF:cr_count
        <li><a href="%cr_url%">Change</a> (%cr_count% pending)</li>
ENDIF:cr_count
      </ul>
     </dd>

    </dl>
  </td>
  <td width="20">&nbsp;</td>
 <td>
    <dl>

     <dt class="adminmenuhead">Orders</dt>
     <dd>
      <ul class="portalsublist">
         <li><a href="%find_order%">Find</a>,
             <a href="%delete_order%">Delete</a>, or
             <a href="%edit_order%">Alter</a></li>
         <li><a href="%order_teampak%">Make</a> or <a
             href="%renew_teampak%">Renew</a>
             a TeamPak Application</li>
         <li><a href="%upgrade_teampak%">Upgrade</a> existing TeamPak</li>
         <li>Place <a href="%order_general%">other orders</a></li>
         <li><a href="%adjust_order%">Adjust</a> an order</li>
         <li><a href="%partially_paid%">List partially paid</a></li>
      </ul>
     </dd>

     <dt class="adminmenuhead">Payments</dt>
     <dd>
      <ul class="portalsublist">
         <li><a href="%find_payment%">Find</a>,
             <a href="%delete_payment%">Delete</a>, or
             <a href="%edit_payment%">Alter</a></li>
         <li><a href="%rec_pay_check%">Post Direct Check</a></li>
         <li><a href="%check_for_po%">Post Check</a> for PO</li>
         <li><a href="%daily_money%">Money Reports</a></li>
      </ul>
     </dd>

     <dt class="adminmenuhead">Receivables</dt>
     <dd>
      <ul class="portalsublist">
        <li>List <a href="%unpaid_pos%">unpaid POs</a></li>
        <li>List <a href="%unpaid_shipped%">unpaid shipped orders</a></li>
         <li><a href="%rec_pay_po%">Post PO</a></li>
        <li><a href="%reprint_inv%">Reprint invoices/receipts</a></li>
        <li><a href="%apply_po%">Apply</a> existing PO/check</li>
      </ul>
     </dd>

     <dt class="adminmenuhead">Shipping</dt>
     <dd>
      <ul class="portalsublist">
         <li><a href="%shipping_summary%">Print labels/packing slips</a></li>
         <li>Daily <a href="%shipping_report%">shipping report</a>.</li>
      </ul>
     </dd>


      <dt class="adminmenuhead">Credit Cards</dt>
      <dd>
        <ul class="portalsublist">
           <li><a href="%cc_log%">Credit card log</a></li>
        </ul>
      </dd>

     <dt class="adminmenuhead">Affiliate Fees</dt>
     <dd>
      <ul class="portalsublist">
         <li><a href="%cycle_summary%">Affiliate status</a></li>
         <li><a href="%complete_cycle%">Generate statements</a></li>
      </ul>
     </dd>

    </dl>
  </td>
</tr>
</table>
}

######################################################################
# Headquarters observer menu

HQO_MENU_TEMPLATE = %{

<p class="portaltitle">Eye on DION</p>
<ul>
  <li><p><a href="%status_menu%">Status reports</a></p></li>
  <li><p><a href="%lists%">Reports</a> on teampaks, teams, and
        individuals</p></li>
  <li><p><a href="%download%">Download</a> data to your PC</p></li>
  <li><p>Find <a href="%user_search%">Users</a></p></li>
  <li><p>Find <a href="%teampak_search%">TeamPaks</a></p></li>
  <li><p><a href="%cycle_summary%">Affiliate fee status</a></p></li>
</ul>
}

######################################################################
# Standard news inclusion
######################################################################
# Standard news inclusion

PORTAL_NEWS = %{
IF:news
<table cellspacing="0" cellpadding="0" width="100%">
<tr class="portalnewstitlerow">
 <td class="portalnewstitlecell">Top DI News for %name%</td>
 <td class="portalnewstitleoptions">
   <a class="portaltitlelink" href="%all_news_url%">All news</a>
   <a class="portaltitlelink" href="%refresh_news_url%">Refresh</a>&nbsp;
 </td>
</table>
<ul class="portalmsglist">
START:news
<li><span class="portalmsghdr">%news_byline%:</span>
<a href="%news_url%" class="portalmsg">%news_summary%</a>
</li>
END:news
</ul>
ENDIF:news
IFNOT:news
<table cellspacing="0" cellpadding="0" width="100%">
<tr class="portalnewstitlerow">
 <td class="portalnewstitlecell">%name%'s Home Page</td>
 <td class="portalnewstitleoptions">
   <a class="portaltitlelink" href="%refresh_news_url%">Check for news</a>&nbsp;
 </td>
</table>
ENDIF:news
}


######################################################################
# Our standard page layout

STANDARD_HEADER = %{
<table width="100%">
<tr valign="top">
<td>
#{PORTAL_NEWS}
</td>

IF:sidemenu
<td width="230" class="portalmenubox">
<table cellspacing="0" cellpadding="0" width="100%">
<tr class="portalnewstitlerow">
 <td class="portalnewstitlecell">My Menu</td>
</table>

<ul class="yourmenu">
START:sidemenu
<li class="yourmenu">
IF:url
<a href="%url%">%text%</a>
ENDIF:url
IFNOT:url
%text%
ENDIF:url
</li>
END:sidemenu
<li class="yourmenu"><a href="http://www.shopdi.org">Other products</a></li>
</ul>
</td>
ENDIF:sidemenu
</table>
}

######################################################################

PORTAL_PAGE = %{

#{STANDARD_HEADER}

!INCLUDE!

}

######################################################################

STATUS_TEAMPAKS = 
%{IF:mems
<p class="portaltitle">Your TeamPaks</p>
IF:reg_open
Here is a list of all the TeamPaks associated with you.
IF:any_suspended
<p class="small">
If a TeamPak
has a status of "Inactive," then it was associated with you last year,
but has not been re-registered this year. If you want to renew it, click
the "[RENEW]" button, and you'll be given the opportunity to update
any details before placing your order. If you don't want to renew it,
just ignore the entry; you won't get charged for it unless you choose
to renew.
</p>
ENDIF:any_suspended
IF:any_not_suspended
<p class="small">
For this year's TeamPaks, you can click on the TeamPak name to get
details,
IF:any_change_url
click the "[CHANGE]" button to update details,
ENDIF:any_change_url
or click
"[TEAMS]" to add, remove, or maintain individual teams.
</p>
ENDIF:any_not_suspended
ENDIF:reg_open

IFNOT:reg_open
<p class="small">
The following TeamPak(s) are associated with you from last year. You
can click on a TeamPak's name to get more details. Once
registration opens, you'll be able to renew any Teampaks from last
year (if you want to). You'll
also be able to create new TeamPaks at that time.
%reg_open_msg%
</p>
ENDIF:reg_open

<table class="portalteamstable">
<tr>
  <th>Passport</th>
  <th>Pak</th>
  <th>TeamPak/School Name</th>
  <th>Status</th>
  <th width="30">&nbsp;</th>
  <th colspan="3">Actions...</th>
</tr>
START:mems
<tr valign="top">
  <td>%full_passport%</td>
  <td align="center">%mem_type%</td>
  <td><span><a href="%status_url%"  class="portalmemname">%mem_name%</a></span></td>
  <td>%mem_state%</td>
  <td></td>
IF:change_url
  <td class="portalaction"><a href="%change_url%">CHANGE</a></td>
ENDIF:change_url
IFNOT:change_url
  <td></td>
ENDIF:change_url
  <td class="spread">&nbsp;</td>
IF:team_url
  <td class="portalaction"><a href="%team_url%">TEAMS</a></td>
ENDIF:team_url
IF:reg_open
IF:renew_url
  <td class="portalaction"><a href="%renew_url%">RENEW</a></td>
ENDIF:renew_url
ENDIF:reg_open
</tr>
<tr><td></td><td></td><td class="portalmemname">%mem_schoolname%</td></tr>
END:mems
</table>
ENDIF:mems
}


STATUS_TEAMS = 
%{IF:teams
<p class="portaltitle">Your Teams</p>
<table class="portalordertable">
<tr><th align="left">Passport</th>
    <th align="left">Level</th>
    <th align="left">Challenge</th>
    <th align="left">Team Name</th>
    <th width="20">&nbsp;</th>
    <th colspan="3">Actions...</th>
</tr>
START:teams
<tr>
 <td class="spread">%team_passport%</td>
 <td class="spread">%level_name%</td>
 <td class="spread">%challenge%</td>
 <td><a href="%team_status_url%"><b>%team_name%</b></a></td>
 <td></td>
 <td class="portalaction"><a href="%change_url%">Change</a></td>
 <td>&nbsp;</td>
 <td class="portalaction"><a href="%delete_url%">Delete</a></td>
</tr>
END:teams
</table>
ENDIF:teams
}

STATUS_ORDERS =
%{IF:orders
<p class="portaltitle">Order Status</p>
<table class="portalordertable">
START:orders
<tr>
  <td>%fmt_order_date%</td>
  <td class="portalordercell">%order_passport%</td>
  <td class="portalordercell"><a href="%order_url%">Order #%order_id%</a></td>
  <td></td>
  <td colspan="2" class="portalorderstatus">%order_status%</td>
</tr>
START:product_list
<tr>
  <td></td><td class="portalordercell" colspan="2">&bull; %fmt_desc%</td>
  <td align="right">$%price%</td>
  <td class="portalorderstatus" colspan="2">%status%</td>
</tr>
END:product_list
IF:intl_surcharge
<tr>
  <td></td><td class="portalordercell" colspan="2">&bull; International dispatch</td>
  <td align="right">$%intl_surcharge%</td>
</tr>
ENDIF:intl_surcharge
<tr>
  <td></td><td class="portalordercell" colspan="2">&bull; Shipping</td>
  <td align="right">$%shipping%</td>
  <td></td>
  <td class="totalcell">$%grand_total%</td>
</tr>
<tr><td>&nbsp;</td></tr>
END:orders
</table>
ENDIF:orders
}

######################################################################

end
