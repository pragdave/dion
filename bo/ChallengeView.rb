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

class ChallengeView < BusinessObject

  def ChallengeView.for_affiliate(aff_id)
    $store.select(ChallengeViewTable, 
                  "cha_aff_id=? order by chd_name",
                  aff_id).map {|c| new(c)}
  end

  def ChallengeView.count_for_affiliate(aff_id)
    $store.count(ChallengeViewTable, "cha_aff_id=?", aff_id)
  end

  def ChallengeView.options_for_affiliate(aff_id)
    challenges = ChallengeView.for_affiliate(aff_id)
    res = {}
    challenges.each do |c|
      res[c.cha_id] = c.chd_name
    end
    res
  end

  def initialize(data_object)
    @data_object = data_object
  end
end
