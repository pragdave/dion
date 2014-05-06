create table session (
    session_id           serial           primary key not null ,
    session_parent       int              null  references session(session_id),
    session_touched      timestamp        not null ,
    session_expired      boolean          not null ,
    session_data         bytea            not null ,
    _version             int              default '0' not null );
create table address (
    add_id               serial           primary key not null ,
    add_commercial       boolean          default 'FALSE' not null ,
    add_line1            varchar(100)     null ,
    add_line2            varchar(100)     null ,
    add_city             varchar(100)     null ,
    add_county           varchar(100)     null ,
    add_state            varchar(20)      null ,
    add_zip              varchar(12)      null ,
    add_country          varchar(100)     null ,
    _version             int              default '0' not null );
create table contact (
    con_id               serial           primary key not null ,
    con_first_name       varchar(50)      not null ,
    con_last_name        varchar(50)      not null ,
    con_ship_to_mail     boolean          not null ,
    con_ship             int              null  references address(add_id),
    con_mail             int              null  references address(add_id),
    con_day_tel          varchar(20)      null ,
    con_eve_tel          varchar(20)      null ,
    con_fax_tel          varchar(20)      null ,
    con_email            varchar(60)      null ,
    _version             int              default '0' not null ,
    unique (con_email));
create table affiliate (
    aff_id               serial           primary key not null ,
    aff_passport_prefix  varchar(3)       not null ,
    aff_passport_length  int              not null ,
    aff_short_name       varchar(20)      not null ,
    aff_long_name        varchar(100)     not null ,
    aff_has_regions      boolean          not null ,
    aff_is_foreign       boolean          default 'FALSE' not null ,
    aff_in_canada        boolean          default 'FALSE' not null ,
    aff_is_sa            boolean          not null ,
    aff_to_do            int              not null ,
    _version             int              default '0' not null ,
    unique (aff_short_name),
    unique (aff_long_name),
    unique (aff_passport_prefix));
create table region (
    reg_id               serial           primary key not null ,
    reg_affiliate        int              not null  references affiliate(aff_id),
    reg_name             varchar(100)     not null ,
    _version             int              default '0' not null );
create table user_table (
    user_id              serial           primary key not null ,
    user_acc_name        varchar(50)      null ,
    user_password        varchar(32)      null ,
    user_contact         int              not null  references contact(con_id),
    user_affiliate       int              not null  references affiliate(aff_id),
    user_region          int              null  references region(reg_id),
    _version             int              default '0' not null ,
    unique (user_acc_name));
create table products (
    prd_id               serial           primary key not null ,
    prd_short_desc       char(20)         not null ,
    prd_long_desc        varchar(100)     not null ,
    prd_sku              char(20)         not null ,
    prd_aff_can_markup   boolean          not null ,
    prd_type             char(1)          not null ,
    prd_show_on_app      boolean          not null ,
    prd_show_general     boolean          not null ,
    prd_show_tournament  boolean          not null ,
    prd_available_in_us  boolean          not null ,
    prd_available_intl   boolean          not null ,
    prd_use_stepped_shipping boolean          not null ,
    prd_use_intl_surcharge boolean          not null ,
    prd_is_active        boolean          not null ,
    prd_price            decimal(6,2)     not null ,
    prd_payment_actions  varchar(10)      null ,
    prd_settlement_actions varchar(10)      null ,
    _version             int              default '0' not null ,
    unique (prd_sku));
create table aff_product (
    afp_id               serial           primary key not null ,
    afp_affiliate        int              not null  references affiliate(aff_id),
    afp_product          int              not null  references products(prd_id),
    afp_markup           decimal(6,2)     not null ,
    _version             int              default '0' not null ,
    unique (afp_affiliate, afp_product));
create view combined_products as select prd_id, prd_short_desc, prd_long_desc, prd_sku, prd_aff_can_markup, prd_type, prd_show_on_app, prd_show_general, prd_show_tournament, prd_available_in_us, prd_available_intl, prd_use_stepped_shipping, prd_use_intl_surcharge, prd_is_active, prd_price, prd_payment_actions, prd_settlement_actions, afp_id, afp_affiliate, afp_product, afp_markup from products left outer join aff_product on afp_product=prd_id;
create table payment_method (
    pme_id               char(1)          primary key not null ,
    pme_desc             varchar(50)      not null ,
    pme_is_credit_card   boolean          not null ,
    pme_form_note        varchar(50)      not null ,
    _version             int              default '0' not null );
