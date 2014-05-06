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

module Formatters

  def fmt_date_time(val)
    return "" unless val
    val = val.to_time if val.kind_of? DBI::Timestamp
    val.strftime("%d-%b-%y %H:%M")
  end

  def fmt_date(val)
    return "" unless val
    val = val.to_time if val.kind_of? DBI::Date
    val = val.to_time if val.kind_of? DBI::Timestamp
    val.strftime("%d-%b-%y")
  end

  def fmt_money(val)
    res = sprintf("%0.2f", val)
    # assume we'll never see anything > 999,999,999
    if res =~ /^(-?\d+)(\d\d\d)(\d\d\d)\./
      res = "#$1,#$2,#$3.#$'"
    elsif res =~ /^(-?\d+)(\d\d\d)\./
      res = "#$1,#$2.#$'"
    end
    res
  end

  def unfmt_money(amt)
    if amt =~ /^[\d,]+(\.\d{1,2})?$/
      amt = amt.gsub(/,/, '')
      Float(amt)
    else
      raise "Invalid amount #{amt}"
    end
  end    

  def unfmt_negative_money(amt)
    if amt =~ /^-?[\d,]+(\.\d{1,2})?$/
      amt = amt.gsub(/,/, '')
      Float(amt)
    else
      raise "Invalid amount #{amt}"
    end
  end    

end

if __FILE__ == $0
  require 'test/unit'

  class TestMoney < Test::Unit::TestCase

    include Formatters

    VALS = [
      [ 1, "1.00" ],
      [ 11, "11.00" ],
      [ 111, "111.00" ],
      [ 1111, "1,111.00" ],
      [ 11111, "11,111.00" ],
      [ 111111, "111,111.00" ],
      [ 1111111, "1,111,111.00" ],
      [ 11111111, "11,111,111.00" ],

      [ -1, "-1.00" ],
      [ -11, "-11.00" ],
      [ -111, "-111.00" ],
      [ -1111, "-1,111.00" ],
      [ -11111, "-11,111.00" ],
      [ -111111, "-111,111.00" ],
      [ -1111111, "-1,111,111.00" ],
      [ -11111111, "-11,111,111.00" ],

    ]
    def test_fmt
      VALS.each do |val, expected|
        assert_equal(expected, fmt_money(val))
      end
    end
  end
end
