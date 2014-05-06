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

require 'app/TeamsTemplates'
require 'app/NameGetter'

require 'bo/Team'
require 'bo/TeamList'
require 'bo/UsersWithRole'
require 'util/Mailer'

class Teams < Application

  app_info(:name            => :Teams,
           :login_required  => true,
           :default_handler => :handle_display,
           :default_app     => false)


  class AppData
    attr_accessor :mem
    attr_accessor :team
    attr_accessor :mgr_list
    attr_accessor :aff_id
    attr_accessor :passport_prefix
    attr_accessor :passport
  end

  def app_data_type
    AppData
  end


  # This is the entry point from an AD or HQ when they want to 
  # maintain the teams for someone else's membership

  def general_change(aff_id=nil)
    @data.aff_id = aff_id
    @data.passport ||= ''

    values = {
      'passport' => @data.passport,
      'form_url' => url(:lookup_teampak)
    }

    if aff_id
      aff = Affiliate.with_id(aff_id)
      if !aff
        error "Affiliate went missing"
        @session.pop
        return
      end
      @data.passport_prefix = aff.aff_passport_prefix
      values['passport_prefix'] = @data.passport_prefix
    else
      @data.passport_prefix = nil
    end

    standard_page("Manage Team", values, SPECIFY_TEAMPAK)
  end

  
  def lookup_teampak
    @data.passport = @cgi['passport']
    if @data.passport_prefix
      pass = @data.passport_prefix + "-" + @data.passport
    else
      pass = @data.passport
    end

    mem = Membership.with_full_passport(pass)
    if mem
      handle_display(mem.mem_id)
    else
      error "Can't find passport #{pass}"
      general_change(@data.aff_id)
    end
  end

  # Simple form:
  #   <list of current teams>
  #   <button to add team>

  def handle_display(mem_id=nil)
    msg = setup_membership(mem_id)
    return page_error(msg) if msg

    update_allowed = @session.hq_session || @session.ad_session || @session.rd_session

    update_allowed ||= @session.user.user_id == @data.mem.mem_creator
      
    update_allowed ||= @session.user.user_id == @data.mem.mem_admin
      
    values = {
      'full_passport'    => @data.mem.full_passport,
      'update_allowed'   => update_allowed
    }


    teams = TeamList.for_membership(@data.mem.mem_id)

    values['team_list'] = teams.portal_data(@context) unless teams.empty?

    @data.mem.add_to_hash(values)

    max_teams =  @data.mem.max_teams

    # if team registration is closed, then disable the buttons

    aff = Affiliate.with_id(@data.mem.mem_affiliate)

    if ChallengeView.count_for_affiliate(aff.aff_id).zero?
      values['reg_closed_msg'] = "You can't add teams until the " +
        "challenges have been posted."
    elsif  aff.team_registration_open? ||
        @session.hq_session || 
        @session.ad_session ||
        @session.rd_session 

      # OnePaks can only have one team, regardless of type
      if max_teams == 1
        if teams.size.zero?
          values['add_team_target'] = url(:handle_add_team)
        end
      else
        if teams.competitive_teams < max_teams
          values['add_team_target'] = url(:handle_add_team)
        else
          unless teams.includes_team_at_level(TeamLevel::University)
            values['add_primary_team_target'] = url(:handle_add_primary_team)
          end
        end
      end
    else
      values['reg_closed_msg'] = "Teams can be added between " +
        "#{aff.fmt_team_reg_start} and #{aff.fmt_team_reg_end}"
    end
    
    standard_page("Maintain Teams", values, MAINTAIN_TEAMS)
  end
  

  # display the status of a team
  def handle_status(mem_id, team_id)
    msg = setup_membership(mem_id)
    return page_error(msg) if msg
    values = standard_status_values(mem_id, team_id, true)
    standard_page("Team Status", values, TEAM_STATUS)
  end
  

  # Delete the given team
  def handle_delete(mem_id, team_id)
    msg = setup_membership(mem_id)
    return page_error(msg) if msg
    
    values = standard_status_values(mem_id, team_id, true)
    values['do_delete_url'] = url(:handle_do_delete, mem_id, team_id)
    values['no_target']     = url(:handle_display, mem_id)
    standard_page("Delete TEAM", values, DELETE_TEAM)
  end
  

  # Second part of delete: user has confirmed
  def handle_do_delete(mem_id, team_id)
    
    msg = setup_membership(mem_id)
    return page_error(msg) if msg
    
    get_manager_list(team_id)

