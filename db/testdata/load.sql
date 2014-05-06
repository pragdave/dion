insert into address
values(0, false, '27 Main St', '', 'Alphaville', 'Jackson', 'TX', '78965', 'U.S.A.');

insert into address
values(1, false, '2324 West 12th', 'Appt 123', 'Windy City', 'Wade', 'TX', '71234', 'U.S.A.');

insert into address
values(2, false, '987 Acacia Ave', '', 'Austin', 'Henry', 'TX', '74321', 'U.S.A.');

insert into address
values(3,  false,  '73 Minden Drive', '', 'Orchard Park', 'Erie', 'New York',  '14127',
'U.S.A.',  0);

select setval('address_add_id_seq', 100);



insert into contact(con_id, con_first_name, con_last_name, con_ship, con_ship_to_mail, con_mail, con_email, con_day_tel)
values (0, 'Dave', 'Thomas', 0, true, 0, 'dave@pragprog.com', '972 539 1811');


insert into contact(con_id, con_first_name, con_last_name, con_ship, con_ship_to_mail, con_mail, con_email, con_day_tel)
values (2, 'Reggie', 'Directrix', 1, false, 2, 'rd@pragprog.com', '111 222 3333');

insert into contact(con_id, con_first_name, con_last_name, con_ship, con_ship_to_mail, con_mail, con_email, con_day_tel)
values (3, 'Big', 'Kahuna', 1, false, 2, 'hq@pragprog.com', '111 222 3333');

insert into contact(con_id, con_first_name, con_last_name, con_ship, con_ship_to_mail, con_mail, con_email, con_day_tel)
values (4, 'Alfie', 'Director', 1, false, 2, 'ad@pragprog.com', '111 222 3333');

insert into contact values(5, 'Dee', 'Urban',   't',   3, 3,  '716-675-7566',     'same',    'same',    'deeurban@adelphia.net', 0);

select setval('contact_con_id_seq', 100);



-- Disable triggers

