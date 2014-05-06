insert into address
values(0, TRUE, ' PO Box 547', '', 'Glassboro', '', 'NJ', '08028', 'U.S.A.');

select setval('address_add_id_seq', 100);



insert into contact(con_id, con_first_name, con_last_name,
                   con_ship, con_mail, con_email, con_day_tel, con_ship_to_mail)
values (0, 'System', 'Administrator', 0, 0, 'dave@pragprog.com', '856.881.1603', true);

select setval('contact_con_id_seq', 100);



insert into affiliate(aff_id, aff_passport_prefix, aff_passport_length,
                      aff_short_name, aff_long_name,
                      aff_has_regions, aff_is_foreign, aff_is_sa, aff_to_do)
values (0, '000', 5, 'HQ', 'DI Headquarters', FALSE, FALSE, FALSE, -1);

select setval('affiliate_aff_id_seq', 100);



insert into user_table(user_id, user_acc_name, user_password,
        user_contact, user_affiliate)
values(0, 'glb',  '  th4HsOutjq', 0, 0);

insert into role(role_user, role_affiliate, role_region,
                 role_name, role_target_type, role_target)
values(0, 0, NULL, 6, NULL, NULL);

select setval('user_table_user_id_seq', 100);
select setval('role_role_id_seq', 100);


insert into season values(2003);

insert into current_season values(2003);

