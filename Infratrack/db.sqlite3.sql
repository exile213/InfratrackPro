BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "auth_group" (
	"id"	integer NOT NULL,
	"name"	varchar(150) NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_group_permissions" (
	"id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	"permission_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "auth_permission" (
	"id"	integer NOT NULL,
	"content_type_id"	integer NOT NULL,
	"codename"	varchar(100) NOT NULL,
	"name"	varchar(255) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "auth_user" (
	"id"	integer NOT NULL,
	"password"	varchar(128) NOT NULL,
	"last_login"	datetime,
	"is_superuser"	bool NOT NULL,
	"username"	varchar(150) NOT NULL UNIQUE,
	"last_name"	varchar(150) NOT NULL,
	"email"	varchar(254) NOT NULL,
	"is_staff"	bool NOT NULL,
	"is_active"	bool NOT NULL,
	"date_joined"	datetime NOT NULL,
	"first_name"	varchar(150) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_user_groups" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "auth_user_user_permissions" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"permission_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "django_admin_log" (
	"id"	integer NOT NULL,
	"object_id"	text,
	"object_repr"	varchar(200) NOT NULL,
	"action_flag"	smallint unsigned NOT NULL CHECK("action_flag" >= 0),
	"change_message"	text NOT NULL,
	"content_type_id"	integer,
	"user_id"	integer NOT NULL,
	"action_time"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "django_content_type" (
	"id"	integer NOT NULL,
	"app_label"	varchar(100) NOT NULL,
	"model"	varchar(100) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "django_migrations" (
	"id"	integer NOT NULL,
	"app"	varchar(255) NOT NULL,
	"name"	varchar(255) NOT NULL,
	"applied"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "django_session" (
	"session_key"	varchar(40) NOT NULL,
	"session_data"	text NOT NULL,
	"expire_date"	datetime NOT NULL,
	PRIMARY KEY("session_key")
);
CREATE TABLE IF NOT EXISTS "frontend_agency" (
	"id"	integer NOT NULL,
	"name"	varchar(255) NOT NULL,
	"city"	varchar(255) NOT NULL,
	"coverage_area"	text NOT NULL,
	"contact_email"	varchar(254) NOT NULL,
	"contact_phone"	varchar(50) NOT NULL,
	"created_at"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "frontend_infrastructuremap" (
	"id"	integer NOT NULL,
	"road_name"	varchar(255) NOT NULL,
	"city"	varchar(255) NOT NULL,
	"province"	varchar(255) NOT NULL,
	"infrastructure_typ_text"	varchar(255) NOT NULL,
	"coordinates"	text NOT NULL,
	"created_at"	datetime NOT NULL,
	"assigned_agency_id"	bigint NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("assigned_agency_id") REFERENCES "frontend_agency"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "frontend_issuetype" (
	"id"	integer NOT NULL,
	"name"	varchar(255) NOT NULL,
	"description"	text NOT NULL,
	"created_at"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "frontend_report" (
	"id"	integer NOT NULL,
	"tracking_code"	varchar(100) NOT NULL,
	"description"	text NOT NULL,
	"photo_url"	text NOT NULL,
	"latitude"	decimal NOT NULL,
	"longitude"	decimal NOT NULL,
	"address"	text NOT NULL,
	"road_name"	varchar(255) NOT NULL,
	"status_report_status"	varchar(100) NOT NULL,
	"citizen_name"	varchar(255) NOT NULL,
	"citizen_email"	varchar(254) NOT NULL,
	"created_at"	datetime NOT NULL,
	"updated_at"	datetime NOT NULL,
	"assigned_agency_id"	bigint NOT NULL,
	"issue_type_id"	bigint NOT NULL,
	"road_type_id"	bigint NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("assigned_agency_id") REFERENCES "frontend_agency"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("issue_type_id") REFERENCES "frontend_issuetype"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("road_type_id") REFERENCES "frontend_roadtype"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "frontend_roadtype" (
	"id"	integer NOT NULL,
	"name"	varchar(255) NOT NULL,
	"description"	text NOT NULL,
	"created_at"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "frontend_roadtypeagencymapping" (
	"id"	integer NOT NULL,
	"jurisdiction_type"	varchar(50) NOT NULL,
	"created_at"	datetime NOT NULL,
	"agency_id"	bigint NOT NULL,
	"road_type_id"	bigint NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("agency_id") REFERENCES "frontend_agency"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("road_type_id") REFERENCES "frontend_roadtype"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "frontend_role" (
	"id"	integer NOT NULL,
	"name"	varchar(100) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "frontend_users" (
	"id"	integer NOT NULL,
	"username"	varchar(150) NOT NULL UNIQUE,
	"email"	varchar(254) NOT NULL UNIQUE,
	"password"	varchar(255) NOT NULL,
	"full_name"	varchar(255) NOT NULL,
	"is_active"	bool NOT NULL,
	"created_at"	datetime NOT NULL,
	"last_login"	datetime,
	"agency_id"	bigint,
	"role_user_id"	bigint NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("agency_id") REFERENCES "frontend_agency"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("role_user_id") REFERENCES "frontend_role"("id") DEFERRABLE INITIALLY DEFERRED
);
INSERT INTO "auth_permission" VALUES (1,1,'add_logentry','Can add log entry');
INSERT INTO "auth_permission" VALUES (2,1,'change_logentry','Can change log entry');
INSERT INTO "auth_permission" VALUES (3,1,'delete_logentry','Can delete log entry');
INSERT INTO "auth_permission" VALUES (4,1,'view_logentry','Can view log entry');
INSERT INTO "auth_permission" VALUES (5,2,'add_permission','Can add permission');
INSERT INTO "auth_permission" VALUES (6,2,'change_permission','Can change permission');
INSERT INTO "auth_permission" VALUES (7,2,'delete_permission','Can delete permission');
INSERT INTO "auth_permission" VALUES (8,2,'view_permission','Can view permission');
INSERT INTO "auth_permission" VALUES (9,3,'add_group','Can add group');
INSERT INTO "auth_permission" VALUES (10,3,'change_group','Can change group');
INSERT INTO "auth_permission" VALUES (11,3,'delete_group','Can delete group');
INSERT INTO "auth_permission" VALUES (12,3,'view_group','Can view group');
INSERT INTO "auth_permission" VALUES (13,4,'add_user','Can add user');
INSERT INTO "auth_permission" VALUES (14,4,'change_user','Can change user');
INSERT INTO "auth_permission" VALUES (15,4,'delete_user','Can delete user');
INSERT INTO "auth_permission" VALUES (16,4,'view_user','Can view user');
INSERT INTO "auth_permission" VALUES (17,5,'add_contenttype','Can add content type');
INSERT INTO "auth_permission" VALUES (18,5,'change_contenttype','Can change content type');
INSERT INTO "auth_permission" VALUES (19,5,'delete_contenttype','Can delete content type');
INSERT INTO "auth_permission" VALUES (20,5,'view_contenttype','Can view content type');
INSERT INTO "auth_permission" VALUES (21,6,'add_session','Can add session');
INSERT INTO "auth_permission" VALUES (22,6,'change_session','Can change session');
INSERT INTO "auth_permission" VALUES (23,6,'delete_session','Can delete session');
INSERT INTO "auth_permission" VALUES (24,6,'view_session','Can view session');
INSERT INTO "auth_permission" VALUES (25,7,'add_agency','Can add agency');
INSERT INTO "auth_permission" VALUES (26,7,'change_agency','Can change agency');
INSERT INTO "auth_permission" VALUES (27,7,'delete_agency','Can delete agency');
INSERT INTO "auth_permission" VALUES (28,7,'view_agency','Can view agency');
INSERT INTO "auth_permission" VALUES (29,8,'add_issuetype','Can add issue type');
INSERT INTO "auth_permission" VALUES (30,8,'change_issuetype','Can change issue type');
INSERT INTO "auth_permission" VALUES (31,8,'delete_issuetype','Can delete issue type');
INSERT INTO "auth_permission" VALUES (32,8,'view_issuetype','Can view issue type');
INSERT INTO "auth_permission" VALUES (33,9,'add_roadtype','Can add road type');
INSERT INTO "auth_permission" VALUES (34,9,'change_roadtype','Can change road type');
INSERT INTO "auth_permission" VALUES (35,9,'delete_roadtype','Can delete road type');
INSERT INTO "auth_permission" VALUES (36,9,'view_roadtype','Can view road type');
INSERT INTO "auth_permission" VALUES (37,10,'add_role','Can add role');
INSERT INTO "auth_permission" VALUES (38,10,'change_role','Can change role');
INSERT INTO "auth_permission" VALUES (39,10,'delete_role','Can delete role');
INSERT INTO "auth_permission" VALUES (40,10,'view_role','Can view role');
INSERT INTO "auth_permission" VALUES (41,11,'add_infrastructuremap','Can add infrastructure map');
INSERT INTO "auth_permission" VALUES (42,11,'change_infrastructuremap','Can change infrastructure map');
INSERT INTO "auth_permission" VALUES (43,11,'delete_infrastructuremap','Can delete infrastructure map');
INSERT INTO "auth_permission" VALUES (44,11,'view_infrastructuremap','Can view infrastructure map');
INSERT INTO "auth_permission" VALUES (45,12,'add_report','Can add report');
INSERT INTO "auth_permission" VALUES (46,12,'change_report','Can change report');
INSERT INTO "auth_permission" VALUES (47,12,'delete_report','Can delete report');
INSERT INTO "auth_permission" VALUES (48,12,'view_report','Can view report');
INSERT INTO "auth_permission" VALUES (49,13,'add_user','Can add user');
INSERT INTO "auth_permission" VALUES (50,13,'change_user','Can change user');
INSERT INTO "auth_permission" VALUES (51,13,'delete_user','Can delete user');
INSERT INTO "auth_permission" VALUES (52,13,'view_user','Can view user');
INSERT INTO "auth_permission" VALUES (53,13,'add_users','Can add users');
INSERT INTO "auth_permission" VALUES (54,13,'change_users','Can change users');
INSERT INTO "auth_permission" VALUES (55,13,'delete_users','Can delete users');
INSERT INTO "auth_permission" VALUES (56,13,'view_users','Can view users');
INSERT INTO "auth_permission" VALUES (57,14,'add_roadtypeagencymapping','Can add road type agency mapping');
INSERT INTO "auth_permission" VALUES (58,14,'change_roadtypeagencymapping','Can change road type agency mapping');
INSERT INTO "auth_permission" VALUES (59,14,'delete_roadtypeagencymapping','Can delete road type agency mapping');
INSERT INTO "auth_permission" VALUES (60,14,'view_roadtypeagencymapping','Can view road type agency mapping');
INSERT INTO "auth_user" VALUES (1,'pbkdf2_sha256$1000000$DwAZsuK46CI4Av3HMiOwSH$UBDdUBkVrFReQd0ynNHLeI9CrbLpUgz0d1pXi+QRoeU=','2025-06-01 16:12:21.770386',1,'admin','','runeskater27@gmail.com',1,1,'2025-05-31 04:39:55.439659','');
INSERT INTO "django_admin_log" VALUES (1,'1','dpwh_john',3,'',13,1,'2025-06-01 08:37:55.223106');
INSERT INTO "django_admin_log" VALUES (2,'2','ceo_maria',3,'',13,1,'2025-06-01 08:37:58.943577');
INSERT INTO "django_admin_log" VALUES (3,'3','dpwh',3,'',13,1,'2025-06-01 08:38:03.466548');
INSERT INTO "django_admin_log" VALUES (4,'4','city_engineering_office',3,'',13,1,'2025-06-01 08:38:06.428261');
INSERT INTO "django_admin_log" VALUES (5,'3','DPWH',3,'',7,1,'2025-06-01 09:06:20.206919');
INSERT INTO "django_admin_log" VALUES (6,'4','City Engineering Office',3,'',7,1,'2025-06-01 09:06:24.027303');
INSERT INTO "django_admin_log" VALUES (7,'16','REP-20250602-42d9bbcb - Pothole',2,'[{"changed": {"fields": ["Description", "Assigned agency", "Road type"]}}]',12,1,'2025-06-01 16:12:51.170717');
INSERT INTO "django_content_type" VALUES (1,'admin','logentry');
INSERT INTO "django_content_type" VALUES (2,'auth','permission');
INSERT INTO "django_content_type" VALUES (3,'auth','group');
INSERT INTO "django_content_type" VALUES (4,'auth','user');
INSERT INTO "django_content_type" VALUES (5,'contenttypes','contenttype');
INSERT INTO "django_content_type" VALUES (6,'sessions','session');
INSERT INTO "django_content_type" VALUES (7,'frontend','agency');
INSERT INTO "django_content_type" VALUES (8,'frontend','issuetype');
INSERT INTO "django_content_type" VALUES (9,'frontend','roadtype');
INSERT INTO "django_content_type" VALUES (10,'frontend','role');
INSERT INTO "django_content_type" VALUES (11,'frontend','infrastructuremap');
INSERT INTO "django_content_type" VALUES (12,'frontend','report');
INSERT INTO "django_content_type" VALUES (13,'frontend','users');
INSERT INTO "django_content_type" VALUES (14,'frontend','roadtypeagencymapping');
INSERT INTO "django_migrations" VALUES (1,'contenttypes','0001_initial','2025-05-30 23:55:55.565096');
INSERT INTO "django_migrations" VALUES (2,'auth','0001_initial','2025-05-30 23:55:55.631947');
INSERT INTO "django_migrations" VALUES (3,'admin','0001_initial','2025-05-30 23:55:55.690337');
INSERT INTO "django_migrations" VALUES (4,'admin','0002_logentry_remove_auto_add','2025-05-30 23:55:55.811376');
INSERT INTO "django_migrations" VALUES (5,'admin','0003_logentry_add_action_flag_choices','2025-05-30 23:55:55.840733');
INSERT INTO "django_migrations" VALUES (6,'contenttypes','0002_remove_content_type_name','2025-05-30 23:55:55.882015');
INSERT INTO "django_migrations" VALUES (7,'auth','0002_alter_permission_name_max_length','2025-05-30 23:55:55.912695');
INSERT INTO "django_migrations" VALUES (8,'auth','0003_alter_user_email_max_length','2025-05-30 23:55:55.957905');
INSERT INTO "django_migrations" VALUES (9,'auth','0004_alter_user_username_opts','2025-05-30 23:55:55.976922');
INSERT INTO "django_migrations" VALUES (10,'auth','0005_alter_user_last_login_null','2025-05-30 23:55:56.009653');
INSERT INTO "django_migrations" VALUES (11,'auth','0006_require_contenttypes_0002','2025-05-30 23:55:56.019790');
INSERT INTO "django_migrations" VALUES (12,'auth','0007_alter_validators_add_error_messages','2025-05-30 23:55:56.040910');
INSERT INTO "django_migrations" VALUES (13,'auth','0008_alter_user_username_max_length','2025-05-30 23:55:56.076694');
INSERT INTO "django_migrations" VALUES (14,'auth','0009_alter_user_last_name_max_length','2025-05-30 23:55:56.122585');
INSERT INTO "django_migrations" VALUES (15,'auth','0010_alter_group_name_max_length','2025-05-30 23:55:56.164638');
INSERT INTO "django_migrations" VALUES (16,'auth','0011_update_proxy_permissions','2025-05-30 23:55:56.194454');
INSERT INTO "django_migrations" VALUES (17,'auth','0012_alter_user_first_name_max_length','2025-05-30 23:55:56.232262');
INSERT INTO "django_migrations" VALUES (18,'frontend','0001_initial','2025-05-30 23:55:56.321873');
INSERT INTO "django_migrations" VALUES (19,'sessions','0001_initial','2025-05-30 23:55:56.356930');
INSERT INTO "django_migrations" VALUES (20,'frontend','0002_rename_user_users','2025-05-31 16:41:10.000590');
INSERT INTO "django_migrations" VALUES (21,'frontend','0003_roadtypeagencymapping','2025-06-01 14:56:24.493264');
INSERT INTO "django_session" VALUES ('c478iha53t7kqkm4uhibzmkrc6mh0717','.eJxVjEEOwiAQRe_C2hAGUia4dO8ZyMAMUjUlKe2q8e6GpAvd_vfeP1Skfatx77LGmdVVgbr8bonyS5YB-EnLo-nclm2dkx6KPmnX98byvp3u30GlXkftsjFgsDA5wCKQbPZsCiBJCIHAYkLLwgVCnpKF4DFYlybrkVGy-nwB7Dc3_g:1uLlIL:4r9R_UCu_u_e6fvREz6j9kkViQnj_j6BatNTWD6xhD4','2025-06-15 16:12:21.776386');
INSERT INTO "frontend_agency" VALUES (5,'DPWH District 1','','National Roads District 1','dpwh1@gmail.com','1234567890','2025-06-01 08:16:12.229486');
INSERT INTO "frontend_agency" VALUES (6,'DPWH District 5','','National Roads District 5','dpwh5@gmail.com','1234567891','2025-06-01 08:16:12.236021');
INSERT INTO "frontend_agency" VALUES (7,'City Engineer of Victorias','Victorias','Victorias City','victorias.engineer@gmail.com','1234567892','2025-06-01 08:16:12.239021');
INSERT INTO "frontend_agency" VALUES (8,'City Engineer of Silay','Silay','Silay City','silay.engineer@gmail.com','1234567893','2025-06-01 08:16:12.241533');
INSERT INTO "frontend_agency" VALUES (9,'City Engineer of Talisay','Talisay','Talisay City','talisay.engineer@gmail.com','1234567894','2025-06-01 08:16:12.246047');
INSERT INTO "frontend_agency" VALUES (10,'City Engineer of Bacolod','Bacolod','Bacolod City','bacolod.engineer@gmail.com','1234567895','2025-06-01 08:16:12.248045');
INSERT INTO "frontend_issuetype" VALUES (5,'Pothole','Description for Pothole','2025-05-31 16:43:06.637106');
INSERT INTO "frontend_issuetype" VALUES (6,'Drainage Blockage','Description for Drainage Blockage','2025-05-31 16:43:06.640897');
INSERT INTO "frontend_issuetype" VALUES (7,'Faded Markings','Description for Faded Markings','2025-05-31 16:43:06.643902');
INSERT INTO "frontend_issuetype" VALUES (8,'Broken Signage','Description for Broken Signage','2025-05-31 16:43:06.646875');
INSERT INTO "frontend_report" VALUES (1,'TRK2846','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Zone 4','Narra St.','resolved','Test Citizen','citizen@example.com','2025-05-31 16:43:06.675775','2025-05-31 16:43:06.675775',5,5,5);
INSERT INTO "frontend_report" VALUES (2,'TRK2182','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Main Ave','Brgy. San Jose','pending','Test Citizen','citizen@example.com','2025-05-31 16:43:06.681786','2025-05-31 16:43:06.681786',5,5,6);
INSERT INTO "frontend_report" VALUES (3,'TRK9574','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Narra St.','Zone 4','in_progress','Test Citizen','citizen@example.com','2025-05-31 16:43:06.686301','2025-05-31 16:43:06.686301',5,7,5);
INSERT INTO "frontend_report" VALUES (4,'TRK1259','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Brgy. San Jose','Narra St.','resolved','Test Citizen','citizen@example.com','2025-05-31 16:43:06.690300','2025-05-31 16:43:06.690300',5,5,5);
INSERT INTO "frontend_report" VALUES (5,'TRK4276','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Zone 4','Narra St.','in_progress','Test Citizen','citizen@example.com','2025-05-31 16:43:06.693300','2025-05-31 16:43:06.693300',5,5,4);
INSERT INTO "frontend_report" VALUES (6,'TRK9377','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Narra St.','Main Ave','resolved','Test Citizen','citizen@example.com','2025-05-31 16:43:06.698816','2025-05-31 16:43:06.698816',5,8,4);
INSERT INTO "frontend_report" VALUES (7,'TRK9788','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Zone 4','Narra St.','resolved','Test Citizen','citizen@example.com','2025-05-31 16:43:06.702812','2025-05-31 16:43:06.702812',5,7,6);
INSERT INTO "frontend_report" VALUES (8,'TRK8925','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Pine Rd.','Zone 4','pending','Test Citizen','citizen@example.com','2025-05-31 16:43:06.707864','2025-05-31 16:43:06.707864',5,7,4);
INSERT INTO "frontend_report" VALUES (9,'TRK7221','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Pine Rd.','Pine Rd.','resolved','Test Citizen','citizen@example.com','2025-05-31 16:43:06.711844','2025-05-31 16:43:06.711844',5,5,5);
INSERT INTO "frontend_report" VALUES (10,'TRK7353','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Main Ave','Narra St.','pending','Test Citizen','citizen@example.com','2025-05-31 16:43:06.715347','2025-05-31 16:43:06.715347',5,6,6);
INSERT INTO "frontend_report" VALUES (11,'REP-20250601-5d1bd5ac','pothole','/media/reports/REP-20250601-5d1bd5ac_Screenshot%202024-09-06%20174956.png',10.7184128,122.9717504,'Don Mariano Lacson Highway, Zone 15, Talisay, Negros Occidental','Don Mariano Lacson Highway','Pending','Emil Joaquin Diaz','diaz@gmail.com','2025-05-31 17:32:42.351558','2025-05-31 17:32:42.351558',5,5,5);
INSERT INTO "frontend_report" VALUES (12,'REP-20250601-1935ee1f','pothole','/media/reports/REP-20250601-1935ee1f_Screenshot%202024-09-06%20174956.png',10.7184128,122.9717504,'Don Mariano Lacson Highway, Zone 15, Talisay, Negros Occidental','Don Mariano Lacson Highway','Pending','Emil Joaquin Diaz','diaz@gmail.com','2025-05-31 17:32:42.528530','2025-05-31 17:32:42.528530',5,5,5);
INSERT INTO "frontend_report" VALUES (13,'REP-20250601-abd88dc8','pothole for city engineer ','/media/reports/REP-20250601-abd88dc8_Screenshot%202024-09-13%20232541.png',10.7949253192445,122.981166243553,'Doctor Triño Montinola Street, Barangay IV, Silay, Negros Occidental','Doctor Triño Montinola Street','Pending','EMIL JOAQUIN HINOLAN','diaz@gmail.com','2025-06-01 15:25:00.999621','2025-06-01 15:25:00.999621',8,5,11);
INSERT INTO "frontend_report" VALUES (14,'REP-20250601-bf94ea8d','pothole for city engineer ','/media/reports/REP-20250601-bf94ea8d_Screenshot%202024-09-13%20232541.png',10.7949253192445,122.981166243553,'Doctor Triño Montinola Street, Barangay IV, Silay, Negros Occidental','Doctor Triño Montinola Street','Pending','EMIL JOAQUIN HINOLAN','diaz@gmail.com','2025-06-01 15:25:03.438280','2025-06-01 15:25:03.438280',8,5,11);
INSERT INTO "frontend_report" VALUES (15,'REP-20250601-f5236de5','pothole in main road of victorias','/media/reports/REP-20250601-f5236de5_Screenshot%202024-09-13%20231841.png',10.9005072552478,123.069743514061,'Osmeña Avenue, , Victorias, Negros Occidental','Osmeña Avenue','Pending','EMIL JOAQUIN HINOLAN','diaz@gmail.com','2025-06-01 15:49:47.493387','2025-06-01 15:49:47.493387',7,6,12);
INSERT INTO "frontend_report" VALUES (16,'REP-20250602-42d9bbcb','pothole silay','/media/reports/REP-20250602-42d9bbcb_Blippar-Workspace.png',10.8025074,122.9775394,'Rizal Street, Barangay II, Silay, Negros Occidental','Antonio Luna Street','Pending','Emil Diaz','diaz@gmail.com','2025-06-01 16:10:31.319193','2025-06-01 16:12:51.164722',5,5,9);
INSERT INTO "frontend_report" VALUES (17,'REP-20250602-bdbe62e1','pothole there ','/media/reports/REP-20250602-bdbe62e1_Screenshot%202024-11-04%20101631.png',10.897810052852,123.066283464432,'Osmeña Avenue, , Victorias, Negros Occidental','Osmeña Avenue','Pending','Emil Joaquin Diaz','diaz@gmail.com','2025-06-01 16:38:45.491506','2025-06-01 16:38:45.491506',5,5,9);
INSERT INTO "frontend_roadtype" VALUES (4,'Concrete','Description for Concrete road','2025-05-31 16:43:06.650870');
INSERT INTO "frontend_roadtype" VALUES (5,'Asphalt','Description for Asphalt road','2025-05-31 16:43:06.656388');
INSERT INTO "frontend_roadtype" VALUES (6,'Gravel','Description for Gravel road','2025-05-31 16:43:06.660377');
INSERT INTO "frontend_roadtype" VALUES (7,'motorway','Major highways, expressways, and freeways','2025-06-01 14:56:37.885866');
INSERT INTO "frontend_roadtype" VALUES (8,'trunk','Major roads, often connecting cities','2025-06-01 14:56:37.893925');
INSERT INTO "frontend_roadtype" VALUES (9,'primary','Primary roads, major arterial routes','2025-06-01 14:56:37.899141');
INSERT INTO "frontend_roadtype" VALUES (10,'secondary','Secondary roads, connecting primary roads','2025-06-01 14:56:37.905657');
INSERT INTO "frontend_roadtype" VALUES (11,'tertiary','Tertiary roads, connecting secondary roads','2025-06-01 14:56:37.915719');
INSERT INTO "frontend_roadtype" VALUES (12,'residential','Residential streets and local roads','2025-06-01 14:56:37.928287');
INSERT INTO "frontend_roadtype" VALUES (13,'service','Service roads, access roads','2025-06-01 14:56:37.937948');
INSERT INTO "frontend_roadtype" VALUES (14,'unclassified','Unclassified roads','2025-06-01 14:56:37.949522');
INSERT INTO "frontend_roadtype" VALUES (15,'living_street','Living streets, pedestrian priority','2025-06-01 14:56:37.959592');
INSERT INTO "frontend_roadtypeagencymapping" VALUES (1,'national','2025-06-01 14:56:39.023653',5,4);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (2,'national','2025-06-01 14:56:39.023653',5,5);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (3,'national','2025-06-01 14:56:39.023653',5,6);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (4,'national','2025-06-01 14:56:39.023653',5,7);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (5,'national','2025-06-01 14:56:39.023653',5,8);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (6,'national','2025-06-01 14:56:39.023653',5,9);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (7,'national','2025-06-01 14:56:39.023653',5,10);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (8,'national','2025-06-01 14:56:39.023653',5,11);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (9,'national','2025-06-01 14:56:39.023653',5,12);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (10,'national','2025-06-01 14:56:39.023653',5,13);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (11,'national','2025-06-01 14:56:39.023653',5,14);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (12,'national','2025-06-01 14:56:39.023653',5,15);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (13,'city','2025-06-01 14:56:39.023653',7,4);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (14,'city','2025-06-01 14:56:39.023653',7,5);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (15,'city','2025-06-01 14:56:39.023653',7,6);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (16,'city','2025-06-01 14:56:39.023653',7,7);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (17,'city','2025-06-01 14:56:39.023653',7,8);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (18,'city','2025-06-01 14:56:39.023653',7,9);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (19,'city','2025-06-01 14:56:39.023653',7,10);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (20,'city','2025-06-01 14:56:39.023653',7,11);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (21,'city','2025-06-01 14:56:39.023653',7,12);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (22,'city','2025-06-01 14:56:39.023653',7,13);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (23,'city','2025-06-01 14:56:39.023653',7,14);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (24,'city','2025-06-01 14:56:39.023653',7,15);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (25,'city','2025-06-01 14:56:39.023653',8,4);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (26,'city','2025-06-01 14:56:39.023653',8,5);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (27,'city','2025-06-01 14:56:39.023653',8,6);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (28,'city','2025-06-01 14:56:39.023653',8,7);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (29,'city','2025-06-01 14:56:39.023653',8,8);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (30,'city','2025-06-01 14:56:39.023653',8,9);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (31,'city','2025-06-01 14:56:39.023653',8,10);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (32,'city','2025-06-01 14:56:39.023653',8,11);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (33,'city','2025-06-01 14:56:39.023653',8,12);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (34,'city','2025-06-01 14:56:39.023653',8,13);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (35,'city','2025-06-01 14:56:39.023653',8,14);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (36,'city','2025-06-01 14:56:39.023653',8,15);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (37,'city','2025-06-01 14:56:39.023653',9,4);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (38,'city','2025-06-01 14:56:39.023653',9,5);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (39,'city','2025-06-01 14:56:39.023653',9,6);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (40,'city','2025-06-01 14:56:39.023653',9,7);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (41,'city','2025-06-01 14:56:39.023653',9,8);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (42,'city','2025-06-01 14:56:39.023653',9,9);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (43,'city','2025-06-01 14:56:39.023653',9,10);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (44,'city','2025-06-01 14:56:39.023653',9,11);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (45,'city','2025-06-01 14:56:39.023653',9,12);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (46,'city','2025-06-01 14:56:39.023653',9,13);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (47,'city','2025-06-01 14:56:39.023653',9,14);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (48,'city','2025-06-01 14:56:39.023653',9,15);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (49,'city','2025-06-01 14:56:39.023653',10,4);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (50,'city','2025-06-01 14:56:39.023653',10,5);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (51,'city','2025-06-01 14:56:39.023653',10,6);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (52,'city','2025-06-01 14:56:39.023653',10,7);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (53,'city','2025-06-01 14:56:39.023653',10,8);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (54,'city','2025-06-01 14:56:39.023653',10,9);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (55,'city','2025-06-01 14:56:39.023653',10,10);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (56,'city','2025-06-01 14:56:39.023653',10,11);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (57,'city','2025-06-01 14:56:39.023653',10,12);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (58,'city','2025-06-01 14:56:39.023653',10,13);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (59,'city','2025-06-01 14:56:39.023653',10,14);
INSERT INTO "frontend_roadtypeagencymapping" VALUES (60,'city','2025-06-01 14:56:39.023653',10,15);
INSERT INTO "frontend_role" VALUES (4,'Admin');
INSERT INTO "frontend_role" VALUES (5,'Agency Staff');
INSERT INTO "frontend_role" VALUES (6,'Citizen');
INSERT INTO "frontend_role" VALUES (7,'Agency Admin');
INSERT INTO "frontend_users" VALUES (5,'dpwh_district_1','dpwh1@gmail.com','defaultpassword123','DPWH District 1',1,'2025-06-01 08:23:26.907165',NULL,5,7);
INSERT INTO "frontend_users" VALUES (6,'dpwh_district_5','dpwh5@gmail.com
','pbkdf2_sha256$1000000$eTbMfie5MLH1qmHRJBS2A8$5CU2liNxGiJTnBBQXGhvNM+c/Isf1IbdNKtjGbVgNeU=','DPWH District 5',1,'2025-06-01 08:23:27.274907',NULL,6,7);
INSERT INTO "frontend_users" VALUES (7,'city_engineer_of_victorias','victorias.engineer@gmail.com','pbkdf2_sha256$1000000$sSOxhyLqbLvfbPx3LJ2kmZ$WPudoCfJXuZXucxWNkv4c7Xu7MfsHCr7nuAlHeO9K3A=','City Engineer of Victorias',1,'2025-06-01 08:23:27.640587',NULL,7,7);
INSERT INTO "frontend_users" VALUES (8,'city_engineer_of_silay','silay.engineer@gmail.com','pbkdf2_sha256$1000000$5E8UZV38MhjxZTg8DOjy13$K7VRFe9ttmMHZLm9nkhxyHZGVtz0K/vUc4Fj6wm2zZE=','City Engineer of Silay',1,'2025-06-01 08:23:28.003664',NULL,8,7);
INSERT INTO "frontend_users" VALUES (9,'city_engineer_of_talisay','talisay.engineer@gmail.com','pbkdf2_sha256$1000000$znp092CBmBou3ooYdNZUSX$/gGLWWXc6Uq/PcHDxyi5oTREyBYpHor+HETkcwh31xk=','City Engineer of Talisay',1,'2025-06-01 08:23:28.373588',NULL,9,7);
INSERT INTO "frontend_users" VALUES (10,'city_engineer_of_bacolod','bacolod.engineer@gmail.com','pbkdf2_sha256$1000000$ZGpEaXi0NvRK0M3aT3v4k4$wjvZ26T576aiCzcstUtlwxX80dyAgWtzMlQJmAR/20g=','City Engineer of Bacolod',1,'2025-06-01 08:23:28.751438',NULL,10,7);
CREATE INDEX IF NOT EXISTS "auth_group_permissions_group_id_b120cbf9" ON "auth_group_permissions" (
	"group_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_group_permissions_group_id_permission_id_0cd325b0_uniq" ON "auth_group_permissions" (
	"group_id",
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_group_permissions_permission_id_84c5c92e" ON "auth_group_permissions" (
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_permission_content_type_id_2f476e4b" ON "auth_permission" (
	"content_type_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_permission_content_type_id_codename_01ab375a_uniq" ON "auth_permission" (
	"content_type_id",
	"codename"
);
CREATE INDEX IF NOT EXISTS "auth_user_groups_group_id_97559544" ON "auth_user_groups" (
	"group_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_groups_user_id_6a12ed8b" ON "auth_user_groups" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_user_groups_user_id_group_id_94350c0c_uniq" ON "auth_user_groups" (
	"user_id",
	"group_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_user_permissions_permission_id_1fbb5f2c" ON "auth_user_user_permissions" (
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_user_permissions_user_id_a95ead1b" ON "auth_user_user_permissions" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_user_user_permissions_user_id_permission_id_14a6b632_uniq" ON "auth_user_user_permissions" (
	"user_id",
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "django_admin_log_content_type_id_c4bce8eb" ON "django_admin_log" (
	"content_type_id"
);
CREATE INDEX IF NOT EXISTS "django_admin_log_user_id_c564eba6" ON "django_admin_log" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "django_content_type_app_label_model_76bd3d3b_uniq" ON "django_content_type" (
	"app_label",
	"model"
);
CREATE INDEX IF NOT EXISTS "django_session_expire_date_a5c62663" ON "django_session" (
	"expire_date"
);
CREATE INDEX IF NOT EXISTS "frontend_infrastructuremap_assigned_agency_id_3166a00b" ON "frontend_infrastructuremap" (
	"assigned_agency_id"
);
CREATE INDEX IF NOT EXISTS "frontend_report_assigned_agency_id_cfec75f6" ON "frontend_report" (
	"assigned_agency_id"
);
CREATE INDEX IF NOT EXISTS "frontend_report_issue_type_id_e40c7fcd" ON "frontend_report" (
	"issue_type_id"
);
CREATE INDEX IF NOT EXISTS "frontend_report_road_type_id_06577123" ON "frontend_report" (
	"road_type_id"
);
CREATE INDEX IF NOT EXISTS "frontend_roadtypeagencymapping_agency_id_d402f4d3" ON "frontend_roadtypeagencymapping" (
	"agency_id"
);
CREATE INDEX IF NOT EXISTS "frontend_roadtypeagencymapping_road_type_id_4dfa9039" ON "frontend_roadtypeagencymapping" (
	"road_type_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "frontend_roadtypeagencymapping_road_type_id_agency_id_jurisdiction_type_98e1f18d_uniq" ON "frontend_roadtypeagencymapping" (
	"road_type_id",
	"agency_id",
	"jurisdiction_type"
);
CREATE INDEX IF NOT EXISTS "frontend_user_agency_id_a00ce96f" ON "frontend_users" (
	"agency_id"
);
CREATE INDEX IF NOT EXISTS "frontend_user_role_user_id_08df9b3f" ON "frontend_users" (
	"role_user_id"
);
COMMIT;
