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
require 'app/MaintainAffiliateDatesTemplates'
require 'bo/Affiliate'
require 'bo/AffiliateDate'

class MaintainAffiliateDates < Application
  app_info(:name => 'MaintainAffiliateDates')

  class AppData
    attr_accessor :aff
  end

  def app_data_type
    AppData
  end

  ######################################################################

  def edit_dates(aff_id)
    @data.aff = AffiliateDate.with_id(aff_id)
    if aff.nil?
      error "Unknown affiliate"
      @session.pop
    else
      show_edit_page
    end
  end

  def show_edit_page
    values = {
      'form_url' => url(:handle_dates)
    }
    @data.aff.add_to_hash(values)
    standard_page("Maintain Dates", values, MAINTAIN_DATES)
  end

  def handle_dates
    aff = @data.aff
    values = hash_from_cgi
    aff.from_hash(values)
    errs = aff.error_list
    if errs.empty?
      aff.save
      note "Dates updated"
      @session.pop
    else
      error_list errs
      show_edit_page
    end
  end
end

      