insert into payment_method values('C', 'Check/Money Order', 'false', 'In US dollars');
insert into payment_method values('P', 'Purchase Order', 'false', '');
insert into payment_method values('V', 'Visa/Mastercard', 'true', '');
create table state_name (
    stt_id               char(6)          primary key not null ,
    stt_desc             varchar(30)      not null ,
    _version             int              default '0' not null );
insert into state_name values('SUSPND', 'Suspended');
insert into state_name values('WTPAY', 'Not paid');
insert into state_name values('ACTIVE', 'Active');
create table membership (
    mem_id               serial           primary key not null ,
    mem_passport_prefix  char(3)          not null ,
    mem_passport         char(5)          not null ,
    mem_affiliate        int              not null  references affiliate(aff_id),
    mem_is_active        boolean          not null ,
    mem_region           int              null ,
    mem_name             varchar(100)     not null ,
    mem_schoolname       varchar(100)     not null ,
    mem_district         varchar(100)     not null ,
    mem_creator          int              not null  references user_table(user_id),
    mem_admin            int              not null  references user_table(user_id),
    mem_type             char(1)          not null  check (mem_type >= '0' and mem_type <= '9'),
    mem_upgrade_pending  boolean          not null ,
    mem_reg_fee          decimal(8,2)     null ,
    mem_dt_created       timestamp        not null ,
    mem_dt_activated     timestamp        null ,
    mem_dt_assigned      timestamp        null ,
    mem_dt_suspended     timestamp        null ,
    mem_last_activity    timestamp        not null ,
    mem_state            char(6)          not null  references state_name(stt_id),
    _version             int              default '0' not null ,
    unique (mem_passport_prefix, mem_passport));
create table membership_history (
    mh_id                serial           primary key not null ,
    mh_membership        int              not null  references membership(mem_id),
    mh_user              int              not null  references user_table(user_id),
    mh_when              timestamp        not null ,
    mh_inet              varchar(50)      not null ,
    mh_notes             varchar(200)     not null ,
    _version             int              default '0' not null );
create table user_history (
    uh_id                serial           primary key not null ,
    uh_user              int              not null  references user_table(user_id),
    uh_when              timestamp        not null ,
    uh_inet              varchar(50)      not null ,
    uh_notes             varchar(200)     not null ,
    _version             int              default '0' not null );
create index idx_uh_user on user_history(uh_user);
create index idx_uh_when on user_history(uh_when);
create table sale_parameter (
    sp_id                serial           primary key not null ,
    sp_canada_surcharge  decimal(6,2)     not null ,
    sp_intl_surcharge    decimal(6,2)     not null ,
    sp_first_stepped_shipping decimal(6,2)     not null ,
    sp_rest_stepped_shipping decimal(6,2)     not null ,
    _version             int              default '0' not null );
insert into sale_parameter values('0', '10.0', '15.0', '4.0', '2.0');
create table payment (
    pay_id               serial           primary key not null ,
    pay_type             char(1)          not null  references payment_method(pme_id),
    pay_processed        timestamp        not null ,
    pay_our_ref          varchar(40)      not null ,
    pay_doc_ref          varchar(40)      not null ,
    pay_payor            varchar(40)      not null ,
    pay_amount           decimal(8,2)     not null ,
    pay_amount_applied   decimal(8,2)     not null ,
    pay_paying_check_doc_ref varchar(40)      null ,
    pay_paying_check_payor varchar(40)      null ,
    pay_paying_check_our_ref varchar(40)      null ,
    pay_paying_processed timestamp        null ,
    _version             int              default '0' not null );
