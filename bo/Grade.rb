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

class Grade < BusinessObject

  @@grades = nil

  def Grade.grade_list
    $store.select(GradeTable).map{|g| new(g)}
  end

  def Grade.options
    @@grades ||= Grade.grade_list
    res = {}
    @@grades.each {|g| res[g.grade_id] = g.grade_desc}
    res
  end


  def initialize(data_object)
    @data_object = data_object
  end
end
