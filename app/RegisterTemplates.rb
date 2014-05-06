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

class Register < Application

#######################################################################

NEW_OR_RENEW_TEMPLATE = %{

<h2>TeamPak Application</h2>

 If you are renewing a passport from last year, we still have your
 information on file. Select the [RENEW] button below, and we'll show
 you the information we have and let you update it as
 necessary. You'll need last year's passport number.
<p>
 If this is a new registration, click the [NEW REGISTRATION] button.
<p>
 After you register a TeamPak, you can add teams to it: either now or
 in the future.  
<p>
<form method="post" action="%form_target%">
<table cellspacing="5">
<tr>
 <td align="right" valign="top">
    <input type="submit" name="renew" value="RENEW">
 </td>
 <td>Register a TeamPak based on an existing passport. (If you had a
     membership last year, click on this button)
 </td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr>
 <td align="right" valign="top">
   <input type="submit" name="renew" value="NEW REGISTRATION">
 </td>
 <td>Apply for a brand-new TeamPak.</td>
</tr>
</table>
</form>
}

#######################################################################

AFF_LIST_TEMPLATE = %{

Welcome to Destination Imagination Online. 
<p>
Before we can
start working on your registratiion, we need to know
which <i>affiliate</i> you are associated with. (Within the
United States, affiliates normally form at the state level. Internationally,
affiliates may cover provinces or whole countries.)
<p>
<table cellpadding="5">
START:rows
<tr>
START:cols
<td><a href="%url%?aff_short_name=%val%">%val%</a></td>
END:cols
</tr>
END:rows
</table>
<p>
If you don't see your affiliate listed, click 
<a href="http://www.destinationimagination.org/learn/contacts.html">here</a> 
to get details of how to contact us.
}      


#######################################################################

GET_RENEW_PASSPORT = %{
<h2>Welcome Back!</h2>

Please enter your passport number so we can find your information.  
IF:aff_passport_prefix
We
already know that you're in the %aff_long_name% affiliate and your passport
starts '%aff_passport_prefix%', so you just need to enter the part
after the dash. For passport %aff_passport_prefix%-44556, for example, just
enter 44556. (If you're <i>not</i> in the %aff_short_name% affiliate, it
means our records are wrong. Please click <a href="fixup_target%">here</a> 
and we can correct this.)
ENDIF:aff_passport_prefix

<p>
!INCLUDE!
}
#######################################################################

class <<self
  def head(num, title)
    "<tr class=\"formhead\"><td class=\"formtag\">#{num}</td><td>#{title}</td></tr>"
  end
end

PAY_OPTIONS = %{
<tr>#{Html.tag("I will pay with")}
<td>
<table>
START:pay_options
<tr>
<td>
  <label><input type="radio" name="pay_method" value="%pay_method%"%checked%>%desc%</label>
</td>
IFNOT:is_credit_card
<td>
&nbsp;ref: %input:pay_ref_%pay_method%:15:40% <font size="1">(if known)</font>
</td>
ENDIF:is_credit_card
</tr>
END:pay_options
</table>
</td></tr>
<tr><td>&nbsp;</td></tr>
}

# IF:renewing
# <tr><td colspan="2" class="small">You cannot change the passport name,
# school name, or school district when renewing a passport.
# <tr>#{Html.tag("Passport name")}
#      <td class="formval">%mem_name%</td></tr>
# 
# <tr>#{Html.tag("School/organization name")}
#     <td class="formval">%mem_schoolname% (%full_passport%)</td></tr>
# 
# <tr>#{Html.tag("School district/authority")}
#     <td class="formval">%mem_schooldistrict%</td></tr>
# ENDIF:renewing


######################################################################

