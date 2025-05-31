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
INSERT INTO "auth_user" VALUES (1,'pbkdf2_sha256$1000000$DwAZsuK46CI4Av3HMiOwSH$UBDdUBkVrFReQd0ynNHLeI9CrbLpUgz0d1pXi+QRoeU=','2025-05-31 04:51:29.505147',1,'admin','','runeskater27@gmail.com',1,1,'2025-05-31 04:39:55.439659','');
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
INSERT INTO "django_session" VALUES ('zqlp47ai63l4vu1l87709os8ew3atzci','.eJxVjssKwjAQRX9FspaQSWlD3OnelR8QJsmkadVE-kBE_HcbLKK74d5zD_NkBucpmnmkwXSe7Riw7W9m0Z0plcL3mNrMXU7T0FleEL62Iz9mT5fDyv4JIo6xrCsnBAgVPFagAoGVrvEigELSWiNIZZX05ANoV1sJulFaVraWjfKK3CL9_gifO-GVivl2j6bPMS3IkC8l2reU3GNzmjAE9noDfQhK3g:1uLPUz:FOdho8cKVMl-0NMsvD21929RPd70qT7j6cymWEuqq68','2025-06-14 16:55:57.469356');
INSERT INTO "frontend_agency" VALUES (3,'DPWH','Manila','Metro Manila','dpwh@example.com','123-456-7890','2025-05-31 16:43:06.628501');
INSERT INTO "frontend_agency" VALUES (4,'City Engineering Office','Manila','Manila City','ceo@example.com','098-765-4321','2025-05-31 16:43:06.632498');
INSERT INTO "frontend_issuetype" VALUES (5,'Pothole','Description for Pothole','2025-05-31 16:43:06.637106');
INSERT INTO "frontend_issuetype" VALUES (6,'Drainage Blockage','Description for Drainage Blockage','2025-05-31 16:43:06.640897');
INSERT INTO "frontend_issuetype" VALUES (7,'Faded Markings','Description for Faded Markings','2025-05-31 16:43:06.643902');
INSERT INTO "frontend_issuetype" VALUES (8,'Broken Signage','Description for Broken Signage','2025-05-31 16:43:06.646875');
INSERT INTO "frontend_report" VALUES (1,'TRK2846','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Zone 4','Narra St.','resolved','Test Citizen','citizen@example.com','2025-05-31 16:43:06.675775','2025-05-31 16:43:06.675775',4,5,5);
INSERT INTO "frontend_report" VALUES (2,'TRK2182','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Main Ave','Brgy. San Jose','pending','Test Citizen','citizen@example.com','2025-05-31 16:43:06.681786','2025-05-31 16:43:06.681786',4,5,6);
INSERT INTO "frontend_report" VALUES (3,'TRK9574','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Narra St.','Zone 4','in_progress','Test Citizen','citizen@example.com','2025-05-31 16:43:06.686301','2025-05-31 16:43:06.686301',3,7,5);
INSERT INTO "frontend_report" VALUES (4,'TRK1259','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Brgy. San Jose','Narra St.','resolved','Test Citizen','citizen@example.com','2025-05-31 16:43:06.690300','2025-05-31 16:43:06.690300',3,5,5);
INSERT INTO "frontend_report" VALUES (5,'TRK4276','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Zone 4','Narra St.','in_progress','Test Citizen','citizen@example.com','2025-05-31 16:43:06.693300','2025-05-31 16:43:06.693300',3,5,4);
INSERT INTO "frontend_report" VALUES (6,'TRK9377','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Narra St.','Main Ave','resolved','Test Citizen','citizen@example.com','2025-05-31 16:43:06.698816','2025-05-31 16:43:06.698816',3,8,4);
INSERT INTO "frontend_report" VALUES (7,'TRK9788','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Zone 4','Narra St.','resolved','Test Citizen','citizen@example.com','2025-05-31 16:43:06.702812','2025-05-31 16:43:06.702812',3,7,6);
INSERT INTO "frontend_report" VALUES (8,'TRK8925','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Pine Rd.','Zone 4','pending','Test Citizen','citizen@example.com','2025-05-31 16:43:06.707864','2025-05-31 16:43:06.707864',4,7,4);
INSERT INTO "frontend_report" VALUES (9,'TRK7221','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Pine Rd.','Pine Rd.','resolved','Test Citizen','citizen@example.com','2025-05-31 16:43:06.711844','2025-05-31 16:43:06.711844',3,5,5);
INSERT INTO "frontend_report" VALUES (10,'TRK7353','This is a test report generated by seed script.','https://example.com/test-photo.jpg',14.5995,120.9842,'Main Ave','Narra St.','pending','Test Citizen','citizen@example.com','2025-05-31 16:43:06.715347','2025-05-31 16:43:06.715347',4,6,6);
INSERT INTO "frontend_roadtype" VALUES (4,'Concrete','Description for Concrete road','2025-05-31 16:43:06.650870');
INSERT INTO "frontend_roadtype" VALUES (5,'Asphalt','Description for Asphalt road','2025-05-31 16:43:06.656388');
INSERT INTO "frontend_roadtype" VALUES (6,'Gravel','Description for Gravel road','2025-05-31 16:43:06.660377');
INSERT INTO "frontend_role" VALUES (4,'Admin');
INSERT INTO "frontend_role" VALUES (5,'Agency Staff');
INSERT INTO "frontend_role" VALUES (6,'Citizen');
INSERT INTO "frontend_users" VALUES (1,'dpwh_john','john@dpwh.gov.ph','password123','John Doe',1,'2025-05-31 16:43:06.663376',NULL,3,5);
INSERT INTO "frontend_users" VALUES (2,'ceo_maria','maria@ceo.gov.ph','password123','Maria Santos',1,'2025-05-31 16:43:06.669895',NULL,4,5);
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
CREATE INDEX IF NOT EXISTS "frontend_user_agency_id_a00ce96f" ON "frontend_users" (
	"agency_id"
);
CREATE INDEX IF NOT EXISTS "frontend_user_role_user_id_08df9b3f" ON "frontend_users" (
	"role_user_id"
);
COMMIT;
