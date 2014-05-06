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

require "app/Teams"
require "app/Register"
require 'bo/BusinessObject'
require 'bo/Challenge'
require 'bo/ChallengeDesc'
require 'bo/ChallengeView'
require 'bo/TeamMember'
require 'bo/TeamLevel'
require 'bo/Role'

class Team < BusinessObject

  attr_reader :mgr_email
  attr_writer :must_be_primary

  def Team.with_id(team_id)
    maybe_return($store.select_one(TeamTable, "team_id=?", team_id))
  end

  ######################################################################
  # return the number of teams, optionally qualified by an affiliate
  def Team.count_teams(aff_id)
    sql = "select count(*) from team "
    params = []
    if aff_id
      sql << ", membership where team_mem_id=mem_id and mem_affiliate=?"
      params << aff_id
    end
    res = $store.raw_select(sql, *params)
    res[0][0]
  end


  ######################################################################
  # return the number of teams per affiliate
  def Team.count_by_affiliate
    sql = "select aff_long_name, count(*) from team, membership, affiliate " +
      "where team_mem_id=mem_id and mem_affiliate=aff_id " +
      "group by aff_long_name order by 2 desc"
    $store.raw_select(sql)
  end


  ######################################################################
  # return a hash of team counts for an affiliate, with the first key being the
  # challenge and the second the level
  def Team.count_detail(aff)
    sql = 
      "select cha_chd_id, team_level, count(team_level) " +
      "  from team, challenge, membership " +
      " where team_mem_id=mem_id " +
      "   and team_challenge=cha_id " 
      
    if aff
      sql << "and mem_affiliate=#{aff.aff_id}" 
    end

    sql << " group by cha_chd_id, team_level"

    res = $store.raw_select(sql)

    chd_name = {}
    counts = {}

    level_counts = {}
    TeamLevel.options.keys.each { |k| level_counts["L#{k}"] = 0 }

    ChallengeDesc.list.each do |chd|
      name = chd_name[chd.chd_id] = chd.chd_name
      counts[name] = level_counts.dup
    end

    res.each do |challenge, level, count|
      name = chd_name[challenge]
      counts[name]["L#{level}"] = count rescue 0;
    end
    counts
  end


  ######################################################################

  # Return a count of items that match a particular set of criteria

  def Team.count_from_search(where, tables)
    tables = tables.reject {|t| t == TeamTable}
    $store.count_complex(TeamTable,
                         tables,
                         where)
  end

  ######################################################################
  # Return a set of rows for a download
  # We have to cheat here. If the list of columns includes
  # 'tm1_name', we have to add the list of team members to the rest
  # of the results


  def Team.download(col_names, where, table_names)
    if (get_members = /Name 1/ =~ col_names)
      col_names = col_names.sub(/Name 1.*?Grade 7/, '')
    end

    if (get_first_tm = /1st TM/ =~ col_names)
      col_names = col_names.sub(/1st TM.*?1st TM Country/, '')
    end

    if (get_all_tms = /TM 1:/ =~ col_names)
      col_names = col_names.sub(/TM 1:.*?TM 5: E-Mail/, '')
    end

    if get_members || get_first_tm || get_all_tms
      col_names = "team_id," + col_names
      col_names.sub!(/,+$/, '')
      col_names.gsub!(/,,+/, ',')
    end

    sql = "select #{col_names} from #{table_names}"
    sql << " where #{where}" unless where.empty?

    if table_names =~ /membership/
      sql << " order by mem_passport_prefix, mem_passport, team_passport_suffix"
    end

    $store.raw_select(sql) do |row|
      if get_members || get_first_tm || get_all_tms
        row = row.to_a
        team_id = row.shift
        add_team_members(team_id, row) if get_members

        if get_first_tm || get_all_tms
          tms = RoleList.for_users_with_role_and_target(RoleNameTable::TEAM_MANAGER,
                                                        TargetTable::TEAM,
                                                        team_id)
          add_first_tm(tms, row)     if get_first_tm
          add_all_tms(tms, row)      if get_all_tms
        end
      end
      yield row
    end
  end

  # we could be talking about a serious number of objects here, so we
  # bypass the TeamMamber BO and do it the hard way
  def Team.add_team_members(team_id, row)
    count = 7
    $store.raw_select("select tm_name, tm_dob, tm_grade " +
                      "  from team_member where tm_team_id=?",
                      team_id) do |name, dob, grade|
      row << name << dob << grade
      count -= 1
    end

    count.times { row << nil << nil << nil }
  end

  # Get the information for the first team manager
  def Team.add_first_tm(tms, row)
    if tms.empty? || (user = tms[0].user).nil?
      13.times { row << nil }
      return
    end

    con = user.contact
    row << con.con_first_name << con.con_last_name << con.con_email
    row << con.con_day_tel << con.con_eve_tel << con.con_fax_tel

    add = con.mail
    row << add.add_line1 << add.add_line2 << add.add_city
    row << add.add_state << add.add_zip   << add.add_county << add.add_country
  end

  # add name and e-mail information for up to 5 TMs
  def Team.add_all_tms(tms, row)
    count = 5
    tms.each do |role|
      user = role.user
      if user
        con = user.contact
        row << con.con_first_name << con.con_last_name << con.con_email
      end
      count -= 1
      break if count.zero?
    end
    count.times { row << nil << nil << nil }
  end

  ######################################################################

  def Team.delete_for_teampak(mem_id)
    TeamMember.delete_for_teampak(mem_id)
    $store.delete_where(TeamTable, "team_mem_id=?", mem_id)
  end

  ######################################################################

  # Create a new team entry
  def initialize(data_object=nil)
    @data_object = data_object || fresh_object
    @members = get_members(@data_object.team_id)
    if @data_object.team_mem_id
      @mem = Membership.with_id(@data_object.team_mem_id)
    end
  end

  def fresh_object
    tm = TeamTable.new
    tm.team_dt_created = Time.now
    tm
  end

  
  def membership=(mem)
    @mem = mem
    @data_object.team_mem_id = mem.mem_id
  end

  # Return an array of User objects of this team's managers

  def managers
    if @data_object.team_id
      Role.team_managers(@data_object.team_id)
    else
      []
    end
  end

  def add_to_hash(values, team_list=[])
    super(values)

    values['must_be_primary'] = @must_be_primary

    set_teamlevel_options(values, team_list)

    values['team_challenge_opts'] = 
      ChallengeView.options_for_affiliate(@mem.mem_affiliate)

