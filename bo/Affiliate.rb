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

class Affiliate < BusinessObject

  # This is the affiliate value used in ddlb's to indicate 'NONE'
  NONE = -1

  # These are an AD's TODO items at the start of the year

  TODO_CHALLENGES = 1
  TODO_REGIONS    = 2
  TODO_FEES       = 4
  TODO_DATES      = 8

  def Affiliate.with_id(aff_id)
    return nil if aff_id.nil?
    maybe_return($store.select_one(AffiliateTable, "aff_id=?", aff_id))
  end

  def Affiliate.with_passport_prefix(prefix)
    maybe_return($store.select_one(AffiliateTable, "aff_passport_prefix=?", prefix))
  end

#  def Affiliate.with_short_name(name)
#    return nil if name.nil?
#    maybe_return($store.select_one(AffiliateTable, "aff_short_name=?", name))
#  end

  def Affiliate.with_short_name(name)
    maybe_return($store.select_one(AffiliateTable, "aff_short_name ilike ?", name))
  end

  def Affiliate.with_long_name(name)
    maybe_return($store.select_one(AffiliateTable, "aff_long_name ilike ?", name))
  end

  def Affiliate.list
    $store.select(AffiliateTable, "1=1 order by aff_long_name").map {|a| new(a)}
  end

  # Options for a ddlb
  def Affiliate.options
    res = { 
      NONE => "None selected"
    }
    affs = list
    if affs.size == 1
      res[list[0].aff_id] = list[0].aff_long_name
    else
      list.each {|a| res[a.aff_id] = a.aff_long_name unless a.aff_id.zero? }
    end
    res
  end

  # Create a new affiliate entry
  def initialize(data_object = nil)
    @data_object = data_object || fresh_affiliate
  end

  def fresh_affiliate
    a = AffiliateTable.new
    a.aff_passport_prefix = ''
    a.aff_passport_length = 5
    a.aff_short_name      = ''
    a.aff_long_name       = ''
    a.aff_has_regions     = true
    a.aff_is_foreign      = false
    a.aff_in_canada       = false
    a.aff_is_sa           = false
    a.aff_to_do           = TODO_CHALLENGES | TODO_REGIONS | TODO_FEES | TODO_DATES

    today = Date.today
    if today.mon == 1 && today.mday < 15
      cutoff = Date.new2(today.year, 15)
    else
      cutoff = Date.new2(today.year+1, 15)
    end
    
    cutoff = DBI::Date.new(cutoff)

    a.aff_reg_start = cutoff
    a.aff_reg_end   = cutoff
    a.aff_team_reg_start = cutoff
    a.aff_team_reg_end   = cutoff

    a
  end


  # When saving a new aff, its to do list depends on whether it
  # has regions
  def save
    a = @data_object
    unless a.existing_record?
      a.aff_to_do = TODO_CHALLENGES | TODO_FEES | TODO_DATES
      if a.aff_has_regions
        a.aff_to_do |= TODO_REGIONS
      end
    end
    super
  end


  def add_to_hash(values)
    super
    values['fmt_reg_start'] = fmt_reg_start
    values['fmt_reg_end']   = fmt_reg_end
    values['fmt_team_reg_start'] = fmt_team_reg_start
    values['fmt_team_reg_end']   = fmt_team_reg_end
    values
  end

  def from_hash(values)
    a = @data_object
    a.aff_passport_prefix = values['aff_passport_prefix']
    a.aff_passport_length = values['aff_passport_length']
    a.aff_short_name      = values['aff_short_name']
    a.aff_long_name       = values['aff_long_name']
    a.aff_has_regions     = values['aff_has_regions'] == "on"
    a.aff_is_foreign      = values['aff_is_foreign']  == "on"
    a.aff_in_canada       = values['aff_in_canada']   == "on"
    a.aff_is_sa           = values['aff_is_sa']       == "on"
  end

  def error_list
    errs = []
    a = @data_object
    unless a.aff_passport_prefix =~ /^[1-9]\d\d$/
      errs << "Passport prefix should be three digits"
    end

    begin
      l = a.aff_passport_length = Integer(a.aff_passport_length)
      raise "wrong" if l < 3 || l > 5
    rescue
      errs << "Invalid passport length"
    end

    errs << "Missing short name" if a.aff_short_name.empty?
    errs << "Missing long name"  if a.aff_long_name.empty?

    other = Affiliate.with_passport_prefix(a.aff_passport_prefix)
    if other && other.aff_id != a.aff_id
      errs << "Passport prefix already used (by #{other.aff_short_name})"
    end

    other = Affiliate.with_short_name(a.aff_short_name)
    if other && other.aff_id != a.aff_id
      errs << "Passport short name already used (by #{other.aff_long_name})"
    end

    other = Affiliate.with_long_name(a.aff_long_name)
    if other && other.aff_id != a.aff_id
      errs << "Passport long name already used (by #{other.aff_short_name})"
    end

    errs
  end


  # check that a passport number is valid
  def passport_is_valid(passport)
    passport.length == @data_object.aff_passport_length && passport =~ /^\d+$/ 
  end

  # check to see if a given passport number is free 
  def passport_is_free(passport)
    res = $store.raw_select("select count(*) from membership " +
                            "where mem_passport_prefix=? and mem_passport=?",
                            @data_object.aff_passport_prefix,
                            passport)
    res[0][0].zero?
  end

  # Find a free passport number
  def free_passport_number
    max = 1
    @data_object.aff_passport_length.times { max *= 10 }

    srand

    40.times do
      guess = rand(max)
      if passport_is_free(guess)
        return "%0#{@data_object.aff_passport_length}d" % guess
      end

    end

    nil
  end


  # Return a list of cities for teams in this affiliate that have
  # not ben assigned to regions

  def cities_of_paks_not_in_regions
    res = $store.raw_select("select add_city, count(add_city) from " +
                            "user_table, contact, membership, address " +
                            "where mem_affiliate=? " +
                            "  and mem_region is null " +
                            "  and mem_admin = user_id " +
                            "  and mem_state != '#{StateNameTable::Suspended}'" +
                            "  and user_contact = con_id " +
                            "  and con_mail = add_id " +
                            "group by add_city",
                            @data_object.aff_id)
    res.map {|row| "#{row[0]}(#{row[1]})" }
  end

  # Return a list of teampaks not currently in regions
  def paks_with_no_regions
    sql =
      "select mem_id, mem_passport_prefix, mem_passport, mem_name, mem_schoolname, " +
      "       con_first_name, con_last_name, add_city, add_zip " +
      "  from user_table, contact, membership, address " +
      "where mem_affiliate=? " +
      "  and mem_region is null " +
      "  and mem_admin = user_id " +
      "  and mem_state != '#{StateNameTable::Suspended}'" +
      "  and user_contact = con_id " +
      "  and con_mail = add_id " +
      "order by mem_passport"

    res = $store.raw_select(sql, @data_object.aff_id)
    
    i = -1
    res.map do |row|
      i += 1
      { 
        "mem_id"         => row[0],
        "full_passport"  => row[1] + "-" + row[2],
        "mem_name"       => row[3],
        "mem_schoolname" => row[4],
        "coordinator"    => row[5] + " " + row[6],
        "con_city"       => row[7],
        "con_zip"        => row[8],
        "reg_#{i}"       => NONE,
        "i"              => i,
      }
    end
  end

  # Return a list of regions in this affiliate
  def region_opts
    res = $store.select(RegionTable, 
                        "reg_affiliate=? order by reg_name",
                        @data_object.aff_id)

    regions = { Affiliate::NONE => "unassigned" } 

    res.each {|r| regions[r.reg_id] = r.reg_name}
    
    regions
  end


  # Are we open for teampak registration
  
  def registration_open?
    d = @data_object
    today = Date.today
    d.aff_reg_start.to_date <= today && d.aff_reg_end.to_date >= today
  end

  # Are we open for team registration
  
  def team_registration_open?
    d = @data_object
    today = Date.today
    d.aff_team_reg_start.to_date <= today && d.aff_team_reg_end.to_date >= today
  end

  # Have we passed the date for teampaks?
  
  def registration_passed?
    d = @data_object
    today = Date.today
    d.aff_reg_end.to_date < today
  end

  # Have we passed the date for teams?
  
  def team_registration_passed?
    d = @data_object
    today = Date.today
    d.aff_team_reg_end.to_date < today
  end

  def fmt_reg_start
    fmt_date(@data_object.aff_reg_start)
  end

  def fmt_reg_end
    fmt_date(@data_object.aff_reg_end)
  end

  def fmt_team_reg_start
    fmt_date(@data_object.aff_team_reg_start)
  end

  def fmt_team_reg_end
    fmt_date(@data_object.aff_team_reg_end)
  end

  # Mark a particular to_do as being done

  def mark_as_done(todo)
    @data_object.aff_to_do &= ~todo
  end

  def is_set_up?
    @data_object.aff_to_do.zero?
  end

  def pending(flag)
    (@data_object.aff_to_do & flag) != 0
  end

  # For use in Role.rb
  def target_name
    aff_short_name
  end

  def viewer_class
    nil
  end

  def viewer_method
    nil
  end
end
