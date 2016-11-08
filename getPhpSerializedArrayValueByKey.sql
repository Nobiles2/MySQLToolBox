DELIMITER $$

CREATE DEFINER=`root`@`localhost` FUNCTION `getPhpSerializedArrayValueByKey`(_input_string TEXT, _key TEXT) RETURNS TEXT CHARSET utf8 COLLATE utf8_polish_ci
    DETERMINISTIC
    COMMENT 'Function returns last value from serialized array by specific string key.'
BEGIN
	/*
		Function returns last value from serialized array by specific string key.
		
		@author Adam Wnęk (http://kredyty-chwilowki.pl/)
		@licence MIT
		@version 1.2
	*/
	-- required variables
	DECLARE __output_part,__output,__extra_byte_counter,__extra_byte_number,__value_type,__array_part_temp TEXT;
	DECLARE __value_length,__char_ord,__start,__char_counter,__non_multibyte_length,__array_close_bracket_counter,__array_open_bracket_counter INT SIGNED;
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
			-- we get proper array by counting open and close brackets
			SET __array_open_bracket_counter := 1;
			SET __array_close_bracket_counter := 0;
			-- without first open { so counter is 1
			SET __array_part_temp := SUBSTRING(__output_part FROM LOCATE('{',__output_part)+1);
			
			-- we start from first { and counting open and closet brackets until we find last closing one
			WHILE (__array_open_bracket_counter > 0 OR LENGTH(__array_part_temp) = 0) DO
				-- next { exists and its before closest }
				IF LOCATE('{',__array_part_temp) > 0 AND (LOCATE('{',__array_part_temp) < LOCATE('}',__array_part_temp)) THEN
					-- cut from found { + 1, to the end
					SET __array_open_bracket_counter := __array_open_bracket_counter + 1;
					SET __array_part_temp := SUBSTRING(__array_part_temp FROM LOCATE('{',__array_part_temp) + 1);					
				ELSE
					-- cut from found } + 1, to the end
					SET __array_open_bracket_counter := __array_open_bracket_counter - 1;
					SET __array_close_bracket_counter := __array_close_bracket_counter + 1;
					SET __array_part_temp := SUBSTRING(__array_part_temp FROM LOCATE('}',__array_part_temp) + 1);					
				END IF;
			END WHILE;
			-- final array is from beginning to [__array_close_bracket_counter] count of closing }
			SET __output := CONCAT(SUBSTRING_INDEX(__output_part,'}',__array_close_bracket_counter),'}');
			
		WHEN __value_type = 'd' OR __value_type = 'i' OR __value_type = 'b' THEN
			
			-- from left to first appearance of }, from right to first :
			SET __output := SUBSTRING_INDEX(SUBSTRING_INDEX(__output_part,';',1),':',-1);
			
		WHEN __value_type = 'O' THEN			
			
			-- from left to first appearance of ;} but without it so we add it back
			SET __output := CONCAT(SUBSTRING_INDEX(__output_part,';}',1),';}');
			
		WHEN __value_type = 'N' THEN 
            -- when we have null return empty string
            SET __output := NULL;		
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
