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
require 'app/status/StatusTemplates'
require 'app/status/AffiliateSummary'
require 'app/status/LeagueTable'
require 'bo/CycleData'

require 'db/TableDefinitions'

# Report on lots of stuff...

class Status < Application
  app_info(:name => 'Status')

  class AppData
    attr_accessor :aff_id
  end

  def app_data_type
    AppData
  end


  def status_page(title, values, template)
    standard_page(title, values, template)
  end

  ######################################################################

  def status_menu(aff_id = nil)
    @data.aff_id = aff_id
    values = {
      'cha_down' => url(:challenge_downloads),
      'big_picture' => url(:big_picture),
      'aff_summary' => @context.url(AffiliateSummary, :summary_list),
      'league_table' => @context.url(LeagueTable, :league_table),
      'sales_breakdown' => @context.url(ProductSummary, :sales_breakdown),
    }

    standard_page("Status Menu", values, STATUS_MENU)
  end

  ######################################################################

  def challenge_downloads
    sql = 
      "select chd_name, count(*) from role, challenge_desc " +
      " where role_name=#{RoleNameTable::CHALLENGE_DOWNLOADER} " +
      "   and chd_id=role_target " +
      " group by chd_name order by 2"

    report_table(sql, "Challenges Downloaded", "Challenge Name", "Count")
  end

  ######################################################################

  def big_picture
    mem_counts = Membership.count_passports(@data.aff_id)

    payments   = Payment.totals

    pay_types  = Payment.type_summary

    values = {
      'reg_passports' => mem_counts[StateNameTable::Active].to_i +
                         mem_counts[StateNameTable::WaitPayment].to_i,

      'act_passports' => mem_counts[StateNameTable::Active].to_i,

      'susp_passports' => mem_counts[StateNameTable::Suspended].to_i,

      'teamcount'     => Team.count_teams(@data.aff_id),

      'users'         => User.count_users(@data.aff_id),

      'chal_dl'       => Role.count_roles(@data.aff_id,
                                          RoleNameTable::CHALLENGE_DOWNLOADER),

      'pay_received'  => fmt_money(payments[0]),
      'pay_applied'   => fmt_money(payments[1]),
      'aff_paid'      => fmt_money(CycleData.aff_fees_paid),
      'aff_unpaid'    => fmt_money(CycleData.aff_fees_unpaid),
      
      'type_summary'  => pay_types,
    }

    AffiliateSummary.add_teampak_count(nil, values)

    AffiliateSummary.add_team_count(nil, values)
    
    status_page("The Big Picture", values, BIG_PICTURE)
  end

  ######################################################################

  def team_distribution(aff_id=nil)

  end

  ######################################################################

  def report_table(sql, title, *columns)
    colcount = columns.size
    res = $store.raw_select(sql)
    data = []
    res.each do |row|
      vname = "v1"
      cols = {}
      0.upto(colcount-1) do |i|
        cols[vname] = row[i]
        vname.succ!
      end
      data << cols
    end

    values = {
      'title' => title,
      'data'  => data,
    }

    head = "h1"
    columns.each { |c| values[head] = c; head.succ! }

    status_page(title, values, TWOCOL_TABLE)
  end

end
