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

require 'date'

class DionDate

  include Comparable

  attr_reader :date

  def initialize(name, date=nil)
    @name = name
    @date = date
    if date
      @y = date.year
      @m = date.month
      @d = date.mday
    else
      @y = @m = @d = ''
    end
  end

  def add_to_hash(values)
    values[@name + "_m"] = @m
    values[@name + "_d"] = @d
    values[@name + "_y"] = @y
    values
  end

  def from_hash(values)
    @m = values[@name + "_m"]
    @d = values[@name + "_d"]
    @y = values[@name + "_y"]
  end

  def error_list
    m = from_int(@m, "month")
    d = from_int(@d, "day")
    y = from_int(@y, "year")

    if y < 20
      @y = y += 2000
    elsif y < 100
      @y = y += 1900
    end

    if y < 1960 || y > Date.today.year+1
      raise "Invalid year '#{y}'"
    end

    begin
      @date = Date.new(y, m, d)
    rescue
      raise "Invalid date: #{m}/#{d}/#{y}"
    end

    []
  rescue Exception => e
      return [ e.message ]
  end

  def from_int(str, msg)
    Integer(str.sub(/^0+[bdoxBDOX]?/, ''))
  rescue
    raise "Invalid #{msg} in #{@name.tr('_', ' ')}: '#{str}'"
  end

  def <=>(other)
    me = @date
    me = me.to_date unless me.kind_of? Date
    him = other.date
    him = him.to_date unless him.kind_of? Date

    me <=> him
  end

  def to_s
    @date.to_s
  end
end
