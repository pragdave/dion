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

# Allow the user to specify criteria which are then used to determine
# 1. what gets downloaded
# 2. who gets e-mailed
# 3. what gets listed
#
# and so on. Basically, this class manages the process up to the point
# where we have a set of criteria that will generate a list of teampaks,
# teams, or users, and then a subclass takes over.


require "app/Application"
require "app/SelectTemplates"
require 'db/MemberSearch'
require 'db/TeamSearch'
require 'db/UserSearch'

class Select < Application
  app_info(:name => "Select")

  class AppData
    attr_accessor :aff_id
    attr_accessor :reg_id
    attr_accessor :selection_type
    attr_accessor :criteria
    attr_accessor :where_clause
    attr_accessor :tables
  end

  def app_data_type
    AppData
  end

  ######################################################################

  SD = Struct.new(:where, :tables)

  ######################################################################

  TEAMPAK = "0"
  TEAM    = "1"
  USER    = "2"

  # These are the various predefined search criteria

  TP_C_ALL        = "101"
  TP_C_ACTIVE     = "102"
  TP_C_WTPAY      = "103"
  TP_C_NO_TEAMS   = "104"
  TP_C_ACT_NO_TEAMS   = "105"
  TP_C_CUSTOM     = "199"

  TM_C_ALL        = "200"
  TM_C_NO_KIDS    = "201"
  TM_C_KIDS       = "202"
  TM_C_INVALID    = "203"
  TM_C_CUSTOM     = "299"

  US_C_ALL        = "301"
  US_C_TEAMPAK    = "302"
  US_C_TM         = "303"

  US_C_CUSTOM     = "399"

  TypeOpts = {
    TEAMPAK => "TeamPaks",
    TEAM    => "Teams",
    USER    => "Individuals",
  }


  TypeSearchMenu = {
    TEAMPAK => {
      'criteria' => TP_C_ALL,
      'criteria_opts' => {
        TP_C_ALL      => "All TeamPaks",
        TP_C_ACTIVE   => "Active TeamPaks",
        TP_C_WTPAY    => "Unpaid TeamPaks",
        TP_C_NO_TEAMS => "TeamPaks with no teams",
        TP_C_ACT_NO_TEAMS => "Active TeamPaks with no teams",
        TP_C_CUSTOM   => "Custom search",
      }
    },

    TEAM    => {
      'criteria' => TM_C_ALL,
      'criteria_opts' => {
        TM_C_ALL      => "All teams",
        TM_C_KIDS  => "Teams with kids",
        TM_C_NO_KIDS  => "Teams with no kids",
        TM_C_INVALID  => "Teams competing at the wrong level",
        TM_C_CUSTOM   => "Custom search",
      }
    },

    USER    => {
      'criteria' => US_C_ALL,
      'criteria_opts' => {
        US_C_ALL     => "All individuals",
        US_C_TEAMPAK => "TeamPak Admins/Creators",
        US_C_TM      => "Team Managers",
        US_C_CUSTOM  => "Custom search",
      }
    },
  }

  ######################################################################

  SelectData = {

    TP_C_ALL      => SD.new(nil,
                            [MembershipTable]),
    
    TP_C_ACTIVE   => SD.new("mem_state='#{StateNameTable::Active}'",
                            [MembershipTable]),
    
    TP_C_WTPAY    => SD.new("mem_state='#{StateNameTable::WaitPayment}'",
                            [MembershipTable]),
    
    TP_C_NO_TEAMS => SD.new("not exists(select 1 from team where team_mem_id=mem_id)", 
                            [MembershipTable]),

    TP_C_ACT_NO_TEAMS => SD.new("mem_state='ACTIVE' and " +
                            "not exists(select 1 from team where team_mem_id=mem_id)", 
                            [MembershipTable]),


    # Teams
    TM_C_ALL     => SD.new(nil, [TeamTable]),

    TM_C_NO_KIDS => SD.new("not exists(select 1 from team_member where tm_team_id=team_id)",
                           [TeamTable]),

    TM_C_KIDS    => SD.new("exists(select 1 from team_member where tm_team_id=team_id)",
                           [TeamTable]),

    TM_C_INVALID => SD.new("not team_is_valid", [TeamTable]),


    # Users
    US_C_ALL     => SD.new(nil, [UserTable]),

    US_C_TEAMPAK => SD.new("exists (select 1 from membership " +
                           "         where mem_admin=user_id " +
                           "            or mem_creator=user_id)",
                           [UserTable]),

    US_C_TM      => SD.new("exists (select 1 from role " +
                           " where role_name=#{RoleNameTable::TEAM_MANAGER} " +
                           "   and role_user=user_id)",
                           [UserTable]),


  }


  ######################################################################
  # This is an entry point from other code. It allows us to set the 
  # report type and criteria explicitly

  def do_specific_list(aff_id, reg_id, selection_type, criteria)
    @data.aff_id = aff_id
    @data.reg_id = reg_id
    @data.selection_type = selection_type
    @data.criteria = criteria
    handle_criteria_internal(@data.criteria)
  end

  ######################################################################

  def start_selection(aff_id=nil)
    @data.aff_id = aff_id
    @data.selection_type = TEAMPAK
    start_common
  end

  def start_common
    values = {
      'selection_type' => @data.selection_type,
      'type_opts'     => TypeOpts,
      'form_url'      => url(:handle_type),
      'function'      => function,
    }
    standard_page("Select Download Type", values, SELECTION_TYPE)
  end

  ######################################################################

  def handle_type
    dt = @cgi['selection_type']
    values = TypeSearchMenu[dt]
    unless values
      note "Please select a type"
      return start_common
    end

    @data.selection_type = dt
    select_criteria

  end

  def select_criteria
    values = TypeSearchMenu[@data.selection_type].dup
    values['form_url'] = url(:handle_criteria)
    values['function'] = function
    if @data.criteria
      values['criteria'] = @data.criteria
    end

    standard_page("Enter Search Criteria", values, SEARCH_CRITERIA)
  end


  ######################################################################

  def handle_criteria
    @data.criteria = @cgi['criteria']
    handle_criteria_internal(@data.criteria)
  end

  def handle_criteria_internal(criteria)
    case criteria
    when nil
      return handle_type
    when TP_C_CUSTOM
      return teampak_custom_criteria
    when US_C_CUSTOM
      return user_custom_criteria
    when TM_C_CUSTOM
      return team_custom_criteria
    else
      select = SelectData[criteria]
      return handle_type unless select
      @data.where_clause = select.where
      @data.tables       = select.tables.dup
      add_affiliate_constraints
      work_out_data
    end
  end


  ######################################################################

  def teampak_custom_criteria
    ms = MemberSearch.new(@session)
    ms.display_all_fields

