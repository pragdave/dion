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

File.open("create.sql", "w") do |create|
  Table.all_tables.each do |table|
    create.puts table.create_sql
    create.puts table.insert_initial_values
  end
end

File.open("drop.sql", "w") do |drop|
  Table.all_tables.reverse.each do |table|
    drop.puts   table.drop_sql
  end
end
