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

require 'db/Constraint'
require 'db/FieldType'
require 'db/Field'

class Table


  FIELDS = nil

  @@all_tables = []

  @@prefix = "AAAA"

  class <<self
    attr_reader :name, :primary_key
    attr_accessor :fields
    attr_reader :insert_sql, :select_sql, :count_sql
    attr_reader :insert_sql_minus_key
    attr_reader :get_insert_id_sql
    attr_reader :table_constraints
    attr_reader :field_names
    attr_reader :initial_values
  end

  def Table.table(name)
    @name = name
    @fields = []
    @table_constraints = []
    @table_indices  = []
    @initial_values = []
    @is_view = false
    
    yield
    
    # all tables have an _version column
    field(int, "_version", default(0))
    
    @insert_sql = gen_insert_sql
    @select_sql = gen_select_sql
    @count_sql  = gen_count_sql 
    @insert_sql_minus_key = gen_insert_sql_minus_key
    
    @get_insert_id_sql = gen_get_insert_id_sql
  end
  
  
  def Table.view(name, tables, *joins)
    @name = name
    @fields = []
    @tables = tables
    @joins = joins
    @table_constraints = []
    @initial_values = []
    @is_view = true
    
    tables.each do |t|
      t.fields.each do |f|
        unless f.name == "_version"
          @fields << f
          create_accessors_for(f)
        end
      end
    end
    @select_sql = gen_select_sql
    @count_sql  = gen_count_sql 
  end
  
  def Table.outer_view(*args)
    view(*args)
    @outer_join = true
  end

  def Table.gen_select_sql
    pre = @@prefix.succ! + "."
    "select\t" + 
      @fields.map{|f| pre + f.name.to_s}.join(",\n\t") +
      " from #@name #@@prefix "
  end
  
  def Table.gen_count_sql
    "select count(*) from #@name "
  end


  def Table.gen_insert_sql
    gen_insert_common(@fields)
  end
  
  def Table.gen_insert_sql_minus_key
    fields = @fields.reject {|f| f.primary_key?}
    gen_insert_common(fields)
  end
  
  def Table.gen_insert_common(fields)
    "insert into #@name(" + 
      fields.map{|f|f.name}.join(",\n\t") + ") values (" +
      fields.map{"?"}.join(",") + ")"
  end
  
  def Table.gen_get_insert_id_sql
    "select currval('#{@name}_#{@primary_key.name}_seq')"
  end
  
  # construct a new table from an array of values
  def Table.from_row(klass, row)
    res = klass.new
    res.load_from_row(row)
    res
  end
  
  # The following methods build the descriptor for
  # the table
  def Table.field(type, name, *options)
    f = Field.new(name, type, options)
    
    @fields << f
    
    @primary_key = f if f.primary_key?
    
    create_accessors_for(f)
    create_writer_for(f)
  end
  
  def Table.create_accessors_for(field)
    name = field.name
    class_eval <<-EOS
    def #{name}
      @#{name}
    end
    def #{field.setter_name}(val)
      @#{field.name} = val.nil? ? nil : val#{field.type.conversion_function}
    end
    EOS
  end
  
  def Table.create_writer_for(field)
    name = field.name
    class_eval <<-EOS
      def #{name}=(val)
        set_changed(:#{name}) if val != @#{name}
                  @#{name} = val
      end
    EOS
  end

  # # # # # # # # # # #   C O N S T R A I N T S   # # # # # # # # # # # # #

  def Table.pk() 
    :primary_key
  end
  
  def Table.null
    :null
  end
  
  def Table.references(table, field)
    Constraint::References.new(table, field)
  end
  
  def Table.default(val)
    Constraint::Default.new(val)
  end
  
  def Table.check(val)
    Constraint::Check.new(val)
  end
  
  def Table.indexed(*cols)
      @table_indices << Constraint::Indexed.new(self, *cols)
  end
  
  def Table.unique(*cols)
    if cols.empty?
      fail "Don't support column-based unique yet"
    else
      @table_constraints << Constraint::Unique.new(*cols)
    end
  end
  
  def Table.initial_values(*rows)
    @initial_values = rows
  end
  
  # # # # # # # # # # #   F I E L D    T Y P E S   # # # # # # # # # # # #
  
  def Table.int
    FieldType::Int.instance
  end
  
  def Table.autoinc
    FieldType::AutoInc.instance
  end
  
  def Table.boolean
    FieldType::Boolean.instance
  end
  
  def Table.blob
    FieldType::Blob.instance
  end
  
  def Table.date
    FieldType::Date.instance
  end
  
  def Table.varchar(size)
    FieldType::Varchar.new(size)
  end
  
  def Table.decimal(prec, scale)
    FieldType::Decimal.new(prec, scale)
  end
  
  def Table.char(size)
    FieldType::Char.new(size)
  end
  
  def Table.timestamp
    FieldType::Timestamp.instance
  end
  
  def Table.enum(*args)
    FieldType::Enum.new(args)
  end
  
  # Record all our subclasses so we can iterate over all the
  # tables
  
  def Table.inherited(subclass)
    @@all_tables << subclass
  end
  
  def Table.all_tables
    @@all_tables
  end
  
  # ----
  
  def Table.field_list
    fields.map {|f| f.to_s}
  end
  
  def Table.display(on = STDOUT)
    on << name << "(" << primary_key.name << ")"
    on << "\n    "
    on << field_list.join("\n    ")
    on << "\n"
  end
  
  def Table.create_sql
    if @is_view
      create_view
    else
      
      lines = fields.map {|f| f.to_sql}
      lines.concat table_constraints.map {|c| c.to_sql}
      
      res = "create table #@name (\n    " +
        lines.join(",\n    ") +
        ");"
      @table_indices.each do |index|
        res << "\n" << index.to_sql
      end
      res
    end
  end
  
  def Table.create_view
    
    if @outer_join
      joins = ""
      
      while @tables.size > 1
        joins << @tables[0].name << " left outer join " << @tables[1].name
        joins << " on " << @joins[0]
        @tables.shift
        @joins.shift
        joins << ", " if @tables.size > 1
      end
      
      "create view #@name as select " +
        fields.map{|f| f.name}.join(", ") +
        " from " + joins + ";"
    else
      
      tables = @tables.map{|t| t.name}.join(", ")
      where = @joins.join(" and ")
      
      "create view #@name as select " +
        fields.map{|f| f.name}.join(", ") +
        " from #{tables} where #{where};"
    end
    
  end


  def Table.insert_initial_values
    @initial_values.map do |row|
      "insert into #@name values(" + (row.map{|c| "'#{c}'" }.join(', ')) + ");"
    end
  end
  
  def Table. drop_sql
    if @is_view
      "drop view #@name;"
    else
      res = ""
      fields.each do |f|
        if f.type == autoinc
          res << "drop sequence #{@name}_#{f.name}_seq;\n"
        end
      end
      @table_indices.each do |i|
        res << "drop index #{i.name};\n"
      end
      
      res << "drop table #@name;\n"
    end
  end
  
  
  def Table.to_dot
    if @is_view
      # create_view
    else
      
      label = fields.map {|f| f.name.to_s }.join("|")
      res = "#@name [shape=record,label=\"{#{label}}\"];"
      
      fields.each do |f|
        f.constraints.each do |c|
          next unless c.kind_of? Constraint::References
          puts "#@name -> #{c.table.name}"
        end
      end
      #        lines.concat table_constraints.map {|c| c.to_sql}
      #        
      #        res = "create table #@name (\n    " +
      #          lines.join(",\n    ") +
      #          ");"
      #        @table_indices.each do |index|
      #          res << "\n" << index.to_sql
      #        end
      res
    end
  end
  
end

