-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: grubngo
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account` (
  `account_id` bigint NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('CUSTOMER','RESTAURANT') NOT NULL,
  `status` enum('ACTIVE','SUSPENDED','CLOSED') NOT NULL DEFAULT 'ACTIVE',
  `failed_login_attempts` int DEFAULT '0',
  `last_login_attempt` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` bigint DEFAULT NULL,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `email` (`email`),
  KEY `created_by` (`created_by`),
  KEY `idx_account_email` (`email`),
  KEY `idx_account_role` (`role`),
  KEY `idx_account_status` (`status`),
  CONSTRAINT `account_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `account` (`account_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` VALUES (1,'john.doe@email.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25',NULL),(2,'jane.smith@email.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25',NULL),(3,'bob.johnson@email.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25',NULL),(4,'alice.brown@email.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25',NULL),(5,'charlie.davis@email.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25',NULL),(6,'marios.pizza@restaurant.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25',NULL),(7,'burger.palace@restaurant.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25',NULL),(8,'sushi.zen@restaurant.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25',NULL),(9,'taco.fiesta@restaurant.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25',NULL),(10,'cafe.brew@restaurant.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25',NULL);
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `address`
--

DROP TABLE IF EXISTS `address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `address` (
  `address_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint NOT NULL,
  `address_label` varchar(100) DEFAULT NULL,
  `street_address` varchar(255) NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(50) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `country` varchar(50) NOT NULL DEFAULT 'USA',
  `is_default` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_address_customer` (`customer_id`),
  KEY `idx_address_default` (`customer_id`,`is_default`),
  CONSTRAINT `address_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `address`
--

LOCK TABLES `address` WRITE;
/*!40000 ALTER TABLE `address` DISABLE KEYS */;
INSERT INTO `address` VALUES (1,1,'Home','123 Main St','San Francisco','CA','94102','USA',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(2,1,'Work','456 Market St','San Francisco','CA','94105','USA',0,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(3,2,'Home','789 Pine St','San Francisco','CA','94108','USA',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(4,3,'Home','321 Oak St','Oakland','CA','94607','USA',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(5,4,'Home','654 Elm St','Berkeley','CA','94702','USA',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(6,5,'Home','987 Cedar Ave','San Jose','CA','95112','USA',1,'2025-11-25 20:58:25','2025-11-25 20:58:25');
/*!40000 ALTER TABLE `address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditlog`
--

DROP TABLE IF EXISTS `auditlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditlog` (
  `audit_log_id` bigint NOT NULL AUTO_INCREMENT,
  `table_name` varchar(100) NOT NULL,
  `record_id` bigint NOT NULL,
  `action` enum('CREATE','UPDATE','DELETE','STATUS_CHANGE') NOT NULL,
  `field_name` varchar(100) DEFAULT NULL,
  `old_value` text,
  `new_value` text,
  `performed_by` bigint DEFAULT NULL,
  `performed_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  PRIMARY KEY (`audit_log_id`),
  KEY `idx_audit_table_record` (`table_name`,`record_id`),
  KEY `idx_audit_performed_by` (`performed_by`),
  KEY `idx_audit_performed_at` (`performed_at`),
  CONSTRAINT `auditlog_ibfk_1` FOREIGN KEY (`performed_by`) REFERENCES `account` (`account_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditlog`
--

LOCK TABLES `auditlog` WRITE;
/*!40000 ALTER TABLE `auditlog` DISABLE KEYS */;
INSERT INTO `auditlog` VALUES (1,'Order',1,'STATUS_CHANGE','status','CREATED','CONFIRMED',1,'2025-11-25 20:58:25','192.168.1.100',NULL),(2,'Order',1,'STATUS_CHANGE','status','CONFIRMED','PREPARING',6,'2025-11-25 20:58:25','192.168.1.200',NULL),(3,'Order',1,'STATUS_CHANGE','status','PREPARING','READY',6,'2025-11-25 20:58:25','192.168.1.200',NULL),(4,'Order',1,'STATUS_CHANGE','status','READY','OUT_FOR_DELIVERY',6,'2025-11-25 20:58:25','192.168.1.200',NULL),(5,'Order',1,'STATUS_CHANGE','status','OUT_FOR_DELIVERY','DELIVERED',6,'2025-11-25 20:58:25','192.168.1.200',NULL),(6,'MenuItem',1,'UPDATE','price','17.99','18.99',6,'2025-11-25 20:58:25','192.168.1.200',NULL);
/*!40000 ALTER TABLE `auditlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `businesshours`
--

DROP TABLE IF EXISTS `businesshours`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `businesshours` (
  `business_hours_id` bigint NOT NULL AUTO_INCREMENT,
  `restaurant_id` bigint NOT NULL,
  `day_of_week` enum('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY') NOT NULL,
  `open_time` time NOT NULL,
  `close_time` time NOT NULL,
  `is_closed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`business_hours_id`),
  UNIQUE KEY `unique_restaurant_day` (`restaurant_id`,`day_of_week`),
  KEY `idx_business_hours_restaurant` (`restaurant_id`),
  CONSTRAINT `businesshours_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurant` (`restaurant_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `businesshours`
--

LOCK TABLES `businesshours` WRITE;
/*!40000 ALTER TABLE `businesshours` DISABLE KEYS */;
INSERT INTO `businesshours` VALUES (1,6,'MONDAY','11:00:00','22:00:00',0),(2,6,'TUESDAY','11:00:00','22:00:00',0),(3,6,'WEDNESDAY','11:00:00','22:00:00',0),(4,6,'THURSDAY','11:00:00','22:00:00',0),(5,6,'FRIDAY','11:00:00','23:00:00',0),(6,6,'SATURDAY','11:00:00','23:00:00',0),(7,6,'SUNDAY','12:00:00','21:00:00',0),(8,7,'MONDAY','10:00:00','22:00:00',0),(9,7,'TUESDAY','10:00:00','22:00:00',0),(10,7,'WEDNESDAY','10:00:00','22:00:00',0),(11,7,'THURSDAY','10:00:00','22:00:00',0),(12,7,'FRIDAY','10:00:00','23:00:00',0),(13,7,'SATURDAY','10:00:00','23:00:00',0),(14,7,'SUNDAY','11:00:00','21:00:00',0),(15,8,'MONDAY','17:00:00','22:00:00',0),(16,8,'TUESDAY','17:00:00','22:00:00',0),(17,8,'WEDNESDAY','17:00:00','22:00:00',0),(18,8,'THURSDAY','17:00:00','22:00:00',0),(19,8,'FRIDAY','17:00:00','23:00:00',0),(20,8,'SATURDAY','17:00:00','23:00:00',0),(21,8,'SUNDAY','17:00:00','21:00:00',0),(22,9,'MONDAY','08:00:00','20:00:00',0),(23,9,'TUESDAY','08:00:00','20:00:00',0),(24,9,'WEDNESDAY','08:00:00','20:00:00',0),(25,9,'THURSDAY','08:00:00','20:00:00',0),(26,9,'FRIDAY','08:00:00','21:00:00',0),(27,9,'SATURDAY','08:00:00','21:00:00',0),(28,9,'SUNDAY','09:00:00','19:00:00',0),(29,10,'MONDAY','07:00:00','15:00:00',1),(30,10,'TUESDAY','07:00:00','15:00:00',1),(31,10,'WEDNESDAY','07:00:00','15:00:00',1),(32,10,'THURSDAY','07:00:00','15:00:00',1),(33,10,'FRIDAY','07:00:00','15:00:00',1),(34,10,'SATURDAY','08:00:00','16:00:00',1),(35,10,'SUNDAY','08:00:00','16:00:00',1);
/*!40000 ALTER TABLE `businesshours` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `customer_id` bigint NOT NULL,
  `customer_name` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `account` (`account_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (1,'John Doe','555-0101'),(2,'Jane Smith','555-0102'),(3,'Bob Johnson','555-0103'),(4,'Alice Brown','555-0104'),(5,'Charlie Davis','555-0105');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu` (
  `menu_id` bigint NOT NULL AUTO_INCREMENT,
  `restaurant_id` bigint NOT NULL,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`menu_id`),
  KEY `idx_menu_restaurant` (`restaurant_id`),
  KEY `idx_menu_active` (`restaurant_id`,`is_active`),
  CONSTRAINT `menu_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurant` (`restaurant_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu`
--

LOCK TABLES `menu` WRITE;
/*!40000 ALTER TABLE `menu` DISABLE KEYS */;
INSERT INTO `menu` VALUES (1,6,'Main Menu',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(2,6,'Lunch Specials',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(3,7,'Burgers & Fries',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(4,7,'Breakfast Menu',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(5,8,'Dinner Menu',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(6,8,'Sushi Bar',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(7,9,'All Day Menu',1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(8,10,'Coffee & Pastries',0,'2025-11-25 20:58:25','2025-11-25 20:58:25');
/*!40000 ALTER TABLE `menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menuitem`
--

DROP TABLE IF EXISTS `menuitem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menuitem` (
  `menu_item_id` bigint NOT NULL AUTO_INCREMENT,
  `menu_id` bigint NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `is_available` tinyint(1) DEFAULT '1',
  `available_from` time DEFAULT NULL,
  `available_until` time DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`menu_item_id`),
  UNIQUE KEY `unique_menu_item_name` (`menu_id`,`name`),
  KEY `idx_menuitem_menu` (`menu_id`),
  KEY `idx_menuitem_available` (`menu_id`,`is_available`),
  CONSTRAINT `menuitem_ibfk_1` FOREIGN KEY (`menu_id`) REFERENCES `menu` (`menu_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menuitem`
--

LOCK TABLES `menuitem` WRITE;
/*!40000 ALTER TABLE `menuitem` DISABLE KEYS */;
INSERT INTO `menuitem` VALUES (1,1,'Margherita Pizza','Fresh mozzarella, basil, and tomato sauce',18.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(2,1,'Pepperoni Pizza','Classic pepperoni with mozzarella cheese',21.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(3,1,'Caesar Salad','Romaine lettuce, parmesan, croutons, caesar dressing',12.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(4,1,'Garlic Bread','Toasted bread with garlic butter and herbs',6.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(5,2,'Personal Pizza Combo','Small pizza with salad and drink',14.99,1,'11:00:00','15:00:00','2025-11-25 20:58:25','2025-11-25 20:58:25'),(6,2,'Pasta of the Day','Chef selection pasta with garlic bread',13.99,1,'11:00:00','15:00:00','2025-11-25 20:58:25','2025-11-25 20:58:25'),(7,3,'Classic Burger','Beef patty, lettuce, tomato, onion, pickles',15.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(8,3,'Cheeseburger','Classic burger with cheese',17.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(9,3,'BBQ Bacon Burger','Burger with BBQ sauce and bacon',19.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(10,3,'French Fries','Crispy golden fries',5.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(11,3,'Onion Rings','Beer-battered onion rings',7.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(12,4,'Breakfast Burger','Burger with egg and bacon',16.99,1,'06:00:00','11:00:00','2025-11-25 20:58:25','2025-11-25 20:58:25'),(13,4,'Pancakes','Stack of fluffy pancakes',9.99,1,'06:00:00','11:00:00','2025-11-25 20:58:25','2025-11-25 20:58:25'),(14,5,'Chicken Teriyaki','Grilled chicken with teriyaki sauce',22.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(15,5,'Beef Yakitori','Grilled beef skewers',24.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(16,5,'Miso Soup','Traditional soybean soup',4.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(17,6,'California Roll','Crab, avocado, cucumber',8.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(18,6,'Salmon Sashimi','Fresh salmon slices (6 pieces)',14.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(19,6,'Tuna Roll','Fresh tuna roll',12.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(20,7,'Beef Taco','Seasoned ground beef with toppings',3.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(21,7,'Chicken Burrito','Grilled chicken burrito with rice and beans',11.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(22,7,'Guacamole & Chips','Fresh guacamole with tortilla chips',7.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(23,7,'Quesadilla','Cheese quesadilla with sour cream',8.99,1,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(24,8,'Espresso','Double shot espresso',3.99,0,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(25,8,'Latte','Espresso with steamed milk',5.99,0,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(26,8,'Croissant','Buttery flaky croissant',4.99,0,NULL,NULL,'2025-11-25 20:58:25','2025-11-25 20:58:25');
/*!40000 ALTER TABLE `menuitem` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menuitempricehistory`
--

DROP TABLE IF EXISTS `menuitempricehistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menuitempricehistory` (
  `price_history_id` bigint NOT NULL AUTO_INCREMENT,
  `menu_item_id` bigint NOT NULL,
  `old_price` decimal(10,2) NOT NULL,
  `new_price` decimal(10,2) NOT NULL,
  `changed_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `changed_by` bigint DEFAULT NULL,
  PRIMARY KEY (`price_history_id`),
  KEY `menu_item_id` (`menu_item_id`),
  KEY `changed_by` (`changed_by`),
  CONSTRAINT `menuitempricehistory_ibfk_1` FOREIGN KEY (`menu_item_id`) REFERENCES `menuitem` (`menu_item_id`) ON DELETE CASCADE,
  CONSTRAINT `menuitempricehistory_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `account` (`account_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menuitempricehistory`
--

LOCK TABLES `menuitempricehistory` WRITE;
/*!40000 ALTER TABLE `menuitempricehistory` DISABLE KEYS */;
INSERT INTO `menuitempricehistory` VALUES (1,1,17.99,18.99,'2025-11-25 20:58:25',6);
/*!40000 ALTER TABLE `menuitempricehistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `modifier`
--

DROP TABLE IF EXISTS `modifier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `modifier` (
  `modifier_id` bigint NOT NULL AUTO_INCREMENT,
  `menu_item_id` bigint NOT NULL,
  `modifier_name` varchar(255) NOT NULL,
  `min_selections` int DEFAULT '0',
  `max_selections` int DEFAULT '1',
  `is_required` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`modifier_id`),
  KEY `menu_item_id` (`menu_item_id`),
  CONSTRAINT `modifier_ibfk_1` FOREIGN KEY (`menu_item_id`) REFERENCES `menuitem` (`menu_item_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `modifier`
--

LOCK TABLES `modifier` WRITE;
/*!40000 ALTER TABLE `modifier` DISABLE KEYS */;
INSERT INTO `modifier` VALUES (1,1,'Size',1,1,1,'2025-11-25 20:58:25'),(2,2,'Size',1,1,1,'2025-11-25 20:58:25'),(3,7,'Add-ons',0,5,0,'2025-11-25 20:58:25'),(4,8,'Add-ons',0,5,0,'2025-11-25 20:58:25'),(5,9,'Add-ons',0,5,0,'2025-11-25 20:58:25'),(6,19,'Toppings',0,4,0,'2025-11-25 20:58:25'),(7,20,'Protein Level',0,1,0,'2025-11-25 20:58:25'),(8,24,'Size',1,1,1,'2025-11-25 20:58:25'),(9,25,'Size',1,1,1,'2025-11-25 20:58:25');
/*!40000 ALTER TABLE `modifier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `modifieroption`
--

DROP TABLE IF EXISTS `modifieroption`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `modifieroption` (
  `modifier_option_id` bigint NOT NULL AUTO_INCREMENT,
  `modifier_id` bigint NOT NULL,
  `option_name` varchar(255) NOT NULL,
  `price_delta` decimal(10,2) DEFAULT '0.00',
  `is_available` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`modifier_option_id`),
  KEY `modifier_id` (`modifier_id`),
  CONSTRAINT `modifieroption_ibfk_1` FOREIGN KEY (`modifier_id`) REFERENCES `modifier` (`modifier_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `modifieroption`
--

LOCK TABLES `modifieroption` WRITE;
/*!40000 ALTER TABLE `modifieroption` DISABLE KEYS */;
INSERT INTO `modifieroption` VALUES (1,1,'Small (10\")',-2.00,1,'2025-11-25 20:58:25'),(2,1,'Medium (12\")',0.00,1,'2025-11-25 20:58:25'),(3,1,'Large (14\")',3.00,1,'2025-11-25 20:58:25'),(4,1,'Extra Large (16\")',6.00,1,'2025-11-25 20:58:25'),(5,2,'Small (10\")',-2.00,1,'2025-11-25 20:58:25'),(6,2,'Medium (12\")',0.00,1,'2025-11-25 20:58:25'),(7,2,'Large (14\")',3.00,1,'2025-11-25 20:58:25'),(8,2,'Extra Large (16\")',6.00,1,'2025-11-25 20:58:25'),(9,3,'Extra Cheese',1.50,1,'2025-11-25 20:58:25'),(10,3,'Bacon',2.50,1,'2025-11-25 20:58:25'),(11,3,'Avocado',2.00,1,'2025-11-25 20:58:25'),(12,3,'Mushrooms',1.00,1,'2025-11-25 20:58:25'),(13,3,'Jalapeños',0.50,1,'2025-11-25 20:58:25'),(14,4,'Extra Cheese',1.50,1,'2025-11-25 20:58:25'),(15,4,'Bacon',2.50,1,'2025-11-25 20:58:25'),(16,4,'Avocado',2.00,1,'2025-11-25 20:58:25'),(17,4,'Mushrooms',1.00,1,'2025-11-25 20:58:25'),(18,4,'Jalapeños',0.50,1,'2025-11-25 20:58:25'),(19,5,'Extra Cheese',1.50,1,'2025-11-25 20:58:25'),(20,5,'Bacon',2.50,1,'2025-11-25 20:58:25'),(21,5,'Avocado',2.00,1,'2025-11-25 20:58:25'),(22,5,'Mushrooms',1.00,1,'2025-11-25 20:58:25'),(23,5,'Jalapeños',0.50,1,'2025-11-25 20:58:25'),(24,6,'Lettuce',0.00,1,'2025-11-25 20:58:25'),(25,6,'Tomatoes',0.00,1,'2025-11-25 20:58:25'),(26,6,'Cheese',0.50,1,'2025-11-25 20:58:25'),(27,6,'Sour Cream',0.50,1,'2025-11-25 20:58:25'),(28,7,'Double Meat',3.99,1,'2025-11-25 20:58:25'),(29,8,'Small',-1.00,1,'2025-11-25 20:58:25'),(30,8,'Medium',0.00,1,'2025-11-25 20:58:25'),(31,8,'Large',1.00,1,'2025-11-25 20:58:25'),(32,9,'Small',-1.00,1,'2025-11-25 20:58:25'),(33,9,'Medium',0.00,1,'2025-11-25 20:58:25'),(34,9,'Large',1.00,1,'2025-11-25 20:58:25');
/*!40000 ALTER TABLE `modifieroption` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order`
--

DROP TABLE IF EXISTS `order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order` (
  `order_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint NOT NULL,
  `restaurant_id` bigint NOT NULL,
  `delivery_address_id` bigint DEFAULT NULL,
  `delivery_street` varchar(255) DEFAULT NULL,
  `delivery_city` varchar(100) DEFAULT NULL,
  `delivery_state` varchar(50) DEFAULT NULL,
  `delivery_postal_code` varchar(20) DEFAULT NULL,
  `delivery_country` varchar(50) DEFAULT NULL,
  `status` enum('CREATED','CONFIRMED','PREPARING','READY','OUT_FOR_DELIVERY','DELIVERED','CANCELLED','FAILED') NOT NULL DEFAULT 'CREATED',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `confirmed_at` datetime DEFAULT NULL,
  `prepared_at` datetime DEFAULT NULL,
  `ready_at` datetime DEFAULT NULL,
  `picked_up_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax_rate` decimal(5,4) DEFAULT NULL,
  `delivery_fee` decimal(10,2) DEFAULT '0.00',
  `service_fee` decimal(10,2) DEFAULT '0.00',
  `tip` decimal(10,2) DEFAULT '0.00',
  `discount` decimal(10,2) DEFAULT '0.00',
  `total` decimal(10,2) NOT NULL DEFAULT '0.00',
  `payment_method_id` bigint DEFAULT NULL,
  `is_paid` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`order_id`),
  KEY `delivery_address_id` (`delivery_address_id`),
  KEY `payment_method_id` (`payment_method_id`),
  KEY `idx_order_customer` (`customer_id`),
  KEY `idx_order_restaurant` (`restaurant_id`),
  KEY `idx_order_status` (`status`),
  KEY `idx_order_created` (`created_at`),
  KEY `idx_order_customer_created` (`customer_id`,`created_at`),
  CONSTRAINT `order_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE,
  CONSTRAINT `order_ibfk_2` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurant` (`restaurant_id`) ON DELETE CASCADE,
  CONSTRAINT `order_ibfk_3` FOREIGN KEY (`delivery_address_id`) REFERENCES `address` (`address_id`) ON DELETE SET NULL,
  CONSTRAINT `order_ibfk_4` FOREIGN KEY (`payment_method_id`) REFERENCES `paymentmethod` (`payment_method_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order`
--

LOCK TABLES `order` WRITE;
/*!40000 ALTER TABLE `order` DISABLE KEYS */;
INSERT INTO `order` VALUES (1,1,6,1,'123 Main St','San Francisco','CA','94102','USA','DELIVERED','2024-11-01 18:30:00','2024-11-01 18:32:00','2024-11-01 18:45:00','2024-11-01 19:00:00',NULL,'2024-11-01 19:25:00',NULL,'2025-11-25 20:58:25',24.99,2.19,0.0875,3.99,1.99,5.00,0.00,38.16,1,1),(2,2,7,3,'789 Pine St','San Francisco','CA','94108','USA','DELIVERED','2024-11-02 12:15:00','2024-11-02 12:17:00','2024-11-02 12:25:00','2024-11-02 12:35:00',NULL,'2024-11-02 12:50:00',NULL,'2025-11-25 20:58:25',21.98,1.92,0.0875,2.99,1.99,4.00,0.00,32.88,3,1),(3,3,8,4,'321 Oak St','Oakland','CA','94607','USA','CONFIRMED','2024-11-11 19:45:00','2024-11-11 19:47:00',NULL,NULL,NULL,NULL,NULL,'2025-11-25 20:58:25',27.98,2.45,0.0875,4.99,1.99,0.00,0.00,37.41,4,0),(4,4,9,5,'654 Elm St','Berkeley','CA','94702','USA','PREPARING','2024-11-11 11:20:00','2024-11-11 11:22:00','2024-11-11 11:25:00',NULL,NULL,NULL,NULL,'2025-11-25 20:58:25',16.97,1.48,0.0875,3.99,1.99,3.00,2.00,27.43,5,1),(5,1,7,2,'456 Market St','San Francisco','CA','94105','USA','OUT_FOR_DELIVERY','2024-11-11 13:00:00','2024-11-11 13:02:00','2024-11-11 13:15:00','2024-11-11 13:30:00',NULL,NULL,NULL,'2025-11-25 20:58:25',19.99,1.75,0.0875,2.99,1.99,4.50,0.00,31.22,2,1);
/*!40000 ALTER TABLE `order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orderitem`
--

DROP TABLE IF EXISTS `orderitem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderitem` (
  `order_item_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `menu_item_id` bigint NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `item_description` text,
  `quantity` int NOT NULL DEFAULT '1',
  `unit_price` decimal(10,2) NOT NULL,
  `notes` text,
  PRIMARY KEY (`order_item_id`),
  KEY `idx_orderitem_order` (`order_id`),
  KEY `idx_orderitem_menuitem` (`menu_item_id`),
  CONSTRAINT `orderitem_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `orderitem_ibfk_2` FOREIGN KEY (`menu_item_id`) REFERENCES `menuitem` (`menu_item_id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderitem`
--

LOCK TABLES `orderitem` WRITE;
/*!40000 ALTER TABLE `orderitem` DISABLE KEYS */;
INSERT INTO `orderitem` VALUES (1,1,1,'Margherita Pizza','Fresh mozzarella, basil, and tomato sauce',1,21.99,'Large size'),(2,1,4,'Garlic Bread','Toasted bread with garlic butter and herbs',1,6.99,NULL),(3,2,7,'Classic Burger','Beef patty, lettuce, tomato, onion, pickles',1,15.99,'No onions'),(4,2,10,'French Fries','Crispy golden fries',1,5.99,NULL),(5,3,14,'Chicken Teriyaki','Grilled chicken with teriyaki sauce',1,22.99,NULL),(6,3,16,'Miso Soup','Traditional soybean soup',1,4.99,NULL),(7,4,19,'Beef Taco','Seasoned ground beef with toppings',2,3.99,'Extra spicy'),(8,4,21,'Guacamole & Chips','Fresh guacamole with tortilla chips',1,7.99,NULL),(9,5,9,'BBQ Bacon Burger','Burger with BBQ sauce and bacon',1,19.99,'Medium rare');
/*!40000 ALTER TABLE `orderitem` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orderitemmodifier`
--

DROP TABLE IF EXISTS `orderitemmodifier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderitemmodifier` (
  `order_item_modifier_id` bigint NOT NULL AUTO_INCREMENT,
  `order_item_id` bigint NOT NULL,
  `modifier_option_id` bigint NOT NULL,
  `modifier_name` varchar(255) NOT NULL,
  `option_name` varchar(255) NOT NULL,
  `price_delta` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_item_modifier_id`),
  KEY `order_item_id` (`order_item_id`),
  KEY `modifier_option_id` (`modifier_option_id`),
  CONSTRAINT `orderitemmodifier_ibfk_1` FOREIGN KEY (`order_item_id`) REFERENCES `orderitem` (`order_item_id`) ON DELETE CASCADE,
  CONSTRAINT `orderitemmodifier_ibfk_2` FOREIGN KEY (`modifier_option_id`) REFERENCES `modifieroption` (`modifier_option_id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderitemmodifier`
--

LOCK TABLES `orderitemmodifier` WRITE;
/*!40000 ALTER TABLE `orderitemmodifier` DISABLE KEYS */;
INSERT INTO `orderitemmodifier` VALUES (1,1,3,'Size','Large (14\")',3.00),(2,3,11,'Add-ons','Extra Cheese',1.50),(3,7,22,'Toppings','Lettuce',0.00),(4,7,24,'Toppings','Cheese',0.50),(5,8,22,'Toppings','Lettuce',0.00);
/*!40000 ALTER TABLE `orderitemmodifier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paymentmethod`
--

DROP TABLE IF EXISTS `paymentmethod`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paymentmethod` (
  `payment_method_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint NOT NULL,
  `payment_type` enum('CREDIT_CARD','DEBIT_CARD','PAYPAL','APPLE_PAY','GOOGLE_PAY') NOT NULL,
  `payment_token` varchar(255) NOT NULL,
  `card_last_four` varchar(4) DEFAULT NULL,
  `card_brand` varchar(50) DEFAULT NULL,
  `expiry_month` int DEFAULT NULL,
  `expiry_year` int DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_method_id`),
  KEY `idx_payment_method_customer` (`customer_id`),
  KEY `idx_payment_method_default` (`customer_id`,`is_default`),
  CONSTRAINT `paymentmethod_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paymentmethod`
--

LOCK TABLES `paymentmethod` WRITE;
/*!40000 ALTER TABLE `paymentmethod` DISABLE KEYS */;
INSERT INTO `paymentmethod` VALUES (1,1,'CREDIT_CARD','tok_1234567890abcdef','4242','Visa',12,2027,1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(2,1,'PAYPAL','pp_john_doe_token',NULL,NULL,NULL,NULL,0,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(3,2,'CREDIT_CARD','tok_abcdef1234567890','5555','Mastercard',8,2026,1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(4,3,'DEBIT_CARD','tok_fedcba0987654321','1234','Visa',3,2028,1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(5,4,'APPLE_PAY','ap_alice_token_xyz',NULL,NULL,NULL,NULL,1,'2025-11-25 20:58:25','2025-11-25 20:58:25'),(6,5,'GOOGLE_PAY','gp_charlie_token_abc',NULL,NULL,NULL,NULL,1,'2025-11-25 20:58:25','2025-11-25 20:58:25');
/*!40000 ALTER TABLE `paymentmethod` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refund`
--

DROP TABLE IF EXISTS `refund`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refund` (
  `refund_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `transaction_id` bigint DEFAULT NULL,
  `refund_amount` decimal(10,2) NOT NULL,
  `refund_reason` text,
  `status` enum('PENDING','COMPLETED','FAILED') NOT NULL DEFAULT 'PENDING',
  `requested_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `processed_at` datetime DEFAULT NULL,
  `requested_by` bigint DEFAULT NULL,
  PRIMARY KEY (`refund_id`),
  KEY `order_id` (`order_id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `requested_by` (`requested_by`),
  CONSTRAINT `refund_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `refund_ibfk_2` FOREIGN KEY (`transaction_id`) REFERENCES `transaction` (`transaction_id`) ON DELETE SET NULL,
  CONSTRAINT `refund_ibfk_3` FOREIGN KEY (`requested_by`) REFERENCES `account` (`account_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refund`
--

LOCK TABLES `refund` WRITE;
/*!40000 ALTER TABLE `refund` DISABLE KEYS */;
/*!40000 ALTER TABLE `refund` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `restaurant`
--

DROP TABLE IF EXISTS `restaurant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant` (
  `restaurant_id` bigint NOT NULL,
  `restaurant_name` varchar(255) NOT NULL,
  `contact_phone` varchar(20) NOT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `operating_status` enum('OPEN','TEMPORARILY_CLOSED','PERMANENTLY_CLOSED') NOT NULL DEFAULT 'OPEN',
  `street_address` varchar(255) NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(50) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `country` varchar(50) NOT NULL DEFAULT 'USA',
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  PRIMARY KEY (`restaurant_id`),
  KEY `idx_restaurant_status` (`operating_status`),
  KEY `idx_restaurant_location` (`city`,`state`),
  CONSTRAINT `restaurant_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `account` (`account_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurant`
--

LOCK TABLES `restaurant` WRITE;
/*!40000 ALTER TABLE `restaurant` DISABLE KEYS */;
INSERT INTO `restaurant` VALUES (6,'Mario\'s Pizza Palace','555-0201','orders@mariospizza.com','OPEN','100 Columbus Ave','San Francisco','CA','94133','USA',37.79853500,-122.40710400),(7,'Burger Palace','555-0202','info@burgerpalace.com','OPEN','200 Union St','San Francisco','CA','94133','USA',37.80018100,-122.41014000),(8,'Sushi Zen','555-0203','reservations@sushizen.com','OPEN','300 Grant Ave','San Francisco','CA','94108','USA',37.79083400,-122.40541500),(9,'Taco Fiesta','555-0204','orders@tacofiesta.com','OPEN','400 Valencia St','San Francisco','CA','94103','USA',37.76584200,-122.42101800),(10,'Cafe Brew','555-0205','hello@cafebrew.com','TEMPORARILY_CLOSED','500 Hayes St','San Francisco','CA','94102','USA',37.77681800,-122.42450600);
/*!40000 ALTER TABLE `restaurant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction`
--

DROP TABLE IF EXISTS `transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction` (
  `transaction_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `transaction_type` enum('AUTHORIZATION','CAPTURE','REFUND','VOID') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('PENDING','SUCCESS','FAILED') NOT NULL DEFAULT 'PENDING',
  `payment_provider` varchar(100) DEFAULT NULL,
  `external_transaction_id` varchar(255) DEFAULT NULL,
  `error_message` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `processed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `idx_transaction_order` (`order_id`),
  KEY `idx_transaction_type` (`transaction_type`),
  CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order` (`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction`
--

LOCK TABLES `transaction` WRITE;
/*!40000 ALTER TABLE `transaction` DISABLE KEYS */;
INSERT INTO `transaction` VALUES (1,1,'AUTHORIZATION',38.16,'SUCCESS','Stripe','pi_1ABC123DEF456',NULL,'2025-11-25 20:58:25','2024-11-01 18:31:00'),(2,1,'CAPTURE',38.16,'SUCCESS','Stripe','pi_1ABC123DEF456',NULL,'2025-11-25 20:58:25','2024-11-01 19:00:00'),(3,2,'AUTHORIZATION',32.88,'SUCCESS','PayPal','PAYID-ABCD123',NULL,'2025-11-25 20:58:25','2024-11-02 12:16:00'),(4,2,'CAPTURE',32.88,'SUCCESS','PayPal','PAYID-ABCD123',NULL,'2025-11-25 20:58:25','2024-11-02 12:35:00'),(5,4,'AUTHORIZATION',27.43,'SUCCESS','Apple Pay','ap_1XYZ789',NULL,'2025-11-25 20:58:25','2024-11-11 11:21:00'),(6,4,'CAPTURE',27.43,'SUCCESS','Apple Pay','ap_1XYZ789',NULL,'2025-11-25 20:58:25','2024-11-11 11:25:00'),(7,5,'AUTHORIZATION',31.22,'SUCCESS','Stripe','pi_2DEF456GHI789',NULL,'2025-11-25 20:58:25','2024-11-11 13:01:00'),(8,5,'CAPTURE',31.22,'SUCCESS','Stripe','pi_2DEF456GHI789',NULL,'2025-11-25 20:58:25','2024-11-11 13:30:00');
/*!40000 ALTER TABLE `transaction` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-25 21:22:14
