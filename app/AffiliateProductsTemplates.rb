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

class AffiliateProducts < Application

ADMIN_PRODUCTS = %{

<h2>Administer Your Affiliate Product Fees</h2>

<p style="font-size: small">"Below is a list of available DI
products. You can choose to add an Affiliate Fee to some of
these. Enter any Affiliate Fee you wish headquarters to collect for
you to the markup column and press [UPDATE] below.</p>

<p style="font-size: small">For example: If you want HQ to collect
your Affiliate fee of $50 per One Pak simply enter $50 in the Markup
column.  When your users register a Team One Pak they will be charged
$150 ($100 base price PLUS your $50 Affiliate Fee).</p>

<p>
<hr>

<form method="post" action="%form_url%">

<table>
<tr valign="top">
 <th class="spread">Product</th>
 <th class="spread">Base price</th>
 <th>%aff_short_name%<br>Markup</th>
</tr>

START:list
<tr>
 <td>%desc%</td>
 <td align="right" class="spread">%base_price%</td>
IF:markup_index
 <td align="right">%input:markup_%markup_index%:10:10%</td>
ENDIF:markup_index
</tr>
END:list
</table>
<p>
<input type="submit" value=" UPDATE ">
</form>

}
end
