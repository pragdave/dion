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

# Simple interface to allow us to edit affiliate dates

require 'bo/BusinessObject'
require 'bo/Affiliate'
require 'bo/DionDate'

class AffiliateDate < BusinessObject

  def AffiliateDate.with_id(aff_id)
    maybe_return($store.select_one(AffiliateTable, "aff_id=?", aff_id))
  end

  # Create a new affiliate entry
  def initialize(data_object)
    @data_object = data_object
    @reg_start   = DionDate.new("reg_start", @data_object.aff_reg_start)
    @reg_end     = DionDate.new("reg_end",   @data_object.aff_reg_end)
    @team_reg_start = DionDate.new("team_reg_start", @data_object.aff_team_reg_start)
    @team_reg_end   = DionDate.new("team_reg_end",   @data_object.aff_team_reg_end)
  end

  def add_to_hash(values)
    super
    @reg_start.add_to_hash(values)
    @reg_end.add_to_hash(values)
    @team_reg_start.add_to_hash(values)
    @team_reg_end.add_to_hash(values)
  end

  def from_hash(values)
    a = @data_object
    @reg_start.from_hash(values)
    @reg_end.from_hash(values)
    @team_reg_start.from_hash(values)
    @team_reg_end.from_hash(values)
  end

  def error_list
    errs = []
    errs.concat @reg_start.error_list
    errs.concat @reg_end.error_list
    errs.concat @team_reg_start.error_list
    errs.concat @team_reg_end.error_list

    if @reg_start > @reg_end
      errs << "Registration start is after registration end"
    end

    if @team_reg_start > @team_reg_end
      errs << "Team registration start is after registration end"
    end

    if @reg_start > @team_reg_start
      errs << "Team registration must start after teampak"
    end

    errs
  end

  def save
    d = @data_object
    d.aff_reg_start = @reg_start.date
    d.aff_reg_end   = @reg_end.date
    d.aff_team_reg_start = @team_reg_start.date
    d.aff_team_reg_end   = @team_reg_end.date
    mark_as_done(Affiliate::TODO_DATES)
    super
  end

  def mark_as_done(todo)
    @data_object.aff_to_do &= ~todo
  end

end
