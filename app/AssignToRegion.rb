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

require 'app/AssignToRegionTemplates'

class AssignToRegion < Application

  app_info(:name            => :AssignToRegion)

  class AppData
    attr_accessor :affiliate
    attr_accessor :list
    attr_accessor :reg_opts
  end

  def app_data_type
    AppData
  end


  # On entry, display a list of teams not yet assigned to regions,
  # and let the user select regions for them

  def handle_display(aff_id)
    @data.affiliate = Affiliate.with_id(aff_id)
    @data.list = list = @data.affiliate.paks_with_no_regions

    if list.empty?
      standard_page("Assign TeamPaks to Regions", {}, NO_WORK_TO_DO)
      return
    end

    common_display(list, true)
  end

  def common_display(list, initial_assign)
    @data.reg_opts = reg_opts = @data.affiliate.region_opts

    values = {
      'reg_opts'    => reg_opts,
      'list'        => list,
      'form_target' => url(:handle_assign, initial_assign)
    }

    standard_page("Assign TeamPaks to Regions", 
                  values,
                  DISPLAY_LIST)
  end


  # And get here when they've pushed the button...

  def handle_assign(initial_assign)
    list = @data.list
    reg_opts = @data.reg_opts

    count = 0

    list.each do |row|
      index  = row['i']
      mem_id = row['mem_id']
      reg    = @cgi["reg_#{index}"].to_i
      if !initial_assign || reg != Affiliate::NONE
        membership = Membership.with_id(mem_id)
        old_region = membership.mem_region || Affiliate::NONE
        if old_region != reg
          count += 1
          if reg == Affiliate::NONE
            membership.mem_region = nil
          else
            membership.mem_region = reg
          end

          $store.transaction do
            membership.save
            membership.log(@session.user, "Assigned to region #{reg_opts[reg]}")
          end
        end
      end
    end

    note(case count
         when 0 then "No teams assigned"
         when 1 then "One team assigned"
         else
           "#{count} teams assigned"
         end)

    @session.dispatch(Portal)
  end


  ######################################################################

  # Called to assign a particular teampak to a region

  def assign_search(aff_id)
    @data.affiliate = Affiliate.with_id(aff_id)
    assign_common
  end

  def assign_common
    aff = @data.affiliate    
    ms = MemberSearch.new(@session)
    ms.display_all_fields

    ms.fix_field(:mem_affiliate, aff.aff_id)
    ms.fix_field(:mem_passport_prefix, aff.aff_passport_prefix)
    
    html = ms.to_form(url(:handle_search), 
                      false,
                      "Find matches",
                      '')

    values = {
      'done' => url(:handle_search)
    }

    standard_page("Search for TeamPak",
                  values,
                  SEARCH_PAGE,
                  html)
  end


  def handle_search
    ms = MemberSearch.new(@session)
    where, tables = ms.build_query
    list = Membership.list_from_member_search(where, tables, 100)
    if list.empty?
      note "No matches found"
      assign_common
    else
      display_list(list)
    end
  end

  # convert a list of memberships into the format e need for display
  def display_list(teampaks)
    i = -1
    @data.list = list = teampaks.map do |mem|
      i += 1
      creator = mem.creator.contact
      { 
        "mem_id"         => mem.mem_id,
        "full_passport"  => mem.full_passport,
        "mem_name"       => mem.mem_name,
        "mem_schoolname" => mem.mem_schoolname,
        "coordinator"    => creator.con_name,
        "con_city"       => creator.mail.add_city,
        "con_zip"        => creator.mail.add_zip,
        "reg_#{i}"       => mem.mem_region,
        "i"              => i,
      }
    end

    common_display(list, false)
  end

end
