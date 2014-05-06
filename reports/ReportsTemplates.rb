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

class Reports

######################################################################

SHOW_REPORT = %{

<h2>Your Output</h2>

<OBJECT
  CLASSID="clsid:CA8A9780-280D-11CF-A24D-444553540000" 
  WIDTH="100%" HEIGHT="70%" ID=Pdf1> 
      <PARAM NAME="SRC" VALUE="%report_url%">
      <EMBED SRC="%report_url%" HEIGHT="70%" WIDTH="100%">
      <NOEMBED>Sorry - Couldn't load the invoice </NOEMBED>
</OBJECT>

<p>
<hr>
If your report does not appear above, click
<a target="report" href="%report_url%">here</a>
to view it.

}

######################################################################
AFFILIATE_FEE_STATEMENT = %{
\\documentclass{report}
\\usepackage{affiliatestatement}
\\begin{document}

START:cycle_list
\\AffName{%aff_long_name%}
\\CycleDate{%fmt_cycle_date%}
\\PrintDate{%print_date%}
\\begin{fees}
IF:fees
START:fees
  \\begin{product}{%qty%}{%prd_desc%}{%total%}
START:details
     \\litem{%date%}{%fee_desc%}{%amount%}
END:details
  \\end{product}
END:fees
ENDIF:fees
IFNOT:fees
\\none
ENDIF:fees
\\end{fees}

\\begin{refunds}
IF:refunds
START:refunds
  \\begin{product}{%qty%}{%prd_desc%}{%total%}
START:details
     \\litem{%date%}{%fee_desc%}{%amount%}
END:details
  \\end{product}
END:refunds
ENDIF:refunds
IFNOT:refunds
\\none
ENDIF:refunds
\\end{refunds}

\\total{%total%}
END:cycle_list

\\end{document}
}

######################################################################

SHIPPING_LABELS = %{
\\documentclass{article}
\\usepackage{shippinglabel}
\\begin{document}
START:labels
\\lb{%ship_name%}{%ship_rest%}
END:labels
\\end{document}
}

######################################################################

XX_PACKING_LIST = %{
\\documentclass{article}
\\usepackage{packinglist}
\\begin{document}
START:slips
\\begin{packinglist}{%print_date%}
\\lb{%ship_name%}{%ship_rest%}{}
\\begin{litemlist}
START:list_items
IFNOT:full_passport
\\litem{%li_qty%}{%prd_long_desc%}{%fmt_sale_date%}
ENDIF:full_passport
IF:full_passport
\\litem{%li_qty%}{%prd_long_desc% \\textbf{Passport: %full_passport%,
           %mem_name%}}{%fmt_sale_date%}
ENDIF:full_passport
END:list_items
\\end{litemlist}
\\end{packinglist}
END:slips
\\end{document}
}

######################################################################

