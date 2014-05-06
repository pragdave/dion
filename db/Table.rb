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
#  class <<self
#    protected :new
#  end

  def initialize
    @changed = {}
    @_version = 0
  end

  def load_from_row(row)
    fields = type.fields
    fail "Invalid row size" unless row.size == fields.size
    fields.each_with_index do |field, i|
      send field.setter_name, row[i]
    end
  end

  def [](name)
    send name
  end

  def to_h(prefix=nil)
    res = {}
    prefix = prefix.to_s
    type.fields.each do |f|
      name = prefix + f.name.to_s
      res[name] = send(f.name)
    end
    res
  end

  def set_changed(name)
    @changed[name] = 1
#    puts "#{name} changed"
  end

  def changed?(name)
    @changed[name]
  end


  def reset_changed
    @changed.clear
  end

  def changed_fields
    @changed.keys
  end

  def record_changed?
    !@changed.keys.empty?
  end

  def field_values
    field_values_common(type.fields)
  end

  def field_values_minus_key
    field_values_common(type.fields.reject{|f| f.primary_key?})
  end

  # We're an existing record if we have a value in our
  # primary key
  def existing_record?
    send(type.primary_key.name)
  end

  # There's a strange case to do with shipping addresses where we
  # need to force a re-insert of a record (see Contract).
  def force_insert
    set_primary_key(nil)
  end

  def set_primary_key(val)
    send(type.primary_key.setter_name, val)
  end

  # Return the value of our primary key. By coincidence, that's
  # the same code as 'existing_record?', so...

  alias :primary_key_value :existing_record?

  private

  def field_values_common(fields)
    fields.map do |f|
      v = send f.name
      if v.type == String and v.empty?
        nil
      else
        v
      end
    end
  end

end
