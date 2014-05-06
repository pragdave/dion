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
require 'bo/Membership'
require 'bo/ChangeRequest'
require 'app/RequestChangeTemplates'

class RequestChange < Application

  app_info(:name => "RequestChange")

  class AppData
    attr_accessor :mem_id
    attr_accessor :o_mem_name
    attr_accessor :o_mem_schoolname
    attr_accessor :o_mem_district
  end

  def app_data_type
    AppData
  end

  ######################################################################
  #
  # Ask the user

  def request_change(mem_id)
    @data.mem_id = mem_id
    mem = Membership.with_id(mem_id)
    @data.o_mem_name       = mem.mem_name
    @data.o_mem_schoolname = mem.mem_schoolname
    @data.o_mem_district   = mem.mem_district
    request_common(mem)
  end

  def request_common(mem)
    values = {
      'o_mem_name'       => @data.o_mem_name,
      'o_mem_schoolname' => @data.o_mem_schoolname,
      'o_mem_district'   => @data.o_mem_district,
      'form_url'         => url(:handle_request_change),
    }
    mem.add_to_hash(values)
    standard_page("Request Change", values, REQUEST_CHANGE)
  end

  def handle_request_change
    mem_name       = @cgi['mem_name'] || ''
    mem_schoolname = @cgi['mem_schoolname'] || ''
    mem_district   = @cgi['mem_district'] || ''

    cr = ChangeRequest.new

    cr.cr_user_id = @session.user.user_id
    cr.cr_mem_id = @data.mem_id

    unless mem_name.empty? || mem_name == @data.o_mem_name
      cr.mem_name = mem_name
    end
    
    unless mem_schoolname.empty? || mem_schoolname == @data.o_mem_schoolname
      cr.mem_schoolname = mem_schoolname
    end
    
    unless mem_district.empty? || mem_district == @data.o_mem_district
      cr.mem_district = mem_district
    end
    
    if cr.changed
      cr.save
      mem = Membership.with_id(@data.mem_id)
      notes = "Change requested to #{mem.mem_name}: #{cr.to_s}"
      @session.user.log(notes)
      mem.log(@session.user, notes)
      note "Request for change entered"
    else
      note "No changes requested"
    end
    @session.pop
  end


  ######################################################################
  #
  # HQ functions.
  #
  # 1. List all pending changes, and prompt for those to accept
  #

  def hq_menu
    changes = ChangeRequest.list

    list = changes.map do |c|
      c.add_to_hash({'i' => c.cr_id, "action_#{c.cr_id}" => 'N' })
    end

    values = {
      'form_url' => url(:handle_hq_menu),
      'list' => list,
      'action_opts' => { 
        'A' => 'Accept change',
        'D' => 'Deny change',
        'N' => 'Do nothing'
      }
        
    }
    standard_page("List Pending Changes", values, LIST_PENDING)
  end


  def handle_hq_menu
    accepted = declined = unchanged = 0

    @cgi.keys.each do |k|
      next unless k =~ /^action_(\d+)/

      cr_id = $1
      action = @cgi[k]

      cr = ChangeRequest.with_id(cr_id) unless action == 'N'

      case action
      when 'A'
        cr.accept(@session.user)
        accepted += 1

      when 'D'
        cr.decline(@session.user)
        declined += 1

      when 'N'
        unchanged += 1

        ;
      else
        raise "Unexpected action #{action}"
      end
    end
    
    note "#{accepted} accepted, #{declined} declined, #{unchanged} unchanged"
    @session.pop
  end

end