#    puts "After: #{CGI.escapeHTML(@data.mgr_list.inspect)}<p>"
    
    team = Team.with_id(team_id)
    if team
      team.membership = @data.mem
      
      $store.transaction do
        team.delete
        @data.mgr_list.delete_all_existing
      end
      
      @data.mem.log(@session.user, "Deleted team #{team.team_name}")

      @context.no_going_back
    else
      note "Team already deleted"
    end
    handle_display(mem_id)
  end


  # Start the process of adding a team to the roster
  def handle_add_team
    @data.team = Team.new
    @data.team.membership = @data.mem

    get_manager_list(@data.team.team_id)

    collect_team_info
  end


  # Like add_team, but restricted to primary teams
  def handle_add_primary_team
    @data.team = Team.new
    @data.team.membership = @data.mem
    @data.team.team_level = TeamLevel::Primary
    @data.team.must_be_primary = true
    get_manager_list(@data.team.team_id)

    collect_team_info
  end

  # OK - they've entered form data. Validate it and write it
  # out if OK

  def handle_update
    values = Hash.new("")

    t = @data.team

    t.add_to_hash(values)
    @cgi.keys.each {|k| 
      if k =~ /^tm_/
        values[k] = @cgi.values(k)
      else
        values[k] = @cgi[k]
      end
    }

    t.from_hash(values)
    @data.mgr_list.from_hash(values)

    errors = t.error_list + @data.mgr_list.error_list

    if errors.empty?
      
      if @data.mgr_list.needs_filling_in?
        @session.push(type, :finish_update)
        @session.dispatch(NameGetter, 
                          :handle_getting_names_for,
                          [@data.mgr_list, "Team Manager"])
        return
      end

      finish_update
    else
      error_list(errors)
      collect_team_info
    end
  end


  # OK - common cleanup at the end of an update
  def finish_update
    t = @data.team

    unless t.team_passport_suffix
      teams = TeamList.for_membership(@data.mem.mem_id)
      suffix =  teams.next_free_suffix_for(t.team_level)
      invalid = "Attempt to add the same team twice" if suffix.nil?
      t.team_passport_suffix = suffix
    end

    invalid ||= t.check_team_level
    if invalid
      note invalid
      handle_display(@data.mem.mem_id)
      return
    end
    
    action = t.team_id ? "Updated" : "Created"

    $store.transaction do
      t.save
      
      @data.mgr_list.save(t.team_id)
      
      @data.mem.log(@session.user, "#{action} team #{t.team_name}")
      @session.user.log("#{action} team #{t.team_name} in " +
                        "TeamPak #{@data.mem.full_passport}")
    end

    @context.no_going_back

    handle_display
  end


  # A change is basically the same as a create, but with
  # an existing team... However, if we've maxed outa
  # competitive teams in a fivepak and this is a primary
  # team, stop the user changing it to a non-primary

  def handle_change(mem_id, team_id)
    msg = setup_membership(mem_id)
    return page_error(msg) if msg


    @data.team = Team.with_id(team_id)

    get_manager_list(team_id)

    teams = TeamList.for_membership(@data.mem.mem_id)

    max_teams =  @data.mem.max_teams

    if max_teams > 1 && 
        teams.competitive_teams >= max_teams && 
        TeamLevel.is_primary?(@data.team.team_level)
      @data.team.must_be_primary = true
    end

    collect_team_info
  end



  def standard_status_values(mem_id, team_id, strip_blank_members=false)
    @data.mem = Membership.with_id(mem_id)
    return page_error("Unknown membership") unless @data.mem

    affiliate = Affiliate.with_id(@data.mem.mem_affiliate)

    team = Team.with_id(team_id)
    return page_error("Unknown team") unless team

    team.membership = @data.mem

    
    values = team.portal_line(@context)
    values["main_menu_url"]  = url(:handle_display, mem_id)
    values["main_menu"]      = 'Team Status'
    values["change_url"] = url(:handle_change, mem_id, team_id)

    values['ok_to_update'] = aff.team_registration_open? || 
      @session.hq_session || @session.ad_session

    @data.mem.add_to_hash(values)
    team.add_to_hash(values)

    if strip_blank_members
      values['members'].delete_if {|m| name = m['tm_name']; name.nil? || name.empty?}
    end
    
    values['members'] = nil if values['members'].empty?

#    link_to_clarifications(values)

    values
  end

#  def link_to_clarifications(values)
#    values['clari_url'] = "/cgi-bin/test.cgi"
#    values['back_url']  = url(:back_from_clarifications)
#  end
#
#  def back_from_clarifications
#    @session.pop
#  end

  # Collect or maintain information on a team
  
  def collect_team_info
    values = { 
      "form_target"   => url(:handle_update),
      "cancel_target" => url(:handle_display)

    }

    teams = TeamList.for_membership(@data.mem.mem_id)

    @data.team.add_to_hash(values, teams)

    @data.mgr_list.add_to_hash(values,
                               @context,
                               type, 
                               :remove_team_manager,
                               :alter_team_manager)

    unless !values["existing_names"]
      values['email_warning'] = %{If a team manager has given you a new
       e-mail address and that new address is not shown here, then get them
       to change their DION profile. Their new address will then
       appear here automatically.}
    end

    standard_page("Edit Team", values, EDIT_TEAM)
  end

  def remove_team_manager(role_index)
    @data.mgr_list.delete_existing(role_index)
    handle_change(@data.mem.mem_id, @data.team.team_id)
  end

  def alter_team_manager(role_index)
    @data.mgr_list.alter_existing(role_index)
    @session.push(type, :finish_alter_team_manager)
    @session.dispatch(NameGetter, :handle_getting_names_for, 
                      [@data.mgr_list, "Team Manager"])
  end

  def finish_alter_team_manager
    handle_change(@data.mem.mem_id, @data.team.team_id)
  end

  private

  def setup_membership(mem_id)
    @data.mem = Membership.with_id(mem_id) if mem_id
    return "Unknown membership" unless @data.mem
    nil
  end


=begin
  # tell a newly created user that 
  # 1. they've been created, and
  # 2. they are associate with this team

  def notify_newly_created_user(pass)
    
    mailer = Mailer.new

    values = { 
      "original_user_name" => @session.user.contact.con_name,
      "mem_name"  => @data.mem.mem_name,
      "team_name" => @data.team.team_name,
      "user_name" => @data.new_user.user_acc_name,
      "password"  => pass
    }

    mailer.send_from_template(@data.new_usercontact.con_email,
                              "Your DION Registration Information",
                              values,
                              NEW_TEAM_MGR_EMAIL)
  end
=end

  def get_manager_list(team_id)
    res = @data.mgr_list = UsersWithRole.new(RoleNameTable::TEAM_MANAGER,
                                             TargetTable::TEAM,
                                             team_id,
                                             @data.mem.mem_affiliate,
                                             @data.mem.mem_region)
    res
  end



end
