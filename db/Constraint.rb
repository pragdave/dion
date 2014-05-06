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
  module Constraint
    class References
      attr_reader :table
      def initialize(table, field)
        @table = table
        @field = field
      end
      def to_s
        " references #{@table.name}(#@field)"
      end
    end

    class Default
      def initialize(val)
        @value = val
      end
      def to_s
        " default '#@value'"
      end
    end
    
    class Check
      def initialize(val)
        @value = val
      end
      def to_s
        " check (#@value)"
      end
    end
    
    class Unique
      def initialize(*cols)
        @cols = cols
      end

      def to_s
        "unique (#{@cols.join(\", \")})"
      end
      def to_sql
        to_s
      end
    end

    class Indexed
      attr :name
      def initialize(table, *cols)
        @cols  = cols
        @table = table
        @name  = "idx_#{cols.join('_')}"
      end

      def to_s
        "index (#{@cols.join(\", \")})"
      end
      def to_sql
        "create index #@name on #{@table.name}" +
          "(#{@cols.join(', ')});"
      end
    end
  end
end
