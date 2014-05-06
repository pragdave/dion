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

require 'bo/Membership'
require 'db/Search'
require 'db/TableDefinitions'

class UserSearch < Search


  # a table of joins - note this is only one level deep for now


  Joins = {
    UserTable => nil,
    ContactTable    => "con_id=user_contact",
    AddressTable    => "add_id=con_mail"
  }

  ExtraTables =    {
    AddressTable => [ ContactTable ]
  }
  
  # Here's the descriptors of what we can do

  FieldList = {
    :con_email => {
      :order => 0,
      :comp  => :EQUALS,
      :label => 'E-Mail',
      :table => ContactTable,
    },

    :user_acc_name => {
      :order => 1,
      :comp  => :CONTAINS,
      :label => 'Nickname',
      :table => UserTable,
    },

    :con_first_name => {
      :order => 2,
      :comp  => :CONTAINS,
      :label => 'First name',
      :table => ContactTable,
    },
    
    :con_last_name => {
      :order => 3,
      :comp  => :CONTAINS,
      :label => 'Last name',
      :table => ContactTable,
    },
    
    :add_city => {
      :order => 4,
      :comp  => :CONTAINS,
      :label => 'Mailing city',
      :table => AddressTable,
    },
      
    :add_county => {
      :order => 5,
      :comp  => :CONTAINS,
      :label => 'Mailing county',
      :table => AddressTable,
    },
      
    :add_state => {
      :order => 6,
      :comp  => :CONTAINS,
      :label => 'Mailing state',
      :table => AddressTable,
    },
      
    :add_zip => {
      :order => 7,
      :comp  => :CONTAINS,
      :label => 'Mailing zip',
      :table => AddressTable,
    },
      
    :add_country => {
      :order => 8,
      :comp  => :CONTAINS,
      :label => 'Mailing country',
      :table => AddressTable,
    },

    :dummy => {
      :order => 9,
      :break => "Associated with all of...",
    },

    :role_affiliate => {
      :order => 10,
      :comp  => :ROLE,
      :label => "Affiliate",
      :role_target_type => TargetTable::AFFILIATE,
      :ddlb  => 'select aff_id, aff_long_name from affiliate order by aff_long_name',
      :hide_for_affiliate => true,
    },

    :role_region => {
      :order => 11,
      :comp  => :ROLE,
      :label => "Region",
      :needs => :role_affiliate,
      :role_target_type => TargetTable::REGION,
      :ddlb  => 'select reg_id, reg_name from region ' +
      "where reg_affiliate='!role_affiliate!' order by reg_name",
      :only_for_affiliate => true,
    },

    :role_challenge => {
      :order => 12,
      :comp  => :ROLE,
      :allow_none => true,
      :label => "Downloaded challenge",
      :role_target_type => TargetTable::CHALLENGE,
      :ddlb  => 'select chd_id, chd_name from challenge_desc order by chd_name',
    },

    :role_teampak => {
      :order => 13,
      :comp  => :ROLE,
      :label => "TeamPak",
      :role_target_type => TargetTable::MEMBERSHIP,
      :role_lookup => :find_membership,
    },

    :dummy1 => {
      :order => 14,
      :break => "Is one or more of...",
    },

    :isa_teampak_creator => {
      :order => 15,
      :comp  => :ISA,
      :role_name => RoleNameTable::TEAMPAK_CREATOR,
      :label => "TeamPak creator",
      :table => UserTable,
    },

    :isa_teampak_contact => {
      :order => 16,
      :comp  => :ISA,
      :role_name => RoleNameTable::TEAMPAK_CONTACT,
      :label => "TeamPak contact",
      :table => UserTable,
    },

    :isa_affiliate_director => {
      :order => 17,
      :comp  => :ISA,
      :role_name => RoleNameTable::AD,
      :label => "Affiliate director",
      :table => UserTable,
    },

    :isa_regional_director => {
      :order => 18,
      :comp  => :ISA,
      :role_name => RoleNameTable::RD,
      :label => "Regional director",
      :table => UserTable,
    },

    :isa_team_mgr => {
      :order => 19,
      :comp  => :ISA,
      :role_name => RoleNameTable::TEAM_MANAGER,
      :role_target => TargetTable::TEAM,
      :label => "Team manager",
      :table => UserTable,
      :isa_options => "select chd_id, chd_name from challenge_desc order by chd_name",
      :isa_options_label => " for challenge: ",
      :isa_join => "and role_target=cha_id and cha_chd_id=?",
      :isa_extra_tables => [ 'challenge' ]
      
    },

    :user_first_logged_in => {
      :order => 20,
      :comp  => :DAYS_OLD,
      :label => "First logged-in",
      :table => UserTable,
    },


    :user_last_logged_in => {
      :order => 21,
      :comp  => :DAYS_OLD,
      :label => "Last logged-in",
      :table => UserTable,
    },


  }


  def initialize(session)
    super(session, FieldList, Joins, UserTable, ExtraTables)
  end


  def find_membership(value)
    mem = Membership.with_full_passport(value)
    if mem
      mem.mem_id
    else
      nil
    end
  end

end
