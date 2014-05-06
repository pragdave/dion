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

class CreditCardResponse < Application
  app_info(:name => "CreditCardResponse")
  class AppData
  end
  def app_data_type
    AppData
  end

  ######################################################################

  def handle_response
    values = hash_from_cgi
  end

end
