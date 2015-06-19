DELIMITER $$
DROP PROCEDURE IF EXISTS `devLog`$$
CREATE   
    PROCEDURE `devLog`(concat_data TEXT)

    BEGIN	
		CREATE TEMPORARY TABLE IF NOT EXISTS `devLog` (
		  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
		  `concat_data` TEXT,
		  `date` DATETIME,
		  PRIMARY KEY (`id`)
		) ENGINE=INNODB DEFAULT CHARSET=utf8;
		INSERT INTO devLog (`concat_data`,`date`) VALUES (concat_data,NOW());
    END$$

DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS `devLog`$$
CREATE   
    FUNCTION `devLog`(concat_data TEXT)
    RETURNS TEXT DETERMINISTIC
    COMMENT 'Function is only adapter for procedure so it can be used in sql query'
    BEGIN
	    CALL devLog(concat_data);
	    RETURN concat_data;
    END$$

DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `devReset`$$
CREATE   
    PROCEDURE `devReset`()

    BEGIN
	
		DROP TEMPORARY TABLE IF EXISTS `devLog`;
		CREATE TEMPORARY TABLE IF NOT EXISTS `devLog` (
		  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
		  `concat_data` TEXT,
		  `date` DATETIME,
		  PRIMARY KEY (`id`)
		) ENGINE=INNODB DEFAULT CHARSET=utf8;
	
    END$$

DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS `devReset`$$
CREATE   
    FUNCTION `devReset`()
    RETURNS TEXT DETERMINISTIC
    COMMENT 'Function is only adapter for procedure so it can be used in sql query'
    BEGIN
	    CALL devReset();
	  RETURN '';
    END$$

DELIMITER ;