COPY "affiliate"  FROM stdin;
169	151	5	Australia	Australia	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
0	000	5	HQ	DI Headquarters	f	f	f	f	t	-1	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
170	157	5	COL	COL	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
171	169	5	TUR	Turkey	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
172	170	5	IT	Italy	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
173	172	5	Nova Scotia	Nova Scotia	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
174	173	5	PERU	PERU	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
145	148	5	WCPSP	WI - Creative Problem Solving Programs	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
152	160	5	Destino Imaginacion 	Destino Imaginacion Guatemala	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
153	161	5	Germany	Germany	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
154	162	5	Venzuela	Venzuela Destination Imagination	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
155	163	5	Brazillian Destinati	Brazillian Destination Imagination	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
175	174	5	HND	Honduras	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
157	166	5	ECU	Ecuador	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
156	165	5	Nicaragua	NIC	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
158	167	5	DNK	Denmark	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
176	175	5	Ukraine	Ukraine	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
160	171	5	K.A.S.I	Korea Association of Schools Invention	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
161	178	5	Malaysia	Malaysia Imagination Foundation	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
162	179	5	Scotland DI	Scotland Destination Imagination	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
163	181	5	Mariana Pacific	Commonwealth Northern Mariana Island	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
164	182	5	Japan	Japan	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
165	183	5	Greece	Greece	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
166	184	5	TBWI ISRAEL	The Branco Weiss Institute	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
177	177	5	Singapore	Singapore	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
178	180	5	Latvia	Latvia	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	0
102	101	5	AKPS	AK - Alaska	f	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	5
103	102	5	Alabama	AL - Alabama Creative Adventures	f	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
104	103	5	Arkansas	AR - Arkansas Destination Imagination, Inc.	f	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
105	104	5	DIAZ	AZ - Destination Imagination Of Arizona	f	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
106	105	5	California	CA - California Creativity	t	f	f	t	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
107	106	5	Colorado	CO - Colorado Extreme Creativity	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
108	107	5	CT ADventures	CT - ADventures in Creativity	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
109	110	5	FACE	FA - Florida Association of Creative Edventures	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
110	111	5	GEMS	GA - Georgia Enriches Minds	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
111	112	5	SFCI	IA - Students for a creative Iowa	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
159	168	5	UKDI	United Kingdom Destination Imagination	t	t	f	t	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
112	113	5	ICY	ID - Idaho's Creative Youth	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
113	114	5	IL OM Assoc	IL - IL OM Association, Inc.	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
114	115	5	Indiana Creative Pr	IN - Indiana Creative Problem Solving Association	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
115	116	5	Kansas DI	KS - Kansas Destination Imagination	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
116	117	5	Kentucky DI	KY - Kentucky Destination Imagination	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
117	118	5	Louisiana Assoc	LA - Louisiana Association for Creative Minds	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
118	119	5	MAOM	MA - MAOM Association, Inc.	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	3
119	120	5	MCPS	MD - Maryland Creative Problem Solvers	t	f	f	t	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
120	121	5	Create ME	ME - Create ME	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
121	122	5	MICA	MI - Michigan Creativity Association	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
122	123	5	Minnesota DI	MN - Minnesota Destination Imagination	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
123	124	5	MOCA	MO - Missouri Creative Adventures	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
124	125	5	MAPS	MS - Mississippi Advanced Problem Solvers	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
125	126	5	MTCQ	MT - Montana Creativity Quest	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
126	127	5	NCDI	NC - North Carolina Destination Imagination	t	f	f	t	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
127	128	5	CND	ND - Creative North Dakota	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
128	129	5	N-CAPS	NE - Nebraska's Creative Association for Problem Solvers	t	f	f	t	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
129	130	5	NHDI	NH - NH Destination Imagination	t	f	f	t	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
130	131	5	NJOM	NJ - New Jersey OM Association	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
131	132	5	CPNM	NM - Creative Programs of New Mexico, Inc.	t	f	f	t	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
132	133	5	CA-Nevada	NV - Creative Association of Nevada	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
133	134	5	DI of NY	NY - Destination Imagination of New York	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
134	135	5	OH-Kids for Creativi	OH - Ohio Kids for Creativity	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
135	137	5	DI-Oregon	OR - Oregon Destination Imagination	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
136	138	5	PaCPS, Inc.	PA - Pennsylvania Creative Problem Solvers	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
137	139	5	RImagination	RI - RImagination	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
138	140	5	SCOOPS	SC - South Carolina Org Of Problem Solvers	t	f	f	t	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
139	141	5	Creativity-SD	SD - South Dakota Creativity Association	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
140	142	5	Tennessee Assoc.	TN - Tennessee Association, Inc.	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
141	144	5	Creativity Unlimited	UT - Creativity Unlimited of Utah, Inc.	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
142	145	5	DI VirginiA (DIVA)	VA - DI VirginiA (DIVA)	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	3
143	146	5	Creative Imagination	VT - Vermont Creative Imagination, Inc.	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
146	149	5	W. Virginia CAN	WV - W. Virginia Creative Adventures Network	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
147	150	5	WACY	WY - Wyoming Association for Creative Youth	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
148	153	5	BCOMA	BC - B.C. Original Minds Association	t	f	t	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
149	154	5	ON1 CP0	ON - Creative Programs of Ontario	t	f	t	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
151	159	5	Curacoa	Curacoa Creative Problem Solving Foundation	t	t	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
150	155	5	NWT	NW. TERR.	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	1
167	750	5	TXCPSO	TX - Texas Creative Problem Solving Organization	t	f	f	t	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	3
144	147	5	WIN	WA - Washington Imagination Network	t	f	f	t	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	3
168	108	5	Washington	DC - Washington	t	f	f	f	t	7	'01-15-03'	'01-15-03'	'01-15-03'	'01-15-03'	2
\.
-- Enable triggers

update affiliate set aff_to_do=0;


select setval('affiliate_aff_id_seq', 500);

insert into  region(reg_affiliate, reg_name) values(167, 'West Region');
insert into  region(reg_affiliate, reg_name) values(167, 'East Region');


insert into user_table(user_id, user_acc_name, user_password, user_contact, user_affiliate)
values(1, 'dave', '  mm9eT/HGCJU', 0, 167);

insert into role(role_user, role_affiliate, role_region, role_name, role_target_type, role_target)
values(1, 167, NULL, 3, 2, 167);

insert into user_table(user_id, user_acc_name, user_password, user_contact, user_affiliate, user_region)
values(2, 'rd',  '  mm9eT/HGCJU', 2, 167, 1);
insert into role(role_user, role_affiliate, role_region, role_name, role_target_type, role_target)
values(2, 167, 1, 5, 3, 1);


insert into user_table(user_id, user_acc_name, user_password, user_contact, user_affiliate)
values(3, 'hq',  '  mm9eT/HGCJU', 3, 0);

insert into role(role_user, role_affiliate, role_region, role_name, role_target_type, role_target)
values(3, 0, NULL, 6, NULL, NULL);

insert into user_table(user_id, user_acc_name, user_password, user_contact, user_affiliate)
values(4, 'ad',  '  mm9eT/HGCJU', 4, 167);
insert into role(role_user, role_affiliate, role_region, role_name, role_target_type, role_target)
values(4, 167, null, 4, 2, 167);

