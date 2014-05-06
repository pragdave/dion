delete from team_member;
delete from team;
delete from pays;
delete from invoice_line;
delete from invoice;
delete from aff_product;
delete from affiliate_fee;
delete from ship;
delete from line_item;
delete from ship_cycle;
delete from user_history;
delete from membership_history;
delete from cc_log;
delete from payment;
delete from orders;
delete from products where prd_type in ('1', '5', 'U');
delete from challenge_download;
delete from challenge;
delete from challenge_desc;
drop view challenge_view;
drop sequence challenge_desc_chd_id_seq;
drop table challenge_desc;
create table challenge_desc (
    chd_id               serial           primary key not null,
    chd_season           int              not null  references season(season),
    chd_levels           int              not null ,
    chd_name             varchar(100)     not null ,
    chd_short_name       varchar(100)     not null ,
    _version             int              default '0' not null );
create view challenge_view as select cha_id, cha_aff_id, cha_chd_id, cha_levels, chd_id, chd_season, chd_levels, chd_name, chd_short_name from challenge, challenge_desc where cha_chd_id = chd_id;


insert into grade values('14', 'Other Adult');
update current_season set current_season=2004;

delete from membership where mem_state != 'ACTIVE';
update membership set mem_is_active='N', mem_state='SUSPND', mem_upgrade_pending='N', mem_reg_fee=null, mem_dt_activated=null, mem_dt_suspended=null;

update affiliate set aff_is_sa = false;
update affiliate set aff_to_do=15 where aff_has_regions;
update affiliate set aff_to_do=13 where not aff_has_regions;
update affiliate set aff_reg_start='2003-09-01', aff_reg_end='2004-02-01',
aff_team_reg_start='2003-09-01', aff_team_reg_end='2004-02-01';

update state_name set stt_desc = 'Inactive' where stt_desc='Suspended';

