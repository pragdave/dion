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
require "db/Store"
require "web/Session"

class TestSession < Test::Unit::TestCase

  class TestContext
    attr_accessor :a, :b
  end

  def setup
    @store = Store.new("DBI:Pg:test", "dave", "")
    @context = [ 1, 2, /fred/ ]
  end

  def test_basic_create
    session = Session.create(@store, TestContext.new)
    orig_id = session.session_id
    session.context.a = 123
    session.context.b = 'cat'
    session.save(@store)

    new_session = Session.find(@store, orig_id, TestContext)
    assertEqual(orig_id, new_session.session_id)
    assertEqual(123, new_session.context.a)
    assertEqual('cat', new_session.context.b)
  end


end

