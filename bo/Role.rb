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

require 'bo/Affiliate'
require 'bo/Region'
require 'bo/Membership'
require 'bo/Team'

class Role < BusinessObject

  class TargetInfo
    attr_reader :name, :viewer_class, :viewer_method, :target_id



    ######################################################################

    def initialize(target_type, target_id)
      @target_type = target_type
      @target_id   = target_id
      
      klass = case  target_type
              when TargetTable::MEMBERSHIP then Membership
              when TargetTable::TEAM       then Team
              when TargetTable::AFFILIATE  then Affiliate
              when TargetTable::CHALLENGE  then ChallengeDesc
              else 
                nil
              end

      target = nil

      if klass
        target = klass.with_id(target_id)
      end

      if target.nil?
        @name = "???"
        @viewer_class = @viewer_method = nil
        $stderr.puts "Couldn't create TargetInfo(#{target_type}, #{target_id})"
      else
        @name  = target.target_name
        @viewer_class = target.viewer_class
        @viewer_method = target.viewer_method
      end
    end

    def to_s
      name
    end
  end

  @@name_table = nil
  @@target_table = nil

  def Role.count_roles(aff_id, role_name)
    sql = "select count(*) from role  where role_name=? "
    params = [ role_name ]
    if aff_id
      sql << " and role_affiliate = ?"
      params << aff_id
      end
    res = $store.raw_select(sql, *params)
    res[0][0]
  end

  ######################################################################
  
  def Role.delete_for_teampak(mem_id)
    teams = TeamList.for_membership(mem_id)
    teams.each do |team|
      $store.delete_where(RoleTable,
                          "role_target_type=#{TargetTable::TEAM} and " +
                          "role_target=?",
                          team.team_id)
    end

    $store.delete_where(RoleTable,
                        "role_target_type=#{TargetTable::MEMBERSHIP} and " +
                        "role_target=?",
                        mem_id)
  end

  # Use this where the role is defined per user

  def Role.set_user_role(user, aff, region, role_name, target_type, target)
    $store.transaction do
      $store.delete_where(RoleTable,
                          "role_user=? and " +
                          "role_name=?",
                          user, role_name)
      Role.add(user, aff, region, role_name, target_type, target)
    end
  end

  # use this one when there's just one person linked to a particular
  # target (say a teampak creator). It deletes out any existing
  # ones before adding the new

  def Role.set(user, aff, region, role_name, target_type, target)
    $store.transaction do
      $store.delete_where(RoleTable,
                          "role_name=? and " +
                          "role_target_type=? and role_target=?",
                          role_name, target_type, target)
      Role.add(user, aff, region, role_name, target_type, target)
    end
  end

  def Role.delete_role(role_id)
    $store.delete_where(RoleTable, "role_id=?", role_id)
  end

  
  def Role.add(user, aff, region, role_name, target_type, target)
    r = new
    r.role_user = user
    r.role_affiliate = aff
    r.role_region    = region
    r.role_name      = role_name
    r.role_target_type = target_type
    r.role_target      = target
    r.save
  end

  def Role.change_membership_region(mem_id, reg_id)
    $store.update_where(RoleTable,
                        "role_region=?",
                        "role_target_type=#{TargetTable::MEMBERSHIP} and " +
                        "role_target=?",
                        reg_id, mem_id)
  end

  def Role.count_user_in_affiliate(user_id, aff_id)
    res = $store.raw_select("select count(*) from role " +
                            " where role_user=? and role_affiliate=?",
                            user_id, aff_id)
    res[0][0]
  end

  def Role.team_managers(team_id)
    res = $store.select(RoleTable,
                        "role_name=#{RoleNameTable::TEAM_MANAGER} and " +
                        "role_target_type=#{TargetTable::TEAM} and " +
                        "role_target=?",
                        team_id)
    res.map {|r| User.with_id(r.role_user) }
  end


  def initialize(data_object=nil)
    @data_object = data_object || RoleTable.new
  end


  def role_user=(u)
    @data_object.role_user = u
    @user = nil
  end

  def user
    @user ||= (User.with_id(@data_object.role_user) || User.new)
  end

  ########################################################################
  #
  # This stuff is basically for debugging
  #

  def name
    load_name_table
    @@name_table[@data_object.role_name]
  end


  def target_name
    load_target_table
    @@target_table[@data_object.role_target_type]
  end

  def target_info
    TargetInfo.new(@data_object.role_target_type, @data_object.role_target)
  end

  def affiliate
    Affiliate.with_id(@data_object.role_affiliate)
  end
  
  def region
    Region.with_id(@data_object.role_region)
  end

  private

  def load_name_table
    return if @@name_table
    @@name_table = {}
    $store.select(RoleNameTable).each do |row|
      @@name_table[row.rn_id] = row.rn_name
    end
  end

  def load_target_table
    return if @@target_table
    @@target_table = {}
    $store.select(TargetTable).each do |row|
      @@target_table[row.tar_id] = row.tar_name
    end
  end
end
