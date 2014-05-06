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

class Region < BusinessObject

  NONE = -1

  def Region.with_id(reg_id)
    maybe_return($store.select_one(RegionTable, "reg_id=?", reg_id))
  end

  def Region.list(aff_id)
    $store.select(RegionTable, "reg_affiliate=? order by reg_name", aff_id).map {|a| new(a)}
  end

  # Options for a ddlb
  def Region.options(aff_id)
    res = { 
      NONE => "No region"
    }
    list(aff_id).each {|r| res[r.reg_id] = r.reg_name }
    res
  end

  def initialize(data_object = nil)
    @data_object = data_object || fresh_region
  end

  def fresh_region
    r = RegionTable.new
    r.reg_name = ''
    r
  end

  def from_hash(values)
    @data_object.reg_name = values['reg_name']
  end

  def error_list
    if @data_object.reg_name.empty?
       ["Missing region name"]
    else
      []
    end
  end

  # Does this region have any of the following entities associated with it?

  def has_rds?
    list =  RoleList.for_users_with_role_and_target(RoleNameTable::RD,
                                                    TargetTable::REGION,
                                                    @data_object.reg_id)
    !list.empty?
  end

  def has_teampaks?
    Membership.count_for_region(@data_object.reg_id) > 0
  end

  def has_users?
    User.count_for_region(@data_object.reg_id) > 0
  end

  def has_news?
    News.count_for_region(@data_object.reg_id) > 0
  end

end
