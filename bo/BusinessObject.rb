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

require 'db/TableDefinitions'
require 'util/Formatters'

class BusinessObject

  include Formatters

  class <<self
    include Formatters
  end

  def BusinessObject.maybe_return(data_object)
    if data_object
      new(data_object)
    else
      nil
    end
  end


  # Business objects can delegate to the underlying
  # data object (providing easy access to fields)

  def method_missing(*args)
    if @data_object
      @data_object.send(*args)
    else
      super
    end
  end

  def add_to_hash(hash, prefix=nil)
    if @data_object
      hash.update(@data_object.to_h(prefix))
    end
    hash
  end

  # Save away if new record, or update if existing. If we really want to 
  # force an insert, but the record already has a primary key (for example
  # when two tables share a primary key) you can set force_primary_key to
  # the key value.

  def save(force_primary_key=nil)
    if @data_object.existing_record?
      $store.update(@data_object)
    else
      if force_primary_key
        @data_object.set_primary_key(force_primary_key)
        $store.insert_all(@data_object)
      else
        $store.insert_sequenced(@data_object)
      end
    end
    @data_object.primary_key_value
  end

  def delete
    $store.delete(@data_object)
  end


  # Read a checkbox back from a value hash
  def bool(val)
    case val
    when true, false
      val
    else
      !!(val && val.downcase == 'on')
    end
  end

  # Check the length of a string field, appending to an error array
  # if invalid
  def check_length(errors, field, length, msg)
    if field && field.respond_to?(:length)
      if field.length > length
        errors << "Field '#{msg}' must be #{length} or fewer characters"
      end
    end
  end
end
