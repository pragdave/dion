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

require 'app/Application'
require 'app/status/LeagueTableTemplates'

class LeagueTable < Application

  app_info(:name => 'LeagueTable')

  class AppData
    attr_accessor :list
  end

  def app_data_type
    AppData
  end

  ######################################################################

  class Place
    attr_accessor :count, :rank

    def initialize(field_name)
      @field_name = field_name
    end

    def add_to_hash(values)
      values[@field_name + "_count"] = @count || ''
      if @rank
        values[@field_name + "_rank"] = "(#@rank)"
      else
        values[@field_name + "_rank"] = ""
      end
    end
  end

  class AffiliateRow

    attr_accessor :affiliate

    def initialize(affiliate)
      @data = {
        :teampaks => Place.new('teampak'),
        :onepaks  => Place.new('onepak'),
        :fivepaks => Place.new('fivepak'),
        :teams    => Place.new('team'),
        :users    => Place.new('user')
      }
      @affiliate = affiliate
    end

    def set_stats(field, count, rank)
      place = @data[field]
      place.count = count
      place.rank  = rank
    end

    def rank(field)
      @data[field].rank || 999
    end

    def to_hash
      res = { 'aff_name' => @affiliate }
      @data.each_value {|p| p.add_to_hash(res) }
      res
    end
  end

  ######################################################################

  def league_table
    @data.list = {}
    Affiliate.list.map do |a|
      name = a.aff_long_name
      @data.list[name] = AffiliateRow.new(name)
    end

    add_ranks(Membership.count_by_affiliate, :teampaks)
    add_ranks(Membership.onepaks_by_affiliate, :onepaks)
    add_ranks(Membership.fivepaks_by_affiliate, :fivepaks)
    add_ranks(Team.count_by_affiliate, :teams)
    add_ranks(User.count_by_affiliate, :users)

    display_by(:teampaks)
  end


  ######################################################################
  
  # sort according to a given field
  def display_by(field)
    sorted = @data.list.values.sort do |a,b| 
      (a.rank(field) <=> b.rank(field)).nonzero? ||
        a.affiliate <=> b.affiliate
    end

    list = sorted.map {|a| a.to_hash}

    values = {
      'sort_teampaks' => url(:display_by, :teampaks),
      'sort_onepaks'  => url(:display_by, :onepaks),
      'sort_fivepaks' => url(:display_by, :fivepaks),
      'sort_teams'    => url(:display_by, :teams),
      'sort_users'    => url(:display_by, :users),
      'sort_type'     => field.to_s.capitalize,
      'list'          => list,
    }

    standard_page("League Table", values, LEAGUE_TABLE)
  end

  ######################################################################

  def add_ranks(array, field)
    rank = 1
    array.each do |affiliate, count|
      @data.list[affiliate].set_stats(field, count, rank)
      rank += 1
    end
  end

end