#    values['mgr_email'] = @mgr_email

    values['members'] = @members.map {|m| m.add_to_hash({}) }

    values['team_passport'] = team_passport

    values['team_is_valid'] = !!@data_object.team_is_valid

    values['team_dt_created'] = fmt_date(@data_object.team_dt_created)
    values
  end

  def set_teamlevel_options(values, team_list)

    if @must_be_primary
      values['level_fixed'] = true
      values['fixed_level_name'] = TeamLevel::Options[TeamLevel::Primary]
      return
    end

    # No need to check if we're the only team there
    show_all = team_list.empty? || (team_list.size == 1 && team_list[0].team_id == team_id)

    unless show_all
      for level in [ TeamLevel::University, TeamLevel::DiLater ]
        if team_list.includes_team_at_level(level)
          @data_object.team_level = level
          values['level_fixed'] = true
          values['fixed_level_name'] = TeamLevel::Options[level]
          break
        end
      end
    end
    

    # don't show university/dilater options unless the list
    # is empty (so the choice is free) or we're the only entry
    # in the list. 

    unless values['level_fixed']
      values['team_level_opts'] = TeamLevel.options(show_all)
    end

  end

  # Recover ourselves from a hash of values
  def from_hash(values)
    @data_object.team_challenge = values['team_challenge']
    @data_object.team_level     = values['team_level']
    @data_object.team_name      = values['team_name']

