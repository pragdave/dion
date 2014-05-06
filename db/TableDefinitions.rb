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

require 'db/TableClass'
require 'db/Table'

# The session table holds session and context data as serialized
# Ruby objects. For sessions, the session_parent field is null, for
# contexts it references the session entry

class SessionTable < Table
  table "session" do 
    field autoinc,      :session_id,       pk
    field int,          :session_parent,   null, references(SessionTable, :session_id)
    field timestamp,    :session_touched
    field boolean,      :session_expired
    field blob,         :session_data
    indexed(:session_touched)
  end
end


class AddressTable < Table
  table  "address" do
    field  autoinc,      :add_id,          pk
    field  boolean,      :add_commercial,  default(FieldType::Boolean::FALSE)
    field  varchar(100), :add_line1,       null
    field  varchar(100), :add_line2,       null
    field  varchar(100), :add_city,        null
    field  varchar(100), :add_county,      null
    field  varchar(20),  :add_state,       null
    field  varchar(12),  :add_zip,         null
    field  varchar(100), :add_country,     null
  end
end


class ContactTable < Table
  table  "contact" do
    field  autoinc,      :con_id,      pk
    field  varchar(50),  :con_first_name
    field  varchar(50),  :con_last_name

    # true -> use mailing address for shipping
    field  boolean,      :con_ship_to_mail

    field  int,          :con_ship,    null, references(AddressTable, :add_id)
    field  int,          :con_mail,    null, references(AddressTable, :add_id)
    field  varchar(20),  :con_day_tel, null
    field  varchar(20),  :con_eve_tel, null
    field  varchar(20),  :con_fax_tel, null
    field  varchar(60),  :con_email,   null
    unique(:con_email)
  end
end


class AffiliateTable < Table
  table "affiliate" do
    field autoinc,       :aff_id,          pk
    field varchar(3),    :aff_passport_prefix
    field int,           :aff_passport_length    # of the suffix (4 or 5)
    field varchar(20),   :aff_short_name
    field varchar(100),  :aff_long_name
    field boolean,       :aff_has_regions
    field boolean,       :aff_is_foreign,  default(FieldType::Boolean::FALSE)
    field boolean,       :aff_in_canada,   default(FieldType::Boolean::FALSE)
    field boolean,       :aff_is_sa             # self admin
    field boolean,       :aff_rds_can_assign    # can rds assign teams to regions
    field int,           :aff_to_do             # stuff to do before season starts
    field date,          :aff_reg_start
    field date,          :aff_reg_end
    field date,          :aff_team_reg_start
    field date,          :aff_team_reg_end

    unique(:aff_short_name)
    unique(:aff_long_name)
    unique(:aff_passport_prefix)
  end
end

class RegionTable < Table
  table "region" do
    field autoinc,       :reg_id,         pk
    field int,           :reg_affiliate,  references(AffiliateTable, :aff_id)
    field varchar(100),  :reg_name
  end
end


class UserTable < Table
  table "user_table" do
    field  autoinc,      :user_id,         pk
    field  varchar(50),  :user_acc_name,   null
    field  varchar(32),  :user_password,   null
#    field  int,          :user_level
    field  int,          :user_contact,    references(ContactTable, :con_id)
    field  int,          :user_affiliate,  references(AffiliateTable, :aff_id)
    field  int,          :user_region,     null, references(RegionTable, :reg_id)
    field  timestamp,    :user_first_logged_in, default("now()")
    field  timestamp,    :user_last_logged_in
    unique(:user_acc_name)
  end
end

class ProductTable < Table

  # product types
  TEAMPAK_MIN = "1"
  TEAMPAK_MAX = "9"
  REGULAR_PRODUCT = "A"
  UPGRADE_PRODUCT = "U"
  ADJUSTMENT_PRODUCT = "?"

  # Payment and settlement actions
  PA_ACTIVATE_MEMBERSHIP = 'A'
  PA_SHIP                = 'S'
  PA_UPGRADE_MEMBERSHIP  = 'U'


  
  table "products" do
    field autoinc,       :prd_id,         pk
    field char(20),      :prd_short_desc
    field varchar(100),  :prd_long_desc
    field char(20),      :prd_sku
    field boolean,       :prd_aff_can_markup   # can affiliate add a markup?
