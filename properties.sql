CREATE TABLE `ayse_properties` (
    `id` VARCHAR(250) DEFAULT NULL,
    `owner` INT(11) DEFAULT NULL,
    `access` LONGTEXT DEFAULT '[]',
    `address` VARCHAR(250) DEFAULT NULL,
    `sale` INT(11) DEFAULT NULL,
    INDEX `owner` (`owner`) USING BTREE,
    CONSTRAINT `property_owner` FOREIGN KEY (`owner`) REFERENCES `characters` (`character_id`) ON UPDATE CASCADE ON DELETE CASCADE
);