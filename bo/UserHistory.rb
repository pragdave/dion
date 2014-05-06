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

class UserHistory < BusinessObject

  def UserHistory.list_for_user(user_id, max=20)
    $store.select(UserHistoryTable, 
                  "uh_user=? order by uh_when desc limit ?", 
                  user_id, max).map do |m|
      new(m)
    end
  end

  def UserHistory.count_for_user(user_id)
    res = $store.raw_select("select count(*) from user_history " +
                            "where uh_user=?",
                            user_id)
    res[0][0]
  end

  # Create a new user history entry
  def initialize(data_object=nil)
    @data_object = data_object || UserHistoryTable.new
  end


  def add_to_hash(values)
    values['uh_when'] = @data_object.uh_when.to_time.strftime("%d-%b-%y %H:%M")
    values['uh_inet'] = @data_object.uh_inet
    values['uh_notes'] = @data_object.uh_notes
    values
  end

  def log(user, notes)
    conn = Apache.request.connection

    @data_object.uh_user       = user.user_id
    @data_object.uh_when       = Time.now
    @data_object.uh_inet       = conn.remote_ip
    @data_object.uh_inet       += " (" + conn.remote_host + ")" if conn.remote_host
    @data_object.uh_notes      = notes

    $store.insert_sequenced(@data_object)
  end


end
