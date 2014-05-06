alter table user_table add column user_first_logged_in timestamp;
alter table user_table alter column user_first_logged_in set default now();
update user_table set user_first_logged_in = '2003-01-01 12:00:00';

alter table user_table add column user_last_logged_in timestamp;
update user_table set user_last_logged_in = '2003-01-01 12:00:00';

update user_table
 set user_first_logged_in = (select min(uh_when) from user_history where uh_user=user_id);

update user_table
 set user_first_logged_in = '2001-01-01 12:00' where user_first_logged_in is null;


update user_table
 set user_last_logged_in = (select max(uh_when) from user_history where uh_user=user_id);

update user_table
 set user_last_logged_in = '2001-01-01 12:00' where user_last_logged_in is null;

