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
require 'app/UserStuff'
require 'bo/Affiliate'
require 'bo/Region'
require 'bo/Role'
require 'bo/RoleList'
require 'app/status/AffiliateSummaryTemplates'

class AffiliateSummary < Application

  app_info(:name => 'AffiliateSummary')

  class AppData
    attr_accessor :aff_id
  end

  def app_data_type
    AppData
  end

  def summary_list
    affs = Affiliate.list
    list = affs.map do |aff|
      res = aff.add_to_hash({})
      res['setup'] = aff.is_set_up?
      res['url']   = url(:affiliate_detail, aff.aff_id)
      res
    end
    values = { 'list' => list }
    standard_page("Affiliate Summary", values, AFFILIATE_SUMMARY)
  end


  ######################################################################

  def affiliate_detail(aff_id)
    aff = Affiliate.with_id(aff_id)

    if !aff
      error "Missing affiliate"
      @session.pop
      return
    end

    values = {}
    aff.add_to_hash(values)
    add_ads(aff, values)
    if aff.aff_has_regions
      add_regions(aff, values)
    end

    add_user_count(aff, values)

    AffiliateSummary.add_teampak_count(aff, values)

    AffiliateSummary.add_team_count(aff, values)

    standard_page(aff.aff_long_name, values, AFFILIATE_DETAIL)
  end


  ######################################################################

  # Add in the affiliate directors for this Affiliate
  def add_ads(aff, values)
    add_roles(values,
              RoleNameTable::AD,
              TargetTable::AFFILIATE,
              aff.aff_id,
              'ad_list')
  end


  ######################################################################

  # Add in information about the regions
  def add_regions(aff, values)
    regions = Region.list(aff.aff_id)
    return if regions.empty?

    values['region_list'] = regions.map do |region|
      res = { 'reg_name' => region.reg_name }
      add_rds(region, res)
      res
    end
  end

  ######################################################################

  # Add a list of RDs for a region
  def add_rds(region, values)
    add_roles(values,
              RoleNameTable::RD,
              TargetTable::REGION,
              region.reg_id,
              'rd_list')
  end




  ######################################################################

  def add_roles(values, role_name, target_type, target_id, hash_name)
    roles = RoleList.for_users_with_role_and_target(role_name,
                                                    target_type,
                                                    target_id)
    unless roles.empty?
      values[hash_name] = roles.map do |role|
        u = role.user
        {
          'name' => u.contact.con_name,
          'email' => u.contact.con_email,
          'url'   => @context.url(UserStuff, :display_details_for_id, u.user_id)
        }
      end
    end
  end


  ######################################################################

  def add_user_count(aff, values)
    values['direct_users'] = User.count_users(aff.aff_id)
    values['total_users']  = RoleList.count_target_users(TargetTable::AFFILIATE,
                                                         aff.aff_id)

  end


  ######################################################################

  def AffiliateSummary.add_teampak_count(aff, values)
    counts = Membership.count(aff)

    res = []
    ones = counts["1"]
    ones['name'] = "OnePaks"

    fives = counts["5"]
    fives['name'] = "FivePaks"

    totals = ones.dup
    totals.each_key {|k| totals[k] += fives[k]}
    totals['name'] = "TOTAL"

    values['teampaks'] = [ ones, fives, totals ]
  end


  ######################################################################

  def AffiliateSummary.add_team_count(aff, values)
    counts = Team.count_detail(aff)

    res = []
    totals = {}

    ChallengeDesc.list.each do |chd|
      name = chd.chd_name
      row = counts[name]
      total = 0
      row.each {|k,v| total += v}
      row['total'] = total
      row['name'] = name
      res << row
    end

    values['teams'] = res

  end

end
