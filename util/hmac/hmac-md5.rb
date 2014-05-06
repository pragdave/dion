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

require 'util//hmac/hmac'
require 'digest/md5'

module HMAC
  class MD5 < Base
    def initialize(key = nil)
      super(Digest::MD5, 64, 16, key)
    end
    public_class_method :new, :digest, :hexdigest
  end
end
