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
require 'app/MaintainRegionsTemplates'
require 'app/MaintainRoles_RDs'
require 'bo/Region'

class MaintainRegions < Application

  app_info(:name => :MaintainRegions)

  class AppData
    attr_accessor :aff_id
    attr_accessor :reg
  end
  
  def app_data_type
    AppData
  end

  ######################################################################

  # Let user alter an existing region or create a new one

  def maintain_regions(aff_id)
    @data.aff_id = aff_id

    regions = Region.list(aff_id).map do |reg|
      {
        'name'       => reg.reg_name,
        'alter'      => url(:alter, reg.reg_id),
        'rds'        => url(:update_rds,   reg.reg_id),
        'delete'     => url(:delete, reg.reg_id),

      }
    end

    values = {
      'reg_id'   => -1,
      'form_url' => url(:create_new_region),
      'done_url' => url(:done_with_regions),
    }

    values['regions']  = regions unless regions.empty?
    
    aff = Affiliate.with_id(aff_id)
    if aff.pending(Affiliate::TODO_REGIONS)
      values['setup_regions'] = true
    end

    values['rds_can_assign'] = aff.aff_rds_can_assign ? "" : "not "
    values['toggle_rds']     = url(:toggle_rds)

    standard_page("Maintain Regions", values, MAINTAIN_REGIONS)
  end

  def toggle_rds
    aff = Affiliate.with_id(@data.aff_id)
    aff.aff_rds_can_assign = !aff.aff_rds_can_assign
    note "RD status changed"
    aff.save
    @context.no_going_back
    maintain_regions(@data.aff_id)
  end

  def done_with_regions
    aff = Affiliate.with_id(@data.aff_id)
    aff.mark_as_done(Affiliate::TODO_REGIONS)
    aff.save
    @session.user.log("Completed creating regions")
    @session.pop
  end


  def alter(reg_id)
    @data.reg = Region.with_id(reg_id)
    if @data.reg.nil?
      error "Region disappeared"
       maintain_regions(@data.aff_id)
    else
      edit_region
    end
  end


  ######################################################################
  # Before deleting a region, we have to work out if we're orphaning
  # roles, teampaks
  def delete(reg_id)
    reg = @data.reg = Region.with_id(reg_id)
    if @data.reg.nil?
      error "Region disappeared"
      maintain_regions(@data.aff_id)
      return
    end

    klingons = []

    klingons << "RDs"         if reg.has_rds?
    klingons << "TeamPaks"    if reg.has_teampaks?
    klingons << "Users"       if reg.has_users?
    klingons << "news items"  if reg.has_news?

    if klingons.empty?
      do_delete(reg)
    else
      targets = Region.options(@data.aff_id)
      targets.delete(reg_id)

      if targets.size == 1
        values = {
          "klingons" => klingons.join(", "),
          "reg_name" => reg.reg_name,
          "form_url" => url(:maintain_regions, @data.aff_id)
        }
        standard_page("Can't Delete", values, CANT_DELETE)
      else
        values = {
          "klingons" => klingons.join(", "),
          "reg_opts" => targets,
          "reg_name" => reg.reg_name,
          "reg_id"   => -1,
          "reassign" => url(:reassign)
        }
        standard_page("Reassign Region", values, REASSIGN_REGION)
      end
    end
  end

  def reassign
    old_reg_id = @data.reg.reg_id
    new_reg_id = @cgi['reg_id'].to_i
    if new_reg_id == Region::NONE
      new_reg_id = nil
    end

    if old_reg_id == new_reg_id
      error "Can't reassign into same region"
      delete(old_reg_id)
      return
    end

    $store.transaction do 
      RoleList.reassign_region_target(old_reg_id, new_reg_id)
      Membership.reassign_region(@session.user, old_reg_id, new_reg_id)
      News.reassign_region(old_reg_id, new_reg_id)
      User.reassign_region(old_reg_id, new_reg_id)
      
      do_delete(@data.reg)
    end
  end


  def do_delete(reg)
    RoleList.delete_role_region(reg.reg_id)
    reg.delete
    note "Region '#{reg.reg_name}' deleted"
    done_maintaining
  end

  ######################################################################

  def create_new_region
    @data.reg = Region.new
    @data.reg.reg_affiliate = @data.aff_id
    edit_region
  end


  def edit_region
    values = {
      'form_url' => url(:handle_edit_region),
    }

    @data.reg.add_to_hash(values)
    standard_page("Edit Region", values, EDIT_REGION)
  end



  def handle_edit_region
    values = hash_from_cgi
    reg = @data.reg
    reg.from_hash(values)
    errs = reg.error_list
    if errs.empty?
      @context.no_going_back
      reg.save
      note "Region #{reg.reg_name} updated"
      done_maintaining
    else
      error_list errs
      edit_region
    end
  end

  def update_rds(reg_id)
    @session.push(type, :done_maintaining)
    @session.dispatch(MaintainRoles_RDs, 
                      :handle_one_role,
                      [ reg_id ])
  end

  def done_maintaining
    maintain_regions(@data.aff_id)
  end
end
