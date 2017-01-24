camelCase
============

###Description
Function returns camelCase form of provided string using passed separator.

##Specification

```mysql
FUNCTION `camelCase`(_string TEXT, _separator_char VARCHAR(1))
RETURNS TEXT;
```

##Example usage:

```mysql
SELECT 
camelCase('lorem-Ipsum','-') AS 'first'
,camelCase('lorem ipsum',' ') AS 'second'
,camelCase('Lorem_Ipsum','_') AS 'third'
;
```
###Result
|"first"|"second"|"third"|
|-------------|-------------|-------------|
|LoremIpsum|LoremIpsum|LoremIpsum|