INVOICE = %{
\\documentclass{report}
\\usepackage{invoice}
\\usepackage{longtable}
\\begin{document}
\\BaseDir{%latex_dir%}
\\To{%inv_billing_address%}
\\From{This is\\The From\\Address}
\\Contact{Mt Contact}
\\Org{The Organization}
\\Telephone{123 456 7890}
\\YourPO{%pay_doc_ref%}
\\OurRef{%pay_our_ref%}
\\Date{%inv_date%}
\\Total{%pay_amount%}
\\InvComment{%inv_notes%}
\\InvId{%inv_id%}
IF:is_invoice
\\IsInvoice
ENDIF:is_invoice
IF:is_receipt
\\IsReceipt
ENDIF:is_receipt
\\DIINV

\\setlength{\\LTleft}{0pt}
\\setlength{\\LTright}{0pt}


\\begin{longtable}{ @{\\extracolsep{\\fill}}| p{4.5in}
                   >{\\hfill}p{0.6in}  |
                   >{\\hfill}p{0.65in} |
                   >{\\hfill}p{0.65in} |}
 \\hline

  \\textbf{Description} &
  &
  \\raisebox{1ex}{\\parbox[c]{.6in}{\\center\\small
       \\textbf{Order}\\\\\\textbf{Total}}} &
  \\raisebox{1ex}{\\parbox[c]{.6in}{\\center\\small
       \\textbf{Applied}\\\\\\textbf{to Order}}}\\rule[-3ex]{0ex}{2ex} 
  \\\\

  \\hline & & & \\\\[-1ex]
\\endhead

  \\hline
  \\multicolumn{4}{r}{\\small\\emph{continued...}}\\
\\endfoot

  \\kill
\\endlastfoot

START:orders

IFNOTBLANK:order_passport
   \\textbf{Order \\#%order_id% for passport %order_passport% placed
     %fmt_order_date%} & &
    \\textbf{\\$%grand_total%} &
    \\textbf{\\$%applied%} \\\\
 \\quad\\quad School: %order_school% & & &\\\\[-0.5ex]
ENDIF:order_passport

IFBLANK:order_passport
  \\textbf{Order \\#%order_id% placed %fmt_order_date%} & &
    \\textbf{\\$%grand_total%} &
    \\textbf{\\$%applied%} \\\\[-0.5ex]
ENDIF:order_passport

START:product_list
\\quad\\quad {\\small
IF:qty
\\makebox[2.5em]{%qty% $\\times$}%
ENDIF:qty
IFNOT:qty
\\makebox[2.5em]{}%
ENDIF:qty
%desc%
IF:unit
@ \\$%unit%
ENDIF:unit
}\\dotfill & {\\small \\$%price%} & &\\\\[-1ex]
END:product_list
 & & &\\\\
END:orders

IF:inv_unapp_desc
 \\textbf{%inv_unapp_desc%} & & & \\textbf{\\$%unapp_amt%} \\\\
 & & &\\\\
ENDIF:inv_unapp_desc

  \\hline
IF:is_invoice
  \\multicolumn{3}{r |}{\\textbf{PLEASE REMIT PAYMENT FOR THIS
                                 AMOUNT:}} & \\textbf{\\$\\TOTAL} \\\\
ENDIF:is_invoice
IF:is_receipt
  \\multicolumn{3}{r |}{\\textbf{TOTAL PAID}} & \\textbf{\\$\\TOTAL} \\\\
ENDIF:is_receipt
  \\cline{4-4}
\\end{longtable}
\\ENDINV

\\end{document}
}

######################################################################

STATEMENT = %{
\\documentclass{article}
\\usepackage{statement}
\\begin{document}
\\BaseDir{%latex_dir%}
\\StatementDate{%statement_date%}

START:statements

\\begin{STATEMENT}
  \\To{%order_contact%}
  \\ShipTo{%ship_address%}
  \\OrderNo{%order_id%}
  \\OrderDate{%fmt_order_date%}
IF:order_aff_fee
  \\Comment{This order includes \\$%order_aff_fee% in affiliate fees}
ENDIF:order_aff_fee

  \\OrderDetails

  \\begin{tabularx}{\\textwidth}{ @{\\extracolsep{\\fill}}| X | r | r |}

  \\hline

IFNOTBLANK:order_passport
  \\textbf{Order \\#%order_id% for passport %order_passport% placed
     %fmt_order_date%} & \\textbf{Amount} & \\textbf{Total}\\\\
  \\hline
  \\quad\\quad School: %order_school% & & \\\\[-0.5ex]
ENDIF:order_passport

IFBLANK:order_passport
  \\textbf{Order \\#%order_id% placed %fmt_order_date%} & \\textbf{Amount} & \\textbf{Total}\\\\[-0.5ex]
  \\hline
ENDIF:order_passport

START:product_list
\\quad\\quad {\\small
IF:qty
\\makebox[2.5em]{%qty% $\\times$}%
ENDIF:qty
IFNOT:qty
\\makebox[2.5em]{}%
ENDIF:qty
%desc%
IF:unit
@ \\$%unit%
ENDIF:unit
}\\dotfill & {\\small \\$%price%} &\\\\[-.5ex]
END:product_list

\\quad\\quad\\textbf{Order Total} & & \\$%grand_total%\\\\[2ex]

IF:payments
\\hline
\\textbf{Payments applied to this order} & & \\\\
\\hline

START:payments
\\quad\\quad %short_type% %pay_doc_ref% from %pay_payor% for
\\$%pay_amount% & \\$%applied_amount% & \\\\

END:payments

\\quad\\quad\\textbf{Total applied to order} & & \\$%total_paid%\\\\[2ex]

ENDIF:payments

  \\hline
  \\multicolumn{2}{r |}{\\textbf{OUTSTANDING BALANCE:}} & \\textbf{\\$%amount_due%} \\\\
  \\cline{3-3}

  \\end{tabularx}

\\end{STATEMENT}

END:statements

\\end{document}
}

######################################################################

PACKING_LIST = %{
\\documentclass{article}
\\usepackage{statement}
\\begin{document}
\\BaseDir{%latex_dir%}
\\StatementDate{%statement_date%}
\\IsPackingList

START:statements

\\begin{STATEMENT}
  \\To{%order_contact%}
  \\ShipTo{%ship_address%}
  \\OrderNo{%order_id%}
  \\OrderDate{%fmt_order_date%}
IF:order_aff_fee
  \\Comment{This order includes \\$%order_aff_fee% in affiliate fees}
ENDIF:order_aff_fee

  \\OrderDetails

  \\begin{tabularx}{\\textwidth}{ @{\\extracolsep{\\fill}}| X | r | r |}

  \\hline

IFNOTBLANK:order_passport
  \\textbf{Order \\#%order_id% for passport %order_passport% placed
     %fmt_order_date%} & \\textbf{Amount} & \\textbf{Total}\\\\
  \\hline
  \\quad\\quad School: %order_school% & & \\\\[-0.5ex]
ENDIF:order_passport

IFBLANK:order_passport
  \\textbf{Order \\#%order_id% placed %fmt_order_date%} & \\textbf{Amount} & \\textbf{Total}\\\\[-0.5ex]
  \\hline
ENDIF:order_passport

START:product_list
\\quad\\quad {\\small
IF:qty
\\makebox[2.5em]{%qty% $\\times$}%
ENDIF:qty
IFNOT:qty
\\makebox[2.5em]{}%
ENDIF:qty
%desc%
IF:unit
@ \\$%unit%
ENDIF:unit
}\\dotfill & {\\small \\$%price%} &\\\\[-.5ex]
END:product_list

\\quad\\quad\\textbf{Order Total} & & \\$%grand_total%\\\\[2ex]

IF:payments
\\hline
\\textbf{Payments applied to this order} & & \\\\
\\hline

START:payments
\\quad\\quad %short_type% %pay_doc_ref% from %pay_payor% for
\\$%pay_amount% & \\$%applied_amount% & \\\\

END:payments

\\quad\\quad\\textbf{Total applied to order} & & \\$%total_paid%\\\\[2ex]

ENDIF:payments

  \\hline
  \\end{tabularx}

\\end{STATEMENT}

END:statements

\\end{document}
}


##################################################

XXX= %{


START:orders


END:orders

IF:inv_unapp_desc
 \\textbf{%inv_unapp_desc%} & & & \\textbf{\\$%unapp_amt%} \\\\
 & & &\\\\
ENDIF:inv_unapp_desc

  \\hline
IF:is_invoice
  \\multicolumn{3}{r |}{\\textbf{PLEASE REMIT PAYMENT FOR THIS
                                 AMOUNT:}} & \\textbf{\\$\\TOTAL} \\\\
ENDIF:is_invoice
IF:is_receipt
  \\multicolumn{3}{r |}{\\textbf{TOTAL PAID}} & \\textbf{\\$\\TOTAL} \\\\
ENDIF:is_receipt
\\end{tabularx}

\\end{STATEMENT}

END:statements

\\end{document}

}

######################################################################
end
