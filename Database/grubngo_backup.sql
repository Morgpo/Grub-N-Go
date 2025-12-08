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
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` VALUES (1,'customer01@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',18,'2025-12-07 17:11:53','2025-12-07 17:07:24','2025-12-07 17:11:53',NULL),(2,'customer02@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(3,'customer03@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(4,'customer04@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(5,'customer05@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(6,'customer06@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(7,'customer07@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(8,'customer08@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(9,'customer09@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(10,'customer10@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(11,'customer11@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(12,'customer12@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(13,'customer13@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(14,'customer14@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(15,'customer15@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(16,'customer16@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(17,'customer17@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(18,'customer18@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(19,'customer19@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(20,'customer20@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(21,'customer21@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(22,'customer22@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(23,'customer23@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(24,'customer24@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(25,'customer25@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(26,'customer26@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(27,'customer27@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(28,'customer28@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(29,'customer29@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(30,'customer30@example.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(31,'restaurant01@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(32,'restaurant02@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(33,'restaurant03@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(34,'restaurant04@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(35,'restaurant05@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(36,'restaurant06@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(37,'restaurant07@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(38,'restaurant08@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(39,'restaurant09@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(40,'restaurant10@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(41,'restaurant11@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(42,'restaurant12@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(43,'restaurant13@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(44,'restaurant14@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(45,'restaurant15@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(46,'restaurant16@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(47,'restaurant17@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(48,'restaurant18@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(49,'restaurant19@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(50,'restaurant20@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(51,'restaurant21@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(52,'restaurant22@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(53,'restaurant23@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(54,'restaurant24@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(55,'restaurant25@grubngo.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG','RESTAURANT','ACTIVE',0,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24',NULL),(56,'grub@go.com','240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9','CUSTOMER','ACTIVE',0,NULL,'2025-12-07 17:12:28','2025-12-07 17:12:28',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `address`
--

LOCK TABLES `address` WRITE;
/*!40000 ALTER TABLE `address` DISABLE KEYS */;
INSERT INTO `address` VALUES (1,1,'Home','101 Market St','San Francisco','CA','94101','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(2,2,'Home','102 Market St','San Francisco','CA','94102','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(3,3,'Home','103 Market St','San Francisco','CA','94103','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(4,4,'Home','104 Market St','San Francisco','CA','94104','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(5,5,'Home','105 Market St','San Francisco','CA','94105','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(6,6,'Home','106 Market St','San Francisco','CA','94106','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(7,7,'Home','107 Market St','San Francisco','CA','94107','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(8,8,'Home','108 Market St','San Francisco','CA','94108','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(9,9,'Home','109 Market St','San Francisco','CA','94109','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(10,10,'Home','110 Market St','San Francisco','CA','94110','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(11,11,'Home','111 Market St','San Francisco','CA','94111','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(12,12,'Home','112 Market St','San Francisco','CA','94112','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(13,13,'Home','113 Market St','San Francisco','CA','94113','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(14,14,'Home','114 Market St','San Francisco','CA','94114','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(15,15,'Home','115 Market St','San Francisco','CA','94115','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(16,16,'Home','116 Market St','San Francisco','CA','94116','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(17,17,'Home','117 Market St','San Francisco','CA','94117','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(18,18,'Home','118 Market St','San Francisco','CA','94118','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(19,19,'Home','119 Market St','San Francisco','CA','94119','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(20,20,'Home','120 Market St','San Francisco','CA','94120','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(21,21,'Home','121 Market St','San Francisco','CA','94121','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(22,22,'Home','122 Market St','San Francisco','CA','94122','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(23,23,'Home','123 Market St','San Francisco','CA','94123','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(24,24,'Home','124 Market St','San Francisco','CA','94124','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(25,25,'Home','125 Market St','San Francisco','CA','94125','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(26,26,'Home','126 Market St','San Francisco','CA','94126','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(27,27,'Home','127 Market St','San Francisco','CA','94127','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(28,28,'Home','128 Market St','San Francisco','CA','94128','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(29,29,'Home','129 Market St','San Francisco','CA','94129','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(30,30,'Home','130 Market St','San Francisco','CA','94130','USA',1,'2025-12-07 17:07:24','2025-12-07 17:07:24');
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditlog`
--

LOCK TABLES `auditlog` WRITE;
/*!40000 ALTER TABLE `auditlog` DISABLE KEYS */;
INSERT INTO `auditlog` VALUES (1,'Order',1,'STATUS_CHANGE','status','CREATED','DELIVERED',31,'2025-01-01 10:05:00','192.168.1.101','seed-script'),(2,'Order',2,'STATUS_CHANGE','status','CREATED','DELIVERED',32,'2025-01-02 10:05:00','192.168.1.102','seed-script'),(3,'Order',3,'STATUS_CHANGE','status','CREATED','OUT_FOR_DELIVERY',33,'2025-01-03 10:05:00','192.168.1.103','seed-script'),(4,'Order',4,'STATUS_CHANGE','status','CREATED','PREPARING',34,'2025-01-04 10:05:00','192.168.1.104','seed-script'),(5,'Order',5,'STATUS_CHANGE','status','CREATED','DELIVERED',35,'2025-01-05 10:05:00','192.168.1.105','seed-script'),(6,'Order',6,'STATUS_CHANGE','status','CREATED','CONFIRMED',36,'2025-01-06 10:05:00','192.168.1.106','seed-script'),(7,'Order',7,'STATUS_CHANGE','status','CREATED','READY',37,'2025-01-07 10:05:00','192.168.1.107','seed-script'),(8,'Order',8,'STATUS_CHANGE','status','CREATED','DELIVERED',38,'2025-01-08 10:05:00','192.168.1.108','seed-script'),(9,'Order',9,'STATUS_CHANGE','status','CREATED','DELIVERED',39,'2025-01-09 10:05:00','192.168.1.109','seed-script'),(10,'Order',10,'STATUS_CHANGE','status','CREATED','CANCELLED',40,'2025-01-10 10:05:00','192.168.1.110','seed-script'),(11,'Order',11,'STATUS_CHANGE','status','CREATED','DELIVERED',41,'2025-01-11 10:05:00','192.168.1.111','seed-script'),(12,'Order',12,'STATUS_CHANGE','status','CREATED','DELIVERED',42,'2025-01-12 10:05:00','192.168.1.112','seed-script'),(13,'Order',13,'STATUS_CHANGE','status','CREATED','FAILED',43,'2025-01-13 10:05:00','192.168.1.113','seed-script'),(14,'Order',14,'STATUS_CHANGE','status','CREATED','DELIVERED',44,'2025-01-14 10:05:00','192.168.1.114','seed-script'),(15,'Order',15,'STATUS_CHANGE','status','CREATED','DELIVERED',45,'2025-01-15 10:05:00','192.168.1.115','seed-script'),(16,'Order',16,'STATUS_CHANGE','status','CREATED','PREPARING',46,'2025-01-16 10:05:00','192.168.1.116','seed-script'),(17,'Order',17,'STATUS_CHANGE','status','CREATED','DELIVERED',47,'2025-01-17 10:05:00','192.168.1.117','seed-script'),(18,'Order',18,'STATUS_CHANGE','status','CREATED','DELIVERED',48,'2025-01-18 10:05:00','192.168.1.118','seed-script'),(19,'Order',19,'STATUS_CHANGE','status','CREATED','OUT_FOR_DELIVERY',49,'2025-01-19 10:05:00','192.168.1.119','seed-script'),(20,'Order',20,'STATUS_CHANGE','status','CREATED','DELIVERED',50,'2025-01-20 10:05:00','192.168.1.120','seed-script'),(21,'Order',21,'STATUS_CHANGE','status','CREATED','CONFIRMED',51,'2025-01-21 10:05:00','192.168.1.121','seed-script'),(22,'Order',22,'STATUS_CHANGE','status','CREATED','DELIVERED',52,'2025-01-22 10:05:00','192.168.1.122','seed-script'),(23,'Order',23,'STATUS_CHANGE','status','CREATED','DELIVERED',53,'2025-01-23 10:05:00','192.168.1.123','seed-script'),(24,'Order',24,'STATUS_CHANGE','status','CREATED','DELIVERED',54,'2025-01-24 10:05:00','192.168.1.124','seed-script'),(25,'Order',25,'STATUS_CHANGE','status','CREATED','DELIVERED',55,'2025-01-25 10:05:00','192.168.1.125','seed-script');
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `businesshours`
--

