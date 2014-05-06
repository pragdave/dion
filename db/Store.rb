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

# Implement the persistence layer
require 'dbi'
require 'db/TableDefinitions'

class Store
  attr_reader :in_transaction
  

  def initialize(*connection_params)
    @connection_params = connection_params
    @trans_nest = 0
  end

  def db
    @db ||= DBI.connect(*@connection_params)
  end

  def transaction
    db.do("begin") if @trans_nest == 0
    @trans_nest += 1
    @in_transaction = true
    begin
      yield
      transaction_commit
    rescue  Exception => e
      transaction_rollback
      raise
    ensure
      @trans_nest -=1 
    end
  end


  def locked_transaction(*tables)
    lockset = []
    transaction do
      tables.each { |table| lock_table(table) }
      yield
    end
  end

  def lock_table(klass)
    name = klass.name
    @db.do("lock table #{name} in exclusive mode")
  end

  def transaction_commit
    if @trans_nest == 1 && @in_transaction
      db.do("commit") 
      @in_transaction = false
    end
  end

  def transaction_rollback
    db.do("rollback") if @in_transaction
    @in_transaction = false
  end

  def raw_select(sql, *bindvars, &block)
#    $stderr.puts sql
#    $stderr.puts bindvars.inspect
    db.select_all(sql, *bindvars, &block)
  end

  def get_next_sequence(name)
    res = raw_select("select nextval('#{name}')")
    $stderr.puts name
    $stderr.puts res.inspect
    res[0][0].to_i
  end

  def quote(string)
    db.quote(string)
  end

  def select(klass, where='', *bindvars)
    sql = klass.select_sql
    select_with_where(klass, sql, where, *bindvars)
  end

  def count(klass, where="", *bindvars)
    count_with_where(klass, klass.count_sql, where, *bindvars)
  end

  def select_one(*args)
#    $stderr.puts args.inspect
    select(*args)[0]
  end

  def select_complex(klass, extra_tables, where, *bindvars)
    sql = klass.select_sql.dup
    if extra_tables && !extra_tables.empty?
      sql << "," << extra_tables.map{|t| t.name}.join(",")
    end
#    $stderr.puts sql
#    $stderr.puts bindvars.inspect
    select_with_where(klass, sql, where, *bindvars)
  end

  def select_complex(klass, extra_tables, where, *bindvars)
    sql = klass.select_sql.dup
    select_complex_common(sql, klass, extra_tables, where, *bindvars)
  end

  def count_complex(klass, extra_tables, where, *bindvars)
    sql = klass.count_sql.dup
    count_complex_common(sql, klass, extra_tables, where, *bindvars)
  end

  def select_complex_common(sql, klass, extra_tables, where, *bindvars)
    if extra_tables && !extra_tables.empty?
      sql << "," << extra_tables.map{|t| t.name}.join(",")
    end
    select_with_where(klass, sql, where, *bindvars)
  end

  def count_complex_common(sql, klass, extra_tables, where, *bindvars)
    if extra_tables && !extra_tables.empty?
      sql << "," << extra_tables.map{|t| t.name}.join(",")
    end
    count_with_where(klass, sql, where, *bindvars)
  end

  def select_with_where(klass, sql, where, *bindvars)
    if where && !where.empty?
      sql += " where " + where
    end
#    $stderr.puts sql
#    $stderr.puts bindvars.inspect
    basic_select(klass, sql, *bindvars)
  end

  def count_with_where(klass, sql, where, *bindvars)
    if where && !where.empty?
      sql += " where " + where
    end
#    $stderr.puts sql
#    $stderr.puts bindvars.inspect
    basic_count(klass, sql, *bindvars)
  end


  def basic_select_with_columns(klass, sql, *bindvars)
    cols = klass.fields.map {|f| "#{klass.name}.#{f.name}" }.join(",")
    basic_select(klass, sql.gsub(/%columns%/, cols), *bindvars)
  end

  def basic_select(klass, sql, *bindvars)
    res = []
    db.select_all(sql, *bindvars) do |row|
      res << Table.from_row(klass, row)
    end
    res
  end


  def basic_count(klass, sql, *bindvars)
    res = db.select_all(sql, *bindvars)
    res[0][0]
  end

  

  def insert_all(row)
    sql = row.type.insert_sql
    db.do(sql, *row.field_values)
    row.reset_changed
  end


  # insert, auto-allocating the primary key from a sequence
  def insert_sequenced(row)
    sql = row.type.insert_sql_minus_key
    vals = row.field_values_minus_key
#$stderr.puts sql
#$stderr.puts vals.inspect

    db.do(sql, *vals)
    insert_id = db.select_one(row.type.get_insert_id_sql)[0]
    row.send(row.type.primary_key.setter_name, insert_id)
    row.reset_changed
  end

  
  # delete a row
  def delete(row)
    table = row.type
    sql = "delete from #{table.name} where #{table.primary_key.name.to_s}=?"
    db.do(sql, row.send(table.primary_key.name))
  end

  # delete multiple rows
  def delete_where(table, where, *bindvars)
    sql = "delete from #{table.name} where #{where}"
    db.do(sql, *bindvars)
  end

  # update a table with new data
  def update(row)
    table = row.type
    fields = row.changed_fields
    return if fields.empty?

    sql = "update #{table.name}\nset\t"

    sql << fields.map{|field| "#{field} = ?"}.join(",\n\t")
    sql << ",\n\t_version = _version + 1\n"
    sql << "where\t"
    sql << table.primary_key.name.to_s << " = ?\n"
    sql << "  and\t_version = ?"

    # now get the values for the changed rows
    vals = fields.map do |f| 
      v = row.send(f)
      v = nil if v.type == String and v.empty?
      v
    end
    vals << row.send(table.primary_key.name)
    vals << row._version

    rpc = db.do(sql, *vals)
    if rpc != 1
      msg = "Expected to update one row, but updated #{rpc}: #{sql}\n\n" +
        vals.map {|v| v.inspect} .join("\n")
      $stderr.puts msg
    end

    row._version += 1

    row.reset_changed
  end

  # free-form update multiple rows
  def update_where(table, what, where, *bindvars)
    sql = "update #{table.name}\nset #{what} where #{where}"
#$stderr.puts sql
    db.do(sql, *bindvars)
  end

end
