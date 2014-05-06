drop table marita_people;
create table marita_people (
  unique_id  int          ,
  passport  varchar(14)  ,
  organization_name  varchar(200) ,
  passport_prefix  varchar(50)  ,
  affiliation  varchar(50)  ,
  shipping_name  varchar(100) ,
  ship_street_address  varchar(100) ,
  ship_line2  varchar(100) ,
  ship_district  varchar(100) ,
  ship_international_1  varchar(100) ,
  ship_international_2  varchar(100) ,
  ship_city  varchar(100) ,
  ship_state  varchar(100) ,
  ship_zipcode  varchar(20)  ,
  county  varchar(100) ,
  country  varchar(100) ,
  membership_category  varchar(50)  ,
  mail_name  varchar(100) ,
  mail_street_address  varchar(100) ,
  mail_line2  varchar(100) ,
  mail_city  varchar(100) ,
  mail_state  varchar(100) ,
  mail_international_1  varchar(100) ,
  mail_international_2  varchar(100) ,
  mail_country  varchar(100) ,
  mail_zipcode  varchar(50)  ,
  current  varchar(50)  ,
  bill_ID  varchar(50)  ,
  globals_year  varchar(50)  ,
  member_year  varchar(50)  ,
  PAK  varchar(50)  ,
  start_grade  varchar(50)  ,
  end_grade  varchar(50)  ,
  con_last_name  varchar(50)  ,
  con_first_name  varchar(50)  ,
  con_home_phone  varchar(50)  ,
  con_work_phone  varchar(50)  ,
  con_fax  varchar(50)  ,
  con_email  varchar(100) 
);