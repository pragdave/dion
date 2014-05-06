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

class OrderSearch < Search


  # a table of joins - note this is only one level deep for now


  Joins = {
    OrderTable => nil,
    ContactTable    => "user_id=order_user_id and con_id=user_contact",
    MembershipTable      => "order_mem_id=mem_id",
  }

  ExtraTables =
    {
      ContactTable => [ UserTable ]
    }
  
  # Here's the descriptors of what we can do

  FieldList =  {
    :con_first_name => { 
      :order => 1,
      :comp  => :CONTAINS,
      :label => 'Contact first name',
      :table => ContactTable},
    
    :con_last_name => { 
      :order => 2,
      :comp  => :CONTAINS,
      :label => 'Contact last name',
      :table => ContactTable},
    
    :con_email => {
      :order => 3,
      :comp  => :CONTAINS,
      :label => 'E-mail address',
      :table => ContactTable},
    
    :order_pay_type => {
      :order => 4,
      :comp  => :EQUALS,
      :label => 'Payment method',
      :table => OrderTable,
      :ddlb  => 'select pme_id, pme_desc from payment_method'},
    
    :order_doc_ref => {
      :order => 5,
      :comp  => :EQUALS,
      :label => 'Check/PO number',
      :table => OrderTable},
    
    :order_grand_total => {
      :order => 6,
      :comp  => :FLEQUALS,
      :label => 'Order total',
      :table => OrderTable},

    :mem_passport_prefix => {
      :order => 7,
      :comp  => :EQUALS,
      :table => MembershipTable},
    
    :mem_passport => {
      :order => 8,
      :comp  => :EQUALS,
      :label => 'Passport',
      :table => MembershipTable,
      :prefix => :mem_passport_prefix},
    
    :mem_affiliate => {
      :order => 9,
      :comp  => :EQUALS,
      :label => 'Affiliate',
      :table => MembershipTable,
      :ddlb  => 'select aff_id, aff_short_name from affiliate'},
    
    :mem_region => {
      :order => 10,
      :comp  => :EQUALS,
      :label => 'Region',
      :table => MembershipTable,
      :needs => :mem_affiliate,
      :ddlb  => "select reg_id, reg_name from region
                  where reg_affiliate='!mem_affiliate!'"},
    
    :mem_name => {
      :order => 11,
      :comp  => :CONTAINS,
      :label => 'Passport name',
      :table => MembershipTable},
    
    :mem_schoolname => {
      :order => 12,
      :comp  => :CONTAINS,
      :label => 'School name',
      :table => MembershipTable},
    
    :mem_district => {
      :order => 13,
      :comp  => :CONTAINS,
      :label => 'School district',
      :table => MembershipTable},
    
  }


  def initialize(session)
    super(session, FieldList, Joins, OrderTable, ExtraTables)
  end


  def build_query
    where, tables = super
    where << " and order_amount_paid < order_grand_total"
    return where, tables
  end
end