insert into user_table(user_id, user_acc_name, user_password, user_contact, user_affiliate)
values (5, 'dee', '  bM4r0Ht7jcM',   5,    167);
insert into role(role_user, role_affiliate, role_region, role_name, role_target_type, role_target)
values(5, 167, NULL, 3, 2, 167);



select setval('role_role_id_seq', 100);

select setval('user_table_user_id_seq', 100);

insert into products values(0, 'OnePak', '2002/3 One Pak', 'SKU123',
TRUE, '1',
TRUE, FALSE, FALSE,
TRUE, FALSE,
FALSE, FALSE,
TRUE,
100, 'AS', null);

insert into products values(1, 'FivePak', '2002/3 Five Pak', 'SKU124',
TRUE, '5',
TRUE, FALSE, FALSE,
TRUE, FALSE,
FALSE, FALSE,
TRUE,
175, 'AS', null);


insert into products values(2, 'Intl OnePak', '2002/3 One Pak (International)',
'SKU123I',
TRUE, '1',
TRUE, FALSE, FALSE,
FALSE, TRUE,
FALSE, FALSE,
TRUE,
80, 'AS', null);

insert into products values(3, 'Intl FivePak', '2002/3 Five Pak (International)', 'SKU124I',
TRUE, '5',
TRUE, FALSE, FALSE,
FALSE, TRUE,
FALSE, FALSE,
TRUE,
135, 'AS', null);

insert into products values(4, 'CD', 'Membership Materials on CD', 'SKU125',
TRUE, 'A',
TRUE, FALSE, FALSE,
TRUE, TRUE,
FALSE, FALSE,
TRUE,
0, 'S', null);

insert into products values(5, 'My Life', 'Book: Do or DI, A Memoir', 'SKU126',
TRUE, 'A',
TRUE, FALSE, FALSE,
TRUE, TRUE,
TRUE, FALSE,
TRUE,
15, 'S', null);

insert into products values(6, 'Upgrade', 'Upgrade OnePak to FivePak', 'SKU127',
TRUE, 'U',
FALSE, FALSE, FALSE,
TRUE, FALSE,
FALSE, FALSE,
TRUE,
85, 'U', null);

insert into products values(7, 'Intl Upgrade', 'Upgrade OnePak to FivePak (Intl)', 'SKU128',
TRUE, 'U',
FALSE, FALSE, FALSE,
FALSE, TRUE,
FALSE, FALSE,
TRUE,
55, 'U', null);

select setval('products_prd_id_seq', 100);

/*insert into aff_product values(0, 167, 1, 15);*/
/*insert into aff_product values(1, 167, 2, 1.23);*/
select setval('aff_product_afp_id_seq', 100);


insert into season values(2002);
insert into season values(2003);
insert into season values(2004);

insert into current_season values(2003);


INSERT INTO "challenge_desc" ("chd_id","chd_season","chd_primary_only",
"chd_levels","chd_name","_version")
VALUES (2,2003,'f',62,'A Change in DIrection', 2);

INSERT INTO "challenge_desc" ("chd_id","chd_season","chd_primary_only",
"chd_levels","chd_name","_version")
VALUES (6,2003,'t',0,'Lost and Found',4);

INSERT INTO "challenge_desc" ("chd_id","chd_season","chd_primary_only",
"chd_levels","chd_name","_version")
VALUES (3,2003,'f',62,'Once Improv a Time',2);

INSERT INTO "challenge_desc" ("chd_id","chd_season","chd_primary_only",
"chd_levels","chd_name","_version")
VALUES (5,2003,'f',62, 'Theater SmARTS', 2);

INSERT INTO "challenge_desc" ("chd_id","chd_season","chd_primary_only",
"chd_levels","chd_name","_version")
VALUES (1,2003,'f',62, 'viDIo Adventure', 18);

INSERT INTO "challenge_desc" ("chd_id","chd_season","chd_primary_only",
"chd_levels","chd_name","_version")
VALUES (4,2003,'f',30,'ConnecDId',3);

INSERT INTO "challenge_desc" ("chd_id","chd_season","chd_primary_only",
"chd_levels","chd_name","_version")
VALUES (7,2003,'f',32,'ConnecDId ( University/Military Version )',1);



