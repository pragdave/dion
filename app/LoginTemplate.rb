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

class Login < Application

#############################################################################

MAIN_LOGIN = %{
<h2>DIONline!</h2>

To get access to all the features of DIONline, you'll
have to log in. If you already  have an account with us, enter 
your e-mail address and password below and press 
login.
<p>
If you don't have an account yet, click
<a href="%create_ac%"><b>here</b></a> to set one up. It only takes a minute.
<p />
<hr width="30%" />
<p />
<form method="post" action="%form_target%">
<table>
<tr valign="top"><td align="right">Nickname or E-Mail address:</td>
    <td><input type="text" name="user_acc_name" value="%user_acc_name%"></td>
</tr>
<tr><td align="right">Password:&nbsp;</td>
    <td><input type="password" name="user_password" value=""></td>
</tr>
<tr><td/td>
    <td><input type="submit" value="Log In"></td>
</tr>
</table>    
</form>
<p />
<hr width="30%" />
Forgotten your password? Click
<a href="%forgot_ref%">here</a> and we'll see if we can help.
<p />
<p class="small">Do you have any ideas on how to make DIONline even better?
Click <a href="mailto:dionlinesuggestions@destinationimagination.org">here</a> to let us know.</p>
}

#############################################################################

RETRY_LOGIN = %{

<h2>Hmmm...</h2>

We don't have that e-mail address or password in the system.  If
you've forgotten your password, click <a
href="%forgot_ref%">here</a>.  To create a new account click <a
href="%create_ac%">here</a>. 
              
<p />
<form method="post" action="%form_target%">
<table>
<tr><td align="right">E-Mail address:&nbsp;</td>
    <td><input type="text" name="user_acc_name" value="%user_acc_name%"></td>
</tr>
<tr><td align="right">Password:&nbsp;</td>
    <td><input type="password" name="user_password" value=""></td>
</tr>
<tr><td/td>
    <td><input type="submit" value="Log In"></td>
</tr>
</table>    
</form>
}

#######################################################################

