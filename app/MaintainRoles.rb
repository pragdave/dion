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
require 'app/MaintainRolesTemplates'
require 'bo/Affiliate'
require 'bo/ChallengeDesc'
require 'bo/RoleHelper'
require 'bo/RoleList'

class MaintainRoles < Application

  app_info(:name => :MaintainProducts)

  class AppData
    attr_accessor :roles
    attr_accessor :an_id
  end
  
  def app_data_type
    AppData
  end

  ######################################################################

  # Allow users to maintain the users associated with a role


  # 1. Choose the category

  def select_target(msg, options)
    values = { 
      'form_url' => url(:handle_select_target, msg),
      'what'     => msg,
      'options'  => options,
      'an_id'   => -1,
    }
    standard_page("Select #{msg}", values, SELECT_TARGET)
  end


  def handle_select_target(msg)
    an_id = @cgi['an_id'].to_i
    if an_id < 0
      error "Please select #{msg}"
      select_target
      return
    end

    handle_one_role(an_id)
  end


  def handle_one_role(an_id)
    @data.an_id = an_id
    @data.roles = get_rolehelper(an_id)
    maintain_specific_id
  end



  # 2. Given an affiliate, maintain the list of ADs
  def maintain_specific_id
    values = {
      'title'    => get_role_title,
      'form_url' => url(:handle_maintain_specific_id)
    }

    @data.roles.add_to_hash(values,
                            @context,
                            type, 
                            :remove_role)

    standard_page("Maintain #{get_role_title}", values, MAINTAIN_SPECIFIC_ID)
  end




  def remove_role(role_index)
    @data.roles.remove_role(role_index)
    maintain_specific_id
  end
    


  def handle_maintain_specific_id
    unless @cgi['done'].empty?
      @session.pop
      return
    end

    values = hash_from_cgi
    @data.roles.from_hash(values)

    errors =  @data.roles.error_list

    if errors.empty?
      @context.no_going_back

      count = @data.roles.save(get_role_name,
                               get_affiliate,
                               get_region,
                               get_target_table,
                               @data.an_id)
      if count.zero?
        @session.pop
      else
        @data.roles = get_rolehelper(@data.an_id)
        maintain_specific_id
      end
    else
      error_list(errors)
      maintain_specific_id
    end
  end


  def get_rolehelper(an_id)
    list = role_specific_list(an_id)
    RoleHelper.new(list)
  end

  def role_specific_list(an_id)
    RoleList.for_users_with_role_and_target(get_role_name,
                                            get_target_table,
                                            an_id)
  end

end

########################################################################



########################################################################


########################################################################


########################################################################

