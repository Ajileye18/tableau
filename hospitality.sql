USE RWFD;
CREATE TABLE hospitality(
Avg_Room_Rate DECIMAL(5,2),
reservation_id VARCHAR(20),
check_in_date DATE,
stay_duration INT,
adults INT,
children INT,
room_type VARCHAR(20),
special_requests_flag VARCHAR(5),
booking_channel VARCHAR(20),
reservation_status VARCHAR(20),
advanced_booking VARCHAR(5),
Property VARCHAR(20),
`Date` DATE,	
Rate_Type VARCHAR(20) );

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Hospitality.csv"
INTO TABLE hospitality
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Avg_Room_Rate, reservation_id, @check_in_date, stay_duration, adults, 
children, room_type, special_requests_flag, 
booking_channel, reservation_status, advanced_booking, Property, @Date, Rate_Type)
SET
check_in_date= str_to_date(@check_in_date, '%m/%d/%Y'),
Date= str_to_date(@Date, '%m/%d/%Y');

-- check for the uniqueness of reservation_id
SELECT count(*), reservation_id
FROM hospitality
GROUP BY reservation_id
HAVING count(*) =1;

-- Check for the start and end period of the bookings
SELECT MIN(check_in_date), MAX(check_in_date)
FROM hospitality;
SELECT MIN(date), MAX(date)
FROM hospitality;


-- Check for missing values in stay_duration column, Adults column and children column
SELECT stay_duration FROM hospitality WHERE stay_duration = ' '; -- IS NULL;

SELECT adults FROM hospitality WHERE adults = ' '; -- IS NULL;

SELECT children FROM hospitality WHERE adults = ' '; -- IS NULL;


-- checking for trailing or leading spaces in the room_type column
SELECT room_type FROM hospitality WHERE room_type != TRIM(room_type);

-- checking for trailing or leading spaces in the room_type column
SELECT DISTINCT(special_requests_flag)
FROM hospitality;
SELECT special_requests_flag 
FROM hospitality 
WHERE special_requests_flag != TRIM(special_requests_flag);

-- checking for trailing or leading spaces in the booking_channel column
SELECT DISTINCT(booking_channel)
FROM hospitality;
SELECT booking_channel
FROM hospitality 
WHERE booking_channel != TRIM(booking_channel);

-- checking for trailing or leading spaces in the Property column
SELECT DISTINCT(Property)
FROM hospitality;
SELECT Property
FROM hospitality 
WHERE Property != TRIM(Property);

-- checking for trailing or leading spaces in the Rate_Type column
SELECT DISTINCT(Rate_Type)
FROM hospitality;
SELECT Rate_Type
FROM hospitality 
WHERE Rate_Type != TRIM(Rate_Type);

-- Distribution of Avg_room by room_type
SELECT distinct(room_type), avg(avg_room_rate) avg_room_rate FROM hospitality
GROUP BY room_type;

-- Distribution of Avg_room by booking channel
SELECT distinct(booking_channel), avg(avg_room_rate) avg_room_rate FROM hospitality
GROUP BY booking_channel;

-- Distribution of Avg_room by property
SELECT distinct(property), avg(avg_room_rate) avg_room_rate FROM hospitality
GROUP BY property;

-- Reservation Pattern
--  Reservation volume by Check_in_date
SELECT COUNT(reservation_status) Reservation, check_in_date
FROM hospitality
WHERE reservation_status = 'completed'
GROUP BY check_in_date
ORDER BY check_in_date;

-- popular booking channel
SELECT booking_channel, count(reservation_id) RESERVATION
FROM hospitality
GROUP BY booking_channel
ORDER BY count(reservation_id) DESC;

-- average stay duration distribution
SELECT avg(stay_duration)
FROM hospitality;

-- adults vs children composition by property
SELECT SUM(adults) adults, sum(children) children, property
FROM hospitality
GROUP BY property;

-- special request frequency
SELECT count(special_requests_flag) special_requests_flag
FROM hospitality
WHERE special_requests_flag = 'yes';

-- property performance comparison
SELECT count(reservation_status) reservation_status, property
FROM hospitality
WHERE reservation_status = 'completed'
GROUP BY property;

-- cancellation rate by booking channel, room type or property

SELECT booking_channel, count(reservation_status) Reservation_status
FROM hospitality
WHERE reservation_status = 'No-show'
GROUP BY booking_channel
ORDER BY count(reservation_status) DESC;

SELECT room_type, count(reservation_status) Reservation_status
FROM hospitality
WHERE reservation_status = 'No-show'
GROUP BY room_type
ORDER BY count(reservation_status) DESC;

SELECT property, count(reservation_status) Reservation_status
FROM hospitality
WHERE reservation_status = 'No-show'
GROUP BY property
ORDER BY count(reservation_status) DESC;