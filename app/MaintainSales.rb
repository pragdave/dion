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
require 'app/MaintainSalesTemplates'
require 'bo/SaleParameter'

class MaintainSales < Application
  app_info(:name => :MaintainSales)

  class AppData
    attr_accessor :sp
  end

  def app_data_type
    AppData
  end

  ######################################################################

  def maintain_sales
    @data.sp = SaleParameter.get
    common_maintain
  end

  def common_maintain
    values = {
      "form_url" => url(:handle_maintain_sales)
    }
    @data.sp.add_to_hash(values)
    standard_page("Sales Parameters", values, SALES_PARAMETERS)
  end


  def handle_maintain_sales
    sp = @data.sp
    values = hash_from_cgi
    sp.from_hash(values)
    errs = sp.error_list
    if errs.empty?
      sp.save
      note "Parameters updated"
      @session.pop
    else
      error_list(errs)
      common_maintain
    end
  end

end
