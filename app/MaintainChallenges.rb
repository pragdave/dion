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
require 'app/MaintainChallengesTemplates'
require 'bo/Challenge'
require 'bo/ChallengeDesc'

class MaintainChallenges < Application
  app_info(:name => :MaintainChallenges, :login_required  => true)

  class AppData
    attr_accessor :cha
    attr_accessor :cdl
    attr_accessor :aff_id
    attr_accessor :my_challenges
    attr_accessor :challenge_map
  end

  def app_data_type
    AppData
  end

  ######################################################################

  def hq_challenge_menu
    values = {
      'new_url' => url(:hq_new_challenge)
    }

    list = ChallengeDesc.list.map do |ch|
      {
        'edit_url'   => url(:hq_edit_challenge,   ch.chd_id),
        'delete_url' => url(:hq_delete_challenge, ch.chd_id),
        'name'       => ch.chd_name,
      }
    end
    values['list'] = list

    standard_page("Maintain Challenges", values, HQ_CHALLENGE_LIST)
  end


  def hq_delete_challenge(chd_id)
    if Challenge.affiliates_using_challenge(chd_id)
      error "Affiliates are currently using this challenge"
    else
      ChallengeDesc.delete_challenge(chd_id)
    end
    hq_challenge_menu
  end


  def hq_edit_challenge(chd_id)
    @data.cha = ChallengeDesc.with_id(chd_id)
    @data.cdl = ChallengeDownload.with_id(chd_id)
    edit_common
  end

  def hq_new_challenge
    @data.cha = ChallengeDesc.new
    @data.cdl = ChallengeDownload.new
    edit_common
  end


  def edit_common
    values = {
      'form_url' => url(:hq_handle_edit)
    }

    @data.cha.add_to_hash(values)
    @data.cdl.add_to_hash(values)
    standard_page("Maintain Challenge", values, HQ_MAINTAIN_CHALLENGE)
  end

  def hq_handle_edit
    cha = @data.cha
    cdl = @data.cdl
    values = hash_from_cgi
    cha.from_hash(values)
    cdl.from_hash(values)

    errors = cha.error_list + cdl.error_list
    if errors.empty?
      $store.transaction do
        cha.save
        cdl.save(cha.chd_id)
      end
      hq_challenge_menu
    else
      error_list(errors)
      edit_common
    end
  end


  ######################################################################

  def ad_challenge_menu(aff_id)
    @data.aff_id = aff_id
    @data.my_challenges = Challenge.for_affiliate(aff_id)

    all_challenges = ChallengeDesc.list

    @data.challenge_map = {}
    all_challenges.each {|c| @data.challenge_map[c.chd_id] = c}

    doing = {}
    mine = @data.my_challenges.map do |ch|
      chd_id = ch.cha_chd_id
      chd = @data.challenge_map[chd_id]
      doing[chd_id] = 1
      values = {
        'name' => chd.chd_name,
        'delete_url' => url(:ad_handle_delete, ch.cha_id),
      }
      unless chd.only_available_at_one_level?
        values['change_url'] = url(:ad_change_levels, ch.cha_id, chd_id)
      end
      values
    end
    
    mine.sort! {|a,b| a['name'] <=> b['name']}

    theirs = []
    all_challenges.each do |ch|
      if !doing[ch.chd_id]
        theirs << {
          'name' => ch.chd_name,
          'add_url' => url(:ad_handle_add, ch.chd_id)
        }
      end
    end

    values = {
      'done_url' => url(:ad_done),
      'mine' => mine,
      'theirs' => theirs
    }

    standard_page("Maintain Challenges", values, AD_MAINTAIN_CHALLENGE);
  end


  def ad_change_levels(cha_id, chd_id)
    cha = @data.my_challenges.find {|ch| ch.cha_id == cha_id}
    unless cha
      error "Challenge went missing"
      ad_challenge_menu(@data.aff_id)
      return
    end

    values = {
      'form_url' => url(:handle_change_levels, cha_id, chd_id)
    }
    chd = @data.challenge_map[chd_id]

    cha.cha_levels &= chd.chd_levels

    cdl = ChallengeDownload.with_id(chd_id)
    cdl.add_to_hash(values)
    chd.add_to_hash(values)
    cha.add_to_hash(values, 'levels')
    standard_page("Change Levels", values, AD_CHOOSE_LEVELS)
  end

  def handle_change_levels(cha_id, chd_id)
    cha = @data.my_challenges.find {|ch| ch.cha_id == cha_id}
    values = hash_from_cgi
    cha.from_hash(values)
    if cha.has_any_levels?
      cha.save
    else
      note "No levels selected"
      Challenge.delete(cha.cha_id)
    end
    ad_challenge_menu(@data.aff_id)
  end


  def ad_handle_delete(cha_id)
    if Challenge.in_use(cha_id)
      error "Can't delete: some teams are using it"
    else
      Challenge.delete(cha_id)
    end
    ad_challenge_menu(@data.aff_id)
  end

  # when we add a challenge, we have to ask the AD what
  # levels its competing at (unless it's primary only)

  def ad_handle_add(chd_id)
    chd = @data.challenge_map[chd_id]

    if chd.only_available_at_one_level?
      do_add(chd)
    else
      ask_for_levels(chd)
    end
  end


  def ask_for_levels(chd)
    values = {
      'form_url' => url(:handle_levels, chd.chd_id)
    }
    chd.add_to_hash(values)
    cdl = ChallengeDownload.with_id(chd.chd_id)
    cdl.add_to_hash(values)
    standard_page("Choose levels", values, AD_CHOOSE_LEVELS)
  end


  def handle_levels(chd_id)
    chd = @data.challenge_map[chd_id]
    values = hash_from_cgi
    chd.from_hash(values)
    do_add(chd)
  end

  def do_add(chd)
    ch = Challenge.new
#    if chd.chd_primary_only
#      ch.cha_levels = ch.level_bit(TeamLevel::Primary)
#    else
      ch.cha_levels = chd.chd_levels
#    end
    if ch.has_any_levels?
      ch.cha_chd_id = chd.chd_id
      ch.cha_aff_id = @data.aff_id
      ch.save
    else
      note "No levels selected"
    end
    ad_challenge_menu(@data.aff_id)
  end

  # flag the fact that the challenges are now set up

  def ad_done
    aff = Affiliate.with_id(@data.aff_id)
    aff.mark_as_done(Affiliate::TODO_CHALLENGES)
    aff.save
    @session.user.log("Completed selecting challenges")
    @session.pop
  end
end
