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

# This class is an attempt to abstract out the concept
# of a group of users associated with some entity by
# a role. For example, Team Managers are simply Users
# in a TEAM_MANAGER role with a team.
#
# This class provides the methods to allow us to create
# and edit the list of these associations

require "bo/RoleList"

class UsersWithRole

  NUM_NEW_TO_SHOW = 2

  class RoleHolder
    attr_reader     :role
    attr_accessor   :dont_know
    attr_reader     :changed
    attr_accessor   :email
    attr_reader     :name
    attr_accessor   :needs_saving
    attr_accessor   :needs_filling_in
    attr_reader     :new_entry

    def initialize(role, new_entry=false)
      @role = role
      @email = role.user.contact.con_email
      @name  = role.user.contact.con_name
      @dont_know = false
      @changed   = false
      @new_entry = new_entry
    end

    def user
      @role.user
    end

    def save
      @role.save
    end
  end


  ######################################################################


  def initialize(role_name, target_type, target_id, affiliate, region)

    @roles = []

    if target_id
      roles = RoleList.for_users_with_role_and_target(role_name,
                                                      target_type,
                                                      target_id)
      @roles.concat roles.map {|r| RoleHolder.new(r)}
    end

    NUM_NEW_TO_SHOW.times do |i|
      r = RoleHolder.new(Role.new, true)
      r.role.role_name        = role_name
      r.role.role_target_type = target_type
      r.role.role_target      = target_id
      r.role.role_region      = region
      r.role.role_affiliate   = affiliate
      r.user.user_affiliate   = affiliate
      @roles << r
    end
    
  end


  def delete_existing(role_index)
    role = @roles.delete_at(role_index)
    if role
      Role.delete_role(role.role.role_id)
    else
      raise "Bad role index #{role_index}"
    end
  end


  def alter_existing(role_index)
    r = @roles[role_index]
    r.needs_saving = r.needs_filling_in = true
  end


  def delete_all_existing
    @roles.each {|r| Role.delete_role(r.role.role_id) unless r.new_entry }
    @roles.delete_if {|r| !r.new_entry }
  end



  def add_to_hash(hash, context, klass, remove_method, change_method)

    existing = []
    new_names = []

    @roles.each_with_index do |role, i|
      if role.new_entry
        res = {
          "i" => i,
          "name_#{i}" => role.email,
          "dont_know_#{i}" => role.dont_know
        }
        new_names << res
      else
        res = {
          "i"          => i,
          "name"       => role.name,
          "remove_url" => context.url(klass, remove_method, i)
        }
        if role.email.empty?
          res["change_url"] = context.url(klass, change_method, i)
        end
        existing << res
      end
    end

    hash["existing_names"] = existing unless existing.empty?
    hash["new_names"] = new_names     unless new_names.empty?

    hash
  end



  def from_hash(hash)
    @roles.each_with_index do |role, i|
      if role.new_entry
        role.email     = hash["name_#{i}"]
        role.dont_know = hash["dont_know_#{i}"].downcase == "on"
      end
    end
  end
  


  def error_list 
    res = []
    @roles.each do |role|
      if role.new_entry && !role.email.empty?
        msg = Mailer.invalid_email_address?(role.email)
        res << msg if msg
      end
    end
    res
  end

  # save any relationships that need saving, storing in
  # the reference to the final target
  def save(with_id)
    @roles.each do |role|
      $stderr.puts "Role: #{role.name} '#{role.needs_saving.inspect}'"
      if role.needs_saving
        role.role.role_user = role.user.save
        role.role.role_target = with_id
        role.save
      end
    end

  end

  # Find out what new roles need filling in, and (at the same time)
  # which ones need saving. We need filling in if 'dont_know' is
  # set or if an email address is given which isn't in the
  # system. It needs saving if it needs filling in or if
  # is has a valid e-mail address

  def needs_filling_in?
    any_need_filling = false

    @roles.select{|r| r.new_entry }.each do |role|
      role.needs_saving = role.needs_filling_in = false

      if role.dont_know
        role.needs_filling_in = true
        role.needs_saving = true
      elsif !role.email.empty?
        role.needs_saving = true
        user = User.with_email(role.email)

        if user
          role.role.role_user = user.user_id
        else
          role.needs_filling_in = true
          role.user.contact.con_email = role.email
        end
      end

      any_need_filling ||= role.needs_filling_in
    end
    any_need_filling
  end
    

  def next_to_fill_in
    @roles.each_with_index do |role, index|
      if role.needs_filling_in
        errors = role.user.error_list
        $stderr.puts errors.inspect
        return index 
      end
    end
    nil
  end

  def mark_as_done(index)
    @roles[index].needs_filling_in = false
  end

  def [](i)
    @roles[i].user
  end

end
