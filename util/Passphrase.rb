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

require 'singleton'

DIR = File.dirname(__FILE__)

WORDS = File.join(DIR, "words")

class PassPhrase
  include Singleton

  def initialize
    File.open(WORDS) {|f| @words = f.read }
    @length = @words.length
  end

  def next
    choose + "+" + choose
  end

  private

  def choose
    pos = rand(@length);
    pos -= 1 while (pos > 0) && @words[pos] != ?\n
    pos += 1 if @words[pos] == ?\n
    start = pos
    pos += 1 while (pos < @length) && @words[pos] != ?\n
    @words[start...pos]
  end

end

