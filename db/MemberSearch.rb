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

class MemberSearch < Search


  # a table of joins - note this is only one level deep for now


  Joins = {
    MembershipTable => nil,
    ContactTable    => "user_id=mem_admin and con_id=user_contact",
    OrderTable      => "order_mem_id=mem_id",
  }

  ExtraTables =
    {
      ContactTable => [ UserTable ]
    }
  
  # Here's the descriptors of what we can do

  FieldList =  {
    :mem_passport_prefix => {
      :order => 1,
      :comp  => :EQUALS,
      :table => MembershipTable},
    
    :mem_passport => {
      :order => 2,
      :comp  => :EQUALS,
      :label => 'Passport',
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
    
    :mem_name => {
      :order => 5,
      :comp  => :CONTAINS,
      :label => 'Passport name',
      :table => MembershipTable},
    
    :con_email => {
      :order => 6,
      :comp  => :CONTAINS,
      :label => 'E-mail address',
      :table => ContactTable},
    
    :mem_schoolname => {
      :order => 7,
      :comp  => :CONTAINS,
      :label => 'School name',
      :table => MembershipTable},
    
    :mem_district => {
      :order => 8,
      :comp  => :CONTAINS,
      :label => 'School district',
      :table => MembershipTable},
    
    :con_first_name => { 
      :order => 9,
      :comp  => :CONTAINS,
      :label => 'Contact first name',
      :table => ContactTable},
    
    :con_last_name => { 
      :order => 10,
      :comp  => :CONTAINS,
      :label => 'Contact last name',
      :table => ContactTable},
    
    :mem_state => {
      :order => 11,
      :comp  => :EQUALS,
      :label => 'Current status',
      :table => MembershipTable,
      :ddlb  => 'select stt_id, stt_desc from state_name'},
    
    :mem_is_active => {
      :order => 12,
      :comp  => :EQUALS,
      :label => 'Active',
      :table => MembershipTable,
      :radio => {
        'Y' => 'Yes',
        'N' => 'No'}},
    
    :order_pay_type => {
      :order => 13,
      :comp  => :EQUALS,
      :label => 'Payment method',
      :table => OrderTable,
      :ddlb  => 'select pme_id, pme_desc from payment_method'},
    
    :order_doc_ref => {
      :order => 14,
      :comp  => :EQUALS,
      :label => 'Check/PO number',
      :table => OrderTable},
    
    :mem_dt_created => {
      :order => 15,
      :comp  => :DAYS_OLD,
      :label => "Created",
      :table => MembershipTable,
    },
  }


  def initialize(session)
    super(session, FieldList, Joins, MembershipTable, ExtraTables)
  end

end
