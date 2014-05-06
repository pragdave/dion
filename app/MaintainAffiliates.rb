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
require 'app/MaintainAffiliatesTemplates'
require 'app/MaintainRoles'

class MaintainAffiliates < Application

  app_info(:name => :MaintainProducts)

  class AppData
    attr_accessor :aff
  end
  
  def app_data_type
    AppData
  end

  ######################################################################

  # Let user alter an existing affiliate or create a new one

  def maintain_affiliates
    values = {
      'aff_opts' => Affiliate.options,
      'aff_id'   => -1,
      'form_url' => url(:handle_maintain),
    }

    standard_page("Maintain Affiliates", values, MAINTAIN_AFFILIATES)
  end

  
  def handle_maintain
    if !@cgi['create'].empty?
      create_new_affiliate
    else
      aff_id = @cgi['aff_id'].to_i
      if aff_id < 0
        error "Please select an affiliate before pressing [EDIT]"
        maintain_affiliates
      else
        @data.aff = Affiliate.with_id(aff_id)
        if @data.aff
          edit_affiliate
        else
          error "Hmm... that affiliate seems to have disappeared"
          maintain_affiliates
        end
      end
    end
  end


  def create_new_affiliate
    @data.aff = Affiliate.new
    edit_affiliate
  end


  def edit_affiliate
    values = {
      'form_url' => url(:handle_edit_affiliate),
    }

    @data.aff.add_to_hash(values)
    standard_page("Edit Affiliate", values, EDIT_AFFILIATE)
  end



  def handle_edit_affiliate
    values = hash_from_cgi
    aff = @data.aff
    aff.from_hash(values)
    errs = aff.error_list
    if errs.empty?
      @context.no_going_back
      aff.save
      note "Affiliate #{aff.aff_short_name} updated"
      @session.push(type, :maintain_affiliates)
      @session.dispatch(MaintainRoles_ADs, :handle_one_role, [ aff.aff_id ])
    else
      error_list errs
      edit_affiliate
    end
  end

end
