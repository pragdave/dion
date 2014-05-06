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

class Table
  class Field
    attr_reader :name, :setter_name, :type, :constraints

    def initialize(name, type, options)
      @name = name
      @setter_name = (name.to_s + '_setter').intern
      @type = type
      @primary_key = false
      @constraints  = []
      @nullable = false
      @default  = nil
      options.each do |opt|
        case opt
        when :primary_key
          @primary_key = true
        when :null
          @nullable = true
        when Constraint::Default
          @default = opt
        when Constraint::Check, Constraint::References
          @constraints << opt
        end
      end
    end

    def primary_key?
      @primary_key
    end

    def to_s
      res = "%-20s %-15s "% [@name, @type.sql_type]
      res << @default.to_s if @default
      res << " primary key" if @primary_key
      res << " not"  unless @nullable
      res << " null "
      res << @constraints.map{|c| c.to_s}.join(" ")
      res
    end

    def to_sql
      to_s
    end
  end
end