#    field boolean,       :prd_is_international 

    # TEAMPAK, regular, upgrade
    field char(1),       :prd_type
    
    # Where do we display this product?
    field boolean,       :prd_show_on_app
    field boolean,       :prd_show_general
    field boolean,       :prd_show_tournament

    # Where is this product available
    field boolean,       :prd_available_in_us
    field boolean,       :prd_available_intl

    # do we use the $4 first, $2 subsequent rule?
    field boolean,       :prd_use_stepped_shipping

    # do we apply surcharges
    field boolean,       :prd_use_intl_surcharge

    field boolean,       :prd_is_active

    field decimal(6,2),  :prd_price

    field varchar(10),   :prd_payment_actions,     null
    field varchar(10),   :prd_settlement_actions,  null
    unique(:prd_sku)
  end
end

class AffiliateProductTable < Table
  table "aff_product" do
    field autoinc,       :afp_id,         pk
    field int,           :afp_affiliate,  references(AffiliateTable, :aff_id)
    field int,           :afp_product,    references(ProductTable,   :prd_id)
    field decimal(6,2),  :afp_markup
    unique(:afp_affiliate, :afp_product)
  end
end

class CombinedProductTable < Table
  outer_view "combined_products", 
    [ProductTable, AffiliateProductTable], 
    "afp_product=prd_id"
end

class PaymentMethodTable < Table
  CHECK = "C"
  PO    = "P"
  CC    = "V"

  table "payment_method" do
    field char(1),        :pme_id,           pk
    field varchar(50),    :pme_desc
    field varchar(10),    :pme_short_desc
    field boolean,        :pme_is_credit_card
    field varchar(50),    :pme_form_note
    initial_values([CHECK, 'Check/Money Order', 'Chk',  FALSE, 'In US dollars' ],
                   [PO,    'Purchase Order',    'P.O.', FALSE, ''],
                   [CC,    'Visa/Mastercard',   'CC',   TRUE,  ''])
  end
end

class StateNameTable < Table
  Suspended   = 'SUSPND'
  WaitPayment = 'WTPAY'
  Active      = 'ACTIVE'
  
  table "state_name" do
    field char(6),       :stt_id,            pk
    field varchar(30),   :stt_desc
    
    initial_values([Suspended,   "Inactive"],
                   [WaitPayment, "Not paid"],
                   [Active,      "Active"]
                   )
  end
end

class MembershipTable < Table
  table "membership" do
    field autoinc,        :mem_id,           pk
    field char(3),        :mem_passport_prefix
    field char(5),        :mem_passport
    field int,            :mem_affiliate,    references(AffiliateTable, :aff_id)
    field boolean,        :mem_is_active
    field int,            :mem_region,       null, references(RegionTable, :reg_id)
    field varchar(100),   :mem_name
    field varchar(100),   :mem_schoolname
    field varchar(100),   :mem_district

    field int,            :mem_creator,      references(UserTable, :user_id)
    field int,            :mem_admin,        references(UserTable, :user_id)

    # OnePak or FivePak
    field char(1),        :mem_type,         check("mem_type >= '0' and mem_type <= '9'")

    field boolean,        :mem_upgrade_pending

    field decimal(8,2),   :mem_reg_fee,      null

    #field varchar(100)    mem_ins_contact
    #field varchar(30)     mem_ins_phone

    # Significant dates 
    field timestamp,      :mem_dt_created
    field timestamp,      :mem_dt_activated,  null
    field timestamp,      :mem_dt_assigned,   null
    field timestamp,      :mem_dt_suspended,  null
    field timestamp,      :mem_last_activity

    # Current state, and the event that got us there */
    field char(6),        :mem_state,         references(StateNameTable, :stt_id),

    #   mem_last_event      char(6)      not null references event_name(evt_id),

    unique(:mem_passport_prefix, :mem_passport)
    
  end
end

# Record all significant events on a membership
class MembershipHistoryTable < Table
  table "membership_history" do

    field autoinc,        :mh_id,             pk
    field int,            :mh_membership,     references(MembershipTable, :mem_id)
    field int,            :mh_user,           references(UserTable, :user_id)
    field timestamp,      :mh_when
    field varchar(50),    :mh_inet
    field varchar(200),   :mh_notes
  end
end


# Record all significant events on a user
class UserHistoryTable < Table
  table "user_history" do

    field autoinc,        :uh_id,             pk
    field int,            :uh_user,           references(UserTable, :user_id)
    field timestamp,      :uh_when
    field varchar(50),    :uh_inet
    field varchar(200),   :uh_notes
    indexed(:uh_user)
    indexed(:uh_when)
  end
