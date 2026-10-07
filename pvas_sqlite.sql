BEGIN TRANSACTION;
CREATE TABLE appointment_status_histories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                appointment_id INTEGER NOT NULL REFERENCES appointments (id) ON DELETE CASCADE,
                status TEXT NOT NULL,
                changed_by INTEGER REFERENCES users (id) ON DELETE SET NULL,
                changed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );
INSERT INTO "appointment_status_histories" VALUES(1,2,'confirmed',1,'2026-05-07 03:16:14');
INSERT INTO "appointment_status_histories" VALUES(2,3,'no_show',1,'2026-05-07 03:18:37');
INSERT INTO "appointment_status_histories" VALUES(3,3,'no_show',1,'2026-05-07 03:18:40');
INSERT INTO "appointment_status_histories" VALUES(4,2,'completed',1,'2026-05-07 03:24:06');
INSERT INTO "appointment_status_histories" VALUES(5,4,'confirmed',3,'2026-05-07 11:27:06');
INSERT INTO "appointment_status_histories" VALUES(6,3,'confirmed',3,'2026-05-07 12:22:48');
INSERT INTO "appointment_status_histories" VALUES(7,4,'no_show',3,'2026-05-07 12:23:24');
INSERT INTO "appointment_status_histories" VALUES(8,1,'no_show',1,'2026-05-07 12:25:37');
INSERT INTO "appointment_status_histories" VALUES(9,6,'no_show',1,'2026-05-07 12:31:47');
INSERT INTO "appointment_status_histories" VALUES(10,5,'confirmed',1,'2026-05-07 12:31:57');
INSERT INTO "appointment_status_histories" VALUES(11,6,'scheduled',3,'2026-05-07 12:33:17');
INSERT INTO "appointment_status_histories" VALUES(12,5,'completed',3,'2026-05-07 12:33:48');
INSERT INTO "appointment_status_histories" VALUES(13,3,'completed',3,'2026-05-07 12:34:04');
INSERT INTO "appointment_status_histories" VALUES(14,6,'no_show',1,'2026-05-07 12:43:49');
INSERT INTO "appointment_status_histories" VALUES(15,7,'scheduled',1,'2026-05-07 18:47:15');
INSERT INTO "appointment_status_histories" VALUES(16,8,'scheduled',3,'2026-05-07 19:36:08');
INSERT INTO "appointment_status_histories" VALUES(17,7,'completed',1,'2026-05-07 19:48:28');
INSERT INTO "appointment_status_histories" VALUES(18,8,'completed',1,'2026-05-07 20:08:16');
INSERT INTO "appointment_status_histories" VALUES(19,6,'scheduled',1,'2026-05-07 20:09:15');
INSERT INTO "appointment_status_histories" VALUES(20,6,'confirmed',1,'2026-05-07 20:15:02');
INSERT INTO "appointment_status_histories" VALUES(21,6,'scheduled',3,'2026-05-08 01:08:42');
INSERT INTO "appointment_status_histories" VALUES(22,6,'completed',1,'2026-05-08 01:11:07');
INSERT INTO "appointment_status_histories" VALUES(23,4,'scheduled',1,'2026-05-08 01:11:37');
INSERT INTO "appointment_status_histories" VALUES(24,1,'completed',1,'2026-05-08 01:11:49');
INSERT INTO "appointment_status_histories" VALUES(25,4,'canceled',1,'2026-05-08 01:25:20');
INSERT INTO "appointment_status_histories" VALUES(26,4,'no_show',3,'2026-05-08 01:57:31');
INSERT INTO "appointment_status_histories" VALUES(27,4,'canceled',3,'2026-05-08 02:27:09');
INSERT INTO "appointment_status_histories" VALUES(28,9,'scheduled',3,'2026-05-08 06:38:22');
INSERT INTO "appointment_status_histories" VALUES(29,9,'confirmed',1,'2026-05-08 06:54:41');
INSERT INTO "appointment_status_histories" VALUES(30,4,'completed',3,'2026-05-08 07:14:20');
INSERT INTO "appointment_status_histories" VALUES(31,9,'no_show',4,'2026-05-10 00:52:29');
INSERT INTO "appointment_status_histories" VALUES(32,10,'scheduled',1,'2026-05-10 05:41:32');
INSERT INTO "appointment_status_histories" VALUES(33,10,'confirmed',3,'2026-05-10 05:42:44');
INSERT INTO "appointment_status_histories" VALUES(34,11,'scheduled',3,'2026-05-10 07:16:39');
INSERT INTO "appointment_status_histories" VALUES(35,12,'scheduled',3,'2026-05-10 07:51:06');
INSERT INTO "appointment_status_histories" VALUES(36,10,'completed',1,'2026-05-10 13:57:15');
INSERT INTO "appointment_status_histories" VALUES(37,9,'canceled',1,'2026-05-10 14:00:22');
INSERT INTO "appointment_status_histories" VALUES(38,13,'scheduled',1,'2026-05-10 14:52:10');
INSERT INTO "appointment_status_histories" VALUES(39,13,'confirmed',4,'2026-05-10 15:49:52');
CREATE TABLE appointments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_id INTEGER NOT NULL REFERENCES customers (id) ON DELETE CASCADE,
                pet_id INTEGER NOT NULL REFERENCES pets (id) ON DELETE CASCADE,
                veterinarian_id INTEGER NOT NULL REFERENCES users (id) ON DELETE CASCADE,
                scheduled_date TEXT NOT NULL,
                scheduled_time TEXT NOT NULL,
                reason_for_visit TEXT,
                type TEXT CHECK (type IN ('Checkup', 'Vaccination', 'Surgery', 'Grooming')),
                status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN (
                    'scheduled', 'confirmed', 'completed', 'no_show', 'canceled'
                )),
                created_by INTEGER REFERENCES users (id) ON DELETE SET NULL,
                updated_by INTEGER REFERENCES users (id) ON DELETE SET NULL,
                created_at TEXT,
                updated_at TEXT
            );
