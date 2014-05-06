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

require 'test/unit'
require "db/MemberSearch"
require "db/Store"

$store = Store.new("DBI:Pg:test", "dave")

class MockSession
  def initialize(vals)
    @vals = vals
  end
  def cgi
    self
  end
  def [](name)
    [@vals[name]]
  end
  def url
    "URL:"
  end
end

class TestMemberSearch < Test::Unit::TestCase

  def test_basic
    ms = MemberSearch.new(MockSession.new({"QRY_mem_passport"=>"12345",
                                          "QRY_con_email" => 'fred'}))
    ms.set_default(:mem_pay_method, 'V')
    ms.display_fields :mem_passport, :mem_affiliate, :mem_pay_method
    puts ms.to_form

    where, tables =  ms.build_query
    puts "Where = <#{where}>"
    puts "Tables = <#{tables}>"
  end
  
end
