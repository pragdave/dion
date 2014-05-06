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

# We are responsible for retrieving existing session
# information and storing new session information
#
# New information is created for each request we handle.
# On entry to a page we fetch the existing session.
# We then get the next session number and store this
# into that session object, so that when it gets
# written back it will get that new number.

require "web/Session"

class SessionManager

  
  def initialize(store)
    @store = store
  end


  def next_free_id
    @store.get_next_sequence("session_session_id_seq");
  end

  def load_session_row(session_id)
    @store.select_one(SessionTable, "session_id=?", session_id)
  end


  # When we log a user in, we have to fork their session. That's because they
  # could potentially use back to get back to the login screen. When that happens
  # each new login must be a new session

  def fork_session(session, context)
    sess_id = next_free_id
    session.set_session_id(sess_id)
    context.session_id = sess_id
  end
  


  def SessionManager.encode(obj)
#    $stderr.puts obj.inspect
    dump = Marshal.dump(obj)
    [dump].pack("m*").tr("\n", "_")
  end

  def SessionManager.decode(str)
    decode = str.tr("_", "\n").unpack("m*")[0]
    Marshal.load(decode)
  end

end
