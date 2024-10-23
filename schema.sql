USE pos_project;

CREATE TABLE IF NOT EXISTS reservation (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY, -- 自增主鍵
    customer_name VARCHAR(255) NOT NULL, -- 客戶名稱，不可為空
    customer_phone_number VARCHAR(255) NOT NULL, -- 客戶電話號碼，不可為空
    customer_email VARCHAR(255) NOT NULL, -- 客戶電子郵件，不可為空
    customer_gender ENUM('先生', '小姐') NOT NULL, -- 使用 ENUM 表示性別
    reservation_people INT NOT NULL, -- 預約人數，不可為空
    reservation_date DATE NOT NULL, -- 預約日期，合併自 reservation_management
    reservation_starttime TIME NOT NULL, -- 預約開始時間，合併自 reservation_management
    reservation_endingtime TIME NOT NULL -- 預約結束時間，合併自 reservation_management
);

CREATE TABLE IF NOT EXISTS table_management (
  table_number varchar(20) NOT NULL,
  table_capacity int DEFAULT NULL,
  table_status enum('可使用', '訂位中', '用餐中') DEFAULT '可使用',  -- 更新為中文枚舉值，並設定默認值
  reservation_id INT,  -- reservation_id 欄位，連接到 reservation 表的主鍵
  PRIMARY KEY (table_number),
  CONSTRAINT fk_table_reservation FOREIGN KEY (reservation_id) REFERENCES reservation (reservation_id) -- 外鍵約束，連接到 reservation 表
);

CREATE TABLE IF NOT EXISTS pos_project.reservation_table (
    reservation_id INT,
    table_number VARCHAR(20),
    PRIMARY KEY (reservation_id, table_number),
    FOREIGN KEY (reservation_id) REFERENCES pos_project.reservation (reservation_id),
    FOREIGN KEY (table_number) REFERENCES pos_project.table_management (table_number)
);

