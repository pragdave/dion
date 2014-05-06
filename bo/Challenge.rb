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

class Challenge < BusinessObject

  NONE = -1

  def Challenge.for_affiliate(aff_id)
    $store.select(ChallengeTable, "cha_aff_id=?", aff_id).map do |c|
      new(c)
    end
  end

  def Challenge.delete(cha_id)
    $store.delete_where(ChallengeTable, "cha_id=?", cha_id)
  end


  def Challenge.with_id(cha_id)
    maybe_return($store.select_one(ChallengeTable, "cha_id=?", cha_id))
  end
  

  def Challenge.in_use(cha_id)
    sql = "select count(*) from team where team_challenge=?"
    res = $store.raw_select(sql, cha_id)
    res[0][0] > 0
   end

  def Challenge.affiliates_using_challenge(chd_id)
    sql = "select count(*) from challenge where cha_chd_id=?"

    res = $store.raw_select(sql, chd_id)
    res[0][0] > 0
  end


  def Challenge.delete_challenge(cha_id, chd_id)
    $store.transaction do
      $store.delete_where(ChallengeTable, "cha_id=?", cha_id)
      $store.delete_where(ChallengeDescTable, "chd_id=?", chd_id)
#      @@challenges[0] = nil
    end
  end


  def Challenge.affiliate_uses_level(aff_id, level) 
    level_bit = i << level.to_i
    res = $store.count(ChallengeTable,
                       "cha_aff_id=? and (cha_levels && ?) != 0",
                       aff_id, level_bit)
  end

  def initialize(data_object = nil)
    @data_object = data_object || fresh_challenge
  end

  def fresh_challenge
    c = ChallengeTable.new
    c.cha_levels = 0
    c
  end


  def add_to_hash(values, entry_name="aff_levels")
    levels = []
    for i in (TeamLevel::MinLevel..TeamLevel::MaxLevel)
      levels << {
        'name'    => "level_#{i}",
        "level_#{i}" => @data_object.cha_levels[i.to_i] == 1,
        'desc'    => TeamLevel::Options[i]
      }
    end 
    values[entry_name] = levels
    values
  end

  def from_hash(values)
    @data_object.cha_levels = 0
    for i in (TeamLevel::MinLevel..TeamLevel::MaxLevel)
      if values["level_#{i}"].downcase == "on"
        @data_object.cha_levels |= level_bit(i)
      end
    end
  end

  def level_bit(level)
    1 << level.to_i
  end


  def error_list
    []
  end

  # See if _any_ levels are offered in this challenge.
  def has_any_levels?
    @data_object.cha_levels != 0
  end

  # Check that a challenge is OK at a given level
  def check_ok_for_level(level)
    levels = @data_object.cha_levels

    return nil unless levels[level.to_i].zero?
                      
    names = []
    
    (TeamLevel::MinLevel..TeamLevel::MaxLevel).each do |i|
      if levels[i.to_i] == 1
        names << TeamLevel::Options[i]
      end
    end

    "Challenge only available at: " + names.join(", ")
  end
end
