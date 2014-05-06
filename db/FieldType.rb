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

require 'singleton'

class Table
  module FieldType
    class AnyType
      def sql_type
        to_s
      end
      def conversion_function
        ""
      end
    end

    class Int < AnyType
      include Singleton

      def to_s
        "int"
      end
    end

    class Date < AnyType
      include Singleton

      def to_s
        "date"
      end
    end

    class AutoInc < Int
      include Singleton

      def to_s
        "autoinc"
      end
      def sql_type
        "serial"
      end
    end

    class Decimal < AnyType
      def initialize(prec, scale)
        @prec = prec
        @scale = scale
      end
      def to_s
        "decimal(#@prec,#@scale)"
      end
      def conversion_function
        ".to_f"
      end
    end

    class Timestamp < AnyType
      include Singleton
      def to_s
        "timestamp"
      end
    end

    class Enum < AnyType
      def initialize(args)
        @values = args
      end
      def to_s
        "enum(#{@values.join(', ')})"
      end
      def sql_type
        "char(1)"
      end
    end

    class Boolean < AnyType
      include Singleton

      TRUE  = "TRUE"
      FALSE = "FALSE"

      def to_s
        "boolean"
      end
    end


    class Varchar < AnyType
      def initialize(length)
        @length = length
      end
      def to_s
        "varchar(#@length)"
      end
    end

    class Char < AnyType
      def initialize(length)
        @length = length
      end
      def to_s
        "char(#@length)"
      end
    end

    class Blob < AnyType
      include Singleton

      def to_s
        "blob"
      end
      def sql_type
        "bytea"
      end
    end
  end
end