create table orders (
    order_id             serial           primary key not null ,
    order_date           timestamp        not null ,
    order_date_paid      timestamp        null ,
    order_date_shipped   timestamp        null ,
    order_doc_ref        varchar(40)      null ,
    order_pay_type       char(1)          not null  references payment_method(pme_id),
    order_shipping       decimal(8,2)     not null ,
    order_intl_surcharge decimal(8,2)     not null ,
    order_total_amt      decimal(8,2)     not null ,
    order_pay_id         int              null  references payment(pay_id),
    order_aff_id         int              not null  references affiliate(aff_id),
    order_mem_id         int              not null  references membership(mem_id),
    order_user_id        int              not null  references user_table(user_id),
    _version             int              default '0' not null );
create table line_item (
    li_id                serial           primary key not null ,
    li_order_id          int              not null  references orders(order_id),
    li_desc              varchar(100)     not null ,
    li_qty               int              not null ,
    li_unit_price        decimal(8,2)     not null ,
    li_aff_fee           decimal(8,2)     not null ,
    li_total_amt         decimal(8,2)     not null ,
    li_prd_id            int              not null  references products(prd_id),
    li_use_stepped_shipping boolean          not null ,
    li_use_intl_surcharge boolean          not null ,
    _version             int              default '0' not null );
create table invoice (
    inv_id               serial           primary key not null ,
    inv_pay_id           int              null  references payment(pay_id),
    inv_billing_addreess varchar(2000)    not null ,
    inv_notes            varchar(2000)    not null ,
    inv_internal_notes   varchar(2000)    not null ,
    inv_amount           decimal(8,2)     not null ,
    inv_paid             boolean          not null ,
    _version             int              default '0' not null );
create table invoice_line (
    il_id                serial           primary key not null ,
    il_inv_id            int              not null  references invoice(inv_id),
    il_line_no           int              not null ,
    _version             int              default '0' not null );
create table ship (
    ship_id              serial           primary key not null ,
    ship_created         timestamp        not null ,
    ship_sale_id         int              not null  references line_item(li_id),
    _version             int              default '0' not null );
create view ship_info as select ship_id, ship_created, ship_sale_id, li_id, li_order_id, li_desc, li_qty, li_unit_price, li_aff_fee, li_total_amt, li_prd_id, li_use_stepped_shipping, li_use_intl_surcharge, prd_id, prd_short_desc, prd_long_desc, prd_sku, prd_aff_can_markup, prd_type, prd_show_on_app, prd_show_general, prd_show_tournament, prd_available_in_us, prd_available_intl, prd_use_stepped_shipping, prd_use_intl_surcharge, prd_is_active, prd_price, prd_payment_actions, prd_settlement_actions from ship, line_item, products where ship_sale_id = li_id and li_prd_id = prd_id;
create table fee_cycle (
    cycle_id             serial           primary key not null ,
    cycle_date           timestamp        not null ,
    _version             int              default '0' not null );
create table fee_cycle_paid (
    fcp_id               serial           primary key not null ,
    fcp_cycle_id         int              not null  references fee_cycle(cycle_id),
    fcp_aff_id           int              not null  references affiliate(aff_id),
    fcp_amount           decimal(8,2)     not null ,
    _version             int              default '0' not null );
create table affiliate_fee (
    afee_id              serial           primary key not null ,
    afee_date_created    timestamp        not null ,
    afee_date_paid       timestamp        null ,
    afee_amount          decimal(8,2)     not null ,
    afee_desc            varchar(100)     not null ,
    afee_aff_id          int              not null  references affiliate(aff_id),
    afee_sale_id         int              not null  references line_item(li_id),
    afee_pay_id          int              not null  references payment(pay_id),
    afee_paid_in_cycle   int              null  references fee_cycle(cycle_id),
    _version             int              default '0' not null );
create table season (
    season               int              primary key not null ,
    _version             int              default '0' not null );
create table current_season (
    current_season       int              primary key not null  references season(season),
    _version             int              default '0' not null );
create table challenge_desc (
    chd_id               serial           primary key not null ,
    chd_season           int              not null  references season(season),
    chd_primary_only     boolean          not null ,
    chd_levels           int              not null ,
    chd_name             varchar(100)     not null ,
    chd_desc             varchar(10000)   not null ,
    chd_file_path        varchar(200)     not null ,
    chd_icon_url         varchar(200)     not null ,
    _version             int              default '0' not null );