INSERT INTO "appointments" VALUES(1,1,1,4,'2023-08-03','09:00:00','For Vaccination',NULL,'completed',3,1,'2026-05-03 13:15:55','2026-05-08 01:11:49');
INSERT INTO "appointments" VALUES(2,1,2,4,'2026-05-11','08:00:00','For vaccine',NULL,'completed',3,1,'2026-05-04 07:20:32','2026-05-07 03:24:06');
INSERT INTO "appointments" VALUES(3,2,3,4,'2026-05-08','09:00:00','For vaccination',NULL,'completed',3,3,'2026-05-06 00:46:36','2026-05-07 12:34:04');
INSERT INTO "appointments" VALUES(4,2,5,4,'2026-05-10','09:00:00','For making my pet looks beautiful',NULL,'completed',3,3,'2026-05-07 09:10:07','2026-05-08 07:14:20');
INSERT INTO "appointments" VALUES(5,3,6,4,'2026-05-10','09:00:00','For anti rabbies',NULL,'completed',3,3,'2026-05-07 10:14:58','2026-05-07 12:33:48');
INSERT INTO "appointments" VALUES(6,3,7,4,'2026-05-12','09:00:00','For checking their situation','Checkup','completed',3,1,'2026-05-07 10:32:49','2026-05-08 01:11:07');
INSERT INTO "appointments" VALUES(7,2,8,4,'2026-05-12','09:00:00','Muscle disalign','Surgery','completed',1,1,'2026-05-07 18:47:15','2026-05-07 19:48:28');
INSERT INTO "appointments" VALUES(8,1,9,4,'2026-05-12','09:00:00','Basta','Grooming','completed',3,1,'2026-05-07 19:36:08','2026-05-07 20:08:16');
INSERT INTO "appointments" VALUES(9,4,10,4,'2026-05-11','09:00:00','Ear problem','Surgery','canceled',3,1,'2026-05-08 06:38:22','2026-05-10 14:00:22');
INSERT INTO "appointments" VALUES(10,5,11,5,'2026-05-13','09:00:00','For following check ups','Checkup','completed',1,1,'2026-05-10 05:41:32','2026-05-10 13:57:15');
INSERT INTO "appointments" VALUES(11,4,12,5,'2026-05-15','09:00:00','Nothing','Checkup','scheduled',3,3,'2026-05-10 07:16:39','2026-05-10 07:16:39');
INSERT INTO "appointments" VALUES(12,3,13,5,'2026-05-20','09:00:00','Wala ragud','Grooming','scheduled',3,3,'2026-05-10 07:51:06','2026-05-10 07:51:06');
INSERT INTO "appointments" VALUES(13,5,14,4,'2026-05-15','09:00:00','As if','Vaccination','confirmed',1,4,'2026-05-10 14:52:10','2026-05-10 15:49:52');
CREATE TABLE customers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                registered_by INTEGER REFERENCES users (id) ON DELETE SET NULL,
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                email TEXT UNIQUE,
                contact_number TEXT NOT NULL,
                address TEXT,
                created_at TEXT,
                updated_at TEXT
            );
