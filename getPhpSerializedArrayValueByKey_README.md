getPhpSerializedArrayValueByKey
============

##Specification

**getPhpSerializedArrayValueByKey(_input_string TEXT, _key TEXT)**
**returns TEXT CHARSET utf8;**

##Simple example usage:

```php
<?php
	//return of this serialize is copied to mysql and set to @s
    print_r(
        serialize(array(            
            'custom_key'=>'Lorem ipsum'            
            )
        )
    );
?>
```

```mysql
SET @s := 'a:1:{s:10:"custom_key";s:11:"Lorem ipsum";}';

SELECT `getPhpSerializedArrayValueByKey`(@s,'custom_key') AS `value`;
```

###Result
|value|
|-------------|
|Lorem ipsum|

Returned value is string so it can be used in JOINS, WHERE, other functions like CONCAT etc.

##More advanced example usage:

```php
<?php 

	$b = new stdClass();
    $b->foo = 'Lorem';
    $b->bar = 10;

	//return of this serialize is copied to mysql and set to @s
    print_r(
        serialize(array(
            'a' => 5.99,
            'b' => $b,
            'c' => 8,
            'd'=>'Lorem ipsum',
            'e' => true,
            'f' => array(
                1,
                2,
                '很' => 'Lorem',
                'g' => array(
                    'h' => array(
                            8,
                            array(
                                'i"' => 20
                            )
                        )
                    )
                ),
            null => 'value1',
            true => 'value2',
            false => 'value3',
            Array => 'value4'
            )
        )
    );
```

```SQL
-- MYSQL
SET @s := 'a:11:{s:1:"a";d:5.9900000000000002131628207280300557613372802734375;s:1:"b";O:8:"stdClass":2:{s:3:"foo";s:5:"Lorem";s:3:"bar";i:10;}s:1:"c";i:8;s:1:"d";s:11:"Lorem ipsum";s:1:"e";b:1;s:1:"f";a:4:{i:0;i:1;i:1;i:2;s:3:"很";s:5:"Lorem";s:1:"g";a:1:{s:1:"h";a:2:{i:0;i:8;i:1;a:1:{s:2:"i"";i:20;}}}}s:0:"";s:6:"value1";i:1;s:6:"value2";i:0;s:6:"value3";s:5:"Array";s:6:"value4";s:1:"j";a:2:{i:0;i:1;i:1;i:2;}}';


SELECT 
	`getPhpSerializedArrayValueByKey`(@s,'a') AS a,
	`getPhpSerializedArrayValueByKey`(@s,'b') AS b,
	`getPhpSerializedArrayValueByKey`(@s,'c') AS c,
	`getPhpSerializedArrayValueByKey`(@s,'d') AS d,
	`getPhpSerializedArrayValueByKey`(@s,'e') AS e,
	`getPhpSerializedArrayValueByKey`(@s,'f') AS f,
	`getPhpSerializedArrayValueByKey`(@s,'很') AS 'multibytekey',
	`getPhpSerializedArrayValueByKey`(@s,'g') AS g,
	`getPhpSerializedArrayValueByKey`(@s,'h') AS h,
	`getPhpSerializedArrayValueByKey`(@s,'i"') AS 'i"',
	`getPhpSerializedArrayValueByKey`(@s,'') AS '',
	`getPhpSerializedArrayValueByKey`(@s,0) AS 'false',-- not work because only string keys work
	`getPhpSerializedArrayValueByKey`(@s,'Array') AS 'Array',
	`getPhpSerializedArrayValueByKey`(@s,'j') AS 'j'
;
```

###Result

a|b|c|d|e|f|multibytekey|g|h|i"||false|Array|j
-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|
5.9900000000000002131628207280300557613372802734375|O:8:"stdClass":2:{s:3:"foo";s:5:"Lorem";s:3:"bar";i:10;}|8|Lorem ipsum|1|a:4:{i:0;i:1;i:1;i:2;s:3:"很";s:5:"Lorem";s:1:"g";a:1:{s:1:"h";a:2:{i:0;i:8;i:1;a:1:{s:2:"i"";i:20;}}}}|Lorem|a:1:{s:1:"h";a:2:{i:0;i:8;i:1;a:1:{s:2:"i"";i:20;}}}|a:2:{i:0;i:8;i:1;a:1:{s:2:"i"";i:20;}}|20|value1|NULL|value4|a:2:{i:0;i:1;i:1;i:2;}
