devLog/devReset
============

##Specification


```mysql
PROCEDURE devLog(concat_data TEXT)

FUNCTION `devLog`(concat_data TEXT) -- only adapter for procedure devLog
RETURNS TEXT -- RETURN concat_data;

PROCEDURE `devReset`()

FUNCTION `devReset`() -- only adapter for procedure devReset
RETURNS TEXT -- RETURN '';
```

##Example usage:

```mysql
SELECT devReset();

CALL devLog('start debug1');

SELECT id,column_1,devLog(CONCAT_WS(' | ',id,column_1,id*column_1)) as debug FROM simple_table WHERE `id` BETWEEN 100 AND 105;

SELECT * FROM devLog;
```
###Result
|"id"|"column_1"|"debug"|
|-------------|-------------|-------------|
|"100"|"647075"|"100 \| 647075 \| 64707500"|
|"101"|"1141814"|"101 \| 1141814 \| 115323214"|
|"102"|"1141832"|"102 \| 1141832 \| 116466864"|
|"103"|"1142609"|"103 \| 1142609 \| 117688727"|
|"104"|"1141848"|"104 \| 1141848 \| 118752192"|
|"105"|"1142755"|"105 \| 1142755 \| 119989275"|

```mysql
SELECT devReset();
CALL devLog('start debug2');

DELIMITER $$
CREATE PROCEDURE sample_proc()
BEGIN
	DECLARE _i INT;
  SET _i = 0;

  WHILE _i <  5 DO   
	SELECT devLog(CONCAT_WS(' | ',_i,POW(_i,2)));
	SET _i = _i + 1;    
  END WHILE;

END$$
DELIMITER ;

CALL sample_proc();

DROP PROCEDURE sample_proc;

SELECT * FROM devLog;
```

|"id"|"concat_data"|"date"|
|-------------|-------------|-------------|
|"1"|"start debug2"|"2015-06-19 06:54:44"|
|"2"|"0 \| 0"|"2015-06-19 06:54:49"|
|"3"|"1 \| 1"|"2015-06-19 06:54:49"|
|"4"|"2 \| 4"|"2015-06-19 06:54:49"|
|"5"|"3 \| 9"|"2015-06-19 06:54:49"|
|"6"|"4 \| 16"|"2015-06-19 06:54:49"|

```mysql
SELECT devReset();
CALL devLog('start debug3');

DELIMITER $$

CREATE
    FUNCTION `sample_func`(input VARCHAR(20))
    RETURNS VARCHAR(20)
    DETERMINISTIC
    BEGIN
	DECLARE _output VARCHAR(32);
	SET _output := MD5(input);
	CALL devLog(CONCAT_WS(' | ','input: ',input,'_output: ',_output));
	RETURN _output;	
    END$$
DELIMITER ;

SELECT sample_func('example');

DROP FUNCTION sample_func;

SELECT * FROM devLog;
```

|"id"|"concat_data"|"date"|
|-------------|-------------|-------------|
|"1"|"input:  \| example \| _output:  \| 1a79a4d60de6718e8e5b326e338ae533"|"2015-06-19 07:17:56"|