INSERT INTO "customers" VALUES(1,3,'Amethyst','Nioda','thyst@gmail.com','09674823800','Libungan Cotabato','2026-05-03 10:16:42','2026-05-03 10:16:42');
INSERT INTO "customers" VALUES(2,3,'Irish','Pelayo','irish@gmail.com','09631008080','San Agustin Davao Occidental','2026-05-03 12:32:28','2026-05-03 12:32:28');
INSERT INTO "customers" VALUES(3,3,'Jesierie','Pait','jes@gmail.com','09674823096','Tadazi, TADS','2026-05-07 10:14:03','2026-05-07 10:14:03');
INSERT INTO "customers" VALUES(4,1,'Sab','Nioda','sab@gmail.com','09107637400','Davao City','2026-05-07 20:47:48','2026-05-07 20:47:48');
INSERT INTO "customers" VALUES(5,1,'Bebiana','Nioda','bebz@gmail.com','09673008202','Sta. Maria TADS','2026-05-10 05:38:58','2026-05-10 05:38:58');
INSERT INTO "customers" VALUES(6,1,'Lilia','Orbillo','lilia@gmail.com','09098080800','Poblacion','2026-10-07 08:54:53','2026-10-07 08:54:53');
CREATE TABLE pets (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_id INTEGER NOT NULL REFERENCES customers (id) ON DELETE CASCADE,
                pet_name TEXT NOT NULL,
                species TEXT NOT NULL CHECK (species IN (
                    'Dog', 'Cat', 'Bird', 'Rabbit', 'Hamster', 'Other'
                )),
                breed TEXT,
                gender TEXT CHECK (gender IN ('Male', 'Female')),
                birthdate TEXT,
                color TEXT,
                weight REAL CHECK (weight IS NULL OR weight >= 0),
                medical_notes TEXT,
                created_at TEXT,
                updated_at TEXT
            );