LOCK TABLES `businesshours` WRITE;
/*!40000 ALTER TABLE `businesshours` DISABLE KEYS */;
INSERT INTO `businesshours` VALUES (1,31,'MONDAY','08:00:00','20:00:00',0),(2,32,'MONDAY','08:00:00','20:00:00',0),(3,33,'MONDAY','08:00:00','20:00:00',0),(4,34,'MONDAY','08:00:00','20:00:00',0),(5,35,'MONDAY','08:00:00','20:00:00',0),(6,36,'MONDAY','08:00:00','20:00:00',0),(7,37,'MONDAY','08:00:00','20:00:00',0),(8,38,'MONDAY','08:00:00','20:00:00',0),(9,39,'MONDAY','08:00:00','20:00:00',0),(10,40,'MONDAY','08:00:00','20:00:00',0),(11,41,'MONDAY','08:00:00','18:00:00',1),(12,42,'MONDAY','08:00:00','18:00:00',1),(13,43,'MONDAY','08:00:00','18:00:00',1),(14,44,'MONDAY','08:00:00','20:00:00',0),(15,45,'MONDAY','08:00:00','20:00:00',0),(16,46,'MONDAY','08:00:00','20:00:00',0),(17,47,'MONDAY','08:00:00','20:00:00',0),(18,48,'MONDAY','08:00:00','20:00:00',0),(19,49,'MONDAY','08:00:00','20:00:00',0),(20,50,'MONDAY','08:00:00','20:00:00',0),(21,51,'MONDAY','08:00:00','20:00:00',0),(22,52,'MONDAY','08:00:00','20:00:00',0),(23,53,'MONDAY','08:00:00','20:00:00',0),(24,54,'MONDAY','08:00:00','20:00:00',0),(25,55,'MONDAY','08:00:00','20:00:00',0);
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
INSERT INTO `customer` VALUES (1,'Customer 01','555-1001'),(2,'Customer 02','555-1002'),(3,'Customer 03','555-1003'),(4,'Customer 04','555-1004'),(5,'Customer 05','555-1005'),(6,'Customer 06','555-1006'),(7,'Customer 07','555-1007'),(8,'Customer 08','555-1008'),(9,'Customer 09','555-1009'),(10,'Customer 10','555-1010'),(11,'Customer 11','555-1011'),(12,'Customer 12','555-1012'),(13,'Customer 13','555-1013'),(14,'Customer 14','555-1014'),(15,'Customer 15','555-1015'),(16,'Customer 16','555-1016'),(17,'Customer 17','555-1017'),(18,'Customer 18','555-1018'),(19,'Customer 19','555-1019'),(20,'Customer 20','555-1020'),(21,'Customer 21','555-1021'),(22,'Customer 22','555-1022'),(23,'Customer 23','555-1023'),(24,'Customer 24','555-1024'),(25,'Customer 25','555-1025'),(26,'Customer 26','555-1026'),(27,'Customer 27','555-1027'),(28,'Customer 28','555-1028'),(29,'Customer 29','555-1029'),(30,'Customer 30','555-1030'),(56,'grubngo admin','0');
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu`
--

LOCK TABLES `menu` WRITE;
/*!40000 ALTER TABLE `menu` DISABLE KEYS */;
INSERT INTO `menu` VALUES (1,31,'Main Menu 01',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(2,32,'Main Menu 02',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(3,33,'Main Menu 03',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(4,34,'Main Menu 04',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(5,35,'Main Menu 05',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(6,36,'Main Menu 06',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(7,37,'Main Menu 07',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(8,38,'Main Menu 08',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(9,39,'Main Menu 09',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(10,40,'Main Menu 10',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(11,41,'Main Menu 11',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(12,42,'Main Menu 12',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(13,43,'Main Menu 13',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(14,44,'Main Menu 14',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(15,45,'Main Menu 15',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(16,46,'Main Menu 16',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(17,47,'Main Menu 17',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(18,48,'Main Menu 18',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(19,49,'Main Menu 19',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(20,50,'Main Menu 20',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(21,51,'Main Menu 21',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(22,52,'Main Menu 22',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(23,53,'Main Menu 23',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(24,54,'Main Menu 24',1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(25,55,'Main Menu 25',1,'2025-12-07 17:07:24','2025-12-07 17:07:24');
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
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menuitem`
--