MEMBERSHIP_APP = %{
<form method="post" action="%form_target%">
<table cellspacing="0" cellpadding="0">

#{head("1.", "Passport Information")}

<tr><td>&nbsp;</td></tr>
<tr><td></td><td class="formexplain">The <i>passport name</i> is the
name for the overall TeamPak (often this will be the school
name). Later, when you register teams you'll be able to give each team
a name too.</td></tr>
<tr><td>&nbsp;</td></tr>

<tr>#{Html.tag("Passport name")}
     <td><input type="text" name="mem_name" value="%mem_name%" 
      size="30" maxsize="100"> #{Html::Required}</td></tr>

<tr>#{Html.tag("School/organization name")}
    <td><input type="text" name="mem_schoolname" value="%mem_schoolname%" 
      size="30" maxsize="100"> #{Html::Required}</td></tr>

<tr>#{Html.tag("School district/authority")}
    <td><input type="text" name="mem_district" value="%mem_district%" 
      size="30" maxsize="100"> #{Html::Required}</td></tr>


IF:show_passport
<tr><td></td><td class="formexplain">Passport numbers for your affiliate all look
                 like %mem_passport_prefix%-<i>%nnnn%</i>. If you want,
                 you can choose the <i>%nnnn%</i> part. If that passport number
                 is available, it's yours. Alternatively, leave
                 this field blank and we'll allocate a number for you.</td></tr>

<tr>#{Html.tag("Passport")}
    <td><b>%mem_passport_prefix%-</b><input type="text" name="mem_passport" 
           value="%mem_passport%" size="5" maxsize="5"></td></tr>
ENDIF:show_passport

<tr><td>&nbsp;</td></tr>
<tr>#{Html.tag("TeamPak type")}<td>%radio:mem_type:mem_type_opts%
IF:no_aff_fees
<span style="font-size:small"><i>(These prices do not include any
affiliate fees. Please check with your Affiliate Director to see if
any are due.)</i></span>
ENDIF:no_aff_fees
</td></tr>
<tr><td>&nbsp;</td></tr>

IF:other_products
<tr>#{Html.tag("Other services")}
 <td>
   <table>
     <tr class="groupline">
       <th>Qty</th>
       <th>Description</th>
       <th>Price</th>
     </tr>
START:other_products
     <tr class="groupline"><td><input type="text" name="prd_qty_%index%"
              value="%qty%" size="3" maxsize="3" />
             <input type="hidden" name="prd_id_%index%" value="%prd_id%" /></td>
         <td class="spread">%desc%</td>
         <td class="spread" align="right">%price%</td>
     </tr>
END:other_products
   </table>
 </td>
</tr>
<tr><td>&nbsp;</td></tr>
ENDIF:other_products

#{head("2.", "Contact Details")}

<tr><td></td><td class="formexplain">If you're creating this
       TeamPak on behalf of someone else, you should enter
       their e-mail address here. That way they'll also have access to
       this TeamPak to do things like check its status and add new
       teams. If you don't know the contact person's e-mail address
       (or if they don't have one), leave the box blank.
    </td></tr>

START:contact
<tr>#{Html.tag("Contact e-mail")}<td>%input:con_email:30:100%</td></tr>
<tr><td>&nbsp;</td></tr>
END:contact


#{head("3.", "Method of Payment")}

#{PAY_OPTIONS}

#{head("4.", "Next...")}

<tr><td></td><td class="formexplain">Click on the button below to 
continue processing your membership<p>
<input type="submit" value="Continue..." />
</td></tr>

</table>
</form>
}


#######################################################################

ORDER_SUMMARY = %{
<h2>Order Summary</h2>
<table class="small">
<tr valign="top">
  <th>Qty</th>
  <th>Description</th>
  <th>Net<br />Price</th>
  <th>Affiliate<br />Fee</th>
  <th>Unit<br />Price</th>
  <td>&nbsp;</td>
  <th>Total</th>
</tr>
START:product_list
<tr><td>%qty%</td>
<td class="spread">%desc%</td>
<td align="right">$%net%</td>
<td align="right">$%aff_fee%</td>
<td align="right">$%unit%</td>
  <td>&nbsp;</td>
<td align="right">$%price%</td>
</tr>
END:product_list
<tr class="totalline">
 <td></td>
 <td>Subtotal</td>
 <td></td>
 <td></td>
 <td></td>
 <td></td>
 <td class="totalcell">$%total%</td>
</tr>

<tr class="totalline">
 <td></td>
 <td>Shipping</td>
 <td></td>
 <td></td>
 <td></td>
 <td></td>
 <td align="right">$%shipping%</td>
</tr>

IF:intl_surcharge
<tr class="totalline">
 <td></td>
 <td>International dispatch</td>
 <td></td>
 <td></td>
 <td></td>
 <td></td>
 <td align="right">$%intl_surcharge%</td>
</tr>
ENDIF:intl_surcharge


<tr class="totalline">
 <td></td>
 <td>ORDER TOTAL</td>
 <td></td>
 <td></td>
 <td></td>
 <td></td>
 <td class="totalcell">$%grand_total%</td>
</tr>

</table>
}

#######################################################################

MEMBERSHIP_SUMMARY = %{
IF:confirm_url
<h2>Order Summary</h2>

You're just one click away from registering your TeamPak. Please check
the details below. If you find an error, click your browser's [BACK]
button and correct them. Otherwise click on [PLACE ORDER] below to place
your order and register your TeamPak.
ENDIF:confirm_url


IFNOT:confirm_url
<h2>Thank you</h2>
<blink style="font-size: large; color: #a02020">IMPORTANT!</blink>
Here's a quick checklist of things to do to get "<b>%mem_name%</b>"
(%full_passport%) up and running.

<table cellspacing="10">
IF:pay_detail
<tr valign="top">
 <td><img src="/images/check.gif" height="26" width="25"></td>
 <td>Print off this page, and <b>send it</b>, along with your %pay_detail% 
(in U.S. funds)  for
$%grand_total%, made out to Destination ImagiNation, Inc, to
<blockquote>
Destination ImagiNation Headquarters<br>
PO Box 547<br>
Glassboro, NJ 08028
</blockquote></td>
</tr>
ENDIF:pay_detail
<tr valign="top">
 <td><img src="/images/check.gif" height="26" width="25"></td>
 <td>You might want to <b>print a copy</b> of this page for your
 records.</td>
</tr>
<tr valign="top">
 <td><img src="/images/check.gif" height="26" width="25"></td>
 <td>You should <b>contact your State DI Affiliate</b> organization
 for details of what to do next. Click <a
href="http://www.destinationimagination.org/learn/affiliates.html"
target="affs">here</a> for a list of affiliates and their contacts.</td>
</table>
<p>
Welcome to a new year of Destination Imagination. We will ship your
Challenge Materials CD once payment is received.
ENDIF:confirm_url

} + ORDER_SUMMARY + %{

<h2>TeamPak Details</h2>

!INCLUDE!

<p>

IF:confirm_url
<form method="POST" action="%confirm_url%">
IF:cc_fields
START:cc_fields
<input type="hidden" name="%k%" value="%v%">
END:cc_fields
ENDIF:cc_fields
<input type="submit" value=" PLACE ORDER ">
</form>
ENDIF:confirm_url

IFNOT:confirm_url
<form method="POST" action="%register_another_target%">
<input type="submit" value=" ENTER ANOTHER ">
</form>

ENDIF:confirm_url

}

#######################################################################

MEMBERSHIP_DETAILS = %{
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
IF:team_count
<tr>
<td class="formtag">Teams:</td>
<td class="formval">
  %team_count%
IF:teams_url
  (<a href="%teams_url%">see details</a>)
ENDIF:teams_url
</td>
</tr>
ENDIF:team_count

<tr><td>&nbsp;</td></tr>

START:created_by
!INCLUDE!
END:created_by

<tr><td>&nbsp;</td></tr>

START:contact
!INCLUDE!
END:contact

IF:fmt_ship_address
<tr><td>&nbsp;</td></tr>

<tr><td class="formtag">Ship to:</td><td class="formval">%fmt_ship_address%</td></tr>
ENDIF:fmt_ship_address
</table>

}

#######################################################################

CONTACT = %{
<tr>
  <td class="formtag">%label%:</td>
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
</td>
<td><tb>&nbsp</td>
</td></tr>
}

#######################################################################

NEW_USER = %{
IFNOTBLANK:con_email
<h2>Details for %con_email%</h2>
You gave <i>'%con_email%'</i> as a %contact_type%'s
e-mail address. I don't currently know anything about this address.
<p />
If the e-mail address was mistyped, then you can simply
press your browser's <i>BACK</i> button and fix it. Otherwise please
enter any information you know about this person below.
ENDIF:con_email

IFBLANK:con_email

IF:contact_index
<h2>%contact_index% Contact Information</h2>
ENDIF:contact_index

IFNOT:contact_index
<h2>%cap_contact_type% Information</h2>
ENDIF:contact_index

Please enter the details for this %contact_type% below.
<p>
If <em>you</em> are the %contact_type%, hit the back button and enter your
email address in the 'contact' box. Otherwise, please enter the
%contact_type%'s name and at least one address below.
ENDIF:con_email

<p>
<form method="POST" action="%form_target%">
<table>

IFNOTBLANK:con_email
<tr>#{Html.tag("E-Mail")}<td class="formval">%con_email%
<input type="hidden" name="con_email" value="%con_email%"></td></tr>

ENDIF:con_email

<tr>#{Html.tag("Name")}
    <td>%input:con_first_name:15:50%&nbsp;<span class="formlefttag">Last:&nbsp;</span>%input:con_last_name:15:50%</td>
</tr>
<tr>#{Html.tag("Day telephone")}
    <td>#{Html.echo_input("con_day_tel", "%con_day_tel%", 20, 20)}
    <span style="font-size:small">(please include the area code</span></td>
</tr>
<tr>#{Html.tag("Evening")}
    <td>#{Html.echo_input("con_eve_tel", "%con_eve_tel%", 20, 20)}
<span style="font-size:small">in all phone numbers)</span></td>
</tr>
<tr>#{Html.tag("Fax")}
    <td>#{Html.echo_input("con_fax_tel", "%con_fax_tel%", 20, 20)}</td>
</tr>

<tr><td>&nbsp;</td></tr>

<tr><td colspan="2" class="formlefttag">Regular mailing address</td></tr>

START:mail_add
<tr>#{Html.tag("Address line 1")}
    <td>#{Html.echo_input("M_add_line1", "%M_add_line1%", 40, 100)}</td>
</tr>
<tr>#{Html.tag("Address line 2")}
    <td>#{Html.echo_input("M_add_line2", "%M_add_line2%", 40, 100)}</td>
</tr>
<tr>#{Html.tag("City")}
    <td>#{Html.echo_input("M_add_city", "%M_add_city%", 40, 100)}</td>
</tr>
<tr>#{Html.tag("County")}
    <td>#{Html.echo_input("M_add_county", "%M_add_county%", 40, 100)}</td>
</tr>
<tr>#{Html.tag("State/province")}
    <td>#{Html.echo_input("M_add_state", "%M_add_state%", 20, 20)}</td>
</tr>
<tr>#{Html.tag("Zip/postal code")}
    <td>#{Html.echo_input("M_add_zip", "%M_add_zip%", 12, 12)}</td>
</tr>
<tr>#{Html.tag("Country")}
    <td>#{Html.echo_input("M_add_country", "%M_add_country%", 40, 100)}</td>
</tr>
<tr><td></td>
    <td><label class="formlefttag">%check:M_add_commercial% This is a
    commercial address</label></td>
</tr>
END:mail_add

<tr><td>&nbsp;</td></tr>

<tr><td></td>
    <td class="formexplain">Some mailing addresses (such as Post
    Office boxes in the United States) cannot accept delivery from
    certain shipping companies. If the mailing address can
    accept shipments, please make sure the check box below is
    selected, otherwise enter an alternative address in the form below.</td>
</tr>
<tr>
  <td></td>
  <td><label>%check:con_ship_to_mail% Ship to the mail address above</label></td>
</tr>
<tr><td colspan="2" class="formlefttag">Or... enter your shipping
address</td>
</tr>

START:ship_add
<tr>#{Html.tag("Address&nbsp;line&nbsp;1")}
    <td>#{Html.echo_input("S_add_line1", "%S_add_line1%", 40, 100)}</td>
</tr>
<tr>#{Html.tag("Address line 2")}
    <td>#{Html.echo_input("S_add_line2", "%S_add_line2%", 40, 100)}</td>
</tr>
<tr>#{Html.tag("City")}
    <td>#{Html.echo_input("S_add_city", "%S_add_city%", 40, 100)}</td>
</tr>
<tr>#{Html.tag("County")}
    <td>#{Html.echo_input("S_add_county", "%S_add_county%", 40, 100)}</td>
</tr>
<tr>#{Html.tag("State/province")}
    <td>#{Html.echo_input("S_add_state", "%S_add_state%", 20, 20)}</td>
</tr>
<tr>#{Html.tag("Zip/postal code")}
    <td>#{Html.echo_input("S_add_zip", "%S_add_zip%", 12, 12)}</td>
</tr>
<tr>#{Html.tag("Country")}
    <td>#{Html.echo_input("S_add_country", "%S_add_country%", 40, 100)}</td>
</tr>
<tr><td></td>
    <td><label class="formlefttag">%check:S_add_commercial% This is a
    commercial address</label></td>
</tr>
END:ship_add

<tr><td>&nbsp;</td></tr>
<tr><td></td><td><label>%check:user_over_13% this person is 13 or older</label></td></tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="submit" value="Continue..." /></td></tr>
</table>
</form>
}

#######################################################################

NEW_USER_EMAIL = %{
%original_user_name% recently created a Destination Imagination
membership for '%mem_name%' and gave you as the membership
contact person. We'll be e-mailing you details about this membership
shortly.

As a convenience we've created an account for you on the Destination
Imagination ONline system. Using this you can use the web to check the
status of your membership, add and alter team information, download
challenges, and request clarifications.

You can log in to your personal account by visiting

   http://www.dionline.org/dion/dion.rb 

Your user name is:    %user_name%
and your password is: %password%


(This e-mail is automatically generated)

}

#######################################################################

CLARIFICATION_SYSTEM_EMAIL = %{
dion\t%full_passport%-%type_flag%\t%mem_name%
}
#######################################################################

TEAMPAK_STATUS = %{
<h2>TeamPak Status</h2>

<hr>

!INCLUDE!

!INCLUDE!

!INCLUDE!

}


############################################################

UPDATE_TEAMPAK = %{
<h2>Change Contact</h2>
<form method="post" action="%change_contact%">
<table>
<tr><td></td><td>
START:contact
The current contact for this TeamPak is <b>%con_name%</b>
IFNOTBLANK:con_email
(whose e-mail address is '%con_email%').
ENDIF:con_email


IFBLANK:con_email
You can change the contact for this TeamPak, or you can change the
details for the contact you already entered.
ENDIF:con_email

<ul>
<li>To make a different person the contact for this TeamPak:
<ul>
<li><p>If you know this person's e-mail address (and it really does
help things if you do), enter the e-mail address here and click [UPDATE EMAIL].
(If you want to be the contact, enter your own e-mail address here.)
</p><p><blockquote>
Contact e-mail: %input:con_email:40:100%&nbsp;<input type="submit"
value=" UPDATE EMAIL "></blockquote></p></li>
<li><p>If you want to make a different person the contact, but you don't
know that person's e-mail address, click <a href="%add_anon_contact%">here</a>.</p></li>

</ul>

IFBLANK:con_email
<li>If you want to change the details for %con_name% (for example
because you want to change the address), click
<a href="%update_anon_contact%"> here.</li>
ENDIF:con_email
END:contact


</ul>

</td>

</tr>

<tr>

IF:managers_name_url_NOT_USED
<tr><td></td><td>Or, click <a href="%managers_name_url%">here</a> to update
the information you previously entered for %con_name%.</td></tr>
ENDIF:managers_name_url_NOT_USED

IF:email_warning
<tr><td></td><td class="formexplain">(%email_warning%)</td></tr>
ENDIF:email_warning
</table>
</form>

IF:other_products

<h2>Order More Stuff</h2>

IF:current_order
You have already ordered:


You can order additional materials by entering the quantities and
payment details below.
ENDIF:current_order
<table>
<tr>#{Html.tag("Extra materials")}
 <td>
   <table>
     <tr><th>Qty</th><th>Description</th><th>Price</th><th>Shipping</th></tr>
START:other_products
     <tr><td><input type="text" name="prd_qty_%index%"
              value="%qty%" size="3" maxsize="3" />
             <input type="hidden" name="prd_id_%index%" value="%prd_id%" /></td>
         <td>%desc%</td><td align="right">%price%</td><td align="right">%ship%</td>
     </tr>
END:other_products
   </table>
 </td>
</tr>

<tr>#{Html.tag("I will pay with")}<td>%pay_details%</td></tr>
</table>
ENDIF:other_products


<h2>Other Changes</h2>

<ul>

IF:upgrade_url
<li><b>Upgrade to a FivePak</b><br>
You can <a href="%upgrade_url%">upgrade</a> your OnePak to a FivePak.</li>
ENDIF:upgrade_url

<li><b>TeamPak Name, School name, and District name</b><br>
Click
<a href="%req_change_url%">here</a> to request a change. Other
teampak information cannot be changed directly - please
contact your Affiliate Director for more information.</li>
</ul>

<form method="post" action="%cancel_url%">
<input type="submit" value="Main menu">
</form>

IF:never
<tr>
  <td>TeamPak:</td>
  <td class="formval">%mem_name%</td>
  <td width="20">&nbsp;</td>
  <td>Passport:</td>
  <td class="formval">%full_passport%</td>
</tr>
<tr>
  <td>School/org:</td>
  <td class="formval">%mem_schoolname%</td>
  <td></td>
  <td>Affiliate:</td>
  <td class="formval">%aff_short_name%</td>
</tr>
<tr>
  <td>District:</td>
  <td  class="formval" colspan="4">%mem_district%</td>
</tr>
IF:text_status
<tr>
  <td>Status:</td><td  class="formval" colspan="4">%text_status%</td>
</tr>
ENDIF:text_status
ENDIF:never

}


