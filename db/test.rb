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

require 'dbi'

db = DBI.connect(*ARGV) 

db.do("create table fred(i int)")
5.times {|i| db.do("insert into fred values(#{i})")}

puts db.select_all("select * from fred")

rpc = db.do("update fred set i=i*2")
puts "Expected a count of '5', got '#{rpc}'"


db.do("drop table fred")