INSERT INTO "challenge_download" ("cdl_id", "cdl_desc",cdl_pdf_path_1, "cdl_icon_url",
cdl_lang_1,  "_version")
VALUES (2,'Focus: Technical Design and Construction; Systems Integration; Teamwork\015\012\015\012The Destination: Where This Challenge Will Take You!\015\012The carpet you’re walking on may one day be a bumper on a car. The school bus you ride on could be turned\015\012into a catapult in a junkyard contest. Imagine the fun your team will have creating an original technical device\015\012that can be rebuilt into a second device which performs different functions than the first!\015\012Your team will design two different technical devices that can be built from a single set of parts to perform two\015\012different tasks. Your team will also design and build a transport system. During an eight-minute Presentation,\015\012your team will take apart the first device and then reconnect the parts as the second device. Before putting\015\012together the second technical device, you will use the transport system to move the pieces from one location to\015\012another along a path with a change in direction. Your team will also create an original story that includes a\015\012surprising change in direction. The story will tie together the devices, the tasks, the transformation from the first\015\012device to the second, and the transport system. Your team will integrate an Improv Element and three Side Trips\015\012into its Performance as well.','/tmp/f1.pdf','/images/changeindirectionthumb.jpg','English',2);

INSERT INTO "challenge_download" ("cdl_id", "cdl_desc",cdl_pdf_path_1, "cdl_icon_url",
cdl_lang_1,  "_version")
VALUES (6,'Focus: Storytelling; Map Skills; Multi-step Directions; Teamwork\015\012\015\012The Destination: Where This Challenge Will Take You!\015\012“Where are my glasses?” Grandma asks. “I’ve looked everywhere and I can’t find them.” “Look, Grandma!”\015\012you say as you laugh. “They’re on your forehead!”\015\012Have you ever lost something? How did you find it? Sometimes you need help to find things you have lost.\015\012Your team must present a story about how something is lost and how it is found again.\015\012Your team will make up a Play that tells a Story about how something is lost and how it is found. In the Story,\015\012some of the characters will work together to find what is lost by making a Plan. Your team will make a Map that\015\012you will use in your Story. Your team will also have two Side Trips in your Play.\015\012Note: This is a non-competitive Challenge for early elementary-aged children and will not be scored.','/tmp/f1.pdf','/images/lostandfoundthumb.jpg', 'English', 4);

INSERT INTO "challenge_download" ("cdl_id", "cdl_desc",cdl_pdf_path_1, "cdl_icon_url",
cdl_lang_1,  "_version")
VALUES (3,'Focus: Improvisation Techniques; Research; Theater Arts; Teamwork\015\012\015\012The Destination: Where this Challenge Will Take You!\015\012Once Improv a Time…Baby Bear ran from the Big Bad Wolf, and ended up in a candy factory, where he\015\012learned that running from your fears is like a box of chocolates – you never know what you’re going to get!\015\012Imagine the fun your team will have mixing up Literary Elements from a variety of different Classic Tales to\015\012create your own story.\015\012Your team will read and research ten Classic Tales from around the world and pick out some Literary Elements\015\012in each Classic Tale. Then, in a 30-minute time period at the Tournament your team will create a six-minute\015\012improvisational skit that combines a randomly chosen Surprise Setting with some of the randomly chosen\015\012Literary Elements to create an original story with a team-created Lesson Learned at the end. Your team will\015\012learn and practice Improvisational Techniques and use at least one in the skit. Also during the 30-minute period,\015\012your team will create a Unique Functional Object (UFO) and other items to be used in the skit using only tape\015\012and newspaper. Just before you perform for the audience, your team will also create a Phrase from three\015\012randomly selected letters of the alphabet and use it in the skit.','/tmp/f1.pdf','/images/onceimprovatimethumb.jpg', 'English', 2);

INSERT INTO "challenge_download" ("cdl_id", "cdl_desc",cdl_pdf_path_1, "cdl_icon_url",
cdl_lang_1,  "_version")
VALUES (5,'Focus: Theater Arts; Fine Arts; Teamwork\015\012\015\012The Destination: Where This Challenge Will Take You!\015\012Live performances have delighted audiences for centuries, and when everything doesn’t go according to the\015\012script, it just adds to the fun. Imagine how it must feel to be in the middle of your presentation when there is a\015\012DIsruption! Your own Troupe of Entertainers will give new meaning to the phrase, “the show must go on,”\015\012when you create your own Live Performance and display your “theater smarts” as you deal with the DIsruption.\015\012Your team will create an eight-minute Presentation that tells a Story about a Troupe of Entertainers and their\015\012Live Performance. The Story must include a scene in which the Entertainers are “in character” and put on a\015\012segment of their Live Performance. The Story must include a DIsruption that affects the Live Performance, and\015\012demonstrate how the Troupe of Entertainers continue despite the DIsruption. Your team will choose and\015\012integrate three (3) Elements of Theater Arts into your Presentation. As part of the Presentation, your team will\015\012include Scenery that moves or gives the illusion of movement. You will also integrate an Improv Element and\015\012three Side Trips into your Presentation.','/tmp/f1.pdf','/images/theatersmartsthumb.jpg', 'English', 2);