############################################################

HISTORY_LIST = %{

IF:history_list

<p class="portaltitle">History</p>

<table>
START:history_list
<tr class="historyline">
  <td colspan="2">%when%</td>
  <td>%user%</td>
  <td>%from%</td>
  <td>&nbsp</td><td class="historynotes">%notes%</td>
</tr>
END:history_list
</table>
ENDIF:history_list
}

############################################################

UPGRADE_ONEPAK = %{
<h2>Upgrade Your TeamPak</h2>

You can purchase the following:
<ul><li>%upgrade_desc%</li></ul>
for $%upgrade_price%. To select this upgrade, enter payment details
below and press [PURCHASE].
<p>
<form method="post" action="%purchase_url%">
#{PAY_OPTIONS}
<p>
<input type="submit" value="Purchase Upgrade" />
</form>
<p>
<form method="post" action="%cancel_url%">
<input type="submit" value="Cancel" />
</form>

}

############################################################

UPGRADE_SUMMARY = %{
<h2>Please Confirm...</h2>

You're just one click away from upgrading your TeamPak. Please
check the details below, then click the [CONFIRM] button to
verify that everything's OK. 
<p>
IF:cc_fields
Once you've confirmed the order details, you'll be presented with a
separate screen where you can supply information about the credit card
to be used for payment.
<p>
ENDIF:cc_fields

<form method="post"  action="%confirm_url%">

           } + ORDER_SUMMARY + %{
<p>
<input type="submit" value=" CONFIRM UPGRADE ">
IF:cc_fields
START:cc_fields
<input type="hidden" name="%k%" value="%v%">
END:cc_fields
ENDIF:cc_fields

</form>

}

############################################################

WARNING_DIFFERENT_AFFILIATE = %{

<h2>Warning: Different Affiliate</h2>

The user you have selected, %con_name%, is in the %user_aff%
affiliate, while this TeamPak is in %mem_aff%.
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
end

