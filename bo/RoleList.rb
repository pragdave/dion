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

require 'bo/Role'

class RoleList
  def RoleList.for_user(user_id)
    $store.select(RoleTable, "role_user=?", user_id).map {|r| Role.new(r) }
  end 

  # Return a hash containing role names and counts for a particular user
  def RoleList.counts_for_user(user_id)
    res = {}
    sql = 
      "select rn_name, count(rn_name) from role, role_name " +
      " where role_user=? and rn_id=role_name group by rn_name"

    $store.raw_select(sql, user_id).each do |rn_name, count|
      res[rn_name] = count
    end
    res
  end

  # Return a list of users (for example) who are managers of a given team
  def RoleList.for_users_with_role_and_target(role_name, target_type, target_id)
    res = $store.select(RoleTable,
                        "    role_name=? " +
                        "and role_target_type=? " +
                        "and role_target=?",
                        role_name, target_type, target_id)
    res.map { |row| Role.new(row) }
  end


  # Count the number of unique users for a given target
  def RoleList.count_target_users(target_type, target_id)
    sql = 
      "select count(distinct role_user) from role " +
      " where role_target_type=? and role_target=?"

    res = $store.raw_select(sql, target_type, target_id)
    res[0][0]
  end

  ######################################################################

  # reassign RDs from old_region to new_region

  def RoleList.reassign_region_target(old_reg_id, new_reg_id)
    if new_reg_id
      $store.update_where(RoleTable,
                          "role_target=?",
                          "role_target_type=#{TargetTable::REGION} and " +
                          "role_target=?",
                          new_reg_id,
                          old_reg_id)
    else
      $store.delete_where(RoleTable,
                          "role_target_type=#{TargetTable::REGION} and " +
                          "role_target=?",
                          old_reg_id)
    end
  end

  ######################################################################

  # reassign RDs from old_region to new_region

  def RoleList.delete_role_region(old_reg_id)
    $store.update_where(RoleTable,
                        "role_region=null",
                        "role_region=?",
                        old_reg_id)
  end

  ######################################################################

  # Return a rolelist for a user that can be traversed by the Portal

  def initialize(user)
    @role_list = RoleList.for_user(user.user_id)
    index_role_list
  end


  def each_role_name
    @role_names.each {|rn| yield rn}
  end


  def each_relationship_for_name(name)
    list = @per_role[name]
    if list
      list.each  {|role| yield role}
    end
  end

  private

  # produce a structure that groups all the relationships for a
  # particular role together

  def index_role_list
    @per_role = {}
    @role_list.each do |role|
      @per_role[role.role_name] ||= []
      @per_role[role.role_name] << role
    end

    # then produce a list of names in priority order
    @role_names = @per_role.keys.sort
  end
end
