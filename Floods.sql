USE gym;
CREATE TABLE Floodarchive
(ID	INT NOT NULL,
GlideNumber VARCHAR(50),
Country VARCHAR(50),
OtherCountry VARCHAR(50),
`long` DECIMAL(10,6),
lat  DECIMAL(10,6),
Area  DOUBLE,
Began DATE,
Ended DATE,
Validation VARCHAR(30),
Dead INT,
Displaced INT,
MainCause VARCHAR(50),
Severity INT );

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\FloodArchive.csv"
INTO TABLE Floodarchive
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ID,GlideNumber,Country,OtherCountry,	`long`,	lat,	Area,	@Began,	@Ended,	`Validation`,	Dead,	Displaced,	MainCause,	
@Severity
)SET
began = str_to_date(@began, '%m/%d/%Y'),
ended= str_to_date(@ended, '%m/%d/%Y'), 
severity = trim(@severity);


SELECT DISTINCT COUNTRY FROM floodarchive;

UPDATE floodarchive
SET Country = REGEXP_REPLACE(country, '[^a-zA-Z0-9 ]', '');

ALTER TABLE floodarchive
ADD COLUMN C_Country VARCHAR(50) AFTER COUNTRY;

SELECT country, trim(trailing 'Â' from country) clean_country
from floodarchive
WHERE COUNTRY LIKE '%Â';

UPDATE floodarchive
SET C_Country = trim(trailing 'Â' from country) WHERE COUNTRY LIKE '%Â';

UPDATE floodarchive
SET C_Country = COUNTRY WHERE C_COUNTRY IS NULL;

ALTER TABLE floodarchive
DROP COLUMN COUNTRY;

ALTER TABLE floodarchive
CHANGE COLUMN C_country Country Varchar(50);


ALTER TABLE floodarchive
CHANGE column ï»¿ID ID INT;

ALTER TABLE floodarchive
ADD COLUMN C_Began DATE AFTER Began;

ALTER TABLE floodarchive
DROP COLUMN Began;



UPDATE floodarchive
SET C_Began = CASE WHEN Began LIKE '_/_/____' THEN str_to_date(Began, '%m/%d/%Y')
				WHEN Began LIKE '_/__/____' THEN str_to_date(Began, '%m/%d/%Y') 
                WHEN Began LIKE '__/__/____' THEN str_to_date(Began, '%m/%d/%Y')
                WHEN Began LIKE '__/_/____' THEN str_to_date(Began, '%m/%d/%Y') END;
                
ALTER TABLE floodarchive
ADD COLUMN C_Ended DATE AFTER Ended;

UPDATE floodarchive
SET C_Ended = CASE WHEN Began LIKE '_/_/____' THEN str_to_date(Ended, '%m/%d/%Y')
				WHEN Began LIKE '_/__/____' THEN str_to_date(Ended, '%m/%d/%Y') 
                WHEN Began LIKE '__/__/____' THEN str_to_date(Ended, '%m/%d/%Y')
                WHEN Began LIKE '__/_/____' THEN str_to_date(Ended, '%m/%d/%Y') END;

ALTER TABLE floodarchive
DROP COLUMN Ended;

ALTER TABLE floodarchive
CHANGE COLUMN c_Began Began DATE;

ALTER TABLE floodarchive
CHANGE COLUMN c_Ended Ended DATE;

-- total death
SELECT SUM(dead)
FROM floodarchive; -- 688441


-- total death by country
SELECT  country, SUM(dead) AS death_total
FROM floodarchive
GROUP BY country
ORDER BY SUM(dead) DESC;

-- Investigating total death by Cause
SELECT  MainCause, SUM(dead) AS death_total
FROM floodarchive
GROUP BY MainCause
ORDER BY SUM(dead) DESC;

-- Displaced persons population
SELECT SUM(displaced)
FROM floodarchive; -- 660735683


-- total displaced persons by country 
SELECT Country, SUM(displaced) displaced_count
FROM floodarchive
GROUP BY Country
ORDER BY SUM(displaced) DESC;

-- Displaced person by Cause
SELECT maincause, SUM(displaced) displaced_count
FROM floodarchive
GROUP BY maincause
ORDER BY SUM(displaced) DESC;

-- death, displaced & maincause
-- Displaced person by Cause
SELECT maincause, SUM(displaced) displaced_count, sum(dead) death_count
FROM floodarchive
GROUP BY maincause
ORDER BY sum(dead) DESC, SUM(displaced) DESC;

-- death by severity
SELECT severity, sum(dead)
FROM floodarchive
GROUP BY severity
ORDER BY sum(dead) DESC;

-- count of severity
SELECT severity, count(severity)
FROM floodarchive
GROUP BY severity
ORDER BY count(severity) DESC;

-- How do deaths, displacement, and severity interact?
SELECT sum(dead) death_total, sum(Displaced) displaced_total, Severity
FROM floodarchive
GROUP BY severity
ORDER BY sum(dead)  AND sum(Displaced) DESC;

-- Duration of Cause

SELECT datediff(ended, began) duration, Country, MainCause, dead
FROM floodarchive;

SELECT DISTINCT(Maincause)
FROM floodarchive;

SELECT *
FROM floodarchive;

UPDATE floodarchive
SET MainCause = 'Heavy rain'
WHERE MainCause = 'Heavy  Rain';