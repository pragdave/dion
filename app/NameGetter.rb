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

# We're a helper application whose whole purpose is to fill in
# a name and address form. When finished, we pop back to the original
# caller with a completed UsersWithRole structure

class NameGetter < Application

  app_info(:name            => :NameGetter,
           :login_required  => true,
           :default_app     => false)

  class AppData
    attr_accessor :users
    attr_accessor :user_role
    attr_accessor :index
  end

  def app_data_type
    AppData
  end

  
  # Used for identifying anonymous contacts

  Ordinals = %w{ First Second Third Fourth Fifth Sixth Seventh Eighth Ninth }


  # We are passed a UsersWithRoles stucture containing one or
  # more entries that need filling in. Complete each in turn

  def handle_getting_names_for(users, user_role="contact")
    @data.users = users
    @data.index = users.next_to_fill_in
    @data.user_role = user_role

    if @data.index
      user = @data.users[@data.index]
      collect_for(user)
    else
      @session.pop
    end
  end

  
  def collect_for(user)
    role = Ordinals[@data.index] || "#{@data.index}th"
    if @data.user_role
      role += " " + @data.user_role
    end

    values = {
      "form_target" => url(:handle_completed_user),
      "contact_index" => role,
      "contact_type" => @data.user_role,
      "cap_contact_type" => @data.user_role.capitalize,

    }
    user.add_to_hash(values)

    standard_page("Enter User Information", values, Register::NEW_USER)
  end

  def handle_completed_user

    u = @data.users[@data.index]
#    u.add_to_hash(values)
    values = hash_from_cgi
    values['user_affiliate'] = u.user_affiliate
    u.from_hash(values)

    strict = !u.contact.con_email.empty?

    errors = u.error_list(strict)

    if errors.empty?
=begin
      if u.new_user
        email = u.contact.con_email
        pass = u.create_new_password unless email.empty?
        u.save
        notify_newly_created_user(pass) unless email.empty?
      else
        u.save
      end
      @data.mem.admin = u
      finish_collecting_user_info
=end
      begin
        u.save
        @context.no_going_back
      rescue Exception => e
        error_list [ e.message ]
        collect_for(u)
        return
      end
      @data.users.mark_as_done(@data.index)
      handle_getting_names_for(@data.users)
    else
      error_list errors
      collect_for(u)
    end
  end
end
