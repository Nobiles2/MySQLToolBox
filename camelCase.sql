DELIMITER $$

DROP FUNCTION IF EXISTS `camelCase`$$

CREATE DEFINER=`root`@`localhost` FUNCTION `camelCase`(_string TEXT, _separator_char VARCHAR(1)) RETURNS TEXT CHARSET utf8
    DETERMINISTIC
    COMMENT 'Function returns camelCase form of provided string using passed separator'
BEGIN
/*
	Function returns camelCase form of provided string using passed separator.

	@author Adam Wnęk (http://kredyty-chwilowki.pl/)
	@licence MIT
	@version 1.0
*/   
	DECLARE _string_len INT UNSIGNED DEFAULT 0;
	DECLARE _string_words TEXT DEFAULT '';
	DECLARE _camel_case TEXT DEFAULT '';
	DECLARE _string_parts TEXT DEFAULT '';
	DECLARE _separator_location SMALLINT UNSIGNED DEFAULT 1;
	
	SET _string_len := LENGTH(_string);
	SET _string_parts := _string;
	
	-- while (separator is before end of string and part of a string is not empty) and we have separator in part of a string
	WHILE ((LOCATE(_separator_char,_string_parts) <= _string_len AND LENGTH(_string_parts) > 0)) AND _separator_location > 0 DO
		
		SET _separator_location := LOCATE(_separator_char,_string_parts);
		
		IF _separator_location > 0 THEN
			-- get word before separator
			SET _string_words := SUBSTRING(_string_parts, 1, _separator_location-1);
			-- cut after separator (without it) to end of string
			SET _string_parts := SUBSTRING(_string_parts, _separator_location+1);			
		ELSE
			-- no separator - we have last word
			SET _string_words := _string_parts;
		END IF;
		-- every word concat to camelCase form
		-- first letter uppercase and rest lowercase
		SET _camel_case := CONCAT(_camel_case,CONCAT(UCASE(SUBSTRING(_string_words, 1, 1)),LCASE(SUBSTRING(_string_words, 2))));
	END WHILE;
RETURN _camel_case;
END$$

DELIMITER ;
