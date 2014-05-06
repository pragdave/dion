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

class DLChallenges < Application

##################################################

DL_COPYRIGHT = %{

<h2>Challenge Copyright Notice</h2>

<table width="80%" align="center">
<tr><td>
Unless stated, all materials on this site are copyrighted, and any
unauthorized use of any materials on this site may violate copyright,
trademark, and other laws. You may not download or use any of the
information regarding the Challenges unless you have previously paid
for the right to do so. You agree to prevent any unauthorized copying
of the information for any use/purpose whatsoever.
<p>
<form method="post" action="%ok_url%">
<input type="submit" value=" I AGREE ">
</form>
<p>
<form method="post" action="%not_ok_url%">
<input type="submit" value=" MAIN MENU ">
</form>
</td></tr></table>
<p><hr><p>

<em class="small">
Robert T. Purifico<br />
President<br />
Destination ImagiNation, Inc.<br />
PO Box 547 Glassboro, NJ 08028<br />
856-881-1603 Ph.<br />
856-881-3596 Fax.
</em>

}
##################################################

DOWNLOAD = %{

<h2>Challenge Download</h2>
<p>
<table align="center">
<tr><td colspan="3">
Here are this year's challenges, available for download in 
<a HREF="http://www.adobe.com/products/acrobat/readstep.html">PDF</a>
format.
<p>
<em class="small">Internet Explorer Users: You have to click on the <b>SAVE</b>
button when the challenge has downloaded. Do not press OPEN, as you may not 
be able to access the challenge.</em>
<p>
</td></tr>
START:list
<tr>
IF:odd
<td>
IF:icon_url
<img src="%icon_url%">
</td>
ENDIF:odd
<td colspan="2">
<b>%name%</b> <em class="small">(Level: %levels%)</em>
<br>
<div class="newsstory">%desc%</div>
<span class="downloadlabel">Download now:</span>
START:dl_list
<a class="downloadref" href="%dl_url%">%lang%</a>&nbsp;&nbsp;
END:dl_list
</td>
IFNOT:odd
IF:icon_url
<td>
<img src="%icon_url%">
</td>
ENDIF:icon_url
ENDIF:odd
</tr>
<tr><td width="15%">&nbsp;</td><td width="70%"align="center">&nbsp</td><td width="15%"</tr>
END:list
<tr><td height="20" colspan="3"><hr width="50%"></td></tr>

<tr><td colspan="2">To read these challenges, you'll need the Adobe Acrobat PDF viewer,
available free online.</td>
<td>
<a HREF="http://www.adobe.com/products/acrobat/readstep.html"><img BORDER="0" HEIGHT="31"
WIDTH="88" SRC="http://www.adobe.com/images/getacro.gif" ALT="Get
Acrobat Reader"></a>
</td></tr>
</table>
}
end