INSERT INTO "pets" VALUES(1,1,'Petpet','Dog','Golden Retriever','Male',NULL,'Brown',20.0,NULL,'2026-05-03 13:15:55','2026-05-03 13:15:55');
INSERT INTO "pets" VALUES(2,1,'Catcat','Cat','Persian','Female',NULL,'White',5.0,NULL,'2026-05-04 07:20:32','2026-05-04 07:20:32');
INSERT INTO "pets" VALUES(3,2,'Browny','Dog','Golden Retriever','Male',NULL,'White',15.0,NULL,'2026-05-06 00:46:36','2026-05-06 00:46:36');
INSERT INTO "pets" VALUES(4,2,'Whitey','Dog','Golden Retriever',NULL,NULL,'Brown',15.0,NULL,'2026-05-07 08:35:40','2026-05-07 08:35:40');
INSERT INTO "pets" VALUES(5,2,'Whitey','Dog','Golden Retriever','Male',NULL,'Brown',15.0,NULL,'2026-05-07 09:10:07','2026-05-07 09:10:07');
INSERT INTO "pets" VALUES(6,3,'Piola','Dog','Aspin (Mixed Breed)','Female',NULL,'Black',10.0,NULL,'2026-05-07 10:14:58','2026-05-07 10:14:58');
INSERT INTO "pets" VALUES(7,3,'Buday','Cat','Persian',NULL,NULL,'White',3.0,NULL,'2026-05-07 10:32:49','2026-05-07 10:32:49');
INSERT INTO "pets" VALUES(8,2,'Blacky','Dog','Golden Retriever','Male',NULL,'White',15.0,NULL,'2026-05-07 18:47:15','2026-05-07 18:47:15');
INSERT INTO "pets" VALUES(9,1,'Petpet','Dog','Golden Retriever','Male',NULL,'Brown',14.0,NULL,'2026-05-07 19:36:08','2026-05-07 19:36:08');
INSERT INTO "pets" VALUES(10,4,'Bunsoy','Dog','Golden Retriever','Male',NULL,'Brown',15.0,NULL,'2026-05-08 06:38:22','2026-05-08 06:38:22');
INSERT INTO "pets" VALUES(11,5,'Kulot','Dog','Labrador Retriever','Female',NULL,'Brown',15.0,NULL,'2026-05-10 05:41:32','2026-05-10 05:41:32');
INSERT INTO "pets" VALUES(12,4,'Putot','Dog','Aspin (Mixed Breed)','Female',NULL,'Black',7.0,NULL,'2026-05-10 07:16:39','2026-05-10 07:16:39');
INSERT INTO "pets" VALUES(13,3,'jm','Dog','Golden Retriever','Male',NULL,'White',60.0,NULL,'2026-05-10 07:51:06','2026-05-10 07:51:06');
INSERT INTO "pets" VALUES(14,5,'Kulot','Cat','Persian','Male',NULL,'Orange',5.0,NULL,'2026-05-10 14:52:10','2026-05-10 14:52:10');
CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL,
                role TEXT NOT NULL DEFAULT 'staff' CHECK (role IN (
                    'admin', 'veterinarian', 'receptionist', 'vet_nurse',
                    'vet_assistant', 'groomer', 'staff'
                )),
                phone_number TEXT,
                is_active INTEGER NOT NULL DEFAULT 1,
                created_at TEXT,
                updated_at TEXT
            );
INSERT INTO "users" VALUES(1,'McCoy Neoda','mccoy@gmail.com','$2y$12$gd7D..7CnULMThcJJ4LdqudZOq7DlssgeWUJ7oF/4C7AxZtOgmoJi','admin',NULL,1,'2026-05-03 08:14:48','2026-05-03 08:14:48');
INSERT INTO "users" VALUES(3,'Nessiah Presores','siah@gmail.com','$2y$12$YmXafhUeLU1hiWJA4Z8Mme5IQDY7/3djJwgv0lm8Lidk1h6RoeuaK','receptionist','09678080202',1,'2026-05-03 09:04:39','2026-05-03 09:04:39');
INSERT INTO "users" VALUES(4,'Bella Samantha','bella@gmail.com','$2y$12$7zRqnpITpajaw9AExqPv7eFvl5/Zcmzs0IKEatrmolvapfQyPVtl2','veterinarian','09678080202',1,'2026-05-03 13:14:18','2026-05-03 13:14:18');
INSERT INTO "users" VALUES(5,'Sally Nioda','sally@gmail.com','$2y$12$cxrj8HybQGYvAXdwzbr.feqMAWj1TIN8QRNk2mSByb2wkHsS0mPaW','vet_nurse','09630380020',1,'2026-05-08 00:41:40','2026-05-08 00:41:40');
INSERT INTO "users" VALUES(6,'Sam Nioda','sam@gmail.com','$2y$12$AnXwyJBIP.iIXoLaWh.uKe.EhDPErsO/iuWNiZoigmnQpW1xRQ.vK','groomer','09108040600',1,'2026-05-10 14:55:23','2026-05-10 14:55:23');
INSERT INTO "users" VALUES(7,'Annabelle','belle@gmail.com','$2y$12$NUghzyTvOZ3J2XPwAm3uquVyfBBzhdKxpuKtIythCb2DXRgjmnyGy','vet_assistant','09638002332',1,'2026-05-10 14:56:27','2026-05-10 14:56:27');
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('users',7);
INSERT INTO "sqlite_sequence" VALUES('customers',6);
INSERT INTO "sqlite_sequence" VALUES('pets',14);
INSERT INTO "sqlite_sequence" VALUES('appointments',13);
INSERT INTO "sqlite_sequence" VALUES('appointment_status_histories',39);
COMMIT;