end

# This table contains just a single row containing the parameters
# applied globally to sales

class SaleParameterTable < Table
  table "sale_parameter" do
    field autoinc,       :sp_id,           pk
    field decimal(6,2),  :sp_canada_surcharge
    field decimal(6,2),  :sp_intl_surcharge

    # these two do "first book is $4, rest are $2"
    field decimal(6,2),  :sp_first_stepped_shipping
    field decimal(6,2),  :sp_rest_stepped_shipping

    initial_values(
       [0, 10.00, 15.00, 4.00, 2.00]
    )
  end
end

# Payments are things that we receive: checks and POs. They are
# matched with Orders via the Pays table

class PaymentTable < Table
  table "payment" do
    field autoinc,       :pay_id,           pk
    field char(1),       :pay_type,         references(PaymentMethodTable, :pme_id)
    field timestamp,     :pay_processed
    field varchar(40),   :pay_our_ref
    field varchar(40),   :pay_doc_ref
    field varchar(40),   :pay_payor
    field decimal(8,2),  :pay_amount
    field decimal(8,2),  :pay_amount_applied
    # If the payment is a PO, record the check that paid it
    field varchar(40),   :pay_paying_check_doc_ref, null
    field varchar(40),   :pay_paying_check_payor,   null
    field varchar(40),   :pay_paying_check_our_ref, null
    field timestamp,     :pay_paying_processed,     null
    field varchar(1000), :pay_ship_address, null
    unique(:pay_our_ref)
    indexed(:pay_doc_ref)
    unique(:pay_paying_check_our_ref)
    indexed(:pay_paying_check_doc_ref)
  end
end

# Sales are grouped into Orders, whoch correspond to one or more
# line items purchased at the same time

class OrderTable < Table
  table "orders" do
    field autoinc,        :order_id,          pk
    field timestamp,      :order_date

    # The date it was fully paid
    field timestamp,      :order_date_paid,   null

    # the expected type of payment entered by the user
    field varchar(40),    :order_doc_ref,     null
    field char(1),        :order_pay_type,    references(PaymentMethodTable, :pme_id)

    # various amounts
    
    field decimal(8,2),   :order_shipping
    field decimal(8,2),   :order_intl_surcharge
    field decimal(8,2),   :order_lines_total
    field decimal(8,2),   :order_grand_total

    # and how much has actually been paid?
    field decimal(8,2),   :order_amount_paid

    # and how much settled (if receipt is by PO, settled only gets
    # updated when check arrives)
    field decimal(8,2),   :order_amount_settled

    field int,            :order_aff_id,      references(AffiliateTable, :aff_id)
    field int,            :order_mem_id,      null, 
                                              references(MembershipTable, :mem_id)
    field int,            :order_user_id,     references(UserTable, :user_id)

    field varchar(1000),  :order_ship_address
    field boolean,        :order_ship_add_changed
  end
end

# These are the line items that appear in an order

class LineItemTable < Table
  table "line_item" do
    field autoinc,        :li_id,           pk
    field int,            :li_order_id,     references(OrderTable, :order_id)
    field varchar(100),   :li_desc
    field int,            :li_qty
    field decimal(8,2),   :li_unit_price
    field decimal(8,2),   :li_aff_fee
    field decimal(8,2),   :li_total_amt
    field int,            :li_prd_id,       references(ProductTable, :prd_id)
    field timestamp,      :li_date_shipped, null
    field boolean,        :li_use_stepped_shipping
    field boolean,        :li_use_intl_surcharge
  end
end

# The 'Pays' table links one or more PaymentTable lines with one or
# more OrderTable lines (that is a payment can be applied against
# multiple orders, and an order can be paid using multiple payments.

class PaysTable < Table
  table "pays" do
    field autoinc,      :pys_id,             pk
    field int,          :pys_pay_id,         references(PaymentTable, :pay_id)
    field int,          :pys_order_id,       references(OrderTable,   :order_id)
    field decimal(8,2), :pys_amount
    field timestamp,    :pys_date
    indexed(:pys_pay_id)
    indexed(:pys_order_id)
  end
end

# A join used to display the payment details for an order

class PaysPaymentView < Table
  view "payspayment_view",
    [PaysTable, PaymentTable],
    "pys_pay_id = pay_id"
