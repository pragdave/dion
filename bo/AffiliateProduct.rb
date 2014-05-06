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

require 'bo/BusinessObject'

class AffiliateProduct < BusinessObject

  def AffiliateProduct.with_id(afp_id)
    maybe_return($store.select_one(AffiliateProductTable,
                                   "afp_id=?", 
                                   afp_id))
  end

  def AffiliateProduct.for_affiliate(aff_id, prd_id)
    maybe_return($store.select_one(AffiliateProductTable,
                                   "afp_affiliate=? and afp_product=?", 
                                   aff_id, prd_id))
  end

  ######################################################################

  def initialize(data_object=nil)
    @data_object = data_object || AffiliateProductTable.new
  end

end
