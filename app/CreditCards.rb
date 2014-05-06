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
require 'app/CreditCardsTemplates'
require 'bo/Contact'
class CreditCards < Application
  app_info(:name => "CreditCards")
  class AppData
  end
  def app_data_type
    AppData
  end

  ######################################################################

  def cc_log
    trans = CreditCardTransaction.list
    list = trans.map do |t|
      values = t.add_to_hash({}) 
      values
    end

    values = {
      'list' => list
    }
    standard_page("Credit Card Log", values, CREDIT_CARD_LOG)
  end

end
