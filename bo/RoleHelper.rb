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

# This is a mess. The 'UsersWithRole' class has gotten out of hand, so
# we'll rewrite it for the simpler case of adding and removing known users
# to a list of roles and see if it helps us understand how to
# refactor the original

require 'bo/Role'



class RoleHelper

  EXTRA_TO_ADD = 2

  class RoleEntry
    attr_accessor :email
    attr_reader   :user_name
    attr_accessor :role
    attr_accessor :new_user_id
    attr_accessor :needs_saving

    def initialize(role)
      @role = role
      @needs_saving = false

      if role
        @new       = false
        contact    = User.with_id(role.role_user).contact
        @email     = contact.con_email
        @user_name = contact.con_name
      else
        @new = true
        @email = ''
      end
    end

    def new?
      @new
    end
      
  end


  ######################################################################


  def initialize(role_list)
    @roles = role_list.map {|r| RoleEntry.new(r)}
    EXTRA_TO_ADD.times { @roles << RoleEntry.new(nil)}
  end




  def add_to_hash(hash, context, klass, remove_method)

    existing = []
    new_names = []

    @roles.each_with_index do |role, i|
      if role.new?
        res = {
          "i"         => i,
          "name_#{i}" => role.email,
        }
        new_names << res
      else
        res = {
          "i"          => i,
          "name"       => role.email,
          "user_name"  => role.user_name,
          "remove_url" => context.url(klass, remove_method, i)
        }
        existing << res
      end
    end

    hash["existing_names"] = existing unless existing.empty?
    hash["new_names"] = new_names     unless new_names.empty?

    hash
  end


  
  def from_hash(hash)
    @roles.each_with_index do |role, i|
      if role.new?
        role.email     = hash["name_#{i}"]
      end
    end
  end
  


  def error_list 
    @roles.each do |role|
      if role.new? && !role.email.empty?
        msg = Mailer.invalid_email_address?(role.email)
        return [msg] if msg

        user = User.with_email(role.email)
        return [ "Unknown user '#{role.email}'" ] unless user

        dup = @roles.detect do |r|
          r.new_user_id == user.user_id || 
          ( r.role && r.role.role_user == user.user_id )
        end

        return [ "Duplicate user #{role.email}" ] if dup && dup != role
              
        role.new_user_id = user.user_id
        role.needs_saving = true
      end
    end
    []
  end


  

  # Remove a role at a given index
  def remove_role(index)
    role = @roles.delete_at(index)
    if role && role.role
      Role.delete_role(role.role.role_id)
    else
      raise "Bad role index #{role_index}"
    end
  end



  # save any relationships that need saving, storing in
  # the reference to the final target
  def save(role_name, aff_id, reg_id, target_type, target)
    count = 0
    @roles.each do |role|
      if role.needs_saving
        Role.add(role.new_user_id, aff_id, reg_id, role_name, target_type, target)
        count += 1
      end
    end
    count
  end



end
