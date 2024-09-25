DROP DATABASE IF EXISTS `base`;

CREATE DATABASE `base`;

USE `base`;

--
-- Tables
--

CREATE TABLE `accounts` (
    `id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(24) NOT NULL,
    `hash` VARCHAR(61) NOT NULL
);

CREATE TABLE `characters` (
    `id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `account_id` INT NOT NULL,
    `name` VARCHAR(24) NOT NULL,
    `gender` TINYINT NOT NULL,
    `age` TINYINT NOT NULL,
    `skin` SMALLINT NOT NULL,
    `money` INT NOT NULL DEFAULT 0,
    `world` INT NOT NULL DEFAULT 0,
    `interior` TINYINT NOT NULL DEFAULT 0,
    `health` FLOAT NOT NULL DEFAULT 100.0,
    `armour` FLOAT NOT NULL DEFAULT 0.0,
    `pos_x` FLOAT NOT NULL DEFAULT 0.0,
    `pos_y` FLOAT NOT NULL DEFAULT 0.0,
    `pos_z` FLOAT NOT NULL DEFAULT 0.0,
    `pos_a` FLOAT NOT NULL DEFAULT 0.0,
    CONSTRAINT `fk_characters_accounts` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);