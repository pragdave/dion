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
require 'bo/Grade'
require 'date'

class TeamMember < BusinessObject

  MEMBERS_PER_TEAM = 7

  attr_accessor :tm_dob_mon, :tm_dob_day, :tm_dob_year
  attr_accessor :age_on_j15

  def TeamMember.list_with_team_id(team_id)
    $store.select(TeamMemberTable, "tm_team_id=?", team_id).map{|t| new(t) }
  end

  def TeamMember.new_list
    (1..MEMBERS_PER_TEAM).to_a.map { new }
  end

  ######################################################################

  def TeamMember.delete_for_teampak(mem_id)
    $store.delete_where(TeamMemberTable,
                        "exists (select 1 from team where team_mem_id=? and tm_team_id=team_id)",
                        mem_id)
  end

  ######################################################################

  def initialize(data_object=nil)
    @data_object = data_object || TeamMemberTable.new
    if (dt = @data_object.tm_dob)
      @tm_dob_mon  = dt.mon
      @tm_dob_day  = dt.day
      @tm_dob_year = dt.year
      calc_age_on_june15 rescue 1
    else
      @tm_dob_mon  = ''
      @tm_dob_day  = ''
      @tm_dob_year = ''
    end
  end

  def add_to_hash(hash)
    super
    tm = @data_object
    unless tm.tm_name.nil? || tm.tm_name.empty?
      calc_age_on_june15 rescue 1;
    end

    hash['sex_opts'] = TeamMemberTable::SexOptions

    hash['tm_dob_mon']  = @tm_dob_mon
    hash['tm_dob_day']  = @tm_dob_day
    hash['tm_dob_year'] = @tm_dob_year
    hash['tm_age_next_j15'] = @age_on_j15 || (tm.tm_name.empty? ? '' : 'unknown')
    hash['tm_grade_opts'] = Grade.options
    hash['tm_grade_short'] = case tm.tm_grade
			     when 0
			       "K"
			     when 13
			       "U"
			     else
			       tm.tm_grade.to_s
			     end
    hash
  end

  def clear
    @data_object.tm_name = ''
  end

  def save
    tm = @data_object
    if tm.tm_name.nil? || tm.tm_name.empty?
      if tm.existing_record?
        delete
      end
    else
      @data_object.tm_dob = nil
      begin
        tmp = @tm_dob_mon + @tm_dob_day + @tm_dob_year
        if tmp.kind_of? Numeric
          @data_object.tm_dob = DBI::Date.new(@tm_dob_year, @tm_dob_mon, @tm_dob_day)
        end
      rescue Exception
        ;
      end
      super
    end
  end


  def error_list
    res = []

    if @data_object.tm_name && @data_object.tm_name.length > 100
      res << "Team member name '#{@data_object.tm_name}' too long"
    end

    case @data_object.tm_sex
    when TeamMemberTable::SexMale, TeamMemberTable::SexFemale
      1;
    else
      res <<
        "Please give #{@data_object.tm_name}'s sex. We use this for room allocations " +
        "should this team reach global finals."
    end

    # If all three fields are empty, then there's no DOB

    @age_on_j15 = nil

    @tm_dob_mon = @tm_dob_mon.to_s
    @tm_dob_day = @tm_dob_day.to_s
    @tm_dob_year = @tm_dob_year.to_s

    unless @tm_dob_mon.empty? && @tm_dob_day.empty? && @tm_dob_year.empty?
      if @tm_dob_mon.empty? || @tm_dob_day.empty? || @tm_dob_year.empty?
        raise "You need to specify all of the date of birth (or leave all the fields empty)"
      end
      calc_age_on_june15
    end

    if @age_on_j15 && age_on_j15 < 5
      res << "#{@data_object.tm_name} must be 5 or older on June 15 next year"
    end

    return res
    
  rescue Exception => e
    $stderr.puts e.backtrace
    res << (e.message +  " for #{@data_object.tm_name}")
  end

  private

  def dob(val, msg)
    unless val.kind_of?(Integer)
      raise "Missing #{msg}" if val.nil? || val.empty?
      begin
        val = Integer(val)
      rescue
        raise "Invalid #{msg} '#{val}'"
      end
    end
    raise "xx" if val < 0
    val
  end

  def calc_age_on_june15
    @age_on_j15 = nil

    mon  = dob(@tm_dob_mon,  "month")
    day  = dob(@tm_dob_day,  "day")
    year = dob(@tm_dob_year, "year")

    if year < 20
      year += 2000
    elsif year < 100
      year += 1900
    end

    @tm_dob_mon  = mon
    @tm_dob_day  = day
    @tm_dob_year = year


    if year < 1960 || year > Date.today.year
      raise "Invalid year '#{year}'"
    end

    begin
      d = Date.new(year, mon, day)
    rescue
      raise "Invalid date: #{mon}/#{day}/#{year}"
    end


    now = Time.now
    j15_mon = 6
    j15_day = 15
    j15_year = now.year 
    j15_year += 1 if (now.mon > 6) || (now.mon == 6 && now.day >= 15)

    @age_on_j15 = j15_year - @tm_dob_year

    @age_on_j15 -= 1 if (@tm_dob_mon > 6) || 
      (@tm_dob_mon == 6 && @tm_dob_day > 15)
  end

end