INSERT INTO "challenge_download" ("cdl_id", "cdl_desc",cdl_pdf_path_1, "cdl_icon_url",
cdl_lang_1,  "_version")
VALUES (1,'Focus: Technical Design; International Current Events; Theater Arts; Teamwork\015\012\015\012The Destination: Where This Challenge Will Take You!\015\012Searching for love? A cure for cancer? Or just the perfect cheeseburger? Imagine that you and your team\015\012members are the modern day heroes of your own viDIo Adventure game, on a Quest to other Nations.\015\012Your team will create an eight-minute Presentation that portrays a 3-Dimensional viDIo Adventure game. The\015\012game’s theme must tell a story of a modern day Quest which must be set in the recent past or present. You will\015\012design and build a Seeker that will go through three Nations, theatrically represented as Game Levels in the\015\012viDIo Game. At each Game Level, your Seeker must overcome an Obstacle and collect a Reward Item needed\015\012to triumph in the Quest. Your team will end the story using the Reward Items from each Nation. Your team will\015\012include an Improv Element and three Side Trips in the Presentation as well.','/tmp/f1.pdf','/images/vidioadventure.jpg', 'English', 18);

INSERT INTO "challenge_download" ("cdl_id", "cdl_desc",cdl_pdf_path_1, "cdl_icon_url",
cdl_lang_1,  "_version")
VALUES (4,'Focus: Structural Engineering and Construction; Theater Arts; Teamwork\015\012\015\012The Destination: Where This Challenge Will Take You!\015\012Nations are connected by technology and travel, by roadways and waterways, by bridges and tunnels. People are\015\012connected by our hopes, our fears, our dreams and our imaginations, and also by our cultures and our traditions.\015\012Imagine how the world would be different if you could build a magical Universal Connection Creation that\015\012would allow you to instantly make connections between people, nations, objects or events!\015\012Your team will have to find innovative and creative ways to make Connections between pieces of wood to solve\015\012this Challenge by designing, building, and testing a Structure made completely from Wood. No other materials,\015\012including glue, may be used. At the Tournament the Structure will be tested for its load-bearing efficiency by\015\012stacking weights on it. In addition, your team will create an eight-minute Presentation that tells the story of\015\012Connections devised and made by the team, using a Universal Connection Creation in multiple ways as a\015\012theatrical prop. Your team will integrate an Improv Element and three Side Trips into the Presentation as well.','/tmp/f1.pdf','/images/connecdidthumb.jpg', 'English', 3);

INSERT INTO "challenge_download" ("cdl_id", "cdl_desc",cdl_pdf_path_1, "cdl_icon_url",
cdl_lang_1,  "_version")
VALUES (7,'Focus: Structural Engineering and Construction; Theater Arts; Teamwork\015\012\015\012The Destination: Where This Challenge Will Take You!\015\012Nations are connected by technology and travel, by roadways and waterways, by bridges and tunnels. People are\015\012connected by our hopes, our fears, our dreams and our imaginations, and also by our cultures and our traditions.\015\012Imagine how the world would be different if you could build a magical Universal Connection Creation that\015\012would allow you to instantly make connections between people, nations, objects or events!\015\012Your team will have to find innovative and creative ways to make Connections between pieces of wood to solve\015\012this Challenge by designing, building, and testing a Structure made completely from Wood. No other materials,\015\012including glue, may be used. At the Tournament the Structure will be tested for its load-bearing efficiency by\015\012stacking weights on it. In addition, your team will create an eight-minute Presentation that tells the story of\015\012Connections devised and made by the team, using a Universal Connection Creation in multiple ways as a\015\012theatrical prop. Your team will integrate an Improv Element and three Side Trips into the Presentation as well.','/tmp/f1.pdf','/images/connecdidthumb.jpg', 'English', 1);