create table challenge (
    cha_id               serial           primary key not null ,
    cha_aff_id           int              not null  references affiliate(aff_id),
    cha_chd_id           int              not null  references challenge_desc(chd_id),
    cha_levels           int              not null ,
    _version             int              default '0' not null );
create view challenge_view as select cha_id, cha_aff_id, cha_chd_id, cha_levels, chd_id, chd_season, chd_primary_only, chd_levels, chd_name, chd_desc, chd_file_path, chd_icon_url from challenge, challenge_desc where cha_chd_id = chd_id;
create table team (
    team_id              serial           primary key not null ,
    team_mem_id          int              not null  references membership(mem_id),
    team_passport_suffix int              not null ,
    team_challenge       int              not null  references challenge(cha_id),
    team_level           int              not null ,
    team_name            varchar(100)     not null ,
    _version             int              default '0' not null );
create table grade (
    grade_id             int              primary key not null ,
    grade_desc           varchar(20)      not null ,
    _version             int              default '0' not null );
insert into grade values('0', 'Kindergarten');
insert into grade values('1', 'First');
insert into grade values('2', 'Second');
insert into grade values('3', 'Third');
insert into grade values('4', 'Fourth');
insert into grade values('5', 'Fifth');
insert into grade values('6', 'Sixth');
insert into grade values('7', 'Seventh');
insert into grade values('8', 'Eighth');
insert into grade values('9', 'Ninth');
insert into grade values('10', 'Tenth');
insert into grade values('11', 'Eleventh');
insert into grade values('12', 'Twelfth');
insert into grade values('113', 'College/Military');
create table team_member (
    tm_id                serial           primary key not null ,
    tm_team_id           int              not null  references team(team_id),
    tm_name              varchar(100)     not null ,
    tm_grade             int              not null  references grade(grade_id),
    tm_dob               date             null ,
    _version             int              default '0' not null );
create table target (
    tar_id               int              primary key not null ,
    tar_name             varchar(30)      not null ,
    tar_table            varchar(30)      not null ,
    _version             int              default '0' not null );
insert into target values('0', 'Membership', 'membership');
insert into target values('1', 'Team', 'team');
insert into target values('2', 'Affiliate', 'affiliate');
insert into target values('3', 'region', 'region');
insert into target values('4', 'Challenge', 'challenge_desc');
create table role_name (
    rn_id                int              primary key not null ,
    rn_name              varchar(50)      not null ,
    _version             int              default '0' not null );
insert into role_name values('0', 'TeamPak Creator');
insert into role_name values('1', 'TeamPak Contact');
insert into role_name values('2', 'Team Manager');
insert into role_name values('3', 'Registered');
insert into role_name values('4', 'Affiliate Director');
insert into role_name values('5', 'Regional Director');
insert into role_name values('6', 'HQ Administrator');
insert into role_name values('7', 'International Challenge Master');
insert into role_name values('8', 'Affiliate Challenge Master');
insert into role_name values('9', 'Regional Challenge Master');
insert into role_name values('10', 'Existing User');
insert into role_name values('100', 'Downloaded challenge');
create table role (
    role_id              serial           primary key not null ,
    role_user            int              not null  references user_table(user_id),
    role_affiliate       int              null  references affiliate(aff_id),
    role_region          int              null  references region(reg_id),
    role_name            int              not null  references role_name(rn_id),
    role_target_type     int              null  references target(tar_id),
    role_target          int              null ,
    _version             int              default '0' not null );
create table news (
    news_id              serial           primary key not null ,
    news_start_date      date             not null ,
    news_end_date        date             not null ,
    news_posted_by       int              not null  references user_table(user_id),
    news_aff_id          int              null  references affiliate(aff_id),
    news_reg_id          int              null  references region(reg_id),
    news_user_id         int              null  references user_table(user_id),
    news_byline          varchar(100)     not null ,
    news_summary         varchar(200)     not null ,
    news_story           varchar(10000)   not null ,
    _version             int              default '0' not null );
create index idx_news_start_date on news(news_start_date);
