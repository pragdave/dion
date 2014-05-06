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

require 'db/Search'

class TeamSearch < Search


  # a table of joins - note this is only one level deep for now


  Joins = {
    TeamTable       => nil,
    MembershipTable => "team_mem_id=mem_id",
    ContactTable    => "user_id=mem_admin and con_id=user_contact",
    OrderTable      => "order_mem_id=mem_id",
  }

  ExtraTables =
    {
      ContactTable => [ UserTable ]
    }
  
  # Here's the descriptors of what we can do

  FieldList =    {
    :mem_passport_prefix => {
      :order => 1,
      :comp  => :EQUALS,
      :table => MembershipTable},
      
    :mem_passport => {
      :order => 2,
      :comp  => :EQUALS,
      :label => 'TeamPak Passport',
      :table => MembershipTable,
      :prefix => :mem_passport_prefix},
      
      :mem_affiliate => {
      :order => 3,
      :comp  => :EQUALS,
      :label => 'Affiliate',
      :table => MembershipTable,
      :ddlb  => 'select aff_id, aff_long_name from affiliate order by aff_long_name'},
      
      :mem_region => {
      :order => 4,
      :comp  => :EQUALS,
      :label => 'Region',
      :table => MembershipTable,
      :needs => :mem_affiliate,
      :ddlb  => "select reg_id, reg_name from region
                  where reg_affiliate='!mem_affiliate!' order by reg_name"},
      
    :team_name => {
      :order => 5,
      :comp  => :CONTAINS,
      :label => 'Team name',
      :table => TeamTable},
    
    :team_challenge => {
      :order => 6,
      :comp  => :EQUALS,
      :label => 'Challenge',
      :needs => :mem_affiliate,
      :ddlb  => 'select cha_id, chd_name from challenge, challenge_desc ' +
                "where cha_aff_id=!mem_affiliate! and cha_chd_id=chd_id order by chd_name",
      :table => TeamTable},
    
    :team_level => {
      :order => 7,
      :comp  => :EQUALS,
      :label => 'Team level',
      :ddlb  => TeamLevel::OptionList,
      :table => TeamTable},
    
    :mem_name => {
      :order => 8,
      :comp  => :CONTAINS,
      :label => 'TeamPak name',
      :table => MembershipTable},
      
    :mem_schoolname => {
      :order => 9,
      :comp  => :CONTAINS,
      :label => 'School name',
      :table => MembershipTable},
      
    :mem_district => {
      :order => 10,
      :comp  => :CONTAINS,
      :label => 'School district',
      :table => MembershipTable},

    :team_dt_created => {
      :order => 11,
      :comp  => :DAYS_OLD,
      :label => "Created",
      :table => TeamTable,
    },
      
    }


  def initialize(session)
    super(session, FieldList, Joins, TeamTable, ExtraTables)
  end

end