CREATE TABLE IF NOT EXISTS operating_hours (
    id INT NOT NULL AUTO_INCREMENT,
    day_of_week ENUM('星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日') NOT NULL, -- 更新為枚舉值
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    dining_duration INT NOT NULL, -- 用餐時間，以分鐘為單位
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS waitlist (
    waitlist_id INT AUTO_INCREMENT PRIMARY KEY, 
    customer_name VARCHAR(255) NOT NULL,        
    customer_phone_number VARCHAR(15) NOT NULL, 
    customer_email VARCHAR(255) NOT NULL,      
    customer_gender ENUM('先生', '小姐') NOT NULL, 
    waitlist_people INT NOT NULL,               
    waiting_date DATE NOT NULL,                 
    wait_time TIME NOT NULL,                  
    waitlist_order INT NOT NULL          
);

CREATE TABLE IF NOT EXISTS categories (
  category_id int NOT NULL AUTO_INCREMENT,
  category varchar(45) DEFAULT NULL,
  workstation_id int DEFAULT NULL,
  PRIMARY KEY (`category_id`)
);

CREATE TABLE IF NOT EXISTS menu_items (
  meal_name varchar(45) NOT NULL,
  category_id int DEFAULT NULL,
  workstation_id int DEFAULT NULL,
  price int DEFAULT '0',
  available tinyint DEFAULT '1',
  picture_name longtext,
  PRIMARY KEY (`meal_name`)
);

CREATE TABLE IF NOT EXISTS options (
  option_title varchar(45) NOT NULL,
  cg_id int NOT NULL,
  option_content varchar(45) NOT NULL,
  option_type enum('checkbox','radio') NOT NULL,
  extra_price int DEFAULT '0',
  PRIMARY KEY (`option_title`,`cg_id`,`option_content`)
);

CREATE TABLE IF NOT EXISTS combo_items (
  combo_name varchar(45) NOT NULL,
  combo_detail varchar(1000) DEFAULT NULL,
  discount_amount int DEFAULT NULL,
  category_id int DEFAULT NULL,
  PRIMARY KEY (`combo_name`)
);


CREATE TABLE IF NOT EXISTS checkout_list (
  order_id varchar(60) NOT NULL,
  table_number varchar(20) DEFAULT NULL,
  total_price int DEFAULT NULL,
  pay_type varchar(45) DEFAULT NULL,
  checkout tinyint DEFAULT '0',
  checkout_time datetime DEFAULT NULL,
  PRIMARY KEY (`order_id`)
);

CREATE TABLE  IF NOT EXISTS `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(60) DEFAULT NULL,
  `order_meal_id` varchar(60) DEFAULT NULL,
  `combo_name` varchar(60) DEFAULT NULL,
  `meal_name` varchar(60) DEFAULT NULL,
  `options` varchar(60) DEFAULT NULL,
  `workstation_id` int DEFAULT NULL,
  `price` int DEFAULT NULL,
  `meal_status` enum('準備中','待送餐點','已送達') DEFAULT NULL,
  `table_number` varchar(20) DEFAULT NULL,
  `order_time` datetime DEFAULT NULL,
  `checkout` tinyint DEFAULT '0',
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS checkout_list_history (
  order_id varchar(60) NOT NULL,
  table_number varchar(20) DEFAULT NULL,
  total_price int DEFAULT NULL,
  pay_type varchar(45) DEFAULT NULL,
  checkout tinyint DEFAULT '0',
  checkout_time datetime DEFAULT NULL,
  PRIMARY KEY (`order_id`)
);

CREATE TABLE IF NOT EXISTS orders_history (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(60) DEFAULT NULL,
  `order_meal_id` varchar(60) DEFAULT NULL,
  `combo_name` varchar(60) DEFAULT NULL,
  `meal_name` varchar(60) DEFAULT NULL,
  `options` varchar(60) DEFAULT NULL,
  `workstation_id` int DEFAULT NULL,
  `price` int DEFAULT NULL,
  `meal_status` enum('準備中','待送餐點','已送達') DEFAULT NULL,
  `table_number` varchar(20) DEFAULT NULL,
  `order_time` datetime DEFAULT NULL,
  `checkout` tinyint DEFAULT '0',
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS workstation (
  workstation_id int NOT NULL AUTO_INCREMENT,
  workstation_name varchar(20) DEFAULT NULL,
  PRIMARY KEY (`workstation_id`)
);

CREATE TABLE IF NOT EXISTS announce (
  announce_id int NOT NULL AUTO_INCREMENT,
  announce_title varchar(60) DEFAULT NULL,
  announce_content text,
  announce_picture_name longtext,
  announce_starttime date DEFAULT NULL,
  announce_endtime date DEFAULT NULL,
  PRIMARY KEY (`announce_id`)
);

CREATE TABLE IF NOT EXISTS member (
  member_id int NOT NULL AUTO_INCREMENT,
  pwd varchar(100) NOT NULL,
  name varchar(45) NOT NULL,
  phone varchar(20) NOT NULL,
  birthday date NOT NULL,
  email varchar(90) NOT NULL,
  total_spending_amount int NOT NULL,
  member_level varchar(20) NOT NULL,
  verification_code varchar(6) DEFAULT NULL,
  verification_code_expiry datetime DEFAULT NULL,
  PRIMARY KEY (`member_id`)
);

CREATE TABLE IF NOT EXISTS staff (
  staff_number varchar(45) NOT NULL,
  pwd varchar(100) NOT NULL,
  name varchar(45) NOT NULL,
  phone varchar(45) NOT NULL,
  authorization varchar(45) NOT NULL,
  email varchar(90) NOT NULL,
  verification_code varchar(45) DEFAULT NULL,
  verification_code_expiry varchar(45) DEFAULT NULL,
  error_count int NOT NULL DEFAULT '0',
  block_time datetime DEFAULT NULL,
  first_login tinyint DEFAULT '1',
  PRIMARY KEY (`staff_number`)
);


INSERT INTO staff VALUES ('TEST001','$2a$10$ERKJb8dtFojJu.0jDffRA.mNThkgEugl/KHY03POvAZmWWUAdlgGq','管理員','0912345678','1','test@gmail.com','',NULL,0,NULL,1);

CREATE TABLE IF NOT EXISTS authorization (
  authorization_id int NOT NULL AUTO_INCREMENT,
  authorization_name varchar(45) NOT NULL,
  authorization_item varchar(90) NOT NULL,
  PRIMARY KEY (`authorization_id`)
);

INSERT INTO authorization VALUES (1,'管理員','活動,桌位結帳,點餐,餐點狀態,工作檯,歷史紀錄,銷售分析,員工管理,設定');

ALTER TABLE table_management ADD CONSTRAINT fk_reservation FOREIGN KEY (reservation_id) REFERENCES reservation(reservation_id);

INSERT INTO table_management (table_number, table_capacity, table_status, reservation_id) VALUES 
('A01', 2, '用餐中', NULL),
('A02', 4, '用餐中', NULL),
('A03', 6, '可使用', NULL),
('A04', 8, '可使用', NULL),
('A05', 10, '可使用', NULL);

INSERT INTO pos_project.operating_hours (day_of_week, opening_time, closing_time, dining_duration) VALUES 
('星期一', '06:00:00', '17:00:00', 70),
('星期二', '06:00:00', '17:00:00', 70),
('星期三', '06:00:00', '17:00:00', 70),
('星期四', '06:00:00', '17:00:00', 70),
('星期五', '06:00:00', '17:00:00', 70);

INSERT INTO categories VALUES (1,'漢堡',1),(2,'吐司',2),(3,'蛋餅',3),(4,'沙拉',4),(5,'炒泡麵',5),(6,'炸物',6),(7,'飲料',7),(8,'套餐',NULL);

INSERT INTO menu_items VALUES ('九層塔蛋餅',3,3,45,1,NULL),('凱薩沙拉',4,4,70,1,NULL),('原味炒泡麵',5,2,45,1,NULL),('原味蛋餅',3,3,30,1,NULL),('培根蛋吐司',2,2,40,1,NULL),('歐姆蛋堡',1,1,60,1,''),('泰式炒泡麵',5,2,50,1,NULL),('洋蔥圈',6,6,35,1,NULL),('火腿蛋吐司',2,2,40,1,NULL),('火腿蛋餅',3,3,45,1,NULL),('煎蛋吐司',2,2,30,1,NULL),('煙燻鮭魚沙拉',4,4,130,1,NULL),('燻雞堡',1,1,65,1,NULL),('牛肉堡',1,1,75,1,NULL),('牛肉炒泡麵',5,2,60,1,NULL),('田園蔬菜堡',1,1,40,1,NULL),('紅茶',7,7,25,1,NULL),('綠茶',7,7,25,1,NULL),('美式咖啡',7,7,50,1,NULL),('蔬菜蛋餅',3,3,40,1,NULL),('薯條',6,6,40,1,NULL),('薯餅',6,6,30,1,NULL),('薯餅蛋吐司',2,2,45,1,NULL),('豬肉堡',1,1,70,1,NULL),('豬肉炒泡麵',5,2,55,1,NULL),('起司蛋餅',3,3,40,1,NULL),('雞塊',6,6,40,1,NULL),('鮪魚蛋吐司',2,2,40,1,NULL),('鮮奶紅茶',7,7,35,1,NULL),('鮮奶綠茶',7,7,35,1,NULL),('鮮蝦沙拉',4,4,80,1,NULL);

INSERT INTO `options` VALUES ('冰塊',7,'去冰','radio',0),('冰塊',7,'少冰','radio',0),('冰塊',7,'微冰','radio',0),('冰塊',7,'正常冰','radio',0),('加料',1,'培根','checkbox',20),('加料',1,'蔬菜','checkbox',20),('加料',1,'雙層','checkbox',40),('加料',3,'九層塔','checkbox',10),('加料',3,'火腿','checkbox',10),('加料',3,'起司','checkbox',10),('加料',4,'加水煮蛋','checkbox',10),('加料',4,'加酪梨','checkbox',20),('加料',4,'加雞胸肉','checkbox',30),('加料',5,'肉多多','checkbox',20),('加料',5,'菜多多','checkbox',15),('加料',7,'椰果','checkbox',10),('加料',7,'珍珠','checkbox',10),('加料',7,'粉粿','checkbox',10),('加蛋',5,'全熟蛋','radio',15),('加蛋',5,'半熟蛋','radio',15),('加蛋',5,'炒蛋','radio',20),('加起司',1,'不炙燒','radio',10),('加起司',1,'炙燒','radio',10),('加起司',2,'起司不炙燒','radio',10),('加起司',2,'起司要炙燒','radio',10),('吐司作法',2,'不美乃滋','checkbox',0),('吐司作法',2,'去邊','checkbox',0),('吐司作法',2,'烤酥','checkbox',0),('甜度',7,'半糖','radio',0),('甜度',7,'微糖','radio',0),('甜度',7,'正常甜','radio',0),('甜度',7,'無糖','radio',0),('胡椒',6,'不胡椒','radio',0),('胡椒',6,'多胡椒','radio',0),('蛋',1,'半熟蛋','radio',15),('蛋',1,'歐姆蛋','radio',25),('蛋',1,'蔥花蛋','radio',25),('蛋',2,'半熟蛋','radio',15),('蛋',2,'歐姆蛋','radio',25),('蛋',2,'蔥花蛋','radio',25),('辣',3,'不辣','radio',0),('辣',3,'加特製辣醬','radio',0),('辣度',5,'不辣','radio',0),('辣度',5,'中辣','radio',0),('辣度',5,'大辣','radio',0),('辣度',5,'小辣','radio',0),('醬料',4,'不醬','radio',0),('醬料',4,'低脂醬','radio',0),('醬料',6,'不醬','radio',0),('醬料',6,'番茄醬','radio',0),('醬料',6,'糖醋醬','radio',0);

INSERT INTO workstation VALUES (1,'漢堡檯'),(2,'吐司檯'),(3,'煎檯'),(4,'冷盤檯'),(5,'煮製檯'),(6,'炸檯'),(7,'飲料檯');

INSERT INTO `orders` VALUES (1,'202410172342A01','0867647f-fc7d-4b05-b7e8-5d952aaf860e',NULL,'燻雞堡','半熟蛋, 培根',1,100,'已送達','A01','2024-10-17 15:42:41',0),(2,'202410172342A01','91780bae-64ff-4a8e-b156-67c93392d142',NULL,'綠茶','半糖, 去冰',7,25,'已送達','A01','2024-10-17 15:42:41',0),(3,'202410172342A01','fe8b7974-0c1e-4f3c-afdc-130b0e1c21fa',NULL,'薯條','不胡椒, 不醬',6,40,'已送達','A01','2024-10-17 15:42:49',0),(4,'202410172343A02','b123c97c-39ed-485f-95fd-fc88c0537982',NULL,'凱薩沙拉','不醬, 加水煮蛋',4,80,'已送達','A02','2024-10-17 15:43:36',0),(5,'202410172343A02','b61febde-6c37-4ec6-b7da-5681b4330c02',NULL,'鮮蝦沙拉','低脂醬',4,80,'已送達','A02','2024-10-17 15:43:36',0),(6,'202410172343A02','80a10fe0-e1d8-40c2-aba9-6acdd832a88d','1號餐',NULL,NULL,0,-20,'準備中','A02','2024-10-17 15:43:36',0),(7,'202410172343A02','80a10fe0-e1d8-40c2-aba9-6acdd832a88d','1號餐','牛肉堡','不炙燒, 歐姆蛋',1,110,'已送達','A02','2024-10-17 15:43:36',0),(8,'202410172343A02','80a10fe0-e1d8-40c2-aba9-6acdd832a88d','1號餐','薯條','不胡椒, 不醬',6,40,'已送達','A02','2024-10-17 15:43:36',0),(9,'202410172343A02','80a10fe0-e1d8-40c2-aba9-6acdd832a88d','1號餐','紅茶','微糖, 去冰',7,25,'已送達','A02','2024-10-17 15:43:36',0);




INSERT INTO `combo_items` VALUES ('1號餐','[{\"categoryId\":1,\"dishes\":[\"牛肉堡\"]},{\"categoryId\":6,\"dishes\":[\"洋蔥圈\",\"薯條\",\"雞塊\"]},{\"categoryId\":7,\"dishes\":[\"紅茶\",\"鮮奶紅茶\"]}]',-20,8),('2號餐','[{\"categoryId\":5,\"dishes\":[\"泰式炒泡麵\"]},{\"categoryId\":4,\"dishes\":[\"凱薩沙拉\",\"煙燻鮭魚沙拉\",\"鮮蝦沙拉\"]}]',-10,8);


INSERT INTO `checkout_list_history` VALUES ('202410091500A05','A01',NULL,'現金',1,'2024-08-09 15:00:00'),('202410091500A06','A01',NULL,'信用卡',1,'2024-09-10 15:00:00'),('202410091500A07','A01',NULL,'信用卡',1,'2024-10-01 15:00:00'),('202410091500A10','A01',NULL,'現金',1,'2024-01-14 15:00:00'),('202410091500A11','A01',NULL,'信用卡',1,'2024-02-15 15:00:00'),('202410091500A12','A01',NULL,'現金',1,'2024-03-16 15:00:00'),('202410091500A13','A01',NULL,'現金',1,'2024-04-17 15:00:00'),('202410091500A14','A02',NULL,'現金',1,'2024-05-18 15:00:00'),('202410091500A15','A02',NULL,'信用卡',1,'2024-06-19 15:00:00'),('202410091500A16','A02',NULL,'現金',1,'2024-07-20 15:00:00'),('202410091500A17','A02',NULL,'信用卡',1,'2024-08-21 15:00:00'),('202410091500A18','A02',NULL,'現金',1,'2024-09-22 15:00:00'),('202410091500A19','A02',NULL,'現金',1,'2024-10-02 15:00:00'),('202410091500A22','A02',NULL,'信用卡',1,'2024-01-26 15:00:00'),('202410091500A23','A02',NULL,'現金',1,'2024-02-27 15:00:00'),('202410091500A24','A03',NULL,'現金',1,'2024-03-28 15:00:00'),('202410091500A25','A03',NULL,'信用卡',1,'2024-04-29 15:00:00'),('202410091500A26','A03',NULL,'現金',1,'2024-05-30 15:00:00'),('202410091500A27','A03',NULL,'信用卡',1,'2024-06-30 15:00:00'),('202410091500A28','A03',NULL,'現金',1,'2023-09-01 15:00:00'),('202410091500A29','A03',NULL,'信用卡',1,'2023-10-02 15:00:00'),('202410091500A30','A04',NULL,'信用卡',1,'2023-11-03 15:00:00'),('202410091500A31','A04',NULL,'現金',1,'2024-01-04 15:00:00'),('202410091500A32','A04',NULL,'信用卡',1,'2024-02-05 15:00:00'),('202410091500A33','A04',NULL,'現金',1,'2024-03-06 15:00:00'),('202410091500A34','A04',NULL,'現金',1,'2024-04-07 15:00:00'),('202410091500A35','A04',NULL,'信用卡',1,'2024-05-08 15:00:00'),('202410091500A36','A04',NULL,'現金',1,'2024-06-09 15:00:00'),('202410091500A37','A04',NULL,'信用卡',1,'2024-07-10 15:00:00'),('202410091500A38','A05',NULL,'信用卡',1,'2024-08-11 15:00:00'),('202410091500A39','A05',NULL,'現金',1,'2024-09-12 15:00:00'),('202410091500A40','A05',NULL,'信用卡',1,'2024-10-03 15:00:00'),('202410091500A43','A05',NULL,'信用卡',1,'2024-01-16 15:00:00'),('202410091500A44','A05',NULL,'現金',1,'2024-02-17 15:00:00'),('202410091500A45','A05',NULL,'信用卡',1,'2024-03-18 15:00:00'),('202410091500A46','A05',NULL,'信用卡',1,'2024-04-19 15:00:00'),('202410091500A47','A01',NULL,'現金',1,'2024-05-20 15:00:00'),('202410091500A48','A01',NULL,'信用卡',1,'2024-06-21 15:00:00'),('202410091500A49','A01',NULL,'信用卡',1,'2024-07-22 15:00:00'),('202410091500A50','A01',NULL,'信用卡',1,'2024-08-23 15:00:00'),('202410091500A51','A01',NULL,'信用卡',1,'2024-09-24 15:00:00'),('202410091500A55','A01',NULL,'現金',1,'2024-01-28 15:00:00'),('202410091500A56','A01',NULL,'現金',1,'2024-02-29 15:00:00'),('202410091500A57','A01',NULL,'信用卡',1,'2024-03-30 15:00:00'),('202410091500A58','A02',NULL,'現金',1,'2023-04-01 15:00:00'),('202410091500A59','A02',NULL,'信用卡',1,'2023-05-02 15:00:00'),('202410091500A60','A02',NULL,'現金',1,'2023-06-03 15:00:00'),('202410091500A61','A02',NULL,'信用卡',1,'2023-01-03 15:00:00'),('202410091500A62','A02',NULL,'信用卡',1,'2023-02-03 15:00:00'),('202410091500A63','A02',NULL,'現金',1,'2023-03-03 15:00:00'),('202410091500A64','A02',NULL,'信用卡',1,'2024-04-03 15:00:00'),('202410091500A65','A02',NULL,'信用卡',1,'2024-05-03 15:00:00'),('202410091500A66','A02',NULL,'現金',1,'2024-06-03 15:00:00'),('202410091500A67','A02',NULL,'信用卡',1,'2023-07-03 15:00:00'),('202410091500A68','A02',NULL,'信用卡',1,'2023-08-03 15:00:00'),('202410091500A69','A02',NULL,'現金',1,'2023-12-03 15:00:00'),('202410091500A70','A02',NULL,'現金',1,'2024-07-03 15:00:00'),('202410091500A72','A02',NULL,'現金',1,'2024-10-04 15:00:00'),('202410091500A73','A03',NULL,'現金',1,'2024-10-05 15:00:00'),('202410091500A74','A03',NULL,'信用卡',1,'2024-10-06 15:00:00'),('202410091500A75','A03',NULL,'現金',1,'2024-10-07 15:00:00'),('202410091500A76','A03',NULL,'信用卡',1,'2024-10-08 15:00:00'),('202410091500A77','A03',NULL,'信用卡',1,'2024-10-09 15:00:00'),('202410091500A78','A03',NULL,'現金',1,'2024-10-10 15:00:00'),('202410091500A79','A04',NULL,'信用卡',1,'2024-10-11 15:00:00'),('202410091500A81','A04',NULL,'信用卡',1,'2024-10-13 15:00:00'),('202410091500A82','A04',NULL,'現金',1,'2024-10-14 15:00:00'),('202410091500A83','A04',NULL,'信用卡',1,'2024-10-15 15:00:00'),('202410091500A84','A04',NULL,'現金',1,'2024-10-15 15:00:00'),('202410091500A85','A04',NULL,'現金',1,'2024-10-15 15:00:00'),('202410091500A86','A04',NULL,'現金',1,'2024-10-15 15:00:00'),('202410091500A87','A04',NULL,'現金',1,'2024-10-15 15:00:00'),('202410091500A88','A04',NULL,'現金',1,'2024-10-15 15:00:00'),('202410091500A89','A05',NULL,'現金',1,'2024-10-15 15:00:00'),('202410091500A90','A05',NULL,'現金',1,'2024-10-15 15:00:00'),('202410091500A91','A05',NULL,'現金',1,'2024-10-15 15:00:00'),('202410091500A92','A05',NULL,'現金',1,'2024-10-14 15:00:00');



INSERT INTO `orders_history` VALUES (77,'202410091500A05','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e7','5號餐',NULL,NULL,0,-10,'已送達','A05','2024-10-09 15:00:00',1),(78,'202410091500A05','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e7','5號餐','煎蛋吐司','加火腿,加起司(炙燒)',4,50,'已送達','A05','2024-10-09 15:00:00',1),(79,'202410091500A05','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e7','5號餐','薯餅','加起司醬',7,50,'已送達','A05','2024-10-09 15:00:00',1),(80,'202410091500A05','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e7',NULL,'鮮奶紅茶','半糖,去冰',8,35,'已送達','A05','2024-10-09 15:00:00',1),(81,'202410091500A06','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e8',NULL,'火腿蛋餅',NULL,NULL,45,'已送達',NULL,NULL,1),(82,'202410091500A07','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e9',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(83,'202410091500A08','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e10',NULL,'火腿蛋餅',NULL,NULL,45,'已送達',NULL,NULL,1),(84,'202410091500A09','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e11',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(85,'202410091500A10','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e12',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(86,'202410091500A11','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e13',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(87,'202410091500A12','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e14',NULL,'起司蛋餅',NULL,NULL,40,'已送達',NULL,NULL,1),(88,'202410091500A13','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e15',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(89,'202410091500A14','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e16',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(90,'202410091500A15','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e17',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(91,'202410091500A16','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e18',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(92,'202410091500A17','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e19',NULL,'鮮奶紅茶',NULL,NULL,35,'已送達',NULL,NULL,1),(93,'202410091500A18','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e20',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(94,'202410091500A19','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e21',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(95,'202410091500A20','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e22',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(96,'202410091500A21','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e23',NULL,'起司蛋餅',NULL,NULL,40,'已送達',NULL,NULL,1),(97,'202410091500A22','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e24',NULL,'豬肉堡',NULL,NULL,70,'已送達',NULL,NULL,1),(98,'202410091500A23','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e25',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(99,'202410091500A24','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e26',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(100,'202410091500A25','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e27',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(101,'202410091500A26','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e28',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(102,'202410091500A27','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e29',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(103,'202410091500A28','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e30',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(104,'202410091500A29','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e31',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(105,'202410091500A30','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e32',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(106,'202410091500A31','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e33',NULL,'豬肉堡',NULL,NULL,70,'已送達',NULL,NULL,1),(107,'202410091500A32','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e34',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(108,'202410091500A33','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e35',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(109,'202410091500A34','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e36',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(110,'202410091500A35','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e37',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(111,'202410091500A36','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e38',NULL,'豬肉堡',NULL,NULL,70,'已送達',NULL,NULL,1),(112,'202410091500A37','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e39',NULL,'牛肉堡',NULL,NULL,75,'已送達',NULL,NULL,1),(113,'202410091500A38','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e40',NULL,'原味炒泡麵',NULL,NULL,45,'已送達',NULL,NULL,1),(114,'202410091500A39','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e41',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(115,'202410091500A40','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e42',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(116,'202410091500A41','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e43',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(117,'202410091500A42','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e44',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(118,'202410091500A43','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e45',NULL,'豬肉堡',NULL,NULL,70,'已送達',NULL,NULL,1),(119,'202410091500A44','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e46',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(120,'202410091500A45','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e47',NULL,'牛肉堡',NULL,NULL,75,'已送達',NULL,NULL,1),(121,'202410091500A46','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e48',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(122,'202410091500A47','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e49',NULL,'田園蔬菜堡',NULL,NULL,40,'已送達',NULL,NULL,1),(123,'202410091500A48','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e50',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(124,'202410091500A49','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e51',NULL,'田園蔬菜堡',NULL,NULL,40,'已送達',NULL,NULL,1),(125,'202410091500A50','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e52',NULL,'牛肉堡',NULL,NULL,75,'已送達',NULL,NULL,1),(126,'202410091500A51','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e53',NULL,'原味炒泡麵',NULL,NULL,45,'已送達',NULL,NULL,1),(127,'202410091500A52','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e54',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(128,'202410091500A53','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e55',NULL,'田園蔬菜堡',NULL,NULL,40,'已送達',NULL,NULL,1),(129,'202410091500A54','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e56',NULL,'牛肉堡',NULL,NULL,75,'已送達',NULL,NULL,1),(130,'202410091500A55','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e57',NULL,'鮮奶紅茶',NULL,NULL,35,'已送達',NULL,NULL,1),(131,'202410091500A56','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e58',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(132,'202410091500A57','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e59',NULL,'起司蛋餅',NULL,NULL,40,'已送達',NULL,NULL,1),(133,'202410091500A58','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e60',NULL,'原味炒泡麵',NULL,NULL,45,'已送達',NULL,NULL,1),(134,'202410091500A59','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e61',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,1),(135,'202410091500A60','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e62',NULL,'起司蛋餅',NULL,NULL,40,'已送達',NULL,NULL,1),(137,'202410091500A61','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e63',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(138,'202410091500A62','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e64',NULL,'牛肉堡',NULL,NULL,75,'已送達',NULL,NULL,1),(139,'202410091500A63','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e65',NULL,'牛肉堡',NULL,NULL,75,'已送達',NULL,NULL,1),(140,'202410091500A64','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e66',NULL,'起司蛋餅',NULL,NULL,40,'已送達',NULL,NULL,1),(141,'202410091500A65','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e67',NULL,'原味炒泡麵',NULL,NULL,45,'已送達',NULL,NULL,1),(142,'202410091500A66','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e68',NULL,'田園蔬菜堡',NULL,NULL,40,'已送達',NULL,NULL,1),(143,'202410091500A67','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e69',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(144,'202410091500A68','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e70',NULL,'鮮奶紅茶',NULL,NULL,35,'已送達',NULL,NULL,1),(145,'202410091500A69','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e71',NULL,'田園蔬菜堡',NULL,NULL,40,'已送達',NULL,NULL,1),(146,'202410091500A70','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e72',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,1),(182,'202410091500A71','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e73',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(201,'202410091500A72','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e93',NULL,'田園蔬菜堡',NULL,NULL,40,'已送達',NULL,NULL,1),(202,'202410091500A73','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e94',NULL,'豬肉堡',NULL,NULL,70,'已送達',NULL,NULL,1),(256,'202410091500A74','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e126',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(257,'202410091500A75','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e127',NULL,'雞塊',NULL,NULL,40,'已送達',NULL,NULL,1),(258,'202410091500A76','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e128',NULL,'洋蔥圈',NULL,NULL,35,'已送達',NULL,NULL,1),(259,'202410091500A77','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e129',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,1),(260,'202410091500A78','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e130',NULL,'雞塊',NULL,NULL,40,'已送達',NULL,NULL,1),(261,'202410091500A79','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e131',NULL,'豬肉炒泡麵',NULL,NULL,55,'已送達',NULL,NULL,1),(262,'202410091500A81','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e132',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,1),(263,'202410091500A82','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e133',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(264,'202410091500A83','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e134',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(265,'202410091500A76','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e135',NULL,'田園蔬菜堡',NULL,NULL,40,'已送達',NULL,NULL,1),(266,'202410091500A76','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e135',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(272,'202410091500A84','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e135',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(273,'202410091500A85','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e136',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(274,'202410091500A86','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e137',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(275,'202410091500A87','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e138',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(276,'202410091500A88','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e139',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(277,'202410091500A89','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e140',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(278,'202410091500A90','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e141',NULL,'燻雞堡',NULL,NULL,65,'已送達',NULL,NULL,1),(279,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e142',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(281,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e144',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(284,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e147',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(285,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e148',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(286,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e149',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(288,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e151',NULL,'凱薩沙拉',NULL,NULL,70,'已送達',NULL,NULL,1),(289,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e152',NULL,'起司蛋餅',NULL,NULL,40,'已送達',NULL,NULL,1),(290,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e153',NULL,'起司蛋餅',NULL,NULL,40,'已送達',NULL,NULL,1),(292,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e155',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,1),(293,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e156',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,1),(294,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e157',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,1),(296,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e159',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,1),(297,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e160',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(298,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e161',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(299,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e162',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(300,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e163',NULL,'泰式炒泡麵',NULL,NULL,50,'已送達',NULL,NULL,1),(301,'202410091500A91','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e164',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(302,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e165',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(303,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e166',NULL,'薯餅蛋吐司',NULL,NULL,40,'已送達',NULL,NULL,1),(304,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e167',NULL,'薯條',NULL,NULL,40,'已送達',NULL,NULL,1),(305,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e168',NULL,'薯條',NULL,NULL,40,'已送達',NULL,NULL,1),(306,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e169',NULL,'薯條',NULL,NULL,40,'已送達',NULL,NULL,1),(307,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e170',NULL,'薯條',NULL,NULL,40,'已送達',NULL,NULL,1),(308,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e171',NULL,'薯條',NULL,NULL,40,'已送達',NULL,NULL,1),(309,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e172',NULL,'薯條',NULL,NULL,40,'已送達',NULL,NULL,1),(310,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e173',NULL,'豬肉堡',NULL,NULL,70,'已送達',NULL,NULL,1),(311,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e174',NULL,'豬肉堡',NULL,NULL,70,'已送達',NULL,NULL,1),(312,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e175',NULL,'豬肉堡',NULL,NULL,70,'已送達',NULL,NULL,1),(313,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e176',NULL,'紅茶',NULL,NULL,25,'已送達',NULL,NULL,1),(314,'202410091500A92','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e177',NULL,'紅茶',NULL,NULL,25,'已送達',NULL,NULL,1),(315,'202410091500A07','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e178',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(316,'202410091500A19','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e179',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(317,'202410091500A40','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e180',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(318,'202410091500A72','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e181',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(319,'202410091500A73','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e182',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(320,'202410091500A74','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e183',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(321,'202410091500A40','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e184',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(322,'202410091500A72','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e185',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(323,'202410091500A72','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e186',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(324,'202410091500A72','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e187',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(325,'202410091500A07','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e188',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0),(326,'202410091500A07','74e88ef5-34f4-48a6-9f4e-1b8f4b0e81e189',NULL,'歐姆蛋堡',NULL,NULL,60,'已送達',NULL,NULL,0);





INSERT INTO `announce` VALUES (1,'夏日果香鬆餅季：新鮮莓果的甜蜜誘惑！','這個夏天，快來嘗試我們限量供應的夏日果香鬆餅，搭配新鮮的草莓、藍莓和覆盆子，再加上一球手工冰淇淋，絕對讓您大呼過癮！',NULL,'2024-08-01','2024-08-31'),(2,'情人節巧克力鬆餅特餐：甜蜜滿分的浪漫體驗','情人節當天，我們推出巧克力鬆餅套餐，與您的另一半一同享用這份甜蜜滋味，還有機會參加 情人節浪漫抽獎活動，贏取精美禮品！',NULL,'2024-08-10','2024-08-10'),(3,'健康綠色早晨：全新健康餐選擇登場！','推出全新的健康早午餐，讓您吃得美味又健康！限時優惠中，快來嘗試！',NULL,'2024-09-01','2024-09-05'),(4,'手作蜂蜜週：天然甜味的獨特體驗！','本週與本地蜂農合作，推出限定蜂蜜餐點，從甜蜜鬆餅到蜂蜜拿鐵，讓您體驗最純粹的天然甜味！快來感受這場甜蜜的冒險吧！',NULL,'2024-09-16','2024-09-23'),(5,'健康全麥日：本週四享受健康美味','週四，我們的全麥系列餐點九折優惠，無論是全麥吐司、全麥三明治還是全麥鬆餅，讓您在享受美味的同時保持健康。',NULL,'2024-09-19','2024-09-19'),(6,'週年慶狂歡：特別套餐限時推出！','為慶祝開業週年，我們推出雙人早午餐優惠套餐，只需 $299，還贈送精美甜點一份！感謝您一直以來的支持，快來和我們一起慶祝吧！',NULL,'2024-09-24','2024-09-30'),(7,'鬆餅節慶：全場鬆餅五折，限時放送！','我們一年一度的鬆餅節又來了！喜愛鬆餅的朋友千萬不要錯過，所有鬆餅五折優惠，快帶上朋友一起來享用這場美味盛宴吧！',NULL,'2024-09-24','2024-09-26'),(8,'早鳥優惠：享用美味的早晨餐點','為了回饋早起的顧客，凡是在7點到9點來店用餐，即可享受全店九折優惠！提早開始美好的一天，從一頓美味的早餐開始！',NULL,'2024-10-14','2024-10-18'),(9,' 秋季特別優惠：豐收季節共享美味！','歡慶秋天的到來，我們為大家準備了豐富的早午餐套餐。一切都充滿了秋季的溫暖滋味！來店消費即享所有套餐八折優惠，讓我們一起感受豐收的喜悅吧！',NULL,'2024-10-16','2024-10-18'),(10,'現場音樂晚餐：美食與音樂的完美結合！','想要度過一個充滿音樂和美食的夜晚嗎？本週五晚上，我們邀請本地的音樂人進行現場表演，讓您在享用我們精心準備的晚餐的同時，感受動人的旋律。',NULL,'2024-10-18','2024-10-18'),(11,'週末雙人早午餐優惠：輕鬆享受週末時光！','本週六日，我們推出雙人早午餐套餐，僅需 $399，並贈送兩杯特調飲品！邀請親朋好友一起來享用悠閒的週末時光。',NULL,'2024-10-19','2024-10-20'),(12,'週一咖啡日：開啟活力滿滿的一週！','我們特別推出所有咖啡飲品半價優惠，讓您在新的一週開始時充滿活力。不論是拿鐵、美式還是卡布奇諾，都只需一半價格！',NULL,'2024-10-21','2024-10-21'),(13,'套餐升級日：免費升級您的餐點！','本週三限定，凡點選任何套餐，都可免費升級飲品或加購小食！無論是升級到大杯咖啡，還是加一份薯條，我們讓您的小享受升級不加價！',NULL,'2024-10-23','2024-10-23'),(14,'萬聖節驚悚早午餐派對：帶妝來領驚喜！','帶著萬聖節裝扮前來用餐，即可獲得神秘小禮物，並參加我們的 最佳裝扮比賽，贏取精美獎品！快來感受充滿驚悚與歡樂的氛圍！',NULL,'2024-10-25','2024-10-31');



INSERT INTO checkout_list VALUES ('202410121620A01','A01',495,'信用卡',1,'2024-10-12 22:24:54'),('202410121622A03','A03',75,'現金',1,'2024-10-12 22:25:01'),('202410121623A05','A05',125,'信用卡',1,'2024-10-12 22:25:05'),('202410122225A01','A01',330,'信用卡',1,'2024-10-12 22:25:58'),('202410122225A04','A04',160,'現金',1,'2024-10-12 22:26:05'),('202410122225A05','A05',95,'現金',1,'2024-10-12 22:26:08');


INSERT INTO waitlist (customer_name, customer_phone_number, customer_email, customer_gender, waitlist_people, waiting_date, wait_time, waitlist_order)
VALUES 
('陳小芳', '0987654321', 'example1@gmail.com', '小姐', 2, '2024-10-18', '23:05:00', 1),
('林大華', '0912345678', 'example2@gmail.com', '先生', 4, '2024-10-18', '23:10:00', 2),
('李志明', '0922123456', 'example3@gmail.com', '先生', 3, '2024-10-18', '23:15:00', 3),
('王美麗', '0933456789', 'example4@gmail.com', '小姐', 2, '2024-10-18', '23:20:00', 4);

