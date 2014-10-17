DELIMITER $$

CREATE DEFINER=`root`@`localhost` FUNCTION `getPhpSerializedArrayValueByKey`(_input_string TEXT, _key TEXT) RETURNS TEXT CHARSET utf8
	DETERMINISTIC
	COMMENT 'Function returns last value from serialized array by specific string key.'
BEGIN
	/*
		Function returns last value from serialized array by specific string key.
		
		@author Adam Wnęk (http://kredyty-chwilowki.pl/)
		@licence MIT
		@version 1.0
	*/
	-- required variables
	DECLARE __output_part,__output,__extra_byte_counter,__extra_byte_number,__value_type TEXT;
	DECLARE __value_length,__char_ord,__start,__char_counter,__non_multibyte_length,__value_array_length,__value_array_open_counter INT SIGNED;

	SET __output := NULL;
	
	-- check if key exists in input
	IF LOCATE(CONCAT('s:',LENGTH(_key),':"',_key,'";'), _input_string) != 0 THEN
	
		-- cut from right to key		
		SET __output_part := SUBSTRING_INDEX(_input_string,CONCAT('s:',LENGTH(_key),':"',_key,'";'),-1);
		
		-- get type of value [s,a,b,O,i,d]
		SET __value_type := SUBSTRING(SUBSTRING(__output_part, 1, CHAR_LENGTH(SUBSTRING_INDEX(__output_part,';',1))), 1, 1);
		
		-- custom cut depends of value type
		CASE 	
		WHEN __value_type = 'a' THEN
		
			-- get array length gives information to which } we need to cut in first step
			SET __value_array_length := SUBSTRING_INDEX(SUBSTRING_INDEX(__output_part, ':', 2),':',-1);
			
			SET __output := CONCAT(SUBSTRING_INDEX(__output_part,'}',__value_array_length),'}');
			
			-- get number of { because same number of } need to stay at the end
			SET __value_array_open_counter := LENGTH(__output) - LENGTH(REPLACE(__output, '{', ''));
					
			-- from left to [__value_array_length] appearance of }
			SET __output := CONCAT(SUBSTRING_INDEX(__output_part,'}',__value_array_open_counter),'}');
		
		WHEN __value_type = 'd' OR __value_type = 'i' OR __value_type = 'b' THEN
			
			-- from left to first appearance of }, from right to first :
			SET __output := SUBSTRING_INDEX(SUBSTRING_INDEX(__output_part,';',1),':',-1);
			
		WHEN __value_type = 'O' THEN			
			
			-- from left to first appearance of ;} but without it so we add it back
			SET __output := CONCAT(SUBSTRING_INDEX(__output_part,';}',1),';}');
		ELSE
			
			-- get serialized length
			SET __value_length := SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(__output_part, ':', 2),':',-1),';',1);
			
			-- s:10:" -> 7 because we start after "
			-- we cut from the begin of our value to the end
			-- begin of our string is after: s[1] + :[1] + n[length of number] + :[1] + "[1] + [1](begin after ") = 5+n			
			SET __output_part := SUBSTRING(__output_part, 5+LENGTH(__value_length));
			
			SET __char_counter := 1;
			
			-- real length to cut
			SET __non_multibyte_length := 0;
			
			SET __start := 0;
			-- check every char until [__value_length]
			WHILE __start < __value_length DO
			
				SET __char_ord := ORD(SUBSTR(__output_part,__char_counter,1));
				
				SET __extra_byte_number := 0;
				SET __extra_byte_counter := FLOOR(__char_ord / 256);
				
				-- we detect multibytechars and count them as one to substring correctly
				-- when we now how many chars make multibytechar we can use it to count what is non multibyte length of our value
				WHILE __extra_byte_counter > 0 DO
					SET __extra_byte_counter := FLOOR(__extra_byte_counter / 256);
					SET __extra_byte_number := __extra_byte_number+1;
				END WHILE;
				
				-- to every char i add extra multibyte number (for non multibyte char its 0)
				SET __start := __start + 1 + __extra_byte_number;			
				SET __char_counter := __char_counter + 1;
				SET __non_multibyte_length := __non_multibyte_length +1;
								
			END WHILE;
			
			SET __output :=  SUBSTRING(__output_part,1,__non_multibyte_length);
					
		END CASE;		
	END IF;
	RETURN __output;
	END$$

DELIMITER ;
