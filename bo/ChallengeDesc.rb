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

require "bo/TeamLevel"

class ChallengeDesc < BusinessObject

  NONE = -1

  def ChallengeDesc.list
    $store.select(ChallengeDescTable, 
                  "chd_season = (select current_season from current_season) " +
                  "order by chd_name").map do |c|
      new(c)
    end
  end

  def ChallengeDesc.count
    $store.count(ChallengeDescTable, 
                  "chd_season = (select current_season from current_season) ")
  end

  def ChallengeDesc.delete_challenge(chd_id)
    $store.delete_where(ChallengeDescTable, "chd_id=?", chd_id)
  end

  # Options for a ddlb
  def ChallengeDesc.options
    res = { 
      NONE => "None selected"
    }
    list.each {|c| res[c.chd_id] = c.chd_name }
    res
  end


  def ChallengeDesc.with_id(chd_id)
    maybe_return($store.select_one(ChallengeDescTable, "chd_id=?", chd_id))
  end
  

  ######################################################################

  def initialize(data_object = nil)
    @data_object = data_object || fresh_challengedesc
  end

  def fresh_challengedesc
    c = ChallengeDescTable.new
    c.chd_levels = 0
    for i in (TeamLevel::MinLevel..TeamLevel::MaxLevel)
      c.chd_levels |= 1 << i.to_i
    end
    res = $store.select_one(CurrentSeasonTable)
    c.chd_season = res.current_season
#    c.chd_primary_only = false
    c.chd_name         = ''
    c.chd_short_name   = ''
    c
  end


  def add_to_hash(values)
#    values['chd_primary_only'] = @data_object.chd_primary_only
    values['chd_name']         = @data_object.chd_name
    values['chd_short_name']   = @data_object.chd_short_name

    levels = []
    for i in (TeamLevel::MinLevel..TeamLevel::MaxLevel)
      levels << {
        'name'    => "level_#{i}",
        "level_#{i}" => @data_object.chd_levels[i.to_i] == 1,
        'desc'    => TeamLevel::Options[i]
      }
    end 
    values['levels'] = levels
    values
  end

  def from_hash(values)
#    @data_object.chd_primary_only = values['chd_primary_only'].downcase == "on"
    @data_object.chd_name = values['chd_name'] 
    @data_object.chd_short_name = values['chd_short_name'] 

    @data_object.chd_levels = 0
    for i in (TeamLevel::MinLevel..TeamLevel::MaxLevel)
      if values["level_#{i}"].downcase == "on"
        @data_object.chd_levels |= 1 << i.to_i
      end
    end
  end

  def error_list
    c = @data_object
    errs = []
    errs << "Missing challenge name" if c.chd_name.empty?
    errs << "Missing short challenge name" if c.chd_short_name.empty?

    errs
  end

  # Produce a simple string showing the levels which can use this challenge
  def levels_as_string
    res = []
    for i in (TeamLevel::MinLevel..TeamLevel::MaxLevel)
        if  @data_object.chd_levels[i.to_i] == 1
          res << TeamLevel::Options[i]
        end
    end
    res.join(", ")
  end

  # Is this challenge only available at one level?
  def only_available_at_one_level?
    bits = @data_object.chd_levels
    $stderr.puts "Short name: #{chd_short_name}, bits= #{bits}"
    until bits.zero?
      if (bits & 1) == 1
        $stderr.puts "Returns #{(bits & ~1) == 0}"
        return (bits & ~1) == 0
      end
      bits >>= 1
    end
    $stderr.puts "False"
    return false
  end

  # For use in Role.rb
  def target_name
    chd_name
  end

  def viewer_class
    nil
  end

  def viewer_method
    nil
  end

end
