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

class StateName < BusinessObject

  @@names = {}
  def StateName.with_id(stt_id)
    if @@names[stt_id]
      @@names[stt_id]
    else
      row = $store.select_one(StateNameTable, "stt_id=?", stt_id)
      if row
        @@names[stt_id] = row.stt_desc
      else
        raise "Unknown state id #{stt_id}"
      end
    end
  end


  def initialize(data_object)
    @data_object = data_object
  end
end
