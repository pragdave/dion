 create table change_request (
     cr_id                serial           primary key not null ,
     cr_mem_id            int              not null  references membership(mem_id),
     cr_user_id           int              not null  references user_table(user_id),
     cr_date_requested    timestamp        not null ,
     cr_date_done         timestamp        null ,
     cr_done_by           int              null  references user_table(user_id),
     cr_accepted          boolean          null ,
     cr_mem_name          varchar(100)     null ,
     cr_mem_schoolname    varchar(100)     null ,
     cr_mem_district      varchar(100)     null ,
     _version             int              default '0' not null );