LOCK TABLES `menuitem` WRITE;
/*!40000 ALTER TABLE `menuitem` DISABLE KEYS */;
INSERT INTO `menuitem` VALUES (1,1,'Menu Item 01A','Sample description for menu item 01A',11.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(2,1,'Menu Item 01B','Sample description for menu item 01B',13.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(3,2,'Menu Item 02A','Sample description for menu item 02A',12.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(4,2,'Menu Item 02B','Sample description for menu item 02B',14.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(5,3,'Menu Item 03A','Sample description for menu item 03A',13.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(6,3,'Menu Item 03B','Sample description for menu item 03B',15.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(7,4,'Menu Item 04A','Sample description for menu item 04A',14.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(8,4,'Menu Item 04B','Sample description for menu item 04B',16.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(9,5,'Menu Item 05A','Sample description for menu item 05A',15.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(10,5,'Menu Item 05B','Sample description for menu item 05B',17.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(11,6,'Menu Item 06A','Sample description for menu item 06A',16.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(12,6,'Menu Item 06B','Sample description for menu item 06B',18.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(13,7,'Menu Item 07A','Sample description for menu item 07A',17.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(14,7,'Menu Item 07B','Sample description for menu item 07B',19.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(15,8,'Menu Item 08A','Sample description for menu item 08A',18.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(16,8,'Menu Item 08B','Sample description for menu item 08B',20.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(17,9,'Menu Item 09A','Sample description for menu item 09A',19.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(18,9,'Menu Item 09B','Sample description for menu item 09B',21.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(19,10,'Menu Item 10A','Sample description for menu item 10A',20.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(20,10,'Menu Item 10B','Sample description for menu item 10B',22.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(21,11,'Menu Item 11A','Sample description for menu item 11A',21.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(22,11,'Menu Item 11B','Sample description for menu item 11B',23.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(23,12,'Menu Item 12A','Sample description for menu item 12A',22.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(24,12,'Menu Item 12B','Sample description for menu item 12B',24.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(25,13,'Menu Item 13A','Sample description for menu item 13A',23.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(26,13,'Menu Item 13B','Sample description for menu item 13B',25.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(27,14,'Menu Item 14A','Sample description for menu item 14A',24.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(28,14,'Menu Item 14B','Sample description for menu item 14B',26.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(29,15,'Menu Item 15A','Sample description for menu item 15A',25.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(30,15,'Menu Item 15B','Sample description for menu item 15B',27.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(31,16,'Menu Item 16A','Sample description for menu item 16A',26.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(32,16,'Menu Item 16B','Sample description for menu item 16B',28.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(33,17,'Menu Item 17A','Sample description for menu item 17A',27.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(34,17,'Menu Item 17B','Sample description for menu item 17B',29.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(35,18,'Menu Item 18A','Sample description for menu item 18A',28.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(36,18,'Menu Item 18B','Sample description for menu item 18B',30.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(37,19,'Menu Item 19A','Sample description for menu item 19A',29.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(38,19,'Menu Item 19B','Sample description for menu item 19B',31.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(39,20,'Menu Item 20A','Sample description for menu item 20A',30.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(40,20,'Menu Item 20B','Sample description for menu item 20B',32.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(41,21,'Menu Item 21A','Sample description for menu item 21A',31.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(42,21,'Menu Item 21B','Sample description for menu item 21B',33.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(43,22,'Menu Item 22A','Sample description for menu item 22A',32.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(44,22,'Menu Item 22B','Sample description for menu item 22B',34.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(45,23,'Menu Item 23A','Sample description for menu item 23A',33.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(46,23,'Menu Item 23B','Sample description for menu item 23B',35.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(47,24,'Menu Item 24A','Sample description for menu item 24A',34.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(48,24,'Menu Item 24B','Sample description for menu item 24B',36.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(49,25,'Menu Item 25A','Sample description for menu item 25A',35.99,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(50,25,'Menu Item 25B','Sample description for menu item 25B',37.49,1,NULL,NULL,'2025-12-07 17:07:24','2025-12-07 17:07:24');
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menuitempricehistory`
--

LOCK TABLES `menuitempricehistory` WRITE;
/*!40000 ALTER TABLE `menuitempricehistory` DISABLE KEYS */;
INSERT INTO `menuitempricehistory` VALUES (1,1,10.99,11.99,'2025-12-07 17:07:24',31),(2,2,12.49,13.49,'2025-12-07 17:07:24',31),(3,3,11.99,12.99,'2025-12-07 17:07:24',32),(4,4,13.49,14.49,'2025-12-07 17:07:24',32),(5,5,12.99,13.99,'2025-12-07 17:07:24',33),(6,6,14.49,15.49,'2025-12-07 17:07:24',33),(7,7,13.99,14.99,'2025-12-07 17:07:24',34),(8,8,15.49,16.49,'2025-12-07 17:07:24',34),(9,9,14.99,15.99,'2025-12-07 17:07:24',35),(10,10,16.49,17.49,'2025-12-07 17:07:24',35),(11,11,15.99,16.99,'2025-12-07 17:07:24',36),(12,12,17.49,18.49,'2025-12-07 17:07:24',36),(13,13,16.99,17.99,'2025-12-07 17:07:24',37),(14,14,18.49,19.49,'2025-12-07 17:07:24',37),(15,15,17.99,18.99,'2025-12-07 17:07:24',38),(16,16,19.49,20.49,'2025-12-07 17:07:24',38),(17,17,18.99,19.99,'2025-12-07 17:07:24',39),(18,18,20.49,21.49,'2025-12-07 17:07:24',39),(19,19,19.99,20.99,'2025-12-07 17:07:24',40),(20,20,21.49,22.49,'2025-12-07 17:07:24',40),(21,21,20.99,21.99,'2025-12-07 17:07:24',41),(22,22,22.49,23.49,'2025-12-07 17:07:24',41),(23,23,21.99,22.99,'2025-12-07 17:07:24',42),(24,24,23.49,24.49,'2025-12-07 17:07:24',42),(25,25,22.99,23.99,'2025-12-07 17:07:24',43);
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `modifier`
--

LOCK TABLES `modifier` WRITE;
/*!40000 ALTER TABLE `modifier` DISABLE KEYS */;
INSERT INTO `modifier` VALUES (1,1,'Size Option 01',0,3,0,'2025-12-07 17:07:24'),(2,2,'Size Option 02',0,3,1,'2025-12-07 17:07:24'),(3,3,'Size Option 03',0,3,0,'2025-12-07 17:07:24'),(4,4,'Size Option 04',0,3,1,'2025-12-07 17:07:24'),(5,5,'Size Option 05',0,3,0,'2025-12-07 17:07:24'),(6,6,'Size Option 06',0,3,1,'2025-12-07 17:07:24'),(7,7,'Size Option 07',0,3,0,'2025-12-07 17:07:24'),(8,8,'Size Option 08',0,3,1,'2025-12-07 17:07:24'),(9,9,'Size Option 09',0,3,0,'2025-12-07 17:07:24'),(10,10,'Size Option 10',0,3,1,'2025-12-07 17:07:24'),(11,11,'Size Option 11',0,3,0,'2025-12-07 17:07:24'),(12,12,'Size Option 12',0,3,1,'2025-12-07 17:07:24'),(13,13,'Size Option 13',0,3,0,'2025-12-07 17:07:24'),(14,14,'Size Option 14',0,3,1,'2025-12-07 17:07:24'),(15,15,'Size Option 15',0,3,0,'2025-12-07 17:07:24'),(16,16,'Size Option 16',0,3,1,'2025-12-07 17:07:24'),(17,17,'Size Option 17',0,3,0,'2025-12-07 17:07:24'),(18,18,'Size Option 18',0,3,1,'2025-12-07 17:07:24'),(19,19,'Size Option 19',0,3,0,'2025-12-07 17:07:24'),(20,20,'Size Option 20',0,3,1,'2025-12-07 17:07:24'),(21,21,'Size Option 21',0,3,0,'2025-12-07 17:07:24'),(22,22,'Size Option 22',0,3,1,'2025-12-07 17:07:24'),(23,23,'Size Option 23',0,3,0,'2025-12-07 17:07:24'),(24,24,'Size Option 24',0,3,1,'2025-12-07 17:07:24'),(25,25,'Size Option 25',0,3,0,'2025-12-07 17:07:24');
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `modifieroption`
--

LOCK TABLES `modifieroption` WRITE;
/*!40000 ALTER TABLE `modifieroption` DISABLE KEYS */;
INSERT INTO `modifieroption` VALUES (1,1,'Standard Option 01',0.00,1,'2025-12-07 17:07:24'),(2,2,'Standard Option 02',1.00,1,'2025-12-07 17:07:24'),(3,3,'Standard Option 03',0.00,1,'2025-12-07 17:07:24'),(4,4,'Standard Option 04',1.00,1,'2025-12-07 17:07:24'),(5,5,'Standard Option 05',0.00,1,'2025-12-07 17:07:24'),(6,6,'Standard Option 06',1.00,1,'2025-12-07 17:07:24'),(7,7,'Standard Option 07',0.00,1,'2025-12-07 17:07:24'),(8,8,'Standard Option 08',1.00,1,'2025-12-07 17:07:24'),(9,9,'Standard Option 09',0.00,1,'2025-12-07 17:07:24'),(10,10,'Standard Option 10',1.00,1,'2025-12-07 17:07:24'),(11,11,'Standard Option 11',0.00,1,'2025-12-07 17:07:24'),(12,12,'Standard Option 12',1.00,1,'2025-12-07 17:07:24'),(13,13,'Standard Option 13',0.00,1,'2025-12-07 17:07:24'),(14,14,'Standard Option 14',1.00,1,'2025-12-07 17:07:24'),(15,15,'Standard Option 15',0.00,1,'2025-12-07 17:07:24'),(16,16,'Standard Option 16',1.00,1,'2025-12-07 17:07:24'),(17,17,'Standard Option 17',0.00,1,'2025-12-07 17:07:24'),(18,18,'Standard Option 18',1.00,1,'2025-12-07 17:07:24'),(19,19,'Standard Option 19',0.00,1,'2025-12-07 17:07:24'),(20,20,'Standard Option 20',1.00,1,'2025-12-07 17:07:24'),(21,21,'Standard Option 21',0.00,1,'2025-12-07 17:07:24'),(22,22,'Standard Option 22',1.00,1,'2025-12-07 17:07:24'),(23,23,'Standard Option 23',0.00,1,'2025-12-07 17:07:24'),(24,24,'Standard Option 24',1.00,1,'2025-12-07 17:07:24'),(25,25,'Standard Option 25',0.00,1,'2025-12-07 17:07:24');
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order`
--

LOCK TABLES `order` WRITE;
/*!40000 ALTER TABLE `order` DISABLE KEYS */;
INSERT INTO `order` VALUES (1,1,31,1,'101 Market St','San Francisco','CA','94101','USA','DELIVERED','2025-01-01 10:00:00','2025-01-01 10:05:00','2025-01-01 10:25:00','2025-01-01 10:35:00','2025-01-01 10:50:00','2025-01-01 11:15:00',NULL,'2025-12-07 17:07:24',11.99,1.05,0.0875,3.50,1.50,2.50,1.00,19.54,1,1),(2,2,32,2,'102 Market St','San Francisco','CA','94102','USA','DELIVERED','2025-01-02 10:00:00','2025-01-02 10:05:00','2025-01-02 10:25:00','2025-01-02 10:35:00','2025-01-02 10:50:00','2025-01-02 11:15:00',NULL,'2025-12-07 17:07:24',12.99,1.14,0.0875,3.50,1.50,2.50,1.00,20.63,2,1),(3,3,33,3,'103 Market St','San Francisco','CA','94103','USA','OUT_FOR_DELIVERY','2025-01-03 10:00:00','2025-01-03 10:05:00','2025-01-03 10:25:00','2025-01-03 10:35:00','2025-01-03 10:50:00',NULL,NULL,'2025-12-07 17:07:24',13.99,1.22,0.0875,3.50,1.50,2.50,1.00,21.71,3,1),(4,4,34,4,'104 Market St','San Francisco','CA','94104','USA','PREPARING','2025-01-04 10:00:00','2025-01-04 10:05:00',NULL,NULL,NULL,NULL,NULL,'2025-12-07 17:07:24',14.99,1.31,0.0875,3.50,1.50,2.50,1.00,22.80,4,1),(5,5,35,5,'105 Market St','San Francisco','CA','94105','USA','DELIVERED','2025-01-05 10:00:00','2025-01-05 10:05:00','2025-01-05 10:25:00','2025-01-05 10:35:00','2025-01-05 10:50:00','2025-01-05 11:15:00',NULL,'2025-12-07 17:07:24',15.99,1.40,0.0875,3.50,1.50,2.50,1.00,23.89,5,1),(6,6,36,6,'106 Market St','San Francisco','CA','94106','USA','CONFIRMED','2025-01-06 10:00:00','2025-01-06 10:05:00',NULL,NULL,NULL,NULL,NULL,'2025-12-07 17:07:24',16.99,1.49,0.0875,3.50,1.50,2.50,1.00,24.98,6,1),(7,7,37,7,'107 Market St','San Francisco','CA','94107','USA','READY','2025-01-07 10:00:00','2025-01-07 10:05:00','2025-01-07 10:25:00','2025-01-07 10:35:00',NULL,NULL,NULL,'2025-12-07 17:07:24',17.99,1.57,0.0875,3.50,1.50,2.50,1.00,26.06,7,1),(8,8,38,8,'108 Market St','San Francisco','CA','94108','USA','DELIVERED','2025-01-08 10:00:00','2025-01-08 10:05:00','2025-01-08 10:25:00','2025-01-08 10:35:00','2025-01-08 10:50:00','2025-01-08 11:15:00',NULL,'2025-12-07 17:07:24',18.99,1.66,0.0875,3.50,1.50,2.50,1.00,27.15,8,1),(9,9,39,9,'109 Market St','San Francisco','CA','94109','USA','DELIVERED','2025-01-09 10:00:00','2025-01-09 10:05:00','2025-01-09 10:25:00','2025-01-09 10:35:00','2025-01-09 10:50:00','2025-01-09 11:15:00',NULL,'2025-12-07 17:07:24',19.99,1.75,0.0875,3.50,1.50,2.50,1.00,28.24,9,1),(10,10,40,10,'110 Market St','San Francisco','CA','94110','USA','CANCELLED','2025-01-10 10:00:00','2025-01-10 10:05:00',NULL,NULL,NULL,NULL,'2025-01-10 10:20:00','2025-12-07 17:07:24',20.99,1.84,0.0875,3.50,1.50,2.50,1.00,29.33,10,0),(11,11,41,11,'111 Market St','San Francisco','CA','94111','USA','DELIVERED','2025-01-11 10:00:00','2025-01-11 10:05:00','2025-01-11 10:25:00','2025-01-11 10:35:00','2025-01-11 10:50:00','2025-01-11 11:15:00',NULL,'2025-12-07 17:07:24',21.99,1.92,0.0875,3.50,1.50,2.50,1.00,30.41,11,1),(12,12,42,12,'112 Market St','San Francisco','CA','94112','USA','DELIVERED','2025-01-12 10:00:00','2025-01-12 10:05:00','2025-01-12 10:25:00','2025-01-12 10:35:00','2025-01-12 10:50:00','2025-01-12 11:15:00',NULL,'2025-12-07 17:07:24',22.99,2.01,0.0875,3.50,1.50,2.50,1.00,31.50,12,1),(13,13,43,13,'113 Market St','San Francisco','CA','94113','USA','FAILED','2025-01-13 10:00:00',NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-07 17:07:24',23.99,2.10,0.0875,3.50,1.50,2.50,1.00,32.59,13,0),(14,14,44,14,'114 Market St','San Francisco','CA','94114','USA','DELIVERED','2025-01-14 10:00:00','2025-01-14 10:05:00','2025-01-14 10:25:00','2025-01-14 10:35:00','2025-01-14 10:50:00','2025-01-14 11:15:00',NULL,'2025-12-07 17:07:24',24.99,2.19,0.0875,3.50,1.50,2.50,1.00,33.68,14,1),(15,15,45,15,'115 Market St','San Francisco','CA','94115','USA','DELIVERED','2025-01-15 10:00:00','2025-01-15 10:05:00','2025-01-15 10:25:00','2025-01-15 10:35:00','2025-01-15 10:50:00','2025-01-15 11:15:00',NULL,'2025-12-07 17:07:24',25.99,2.27,0.0875,3.50,1.50,2.50,1.00,34.76,15,1),(16,16,46,16,'116 Market St','San Francisco','CA','94116','USA','PREPARING','2025-01-16 10:00:00','2025-01-16 10:05:00',NULL,NULL,NULL,NULL,NULL,'2025-12-07 17:07:24',26.99,2.36,0.0875,3.50,1.50,2.50,1.00,35.85,16,1),(17,17,47,17,'117 Market St','San Francisco','CA','94117','USA','DELIVERED','2025-01-17 10:00:00','2025-01-17 10:05:00','2025-01-17 10:25:00','2025-01-17 10:35:00','2025-01-17 10:50:00','2025-01-17 11:15:00',NULL,'2025-12-07 17:07:24',27.99,2.45,0.0875,3.50,1.50,2.50,1.00,36.94,17,1),(18,18,48,18,'118 Market St','San Francisco','CA','94118','USA','DELIVERED','2025-01-18 10:00:00','2025-01-18 10:05:00','2025-01-18 10:25:00','2025-01-18 10:35:00','2025-01-18 10:50:00','2025-01-18 11:15:00',NULL,'2025-12-07 17:07:24',28.99,2.54,0.0875,3.50,1.50,2.50,1.00,38.03,18,1),(19,19,49,19,'119 Market St','San Francisco','CA','94119','USA','OUT_FOR_DELIVERY','2025-01-19 10:00:00','2025-01-19 10:05:00','2025-01-19 10:25:00','2025-01-19 10:35:00','2025-01-19 10:50:00',NULL,NULL,'2025-12-07 17:07:24',29.99,2.62,0.0875,3.50,1.50,2.50,1.00,39.11,19,1),(20,20,50,20,'120 Market St','San Francisco','CA','94120','USA','DELIVERED','2025-01-20 10:00:00','2025-01-20 10:05:00','2025-01-20 10:25:00','2025-01-20 10:35:00','2025-01-20 10:50:00','2025-01-20 11:15:00',NULL,'2025-12-07 17:07:24',30.99,2.71,0.0875,3.50,1.50,2.50,1.00,40.20,20,1),(21,21,51,21,'121 Market St','San Francisco','CA','94121','USA','CONFIRMED','2025-01-21 10:00:00','2025-01-21 10:05:00',NULL,NULL,NULL,NULL,NULL,'2025-12-07 17:07:24',31.99,2.80,0.0875,3.50,1.50,2.50,1.00,41.29,21,1),(22,22,52,22,'122 Market St','San Francisco','CA','94122','USA','DELIVERED','2025-01-22 10:00:00','2025-01-22 10:05:00','2025-01-22 10:25:00','2025-01-22 10:35:00','2025-01-22 10:50:00','2025-01-22 11:15:00',NULL,'2025-12-07 17:07:24',32.99,2.89,0.0875,3.50,1.50,2.50,1.00,42.38,22,1),(23,23,53,23,'123 Market St','San Francisco','CA','94123','USA','DELIVERED','2025-01-23 10:00:00','2025-01-23 10:05:00','2025-01-23 10:25:00','2025-01-23 10:35:00','2025-01-23 10:50:00','2025-01-23 11:15:00',NULL,'2025-12-07 17:07:24',33.99,2.97,0.0875,3.50,1.50,2.50,1.00,43.46,23,1),(24,24,54,24,'124 Market St','San Francisco','CA','94124','USA','DELIVERED','2025-01-24 10:00:00','2025-01-24 10:05:00','2025-01-24 10:25:00','2025-01-24 10:35:00','2025-01-24 10:50:00','2025-01-24 11:15:00',NULL,'2025-12-07 17:07:24',34.99,3.06,0.0875,3.50,1.50,2.50,1.00,44.55,24,1),(25,25,55,25,'125 Market St','San Francisco','CA','94125','USA','DELIVERED','2025-01-25 10:00:00','2025-01-25 10:05:00','2025-01-25 10:25:00','2025-01-25 10:35:00','2025-01-25 10:50:00','2025-01-25 11:15:00',NULL,'2025-12-07 17:07:24',35.99,3.15,0.0875,3.50,1.50,2.50,1.00,45.64,25,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderitem`
--

LOCK TABLES `orderitem` WRITE;
/*!40000 ALTER TABLE `orderitem` DISABLE KEYS */;
INSERT INTO `orderitem` VALUES (1,1,1,'Menu Item 01A','Sample description for menu item 01A',1,11.99,NULL),(2,2,3,'Menu Item 02A','Sample description for menu item 02A',1,12.99,NULL),(3,3,5,'Menu Item 03A','Sample description for menu item 03A',1,13.99,NULL),(4,4,7,'Menu Item 04A','Sample description for menu item 04A',1,14.99,NULL),(5,5,9,'Menu Item 05A','Sample description for menu item 05A',1,15.99,NULL),(6,6,11,'Menu Item 06A','Sample description for menu item 06A',1,16.99,NULL),(7,7,13,'Menu Item 07A','Sample description for menu item 07A',1,17.99,NULL),(8,8,15,'Menu Item 08A','Sample description for menu item 08A',1,18.99,NULL),(9,9,17,'Menu Item 09A','Sample description for menu item 09A',1,19.99,NULL),(10,10,19,'Menu Item 10A','Sample description for menu item 10A',1,20.99,NULL),(11,11,21,'Menu Item 11A','Sample description for menu item 11A',1,21.99,NULL),(12,12,23,'Menu Item 12A','Sample description for menu item 12A',1,22.99,NULL),(13,13,25,'Menu Item 13A','Sample description for menu item 13A',1,23.99,NULL),(14,14,27,'Menu Item 14A','Sample description for menu item 14A',1,24.99,NULL),(15,15,29,'Menu Item 15A','Sample description for menu item 15A',1,25.99,NULL),(16,16,31,'Menu Item 16A','Sample description for menu item 16A',1,26.99,NULL),(17,17,33,'Menu Item 17A','Sample description for menu item 17A',1,27.99,NULL),(18,18,35,'Menu Item 18A','Sample description for menu item 18A',1,28.99,NULL),(19,19,37,'Menu Item 19A','Sample description for menu item 19A',1,29.99,NULL),(20,20,39,'Menu Item 20A','Sample description for menu item 20A',1,30.99,NULL),(21,21,41,'Menu Item 21A','Sample description for menu item 21A',1,31.99,NULL),(22,22,43,'Menu Item 22A','Sample description for menu item 22A',1,32.99,NULL),(23,23,45,'Menu Item 23A','Sample description for menu item 23A',1,33.99,NULL),(24,24,47,'Menu Item 24A','Sample description for menu item 24A',1,34.99,NULL),(25,25,49,'Menu Item 25A','Sample description for menu item 25A',1,35.99,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderitemmodifier`
--

LOCK TABLES `orderitemmodifier` WRITE;
/*!40000 ALTER TABLE `orderitemmodifier` DISABLE KEYS */;
INSERT INTO `orderitemmodifier` VALUES (1,1,1,'Size Option 01','Standard Option 01',0.00),(2,2,2,'Size Option 02','Standard Option 02',1.00),(3,3,3,'Size Option 03','Standard Option 03',0.00),(4,4,4,'Size Option 04','Standard Option 04',1.00),(5,5,5,'Size Option 05','Standard Option 05',0.00),(6,6,6,'Size Option 06','Standard Option 06',1.00),(7,7,7,'Size Option 07','Standard Option 07',0.00),(8,8,8,'Size Option 08','Standard Option 08',1.00),(9,9,9,'Size Option 09','Standard Option 09',0.00),(10,10,10,'Size Option 10','Standard Option 10',1.00),(11,11,11,'Size Option 11','Standard Option 11',0.00),(12,12,12,'Size Option 12','Standard Option 12',1.00),(13,13,13,'Size Option 13','Standard Option 13',0.00),(14,14,14,'Size Option 14','Standard Option 14',1.00),(15,15,15,'Size Option 15','Standard Option 15',0.00),(16,16,16,'Size Option 16','Standard Option 16',1.00),(17,17,17,'Size Option 17','Standard Option 17',0.00),(18,18,18,'Size Option 18','Standard Option 18',1.00),(19,19,19,'Size Option 19','Standard Option 19',0.00),(20,20,20,'Size Option 20','Standard Option 20',1.00),(21,21,21,'Size Option 21','Standard Option 21',0.00),(22,22,22,'Size Option 22','Standard Option 22',1.00),(23,23,23,'Size Option 23','Standard Option 23',0.00),(24,24,24,'Size Option 24','Standard Option 24',1.00),(25,25,25,'Size Option 25','Standard Option 25',0.00);
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
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paymentmethod`
--

LOCK TABLES `paymentmethod` WRITE;
/*!40000 ALTER TABLE `paymentmethod` DISABLE KEYS */;
INSERT INTO `paymentmethod` VALUES (1,1,'CREDIT_CARD','tok_cust_01','1111','Visa',12,2028,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(2,2,'DEBIT_CARD','tok_cust_02','2222','Mastercard',11,2027,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(3,3,'PAYPAL','pp_cust_03',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(4,4,'APPLE_PAY','ap_cust_04',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(5,5,'GOOGLE_PAY','gp_cust_05',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(6,6,'CREDIT_CARD','tok_cust_06','3333','Visa',10,2029,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(7,7,'DEBIT_CARD','tok_cust_07','4444','Mastercard',9,2028,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(8,8,'PAYPAL','pp_cust_08',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(9,9,'APPLE_PAY','ap_cust_09',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(10,10,'GOOGLE_PAY','gp_cust_10',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(11,11,'CREDIT_CARD','tok_cust_11','5555','Visa',8,2027,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(12,12,'DEBIT_CARD','tok_cust_12','6666','Mastercard',7,2029,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(13,13,'PAYPAL','pp_cust_13',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(14,14,'APPLE_PAY','ap_cust_14',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(15,15,'GOOGLE_PAY','gp_cust_15',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(16,16,'CREDIT_CARD','tok_cust_16','7777','Visa',6,2028,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(17,17,'DEBIT_CARD','tok_cust_17','8888','Mastercard',5,2027,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(18,18,'PAYPAL','pp_cust_18',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(19,19,'APPLE_PAY','ap_cust_19',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(20,20,'GOOGLE_PAY','gp_cust_20',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(21,21,'CREDIT_CARD','tok_cust_21','9999','Visa',4,2029,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(22,22,'DEBIT_CARD','tok_cust_22','0001','Mastercard',3,2028,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(23,23,'PAYPAL','pp_cust_23',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(24,24,'APPLE_PAY','ap_cust_24',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(25,25,'GOOGLE_PAY','gp_cust_25',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(26,26,'CREDIT_CARD','tok_cust_26','2468','Visa',2,2030,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(27,27,'DEBIT_CARD','tok_cust_27','1357','Mastercard',1,2029,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(28,28,'PAYPAL','pp_cust_28',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(29,29,'APPLE_PAY','ap_cust_29',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24'),(30,30,'GOOGLE_PAY','gp_cust_30',NULL,NULL,NULL,NULL,1,'2025-12-07 17:07:24','2025-12-07 17:07:24');
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refund`
--

LOCK TABLES `refund` WRITE;
/*!40000 ALTER TABLE `refund` DISABLE KEYS */;
INSERT INTO `refund` VALUES (1,1,1,1.60,'Courtesy adjustment 01','COMPLETED','2025-02-01 09:00:00','2025-02-01 09:30:00',1),(2,2,2,1.70,'Courtesy adjustment 02','COMPLETED','2025-02-02 09:00:00','2025-02-02 09:30:00',2),(3,3,3,1.80,'Courtesy adjustment 03','COMPLETED','2025-02-03 09:00:00','2025-02-03 09:30:00',3),(4,4,4,1.90,'Courtesy adjustment 04','COMPLETED','2025-02-04 09:00:00','2025-02-04 09:30:00',4),(5,5,5,2.00,'Courtesy adjustment 05','COMPLETED','2025-02-05 09:00:00','2025-02-05 09:30:00',5),(6,6,6,2.10,'Courtesy adjustment 06','COMPLETED','2025-02-06 09:00:00','2025-02-06 09:30:00',6),(7,7,7,2.20,'Courtesy adjustment 07','COMPLETED','2025-02-07 09:00:00','2025-02-07 09:30:00',7),(8,8,8,2.30,'Courtesy adjustment 08','COMPLETED','2025-02-08 09:00:00','2025-02-08 09:30:00',8),(9,9,9,2.40,'Courtesy adjustment 09','COMPLETED','2025-02-09 09:00:00','2025-02-09 09:30:00',9),(10,10,10,2.50,'Courtesy adjustment 10','COMPLETED','2025-02-10 09:00:00','2025-02-10 09:30:00',10),(11,11,11,2.60,'Courtesy adjustment 11','PENDING','2025-02-11 09:00:00',NULL,11),(12,12,12,2.70,'Courtesy adjustment 12','PENDING','2025-02-12 09:00:00',NULL,12),(13,13,13,2.80,'Courtesy adjustment 13','PENDING','2025-02-13 09:00:00',NULL,13),(14,14,14,2.90,'Courtesy adjustment 14','PENDING','2025-02-14 09:00:00',NULL,14),(15,15,15,3.00,'Courtesy adjustment 15','PENDING','2025-02-15 09:00:00',NULL,15),(16,16,NULL,3.10,'Courtesy adjustment 16','PENDING','2025-02-16 09:00:00',NULL,16),(17,17,NULL,3.20,'Courtesy adjustment 17','PENDING','2025-02-17 09:00:00',NULL,17),(18,18,NULL,3.30,'Courtesy adjustment 18','PENDING','2025-02-18 09:00:00',NULL,18),(19,19,NULL,3.40,'Courtesy adjustment 19','PENDING','2025-02-19 09:00:00',NULL,19),(20,20,NULL,3.50,'Courtesy adjustment 20','PENDING','2025-02-20 09:00:00',NULL,20),(21,21,NULL,3.60,'Courtesy adjustment 21','FAILED','2025-02-21 09:00:00','2025-02-21 09:45:00',21),(22,22,NULL,3.70,'Courtesy adjustment 22','FAILED','2025-02-22 09:00:00','2025-02-22 09:45:00',22),(23,23,NULL,3.80,'Courtesy adjustment 23','FAILED','2025-02-23 09:00:00','2025-02-23 09:45:00',23),(24,24,NULL,3.90,'Courtesy adjustment 24','FAILED','2025-02-24 09:00:00','2025-02-24 09:45:00',24),(25,25,NULL,4.00,'Courtesy adjustment 25','FAILED','2025-02-25 09:00:00','2025-02-25 09:45:00',25);
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
INSERT INTO `restaurant` VALUES (31,'Restaurant 01','555-2001','contact_restaurant01@grubngo.com','OPEN','201 Market St','San Francisco','CA','94131','USA',NULL,NULL),(32,'Restaurant 02','555-2002','contact_restaurant02@grubngo.com','OPEN','202 Market St','San Francisco','CA','94132','USA',NULL,NULL),(33,'Restaurant 03','555-2003','contact_restaurant03@grubngo.com','OPEN','203 Market St','San Francisco','CA','94133','USA',NULL,NULL),(34,'Restaurant 04','555-2004','contact_restaurant04@grubngo.com','OPEN','204 Market St','San Francisco','CA','94134','USA',NULL,NULL),(35,'Restaurant 05','555-2005','contact_restaurant05@grubngo.com','OPEN','205 Market St','San Francisco','CA','94135','USA',NULL,NULL),(36,'Restaurant 06','555-2006','contact_restaurant06@grubngo.com','OPEN','206 Market St','San Francisco','CA','94136','USA',NULL,NULL),(37,'Restaurant 07','555-2007','contact_restaurant07@grubngo.com','OPEN','207 Market St','San Francisco','CA','94137','USA',NULL,NULL),(38,'Restaurant 08','555-2008','contact_restaurant08@grubngo.com','OPEN','208 Market St','San Francisco','CA','94138','USA',NULL,NULL),(39,'Restaurant 09','555-2009','contact_restaurant09@grubngo.com','OPEN','209 Market St','San Francisco','CA','94139','USA',NULL,NULL),(40,'Restaurant 10','555-2010','contact_restaurant10@grubngo.com','OPEN','210 Market St','San Francisco','CA','94140','USA',NULL,NULL),(41,'Restaurant 11','555-2011','contact_restaurant11@grubngo.com','TEMPORARILY_CLOSED','211 Market St','San Francisco','CA','94141','USA',NULL,NULL),(42,'Restaurant 12','555-2012','contact_restaurant12@grubngo.com','TEMPORARILY_CLOSED','212 Market St','San Francisco','CA','94142','USA',NULL,NULL),(43,'Restaurant 13','555-2013','contact_restaurant13@grubngo.com','TEMPORARILY_CLOSED','213 Market St','San Francisco','CA','94143','USA',NULL,NULL),(44,'Restaurant 14','555-2014','contact_restaurant14@grubngo.com','OPEN','214 Market St','San Francisco','CA','94144','USA',NULL,NULL),(45,'Restaurant 15','555-2015','contact_restaurant15@grubngo.com','PERMANENTLY_CLOSED','215 Market St','San Francisco','CA','94145','USA',NULL,NULL),(46,'Restaurant 16','555-2016','contact_restaurant16@grubngo.com','OPEN','216 Market St','San Francisco','CA','94146','USA',NULL,NULL),(47,'Restaurant 17','555-2017','contact_restaurant17@grubngo.com','OPEN','217 Market St','San Francisco','CA','94147','USA',NULL,NULL),(48,'Restaurant 18','555-2018','contact_restaurant18@grubngo.com','OPEN','218 Market St','San Francisco','CA','94148','USA',NULL,NULL),(49,'Restaurant 19','555-2019','contact_restaurant19@grubngo.com','OPEN','219 Market St','San Francisco','CA','94149','USA',NULL,NULL),(50,'Restaurant 20','555-2020','contact_restaurant20@grubngo.com','OPEN','220 Market St','San Francisco','CA','94150','USA',NULL,NULL),(51,'Restaurant 21','555-2021','contact_restaurant21@grubngo.com','OPEN','221 Market St','San Francisco','CA','94151','USA',NULL,NULL),(52,'Restaurant 22','555-2022','contact_restaurant22@grubngo.com','OPEN','222 Market St','San Francisco','CA','94152','USA',NULL,NULL),(53,'Restaurant 23','555-2023','contact_restaurant23@grubngo.com','OPEN','223 Market St','San Francisco','CA','94153','USA',NULL,NULL),(54,'Restaurant 24','555-2024','contact_restaurant24@grubngo.com','OPEN','224 Market St','San Francisco','CA','94154','USA',NULL,NULL),(55,'Restaurant 25','555-2025','contact_restaurant25@grubngo.com','OPEN','225 Market St','San Francisco','CA','94155','USA',NULL,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction`
--

LOCK TABLES `transaction` WRITE;
/*!40000 ALTER TABLE `transaction` DISABLE KEYS */;
INSERT INTO `transaction` VALUES (1,1,'CAPTURE',19.54,'SUCCESS','Stripe','txn_0001',NULL,'2025-12-07 17:07:24','2025-01-01 10:10:00'),(2,2,'CAPTURE',20.63,'SUCCESS','Stripe','txn_0002',NULL,'2025-12-07 17:07:24','2025-01-02 10:10:00'),(3,3,'CAPTURE',21.71,'SUCCESS','Stripe','txn_0003',NULL,'2025-12-07 17:07:24','2025-01-03 10:10:00'),(4,4,'CAPTURE',22.80,'SUCCESS','Stripe','txn_0004',NULL,'2025-12-07 17:07:24','2025-01-04 10:10:00'),(5,5,'CAPTURE',23.89,'SUCCESS','Stripe','txn_0005',NULL,'2025-12-07 17:07:24','2025-01-05 10:10:00'),(6,6,'CAPTURE',24.98,'SUCCESS','Stripe','txn_0006',NULL,'2025-12-07 17:07:24','2025-01-06 10:10:00'),(7,7,'CAPTURE',26.06,'SUCCESS','Stripe','txn_0007',NULL,'2025-12-07 17:07:24','2025-01-07 10:10:00'),(8,8,'CAPTURE',27.15,'SUCCESS','Stripe','txn_0008',NULL,'2025-12-07 17:07:24','2025-01-08 10:10:00'),(9,9,'CAPTURE',28.24,'SUCCESS','Stripe','txn_0009',NULL,'2025-12-07 17:07:24','2025-01-09 10:10:00'),(10,10,'CAPTURE',29.33,'SUCCESS','Stripe','txn_0010',NULL,'2025-12-07 17:07:24','2025-01-10 10:10:00'),(11,11,'CAPTURE',30.41,'SUCCESS','Stripe','txn_0011',NULL,'2025-12-07 17:07:24','2025-01-11 10:10:00'),(12,12,'CAPTURE',31.50,'SUCCESS','Stripe','txn_0012',NULL,'2025-12-07 17:07:24','2025-01-12 10:10:00'),(13,13,'CAPTURE',32.59,'SUCCESS','Stripe','txn_0013',NULL,'2025-12-07 17:07:24','2025-01-13 10:10:00'),(14,14,'CAPTURE',33.68,'SUCCESS','Stripe','txn_0014',NULL,'2025-12-07 17:07:24','2025-01-14 10:10:00'),(15,15,'CAPTURE',34.76,'SUCCESS','Stripe','txn_0015',NULL,'2025-12-07 17:07:24','2025-01-15 10:10:00'),(16,16,'CAPTURE',35.85,'SUCCESS','Stripe','txn_0016',NULL,'2025-12-07 17:07:24','2025-01-16 10:10:00'),(17,17,'CAPTURE',36.94,'SUCCESS','Stripe','txn_0017',NULL,'2025-12-07 17:07:24','2025-01-17 10:10:00'),(18,18,'CAPTURE',38.03,'SUCCESS','Stripe','txn_0018',NULL,'2025-12-07 17:07:24','2025-01-18 10:10:00'),(19,19,'CAPTURE',39.11,'SUCCESS','Stripe','txn_0019',NULL,'2025-12-07 17:07:24','2025-01-19 10:10:00'),(20,20,'CAPTURE',40.20,'SUCCESS','Stripe','txn_0020',NULL,'2025-12-07 17:07:24','2025-01-20 10:10:00'),(21,21,'CAPTURE',41.29,'SUCCESS','Stripe','txn_0021',NULL,'2025-12-07 17:07:24','2025-01-21 10:10:00'),(22,22,'CAPTURE',42.38,'SUCCESS','Stripe','txn_0022',NULL,'2025-12-07 17:07:24','2025-01-22 10:10:00'),(23,23,'CAPTURE',43.46,'SUCCESS','Stripe','txn_0023',NULL,'2025-12-07 17:07:24','2025-01-23 10:10:00'),(24,24,'CAPTURE',44.55,'SUCCESS','Stripe','txn_0024',NULL,'2025-12-07 17:07:24','2025-01-24 10:10:00'),(25,25,'CAPTURE',45.64,'SUCCESS','Stripe','txn_0025',NULL,'2025-12-07 17:07:24','2025-01-25 10:10:00');
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

-- Dump completed on 2025-12-07 17:14:43