end

# ANd a join for all orders paid with a payment

class PaysOrderView < Table
  view "paysorder_view",
    [PaysTable, OrderTable],
    "pys_order_id = order_id"
end


# Here's where we record all the invoices we send out. Invoices can be sent
# either on order, or in response to a purchase order.

class InvoiceTable < Table
  table "invoice" do
    field autoinc,       :inv_id,             pk
    field char(1),       :inv_type            # 'I'nvoice, 'R'eceipt
    field int,           :inv_pay_id,         null, references(PaymentTable, :pay_id)
    field varchar(2000), :inv_billing_address
    field varchar(2000), :inv_notes,          null
    field varchar(2000), :inv_internal_notes, null
    # description used for unapplied amounts
    field varchar(2000), :inv_unapp_desc,     null
    field decimal(8,2),  :inv_amount
    field boolean,       :inv_paid
    indexed(:inv_pay_id)
  end
end


# And the line items on an invoice

#class InvoiceLineTable < Table
#  table "invoice_line" do
#    field autoinc,       :il_id,              pk
#    field int,           :il_inv_id,          references(InvoiceTable, :inv_id)
#    field int,           :il_line_no
#
#  end
#
#end


# A log of credit card transactions
class CreditCardLogTable < Table
  table "cc_log" do
    field autoinc,       :cc_id,               pk
    field timestamp,     :cc_date_submitted
    field decimal(8,2),  :cc_amount
    field int,           :cc_con_id,           references(ContactTable, :con_id)
    field int,           :cc_order_id,         null, references(OrderTable, :order_id)
    field int,           :cc_pay_id,           null, references(PaymentTable, :pay_id)

    field varchar(200),  :cc_description
    field varchar(100),  :cc_payor,            null
    field timestamp,     :cc_date_returned,    null
    field int,           :cc_response_code,    null
    field int,           :cc_reason_code,      null
    field varchar(200),  :cc_reason_text,      null
    field varchar(20),   :cc_auth_code,        null
    field varchar(20),   :cc_trans_id,         null
    field char(1),       :cc_avs_code,         null
    indexed(:cc_pay_id)
  end
end

# Here we record stuff that's ready to ship and shipped
# Shipping works on batches.

#class ShipCycleTable < Table
#  table "ship_cycle" do
#    field autoinc,      :scy_id,               pk
#    field timestamp,    :scy_date
#  end
#end

class ShipTable < Table
  table "ship" do
    field autoinc,      :ship_id,              pk
    field timestamp,    :ship_created
    field int,          :ship_sale_id,         references(LineItemTable, :li_id)
#    field int,          :ship_cycle,           null
#    field timestamp,    :ship_labels_printed,  null
#    field timestamp,    :ship_shipped,         null
  end
end



class ShipInfoTable < Table
  view "ship_info", 
    [ShipTable, LineItemTable, OrderTable, ProductTable], 
    "ship_sale_id = li_id", "li_order_id=order_id", "li_prd_id = prd_id"
end


#################################################################################
#
# We pay affiliate fees on a system. This records the
# cycle number and date

class FeeCycleTable < Table
  table "fee_cycle" do
    field autoinc,      :cycle_id,             pk
    field timestamp,    :cycle_date
  end
end

# And here we record how much we paid each affiliate on each cycle.
# We could simple recalculate it, but that might be expensive

class FeeCyclePaid < Table
  table "fee_cycle_paid" do
    field autoinc,      :fcp_id,                pk
    field int,          :fcp_cycle_id,          references(FeeCycleTable, :cycle_id)
    field int,          :fcp_aff_id,            references(AffiliateTable, :aff_id)
    field decimal(8,2), :fcp_amount
  end
end

#
# The affiliate fee table is a journal of fees that are both pending and paid
# to affiliates. A 'paid' rebate has a paid date, an unpaid one does not

class AffiliateFeeTable < Table
  table "affiliate_fee" do
    field autoinc,       :afee_id,             pk
    field timestamp,     :afee_date_created
    field timestamp,     :afee_date_paid,      null
    field decimal(8,2),  :afee_amount
    field varchar(100),  :afee_desc
    field int,           :afee_aff_id,         references(AffiliateTable, :aff_id)
    field int,           :afee_sale_id,        references(LineItemTable, :li_id)
    field int,           :afee_pay_id,         references(PaymentTable, :pay_id)
    field int,           :afee_paid_in_cycle,  null, references(FeeCycleTable, :cycle_id)
  end