EDIT_USER = %{

<h2>Create/Edit Profile</h2>

<form method="POST" action="%form_target%">
<table>

IF:first_time
<tr><td></td>
  <td class="formexplain" bgcolor="#efe0c0">As this is the first
    time you've logged in, could you spend a minute checking the
    details below are up to date? Also, if we don't have an address
    for you on file, could you enter one below? Once you've done this,
    we won't bother you for it again. Thanks!</td>
</tr>
<tr><td>&nbsp;</td></tr>
ENDIF:first_time

IFNOT:third_party
<tr><td></td>
    <td class="formexplain">We use your e-mail address both to
    send you information and to identify you (so, for example, you can
    log on using your e-mail address). If you want, you can also
    enter a nick name to use instead of an e-mail address when
    identifying yourself to the system. (Your e-mail address and
    nick name cannot be the same as anyone else's)</td>
</tr>
ENDIF:third_party

<tr>#{Html.tag("E-Mail")}<td>%input:con_email:40:100%</td></tr>
<tr>#{Html.tag("Nickname")}<td>%input:user_acc_name:40:100%</td></tr>

<tr><td>&nbsp;</td></tr>

<tr>
IF:third_party
#{Html.tag("User's name")}
ENDIF:third_party
IFNOT:third_party
#{Html.tag("Your name")}
ENDIF:third_party
  <td>%input:con_first_name:15:50% 
    <font size="-1">Last:&nbsp;</font> %input:con_last_name:15:50%</td></tr>
<tr>#{Html.tag("Day phone")}<td>%input:con_day_tel:20:20%
<span style="font-size:small">(please include the area code</span></td></tr>
<tr>#{Html.tag("Evening")}<td>%input:con_eve_tel:20:20%
<span style="font-size:small">in all phone numbers)</span></td></tr>
<tr>#{Html.tag("Fax")}<td>%input:con_fax_tel:20:20%</td></tr>

<tr><td>&nbsp;</td></tr>
IF:third_party
<tr><td></td><td class="formexplain">Select this user's primary Affiliate.</td>
</tr>
ENDIF:third_party
IFNOT:third_party
<tr><td></td><td class="formexplain">Local organizations which sponsor
the DI program (for example in a
state, province, or country) are known as Affiliates.
Most of us interact with a single
DI Affiliate, our primary Affiliate. Some people may have teams in one
Affiliate, but volunteer in others. Enter your primary (or only)
Affiliate here. You'll automatically be associated with other
Affiliates as you interact with them.</td>
</tr>
ENDIF:third_party

<tr>#{Html.tag("DI Affiliate (State, Province or Country)")}<td>%vsortddlb:user_affiliate:user_affiliate_opts%</td></tr>
<tr><td>&nbsp;</td></tr>

<tr><td colspan="2" class="portaltitle">Regular mailing address</td></tr>

START:mail_add
<tr>#{Html.tag("Address line 1")}<td>%input:M_add_line1:40:100%</td></tr>
<tr>#{Html.tag("Address line 2")}<td>%input:M_add_line2:40:100%</td></tr>
<tr>#{Html.tag("City")}<td>%input:M_add_city:40:100%</td></tr>
<tr>#{Html.tag("County")}<td>%input:M_add_county:40:100%</td></tr>
<tr>#{Html.tag("State&nbsp;(or&nbsp;province)")}<td>%input:M_add_state:20:20%</td></tr>
<tr>#{Html.tag("Zip/postal code")}<td>%input:M_add_zip:12:12%</td></tr>
<tr>#{Html.tag("Country")}<td>%input:M_add_country:40:100%</td></tr>
<tr><td></td>
    <td><label class="formlefttag">%check:M_add_commercial% This is a
    commercial address</label></td>
</tr>
END:mail_add

<tr><td>&nbsp;</td></tr>

<tr><td colspan="2" class="portaltitle">Shipping address</td></tr>
<tr><td></td>
    <td class="formexplain">Some mailing addresses (such as Post
    Office boxes in the United States) cannot accept delivery from
    certain shipping companies. If your mailing address can
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
<tr>#{Html.tag("Address&nbsp;line&nbsp;1")}<td>%input:S_add_line1:40:100%</td></tr>
<tr>#{Html.tag("Address line 2")}<td>%input:S_add_line2:40:100%</td></tr>
<tr>#{Html.tag("City")}<td>%input:S_add_city:40:100%</td></tr>
<tr>#{Html.tag("County")}<td>%input:S_add_county:40:100%</td></tr>
<tr>#{Html.tag("State/province")}<td>%input:S_add_state:20:20%</td></tr>
<tr>#{Html.tag("Zip/postal code")}<td>%input:S_add_zip:12:12%</td></tr>
<tr>#{Html.tag("Country")}<td>%input:S_add_country:40:100%</td></tr>
<tr><td></td>
    <td class="formlefttag"><label>%check:S_add_commercial% This is a
    commercial address</label></td>
</tr>
END:ship_add


<tr><td>&nbsp;</td></tr>
<tr><td></td><td><label>%check:user_over_13%
IF:third_party
This user is
ENDIF:third_party
IFNOT:third_party
I am
ENDIF:third_party
13 or older</label></td></tr>
<tr><td>&nbsp;</td></tr>

<tr><td></td><td><input type="submit" value="Continue..." /></td></tr>
</table>
</form>
}

#############################################################################

COLLECT_NEW_PASSWORD = %{

<h2>Set Your Password</h2>
<form method="post" action="%form_target%">
<table>
  <tr>#{Html.tag("New password")}<td>%pwinput:p1:30:30%</td></tr>
  <tr>#{Html.tag("again")}<td>%pwinput:p2:30:30%</td></tr>
  <tr><td></td><td><input type="submit" value="Continue..." /></td></tr>
</table>
</form>
}

#############################################################################

COLLECT_CHANGED_PASSWORD = %{

<h2>Set New Password for %name%</h2>
<form method="post" action="%form_target%">
<table>
  <tr>#{Html.tag("New password")}<td>%pwinput:p1:30:30%</td></tr>
  <tr>#{Html.tag("again")}<td>%pwinput:p2:30:30%</td></tr>
  <tr><td></td><td><input type="submit" value="Continue..." /></td></tr>
</table>
</form>
}


#############################################################################

UPDATE_MENU = %{

<h2>Manage Your Account</h2>

<ul>
<li><a href="%change_pw_url%">Change my password</a>
<li><a href="%update_det_url%">Update my details</a>
</ul>

}

#############################################################################

RETRIEVE_USER = %{

<h2>Find my User ID</h2>

If you have an existing account, you'll have given us your e-mail
address. Enter it below and click on "Send" and we'll send
your password to that address.
<p />
If your e-mail address has changed, or you can't remember which
address you used, click
<a
href="mailto:admin@dion.destinationimagination.org?subject=Request%20User%20Information">here</a>
to send an e-mail to our help desk.
<p />
<form method="post" action="%form_target%">
Enter the e-mail address you used when setting up
you account.<br />
<input type="text" name="email" value="%email%" />
<input type="submit" value="Send" />
</form>
}

#############################################################################

PASSWORD_SENT = %{

<h2>Password Sent</h2>

Thanks, %name%. I've created a new password for you and sent it to
%email%. When it arrives, use it to log in to this
system. You can then use the <em>Update My Details</em> option from
your personal home page to set your password to something more
meaningful to you.

<p>
Back to <a href="http://www.destinationimagination.org:">Destination
Imagination</a>. 
}

######################################################################

SEARCH_FOR_USER = %{

<h2>Become User</h2>
<form method="post" action="%form_url%">
<table>
<tr>#{Html.tag("User e-mail")}
  <td>%input:user_email:40:200%</td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td>
   <td><input type="submit" value=" CHANGE TO THIS USER "></td>
</tr>
</table>
</form>
}

#############################################################################

FORGOT_PASSWORD = %{
You recently asked the Destination Imagination ONline system
to send you information on how to log in.

You can log in by visiting http://www.dionline.org/dion/dion.rb

Your user name is:    %user_name%
and your password is: %password%


(This e-mail is automatically generated)
}

#############################################################################

NEW_USER_EMAIL = %{
An account was recently created for you on the Destination Imagination
ONline system.

You can log in by visiting http://www.dionline.org/dion/dion.rb

Your user name is:    %user_name%
and your password is: %password%


(This e-mail is automatically generated)
}


end