COPY "challenge"  FROM stdin;
1	0	1	-1	0
2	0	2	-1	0
3	0	3	-1	0
4	0	4	-1	0
5	0	5	-1	0
6	0	6	-1	0
7	0	7	-1	0
8	102	1	-1	0
9	102	2	-1	0
10	102	3	-1	0
11	102	4	-1	0
12	102	5	-1	0
13	102	6	-1	0
14	102	7	-1	0
15	103	1	-1	0
16	103	2	-1	0
17	103	3	-1	0
18	103	4	-1	0
19	103	5	-1	0
20	103	6	-1	0
21	103	7	-1	0
22	104	1	-1	0
23	104	2	-1	0
24	104	3	-1	0
25	104	4	-1	0
26	104	5	-1	0
27	104	6	-1	0
28	104	7	-1	0
29	105	1	-1	0
30	105	2	-1	0
31	105	3	-1	0
32	105	4	-1	0
33	105	5	-1	0
34	105	6	-1	0
35	105	7	-1	0
36	106	1	-1	0
37	106	2	-1	0
38	106	3	-1	0
39	106	4	-1	0
40	106	5	-1	0
41	106	6	-1	0
42	106	7	-1	0
43	107	1	-1	0
44	107	2	-1	0
45	107	3	-1	0
46	107	4	-1	0
47	107	5	-1	0
48	107	6	-1	0
49	107	7	-1	0
50	108	1	-1	0
51	108	2	-1	0
52	108	3	-1	0
53	108	4	-1	0
54	108	5	-1	0
55	108	6	-1	0
56	108	7	-1	0
57	109	1	-1	0
58	109	2	-1	0
59	109	3	-1	0
60	109	4	-1	0
61	109	5	-1	0
62	109	6	-1	0
63	109	7	-1	0
64	110	1	-1	0
65	110	2	-1	0
66	110	3	-1	0
67	110	4	-1	0
68	110	5	-1	0
69	110	6	-1	0
70	110	7	-1	0
71	111	1	-1	0
72	111	2	-1	0
73	111	3	-1	0
74	111	4	-1	0
75	111	5	-1	0
76	111	6	-1	0
77	111	7	-1	0
78	112	1	-1	0
79	112	2	-1	0
80	112	3	-1	0
81	112	4	-1	0
82	112	5	-1	0
83	112	6	-1	0
84	112	7	-1	0
85	113	1	-1	0
86	113	2	-1	0
87	113	3	-1	0
88	113	4	-1	0
89	113	5	-1	0
90	113	6	-1	0
91	113	7	-1	0
92	114	1	-1	0
93	114	2	-1	0
94	114	3	-1	0
95	114	4	-1	0
96	114	5	-1	0
97	114	6	-1	0
98	114	7	-1	0
99	115	1	-1	0
100	115	2	-1	0
101	115	3	-1	0
102	115	4	-1	0
103	115	5	-1	0
104	115	6	-1	0
105	115	7	-1	0
106	116	1	-1	0
107	116	2	-1	0
108	116	3	-1	0
109	116	4	-1	0
110	116	5	-1	0
111	116	6	-1	0
112	116	7	-1	0
113	117	1	-1	0
114	117	2	-1	0
115	117	3	-1	0
116	117	4	-1	0
117	117	5	-1	0
118	117	6	-1	0
119	117	7	-1	0
120	118	1	-1	0
121	118	2	-1	0
122	118	3	-1	0
123	118	4	-1	0
124	118	5	-1	0
125	118	6	-1	0
126	118	7	-1	0
127	119	1	-1	0
128	119	2	-1	0
129	119	3	-1	0
130	119	4	-1	0
131	119	5	-1	0
132	119	6	-1	0
133	119	7	-1	0
134	120	1	-1	0
135	120	2	-1	0
136	120	3	-1	0
137	120	4	-1	0
138	120	5	-1	0
139	120	6	-1	0
140	120	7	-1	0
141	121	1	-1	0
142	121	2	-1	0
143	121	3	-1	0
144	121	4	-1	0
145	121	5	-1	0
146	121	6	-1	0
147	121	7	-1	0
148	122	1	-1	0
149	122	2	-1	0
150	122	3	-1	0
151	122	4	-1	0
152	122	5	-1	0
153	122	6	-1	0
154	122	7	-1	0
155	123	1	-1	0
156	123	2	-1	0
157	123	3	-1	0
158	123	4	-1	0
159	123	5	-1	0
160	123	6	-1	0
161	123	7	-1	0
162	124	1	-1	0
163	124	2	-1	0
164	124	3	-1	0
165	124	4	-1	0
166	124	5	-1	0
167	124	6	-1	0
168	124	7	-1	0
169	125	1	-1	0
170	125	2	-1	0
171	125	3	-1	0
172	125	4	-1	0
173	125	5	-1	0
174	125	6	-1	0
175	125	7	-1	0
176	126	1	-1	0
177	126	2	-1	0
178	126	3	-1	0
179	126	4	-1	0
180	126	5	-1	0
181	126	6	-1	0
182	126	7	-1	0
183	127	1	-1	0
184	127	2	-1	0
185	127	3	-1	0
186	127	4	-1	0
187	127	5	-1	0
188	127	6	-1	0
189	127	7	-1	0
190	128	1	-1	0
191	128	2	-1	0
192	128	3	-1	0
193	128	4	-1	0
194	128	5	-1	0
195	128	6	-1	0
196	128	7	-1	0
197	129	1	-1	0
198	129	2	-1	0
199	129	3	-1	0
200	129	4	-1	0
201	129	5	-1	0
202	129	6	-1	0
203	129	7	-1	0
204	130	1	-1	0
205	130	2	-1	0
206	130	3	-1	0
207	130	4	-1	0
208	130	5	-1	0
209	130	6	-1	0
210	130	7	-1	0
211	131	1	-1	0
212	131	2	-1	0
213	131	3	-1	0
214	131	4	-1	0
215	131	5	-1	0
216	131	6	-1	0
217	131	7	-1	0
218	132	1	-1	0
219	132	2	-1	0
220	132	3	-1	0
221	132	4	-1	0
222	132	5	-1	0
223	132	6	-1	0
224	132	7	-1	0
225	133	1	-1	0
226	133	2	-1	0
227	133	3	-1	0
228	133	4	-1	0
229	133	5	-1	0
230	133	6	-1	0
231	133	7	-1	0
232	134	1	-1	0
233	134	2	-1	0
234	134	3	-1	0
235	134	4	-1	0
236	134	5	-1	0
237	134	6	-1	0
238	134	7	-1	0
239	135	1	-1	0
240	135	2	-1	0
241	135	3	-1	0
242	135	4	-1	0
243	135	5	-1	0
244	135	6	-1	0
245	135	7	-1	0
246	136	1	-1	0
247	136	2	-1	0
248	136	3	-1	0
249	136	4	-1	0
250	136	5	-1	0
251	136	6	-1	0
252	136	7	-1	0
253	137	1	-1	0
254	137	2	-1	0
255	137	3	-1	0
256	137	4	-1	0
257	137	5	-1	0
258	137	6	-1	0
259	137	7	-1	0
260	138	1	-1	0
261	138	2	-1	0
262	138	3	-1	0
263	138	4	-1	0
264	138	5	-1	0
265	138	6	-1	0
266	138	7	-1	0
267	139	1	-1	0
268	139	2	-1	0
269	139	3	-1	0
270	139	4	-1	0
271	139	5	-1	0
272	139	6	-1	0
273	139	7	-1	0
274	140	1	-1	0
275	140	2	-1	0
276	140	3	-1	0
277	140	4	-1	0
278	140	5	-1	0
279	140	6	-1	0
280	140	7	-1	0
281	141	1	-1	0
282	141	2	-1	0
283	141	3	-1	0
284	141	4	-1	0
285	141	5	-1	0
286	141	6	-1	0
287	141	7	-1	0
288	142	1	-1	0
289	142	2	-1	0
290	142	3	-1	0
291	142	4	-1	0
292	142	5	-1	0
293	142	6	-1	0
294	142	7	-1	0
295	143	1	-1	0
296	143	2	-1	0
297	143	3	-1	0
298	143	4	-1	0
299	143	5	-1	0
300	143	6	-1	0
301	143	7	-1	0
302	144	1	-1	0
303	144	2	-1	0
304	144	3	-1	0
305	144	4	-1	0
306	144	5	-1	0
307	144	6	-1	0
308	144	7	-1	0
309	145	1	-1	0
310	145	2	-1	0
311	145	3	-1	0
312	145	4	-1	0
313	145	5	-1	0
314	145	6	-1	0
315	145	7	-1	0
316	146	1	-1	0
317	146	2	-1	0
318	146	3	-1	0
319	146	4	-1	0
320	146	5	-1	0
321	146	6	-1	0
322	146	7	-1	0
323	147	1	-1	0
324	147	2	-1	0
325	147	3	-1	0
326	147	4	-1	0
327	147	5	-1	0
328	147	6	-1	0
329	147	7	-1	0
330	148	1	-1	0
331	148	2	-1	0
332	148	3	-1	0
333	148	4	-1	0
334	148	5	-1	0
335	148	6	-1	0
336	148	7	-1	0
337	149	1	-1	0
338	149	2	-1	0
339	149	3	-1	0
340	149	4	-1	0
341	149	5	-1	0
342	149	6	-1	0
343	149	7	-1	0
344	150	1	-1	0
345	150	2	-1	0
346	150	3	-1	0
347	150	4	-1	0
348	150	5	-1	0
349	150	6	-1	0
350	150	7	-1	0
351	151	1	-1	0
352	151	2	-1	0
353	151	3	-1	0
354	151	4	-1	0
355	151	5	-1	0
356	151	6	-1	0
357	151	7	-1	0
358	152	1	-1	0
359	152	2	-1	0
360	152	3	-1	0
361	152	4	-1	0
362	152	5	-1	0
363	152	6	-1	0
364	152	7	-1	0
365	153	1	-1	0
366	153	2	-1	0
367	153	3	-1	0
368	153	4	-1	0
369	153	5	-1	0
370	153	6	-1	0
371	153	7	-1	0
372	154	1	-1	0
373	154	2	-1	0
374	154	3	-1	0
375	154	4	-1	0
376	154	5	-1	0
377	154	6	-1	0
378	154	7	-1	0
379	155	1	-1	0
380	155	2	-1	0
381	155	3	-1	0
382	155	4	-1	0
383	155	5	-1	0
384	155	6	-1	0
385	155	7	-1	0
386	156	1	-1	0
387	156	2	-1	0
388	156	3	-1	0
389	156	4	-1	0
390	156	5	-1	0
391	156	6	-1	0
392	156	7	-1	0
393	157	1	-1	0
394	157	2	-1	0
395	157	3	-1	0
396	157	4	-1	0
397	157	5	-1	0
398	157	6	-1	0
399	157	7	-1	0
400	158	1	-1	0
401	158	2	-1	0
402	158	3	-1	0
403	158	4	-1	0
404	158	5	-1	0
405	158	6	-1	0
406	158	7	-1	0
407	159	1	-1	0
408	159	2	-1	0
409	159	3	-1	0
410	159	4	-1	0
411	159	5	-1	0
412	159	6	-1	0
413	159	7	-1	0
414	160	1	-1	0
415	160	2	-1	0
416	160	3	-1	0
417	160	4	-1	0
418	160	5	-1	0
419	160	6	-1	0
420	160	7	-1	0
421	161	1	-1	0
422	161	2	-1	0
423	161	3	-1	0
424	161	4	-1	0
425	161	5	-1	0
426	161	6	-1	0
427	161	7	-1	0
428	162	1	-1	0
429	162	2	-1	0
430	162	3	-1	0
431	162	4	-1	0
432	162	5	-1	0
433	162	6	-1	0
434	162	7	-1	0
435	163	1	-1	0
436	163	2	-1	0
437	163	3	-1	0
438	163	4	-1	0
439	163	5	-1	0
440	163	6	-1	0
441	163	7	-1	0
442	164	1	-1	0
443	164	2	-1	0
444	164	3	-1	0
445	164	4	-1	0
446	164	5	-1	0
447	164	6	-1	0
448	164	7	-1	0
449	165	1	-1	0
450	165	2	-1	0
451	165	3	-1	0
452	165	4	-1	0
453	165	5	-1	0
454	165	6	-1	0
455	165	7	-1	0
456	166	1	-1	0
457	166	2	-1	0
458	166	3	-1	0
459	166	4	-1	0
460	166	5	-1	0
461	166	6	-1	0
462	166	7	-1	0
463	167	1	-1	0
464	167	2	-1	0
465	167	3	-1	0
466	167	4	-1	0
467	167	5	-1	0
468	167	6	-1	0
469	167	7	-1	0
470	168	1	-1	0
471	168	2	-1	0
472	168	3	-1	0
473	168	4	-1	0
474	168	5	-1	0
475	168	6	-1	0
476	168	7	-1	0
477	169	1	-1	0
478	169	2	-1	0
479	169	3	-1	0
480	169	4	-1	0
481	169	5	-1	0
482	169	6	-1	0
483	169	7	-1	0
484	170	1	-1	0
485	170	2	-1	0
486	170	3	-1	0
487	170	4	-1	0
488	170	5	-1	0
489	170	6	-1	0
490	170	7	-1	0
491	171	1	-1	0
492	171	2	-1	0
493	171	3	-1	0
494	171	4	-1	0
495	171	5	-1	0
496	171	6	-1	0
497	171	7	-1	0
498	172	1	-1	0
499	172	2	-1	0
500	172	3	-1	0
501	172	4	-1	0
502	172	5	-1	0
503	172	6	-1	0
504	172	7	-1	0
505	173	1	-1	0
506	173	2	-1	0
507	173	3	-1	0
508	173	4	-1	0
509	173	5	-1	0
510	173	6	-1	0
511	173	7	-1	0
512	174	1	-1	0
513	174	2	-1	0
514	174	3	-1	0
515	174	4	-1	0
516	174	5	-1	0
517	174	6	-1	0
518	174	7	-1	0
519	175	1	-1	0
520	175	2	-1	0
521	175	3	-1	0
522	175	4	-1	0
523	175	5	-1	0
524	175	6	-1	0
525	175	7	-1	0
526	176	1	-1	0
527	176	2	-1	0
528	176	3	-1	0
529	176	4	-1	0
530	176	5	-1	0
531	176	6	-1	0
532	176	7	-1	0
533	177	1	-1	0
534	177	2	-1	0
535	177	3	-1	0
536	177	4	-1	0
537	177	5	-1	0
538	177	6	-1	0
539	177	7	-1	0
540	178	1	-1	0
541	178	2	-1	0
542	178	3	-1	0
543	178	4	-1	0
544	178	5	-1	0
545	178	6	-1	0
546	178	7	-1	0
\.



select setval('challenge_cha_id_seq', 1000);