end

######################################################################
#
# A list of seasons we know about. A season is defined
# by the year of its tournament, so the 2003 season
# starts in mid 2002

class SeasonTable < Table
  table "season" do
    field int,           :season,           pk
  end
end

# And the current season. This table has just one row
class CurrentSeasonTable < Table
  table "current_season" do
    field int,           :current_season,  references(SeasonTable, :season), pk
  end
end


# THis table defines what challenges are offered
class ChallengeDescTable < Table
  table "challenge_desc" do
    field autoinc,       :chd_id,           pk
    field int,           :chd_season,       references(SeasonTable, :season)
    field int,           :chd_levels        # bitmask
    field varchar(100),  :chd_name
    field varchar(100),  :chd_short_name
  end
end

# and here's the information displayed on the download screen
class ChallengeDownloadTable < Table
  table "challenge_download" do
    field autoinc,       :cdl_id,           pk, references(ChallengeDescTable, :chd_id)
    field varchar(10000),:cdl_desc
    field varchar(200),  :cdl_icon_url
    # field paths for the various pdfs. The first is for the English
    # version, the rest as filled in as neded with other langauges
    field varchar(40),   :cdl_lang_1
    field varchar(200),  :cdl_pdf_path_1

    field varchar(40),   :cdl_lang_2,       null
    field varchar(200),  :cdl_pdf_path_2,   null

    field varchar(40),   :cdl_lang_3,       null
    field varchar(200),  :cdl_pdf_path_3,   null

    field varchar(40),   :cdl_lang_4,       null
    field varchar(200),  :cdl_pdf_path_4,   null

    field varchar(40),   :cdl_lang_5,       null
    field varchar(200),  :cdl_pdf_path_5,   null

    field varchar(40),   :cdl_lang_6,       null
    field varchar(200),  :cdl_pdf_path_6,   null

    field varchar(40),   :cdl_lang_7,       null
    field varchar(200),  :cdl_pdf_path_7,   null
  end
end

# The challenges for a season

class ChallengeTable < Table
  table "challenge" do
    field autoinc,       :cha_id,           pk
    field int,           :cha_aff_id,       references(AffiliateTable, :aff_id)
    field int,           :cha_chd_id,       references(ChallengeDescTable, :chd_id)
    field int,           :cha_levels        # bitmask
  end
end

# and a convenient view
class ChallengeViewTable < Table
  view "challenge_view",
    [ChallengeTable, ChallengeDescTable],
    "cha_chd_id = chd_id"
end

# Information of teams

class TeamTable < Table
  table "team" do
    field autoinc,      :team_id,          pk
    field int,          :team_mem_id,      references(MembershipTable, :mem_id)
    field int,          :team_passport_suffix
    field int,          :team_challenge,   references(ChallengeTable, :cha_id)
    field int,          :team_level
    field boolean,      :team_is_valid
    field timestamp,    :team_dt_created
    field varchar(100), :team_name
    indexed(:team_mem_id)
  end
end

# what grades are around

class GradeTable < Table
  table "grade" do
    field int,          :grade_id,         pk
    field varchar(20),  :grade_desc

    initial_values (
      [ 0, "Kindergarten" ],
      [ 1, "First" ],
      [ 2, "Second" ],
      [ 3, "Third"  ],
      [ 4, "Fourth" ],
      [ 5, "Fifth" ],
      [ 6, "Sixth" ],
      [ 7, "Seventh" ],
      [ 8, "Eighth" ],
      [ 9, "Ninth" ],
      [ 10, "Tenth" ],
      [ 11, "Eleventh" ],
      [ 12, "Twelfth" ],
      [ 13, "College/Military" ],
      [ 14, "Other adult" ]
    )
  end
end


# and the people in teams. These folks don't participate in the
# role table, as they are likely to be under 13 and hence not
# users

class TeamMemberTable < Table
  SexFemale = 'F'
  SexMale = 'M'
  SexUnknown = '?'
  SexMap = {
    SexFemale => 'Female',
    SexMale   => 'Male',
    SexUnknown => 'Unknown'
  }
    
  SexOptions = {
    SexUnknown => '',
    SexFemale => 'F',
    SexMale   => 'M',
  }

  table "team_member" do
    field autoinc,      :tm_id,             pk
    field int,          :tm_team_id,        references(TeamTable, :team_id)
    field varchar(100), :tm_name
    field int,          :tm_grade,          references(GradeTable, :grade_id)
    field char(1),      :tm_sex,            check("tm_sex in ('F', 'M', '?')")
    field date,         :tm_dob,            null
  end
