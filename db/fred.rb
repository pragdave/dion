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

require 'TableDefinitions'

puts ContactTable.drop_sql
puts ContactTable.create_sql


c = Table.from_row(ContactTable, [1,2,3,4,5,6,7,8])
p c.con_id
p c.con_email
