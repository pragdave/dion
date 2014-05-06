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

require 'app/MaintainRoles'

class MaintainRoles_HQ < MaintainRoles

  app_info(:name => type.name)

  # Allow users to maintain the ICMs associated with a challenge

  def select_target
    nil
  end


  def get_role_title
    "Headquarters Staff"
  end

  def get_role_name
    RoleNameTable::HQ
  end

  def get_affiliate
    0
  end

  def get_region
    nil
  end

  def get_target_table
    TargetTable::AFFILIATE
  end

#  def role_specific_list(aff_id)
#    RoleList.for_users_with_role_and_target(RoleNameTable::AD,
#                                            TargetTable::AFFILIATE,
#                                            aff_id)
#  end

end
