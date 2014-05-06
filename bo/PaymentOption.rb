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

# we record the actual payment option chosen by the user
class PaymentOption

  attr_accessor :pay_method
  attr_accessor :pay_ref

  def initialize
    @pay_method = @pay_ref = ''
  end
end
