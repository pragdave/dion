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

require 'hmac'
require 'digest/sha2'

module HMAC
  class SHA256 < Base
    def initialize(key = nil)
      super(Digest::SHA256, 64, 32, key)
    end
    public_class_method :new, :digest, :hexdigest
  end

  class SHA384 < Base
    def initialize(key = nil)
      super(Digest::SHA384, 128, 48, key)
    end
    public_class_method :new, :digest, :hexdigest
  end

  class SHA512 < Base
    def initialize(key = nil)
      super(Digest::SHA512, 128, 64, key)
    end
    public_class_method :new, :digest, :hexdigest
  end
end
