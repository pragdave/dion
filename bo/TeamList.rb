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

require 'bo/TeamLevel'

class TeamList

  def TeamList.for_membership(mem_id)
    teams = $store.select(TeamTable,
                          "team_mem_id=? order by team_passport_suffix",
                          mem_id).map { |t| Team.new(t) }
    new(teams)
  end

  def TeamList.count_for_membership(mem_id)
    $store.count(TeamTable,
                 "team_mem_id=?",
                 mem_id)
  end


  # We're interested in a team if we're a manager for that team, or
  # if the team belongs to a teampak we're interested in


  def TeamList.for_user_id(user_id)
    sql = 
      "select %columns% from team, role \n" +
      " where role_user=? " +
      "   and role_name=#{RoleNameTable::TEAM_MANAGER} " +
      "   and role_target=team_id " 

    teams1 = $store.basic_select_with_columns(TeamTable, sql, user_id).map do |t|
      Team.new(t) 
    end

    sql = 
      "select %columns% from team, membership \n" +
      " where team_mem_id=mem_id and\n" +
      "       (mem_creator=? or mem_admin=?)"

     teams2 = $store.basic_select_with_columns(TeamTable,
                                               sql,
                                               user_id, user_id).map do |t|
      Team.new(t) 
    end


    merge = {}
    res = []

    (teams1+teams2).each { |t| res << t unless merge[t.team_id]; merge[t.team_id] = 1 }

    new(res)
  end

  def initialize(teams)
    @teams = teams
  end

  def empty?
    @teams.empty?
  end


  def includes_team_at_level(level)
    @teams.find {|team| team.team_level.to_s == level}
  end

  private :initialize



  # All the stuff that's fit for a portal page
  def portal_data(context)
    @teams.map { |team| team.portal_line(context) }
  end

  # How many teams do we have
  def size
    @teams.size
  end

  def [](i)
    @teams[i]
  end

  def each(&block)
    @teams.each(&block)
  end

  # How many competitive teams do we have
  def competitive_teams
    res = 0
    @teams.each { |team| res += 1 unless TeamLevel.is_primary?(team.team_level) }
    res
  end

  # Return the next available suffix, or nil if there isn't one
  def next_free_suffix_for(team_level)
    suffix = TeamLevel.is_primary?(team_level) ? 6 : 1

    taken = {}
    @teams.each {|t| taken[t.team_passport_suffix.to_i] = 1}

    suffix += 1 while taken[suffix]

    unless TeamLevel.is_primary?(team_level)
      suffix = nil unless suffix <= 5
    end

    suffix
  end



end