#    $stderr.puts "Affiliate ID = #{@data.aff_id.inspect}"
    aff = Affiliate.with_id(@data.aff_id)
    if aff
      ms.fix_field(:mem_affiliate, @data.aff_id)
      ms.fix_field(:mem_passport_prefix, aff.aff_passport_prefix)
    end

    html = ms.to_form(url(:handle_teampak_custom_criteria), 
                      false,
                      "Select TeamPaks",
                      '')

    standard_page("Search for TeamPak",
                  { 'done' => url(:handle_teampak_custom_criteria),
                    'function' => function,
                  },
                  SEARCH_PAGE,
                  html)
  end


  def handle_teampak_custom_criteria
    ms = MemberSearch.new(@session)
    @data.where_clause, @data.tables = ms.build_query
    work_out_data
  end

  ######################################################################

  def team_custom_criteria
    ts = TeamSearch.new(@session)
    ts.display_all_fields

    aff = Affiliate.with_id(@data.aff_id)

    if aff
      ts.fix_field(:mem_affiliate, @data.aff_id)
      ts.fix_field(:mem_passport_prefix, aff.aff_passport_prefix)
    end

    html = ts.to_form(url(:handle_team_custom_criteria), 
                      false,
                      "Select Teams",
                      '')

    standard_page("Search for Teams",
                  { 'done' => url(:handle_team_custom_criteria),
                    'function' => function,
                  },
                  SEARCH_PAGE,
                  html)
  end


  def handle_team_custom_criteria
    ts = TeamSearch.new(@session)
    @data.where_clause, @data.tables = ts.build_query
    work_out_data
  end

  ######################################################################

  def user_custom_criteria
    us = UserSearch.new(@session)
    us.display_all_fields

    if @data.aff_id && @data.aff_id != 0
      us.fix_field(:role_affiliate, @data.aff_id)
    end

    html = us.to_form(url(:handle_user_custom_criteria), 
                      false,
                      "Select Individuals",
                      '')

    standard_page("Search for Individuals",
                  { 'done' => url(:handle_user_custom_criteria),
                    'function' => function,
                  },
                  SEARCH_PAGE,
                  html)
  end


  def handle_user_custom_criteria
    us = UserSearch.new(@session)
    @data.where_clause, @data.tables = us.build_query
    work_out_data
  end

  ######################################################################

  def count_matches
    case @data.selection_type
    when TEAMPAK
      Membership.count_from_search(@data.where_clause, @data.tables)
    when TEAM
      Team.count_from_search(@data.where_clause, @data.tables)
    when USER
      User.count_from_search(@data.where_clause, @data.tables)
    end
  end

  ######################################################################

  # If the affiliate ID or region id is set, add constraints to the where clause
  # to limit the search to that affiliate. 

  def add_affiliate_constraints
    return unless @data.aff_id || @data.reg_id

    extra = ""

    case @data.selection_type
    when TEAMPAK
      if @data.reg_id
        extra = "mem_region=#{@data.reg_id}"
      else
        extra = "mem_affiliate=#{@data.aff_id}"
      end
    when USER
      if @data.aff_id
        extra = "user_affiliate=#{@data.aff_id}"
      end
    when TEAM
      if @data.reg_id
        extra = "mem_region=#{@data.reg_id} and team_mem_id=mem_id"
      else
        extra = "mem_affiliate=#{@data.aff_id} and team_mem_id=mem_id"
      end
      @data.tables ||= []
      @data.tables << MembershipTable
    end

    if @data.where_clause
      @data.where_clause += " and " + extra
    else
      @data.where_clause = extra
    end
  end


  
  # If we used a customer search, and if the data selection includes
  # the contact table, there may be a name clash, so hash the names in the 
  # 
  
  def fixup_query(table_names, where)
    if table_names =~ /contact,/
      table_names.sub!(/contact,/, 'contact cs,')
      where.gsub!(/(^| |=)con_/, '\\1cs.con_')
    end

    if table_names =~ /user_table,/
      table_names.sub!(/user_table,/, 'user_table us,')
      where.gsub!(/(^| |=)user_/, '\\1us.user_')
    end

    if table_names =~ /address,/
      table_names.sub!(/address,/, 'address ads,')
      where.gsub!(/(^| |=)add_/, '\\1ads.add_')
    end
  end

end
