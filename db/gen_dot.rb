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

puts "digraph schema {"
puts "size=\"8,10\";"
puts "rotate=90;"
puts "node [shape=record];"

Table.all_tables.each do |table|
  puts table.to_dot
end

puts "}"