end

#################################################################
#
# Define the roles between users and other major entities in the
# system

# 1. Possible targets of a foreign key

class TargetTable < Table
  MEMBERSHIP = 0
  TEAM       = 1
  AFFILIATE  = 2
  REGION     = 3
  CHALLENGE  = 4

  table "target" do
    field int,         :tar_id,             pk
    field varchar(30), :tar_name
    field varchar(30), :tar_table

    initial_values (
       [MEMBERSHIP, "Membership", "membership"],
       [TEAM,       "Team",       "team"],
       [AFFILIATE,  "Affiliate",  "affiliate"],
       [REGION,     "region",     "region"],
       [CHALLENGE,  "Challenge",  "challenge_desc"]
    )
  end
end
  
# Possible roles. For example, being an ICM, or a TeamPak contact
# is a role

class RoleNameTable < Table
  TEAMPAK_CREATOR = 0
  TEAMPAK_CONTACT = 1
  TEAM_MANAGER    = 2
  REGISTERED      = 3
  AD              = 4
  RD              = 5
  HQ              = 6
  ICM             = 7
  ACM             = 8
  RCM             = 9
  MARTIA_IMPORT   = 10
  HQ_OBSERVER     = 20
  CHALLENGE_DOWNLOADER = 100

  table "role_name" do
    field int,          :rn_id,            pk
    field varchar(50),  :rn_name

    initial_values (
      [ TEAMPAK_CREATOR, "TeamPak Creator" ],
      [ TEAMPAK_CONTACT, "TeamPak Contact" ],
      [ TEAM_MANAGER,    "Team Manager"    ],
      [ REGISTERED,      "Registered"      ],
      [ AD,              "Affiliate Director"],
      [ RD,              "Regional Director"],
      [ HQ,              "HQ Administrator"],
      [ ICM,             "International Challenge Master"],
      [ ACM,             "Affiliate Challenge Master"],
      [ RCM,             "Regional Challenge Master"],
      [ HQ_OBSERVER,     "International Observer" ],
      [ MARTIA_IMPORT,   "Existing User"],
      [ CHALLENGE_DOWNLOADER, "Downloaded challenge" ]
    )
  end
end


# And here it is - the table that defines the various
# roles that users play.
#

class RoleTable < Table
  table "role" do
    field autoinc,     :role_id,          pk
    field int,         :role_user,        references(UserTable, :user_id)
    field int,         :role_affiliate,   null, references(AffiliateTable, :aff_id)
    field int,         :role_region,      null, references(RegionTable, :reg_id)
    field int,         :role_name,        references(RoleNameTable, :rn_id)
    field int,         :role_target_type, null, references(TargetTable, :tar_id)
    field int,         :role_target,      null
    indexed(:role_user)
  end
end



# News is what you see when you log on

class NewsTable < Table
  table "news" do
    field autoinc,     :news_id,          pk
    field date,        :news_start_date
    field date,        :news_end_date
    field int,         :news_posted_by,   references(UserTable, :user_id)
    field int,         :news_aff_id,      null, references(AffiliateTable, :aff_id)
    field int,         :news_reg_id,      null, references(RegionTable, :reg_id)
    field int,         :news_user_id,     null, references(UserTable, :user_id)
    field varchar(100),:news_byline
    field varchar(200),:news_summary
    field varchar(10000), :news_story

    indexed :news_start_date
  end
end

# Record the changes requested by users

class ChangeRequestTable < Table
  table "change_request" do
    field autoinc,     :cr_id,           pk
    field int,         :cr_mem_id,       references(MembershipTable, :mem_id)
    field int,         :cr_user_id,      references(UserTable, :user_id)
    field timestamp,   :cr_date_requested 
    field timestamp,   :cr_date_done,    null
    field int,         :cr_done_by,      null, references(UserTable, :user_id)
    field boolean,     :cr_accepted,     null
    # new values for the fields
    field varchar(100), :cr_mem_name,       null
    field varchar(100), :cr_mem_schoolname, null
    field varchar(100), :cr_mem_district,   null
  end
end
