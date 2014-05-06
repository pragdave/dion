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

require 'bo/BusinessObject'

class ChangeRequest < BusinessObject

  attr_reader :changed

  def ChangeRequest.with_id(cr_id)
    maybe_return($store.select_one(ChangeRequestTable, "cr_id=?", cr_id))
  end


  def ChangeRequest.count
    res = $store.raw_select("select count(*) from change_request " +
                            " where cr_date_done is null")
    res[0][0]
  end

  def ChangeRequest.list
    res = $store.select(ChangeRequestTable,
                        "cr_date_done is null order by cr_date_requested").map do |cr|
      new(cr)
    end
  end


  def ChangeRequest.delete_for_teampak(mem_id)
    $store.delete_where(ChangeRequestTable, "cr_mem_id=?", mem_id)
  end

  ######################################################################

  def initialize(data_object = nil)
    @data_object = data_object || fresh_change_request
    @changed = false
  end

  def fresh_change_request
    cr = ChangeRequestTable.new
    cr.cr_date_requested = DBI::Timestamp.new(Time.now)
    cr
  end


  def add_to_hash(values)
    cr = @data_object
    values['cr_date_requested'] = fmt_date(cr.cr_date_requested)
    values['user'] = User.with_id(cr.cr_user_id).contact.con_name
    mem = Membership.with_id(cr.cr_mem_id)
    values['mem_passport'] = mem.full_passport

    list = []
    add_change(list, @data_object.cr_mem_name,       mem.mem_name, "TeamPak name")
    add_change(list, @data_object.cr_mem_schoolname, mem.mem_schoolname, "School name")
    add_change(list, @data_object.cr_mem_district,   mem.mem_district, "District")
    
    values['changes'] = list
    values
  end
  
  def add_change(list, new_val, old_val, name)
    if new_val && !new_val.empty?
      list << {
        'field' => name,
        'from'  => old_val,
        'to'    => new_val
      }
    end
  end

  ######################################################################

  def accept(user)
    cr = @data_object
    mem = Membership.with_id(cr.cr_mem_id)
    
    if mem
      if cr.cr_mem_name && !cr.cr_mem_name.empty?
        mem.mem_name = cr.cr_mem_name
      end
      if cr.cr_mem_schoolname && !cr.cr_mem_schoolname.empty?
        mem.mem_schoolname = cr.cr_mem_schoolname
      end
      if cr.cr_mem_district && !cr.cr_mem_district.empty?
        mem.mem_district = cr.cr_mem_district
      end

      mem.save
      notes = "Change accepted: " + to_s
      mem.log(user, notes)
      user.log(notes)
    end

    cr.cr_date_done = Time.now
    cr.cr_done_by   = user.user_id
    cr.cr_accepted  = true
    save
  end


  def decline(user)
    cr = @data_object
    mem = Membership.with_id(cr.cr_mem_id)

    notes = "Change declined: " + to_s

    mem.log(user, notes)
    user.log(notes)

    cr.cr_date_done = Time.now
    cr.cr_done_by   = user.user_id
    cr.cr_accepted  = false
    save
  end

  ######################################################################

  # Mutators, used to flag the actual changes we want

  def mem_name=(name)
    @data_object.cr_mem_name = name
    @changed = true
  end

  def mem_schoolname=(name)
    @data_object.cr_mem_schoolname = name
    @changed = true
  end

  def mem_district=(name)
    @data_object.cr_mem_district = name
    @changed = true
  end

  def save
    super()
    @changed = false
  end


  def to_s
    res = ""
    cr = @data_object
    if cr.cr_mem_name && !cr.cr_mem_name.empty?
      res << "Name -> #{cr.cr_mem_name} "
    end
    if cr.cr_mem_schoolname && !cr.cr_mem_schoolname.empty?
      res << "School -> #{cr.cr_mem_schoolname} "
    end
    if cr.cr_mem_district && !cr.cr_mem_district.empty?
      res << "District -> #{cr.cr_mem_district} "
    end
    res
  end
end
