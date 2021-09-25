-- MySQL dump 10.13  Distrib 5.7.33, for Linux (x86_64)
--
-- Host: localhost    Database: sls
-- ------------------------------------------------------
-- Server version	5.7.33-0ubuntu0.16.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `qrcodes`
--

DROP TABLE IF EXISTS `qrcodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qrcodes` (
  `srid` int(11) NOT NULL AUTO_INCREMENT,
  `product_name` varchar(25) NOT NULL,
  `product_code` varchar(20) NOT NULL,
  `product_batch` smallint(6) NOT NULL,
  `product_batch_MY` char(8) NOT NULL,
  `pdfName` varchar(25) NOT NULL,
  `createdOn` datetime NOT NULL,
  PRIMARY KEY (`srid`),
  UNIQUE KEY `product_name` (`product_name`,`product_code`,`product_batch`,`product_batch_MY`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrcodes`
--

LOCK TABLES `qrcodes` WRITE;
/*!40000 ALTER TABLE `qrcodes` DISABLE KEYS */;
INSERT INTO `qrcodes` VALUES (1,'MENAQUINONE-7 (R1518)','WM/MQG/1500 OSF',2115,'JUN/2021','JUN_2021_2115_20963','2021-06-04 16:55:53'),(2,'MENAQUINONE-7 (R1518)','WM/MQG/1500 OSF',2116,'JUN/2021','JUN_2021_2116_21365','2021-06-04 17:02:42'),(3,'MENAQUINONE-7 (R1518)','WM/MQG/1500 OSF',2117,'JUN/2021','JUN_2021_2117_23500','2021-06-04 17:09:30'),(4,'MENAQUINONE-7 (R1518)','WM/MQG/1500 OSF',2118,'JUN/2021','JUN_2021_2118_23927','2021-06-04 17:12:47'),(5,'MENAQUINONE-7 (R1518)','WM/MQG/1500 OSF',2119,'JUN/2021','JUN_2021_2119_24183','2021-06-04 17:16:10'),(6,'MENAQUINONE-7 (R1518)','WM/MQG/1500 OSF',2120,'JUN/2021','JUN_2021_2120_26465','2021-06-04 17:43:14');
/*!40000 ALTER TABLE `qrcodes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unique_product_codes`
--

DROP TABLE IF EXISTS `unique_product_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unique_product_codes` (
  `srid` int(11) NOT NULL AUTO_INCREMENT,
  `product_name` varchar(25) NOT NULL,
  `product_code` varchar(20) NOT NULL,
  `createdOn` datetime NOT NULL,
  PRIMARY KEY (`srid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unique_product_codes`
--

LOCK TABLES `unique_product_codes` WRITE;
/*!40000 ALTER TABLE `unique_product_codes` DISABLE KEYS */;
INSERT INTO `unique_product_codes` VALUES (1,'MENAQUINONE-7 (R1518)','WM/MQG/1500 OSF','2021-06-04 16:55:53');
/*!40000 ALTER TABLE `unique_product_codes` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-06-04 18:07:06
