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

class MembershipHistory < BusinessObject

  def MembershipHistory.list_for_membership(mem_id)
    $store.select(MembershipHistoryTable, "mh_membership=?", mem_id).map do |m|
      new(m)
    end
  end

  def MembershipHistory.delete_for_membership(mem_id)
    $store.delete_where(MembershipHistoryTable, "mh_membership=?", mem_id)
  end

  # Create a new membership history entry
  def initialize(data_object=nil)
    @data_object = data_object || MembershipHistoryTable.new
  end


  def log(mem_id, user_id, notes)
    conn = Apache.request.connection

    @data_object.mh_membership = mem_id
    @data_object.mh_user       = user_id
    @data_object.mh_when       = Time.now
    @data_object.mh_inet       = conn.remote_ip
    @data_object.mh_inet       += " (" + conn.remote_host + ")" if conn.remote_host
    @data_object.mh_notes      = notes

    $store.insert_sequenced(@data_object)
  end


end