#    @mgr_email = values['mgr_email']

    names = values['tm_name']

    TeamMember::MEMBERS_PER_TEAM.times do |i|
      if names[i].empty?
        @members[i].clear
      else
        @members[i].tm_name = names[i]
        @members[i].tm_grade = values['tm_grade'][i].to_i
        @members[i].tm_dob_mon  = values['tm_dob_mon'][i]
        @members[i].tm_dob_day  = values['tm_dob_day'][i]
        @members[i].tm_dob_year = values['tm_dob_year'][i]
        @members[i].tm_sex      = values['tm_sex'][i]
      end
    end
  end


  # report on any errors we contain
  def error_list
    res = []
    t = @data_object
    res << "Missing team name" if t.team_name.empty?

    check_length(res, t.team_name, 100, "Team Name")

    cha = Challenge.with_id(t.team_challenge)
    if cha
      msg = cha.check_ok_for_level(t.team_level)
      res << msg if msg
    else
      res << "Unknown challenge"
    end

    @members.each do |m|
      unless m.tm_name.empty?
        res.concat m.error_list
      end
    end

    if res.empty?
      err = check_team_level
      res << err if err
    end
    res
  end


  def check_team_level
    max_age = -1
    min_grade = 99
    max_grade = -1
    
    @members.each do |m|
      unless m.tm_name.empty?
        # if any team member has no DOB, then can't use that to check
        if m.age_on_j15.nil?
          max_age = -1
        else
          max_age   = m.age_on_j15 if m.age_on_j15 > max_age
        end
        min_grade = m.tm_grade if m.tm_grade < min_grade
        max_grade = m.tm_grade if m.tm_grade > max_grade
      end
    end

    if max_grade > -1
      invalid =  TeamLevel.verify(@data_object.team_level, max_age, min_grade, max_grade)
    else
      invalid = false
    end
    @data_object.team_is_valid = !invalid
    invalid
  end

  # Save this team away to disk
  def save
    super
    @members.each do |m|
      m.tm_team_id = @data_object.team_id
      m.save
    end
  end

  def delete
    @members.each { |m| m.delete }
    super
  end

  # A dump of all infofmation that's useful for a status page
  def portal_line(context)
    level_name = TeamLevel::Options[team_level.to_s]

    manager_names =  managers.map do |m|
      m.contact.add_to_hash({ "manager" => m.contact.con_name})
    end

    cha = Challenge.with_id(team_challenge)

    {
      "team_name" => team_name,
      "team_passport_suffix" => team_passport_suffix,
      "team_passport" => team_passport,
      "level_name" => TeamLevel::Options[team_level.to_s],
      "short_level_name" => level_name[0,1],
      "managers"   => manager_names,
      "challenge"  => ChallengeDesc.with_id(cha.cha_chd_id).chd_name,
      "team_status_url" => context.url(Teams,
                                       :handle_status,
                                       team_mem_id,
                                       team_id),
      "passport_url" => context.url(Register, :handle_status, team_mem_id),
      "delete_url" => context.url(Teams, 
                                  :handle_delete,
                                  team_mem_id,
                                  team_id),
      "change_url" => context.url(Teams,
                                  :handle_change,
                                  team_mem_id,
                                  team_id)
    }
  end


  # For use in Role.rb
  def target_name
    team_name
  end

  def viewer_class
    nil
  end

  def viewer_method
    nil
  end

  private

  def get_user(user_id)
    if user_id
      User.with_id(user_id)
    else
      User.new
    end
  end

  def get_members(team_id)
    if team_id
      res = TeamMember.list_with_team_id(team_id)
      excess = TeamMember::MEMBERS_PER_TEAM - res.length
      excess.times { res << TeamMember.new }
      res
    else
      TeamMember.new_list
    end
  end

  
  def team_passport
    tp = ''
    if @mem
      tp = "#{@mem.full_passport}-#{@data_object.team_passport_suffix || '?'}"
    end
    tp
  end

end
