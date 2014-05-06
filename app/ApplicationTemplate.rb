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

class Application

PAGE_LAYOUT = %{
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<html><head>
  <title>%title%</title>
  <meta http-equiv="Content-Type" content="text/html; charset="iso-8859-1" />
  <link rel=StyleSheet href="%http%/dion.css" type="text/css" media="screen" />
  <link rel=StyleSheet href="%http%%extra_css%" type="text/css" media="screen" />
  <script type="text/javascript" language="JavaScript">
  <!--
  function popup(url) {
    window.open(url, "Popup", 
          "resizable=yes,scrollbars=yes,toolbar=no,status=no,height=300,width=800")
  }
  //-->
  </script>
</head>
<body>
IF:error_msg
<span class="error">%error_msg%</span><p />
ENDIF:error_msg
IF:note_msg
<span class="note">%note_msg%</span><p />
ENDIF:note_msg
IF:error_list
<span class="error">Please correct the following:</span>
<ul class="errorlist">
START:error_list
<li class="errorlistentry">%error%</li>
END:error_list
</ul>
ENDIF:error_list
!INCLUDE!
<hr>
<span class="dilink">Go to: </span><a class="dilink"
href="%main_menu_url%">%main_menu%</a>

IF:link_to_jitterbug
<span class="dilink">
&nbsp;&nbsp;&nbsp;Go to: <a
href="http://pragprog.com/cgi-bin/dion-bugs"
target="bugs">bug/feature</a> system.</span>
ENDIF:link_to_jitterbug

</body>
</html>
}

######################################################################

FRONT_LAYOUT = %{
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<html><head>
  <title>%title%</title>
  <meta http-equiv="Content-Type" content="text/html; charset="iso-8859-1" />
  <link rel=StyleSheet href="/dion.css" type="text/css" media="screen" />
  <link rel=StyleSheet href="%extra_css%" type="text/css" media="screen" />
  <script type="text/javascript" language="JavaScript">
  <!--
  function popup(url) {
    window.open(url, "Popup", 
          "resizable=yes,scrollbars=yes,toolbar=no,status=no,height=300,width=800")
  }
  //-->
  </script>
</head>
<body>
<table width="500" align="center">
<tr><td>
IF:error_msg
<span class="error">%error_msg%</span><p />
ENDIF:error_msg
IF:note_msg
<span class="note">%note_msg%</span><p />
ENDIF:note_msg
IF:error_list
<span class="error">Please correct the following:</span>
<ul class="errorlist">
START:error_list
<li class="errorlistentry">%error%</li>
END:error_list
</ul>
ENDIF:error_list
!INCLUDE!
</td></tr></table>
<hr>
<a class="dilink"
href="http://www.destinationimagination.org">Destination Imagination
Home.</a>
<br>
<a class="dilink"
href="http://www.destinationimagination.org/privacy.html">Privacy Policy</a>
</body>
</html>
}

######################################################################

POPUP_LAYOUT = %{
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<html><head>
  <title>%title%</title>
  <meta http-equiv="Content-Type" content="text/html; charset="iso-8859-1" />
  <link rel=StyleSheet href="/dion.css" type="text/css" media="screen" />
  <link rel=StyleSheet href="%extra_css%" type="text/css" media="screen" />
</head>
<body>
!INCLUDE!
<hr>
<form>
<input type="Button" VALUE="Close" onClick="self.close()">
</form>
</body>
</html>
}

######################################################################

OLD_PAGE_LAYOUT = %{
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<html><head>
  <title>%title%</title>
  <meta http-equiv="Content-Type" content="text/html; charset="iso-8859-1" />
  <link rel=StyleSheet href="/dion.css" type="text/css" media="screen" />
  <link rel=StyleSheet href="%extra_css%" type="text/css" media="screen" />
</head>
<body>
<table align="center" width="650">
<tr>
<td width="85" valign="top" class="sidecolumn">!INCLUDE!</td>
<tb width="15">&nbsp;</td>
<td width="550">
IF:error_msg
<span class="error">%error_msg%</span><p />
ENDIF:error_msg
IF:note_msg
<span class="note">%note_msg%</span><p />
ENDIF:note_msg
IF:error_list
<span class="error">Please correct the following:</span>
<ul class="errorlist">
START:error_list
<li class="errorlistentry">%error%</li>
END:error_list
</ul>
ENDIF:error_list
!INCLUDE!
</td>
</tr>
</table>
</body>
}

######################################################################

SIDE_MENU = %{
}

######################################################################

DUMMY = %{
<table cellpadding="0" cellspacing="0" width="100%" class="sidecolumn">
<tr width="100%"><td>
<a href="http://www.destinationimagination.com"><span class="sidemenu">DI
Home</span></a><br />
</td>
</tr>
</table>
}

end
