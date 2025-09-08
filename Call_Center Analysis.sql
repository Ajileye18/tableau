CREATE TABLE Call_c (
id VARCHAR(50), customer_name VARCHAR(50),
 sentiment VARCHAR(20), csat_score INT, call_timestamp DATE,
 reason VARCHAR(50), city VARCHAR(50), state VARCHAR(50), channel VARCHAR(50), response_time VARCHAR(50), 
 call_duration_in_minutes INT, call_center VARCHAR(50));
 
 LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Call Center.csv"
 INTO TABLE Call_c
 FIELDS TERMINATED BY ','
 OPTIONALLY ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 LINES
 (id, customer_name, sentiment, @csat_score, @call_timestamp, 
 reason, city, state, channel, 
 response_time, call_duration_in_minutes, call_center)
 SET 
 call_timestamp = str_to_date(@call_timestamp, '%m/%d/%Y'),
 csat_score = NULLIF(@csat_score, '');
 
 SELECT * FROM CALL_C;
 
 -- Checking for trailing and leading spaces
 SELECT customer_name
 FROM call_c
 WHERE customer_name <> TRIM(customer_name);
 
  SELECT distinct(customer_name)
 FROM call_c
 order by customer_name asc;

-- sentiment column
SELECT sentiment
 FROM call_c
 WHERE sentiment <> TRIM(sentiment);
 
  SELECT distinct(sentiment)
 FROM call_c
 order by sentiment asc;
 
 -- reason column
  SELECT reason
 FROM call_c
 WHERE reason <> TRIM(reason);
 
  SELECT distinct(reason)
 FROM call_c
 order by reason asc;
 
 -- = ====================================
 -- Exploratory Analysis for Insight
 -- Overall satisfaction score and how it vary by call center, state, or city
 
 SELECT SUM(csat_score)
 FROM call_c; -- 68085
 
 -- variability by call center, state, city
 SELECT  City, SUM(csat_score)
 FROM call_c
 GROUP BY City
  ORDER BY SUM(csat_score) DESC;
 
 SELECT  state, SUM(csat_score)
 FROM call_c
 GROUP BY state
 ORDER BY SUM(csat_score) DESC;
 
  SELECT  call_center, SUM(csat_score)
 FROM call_c
 GROUP BY call_center 
 ORDER BY SUM(csat_score) DESC;
 
 -- How does sentiment align with CSAT score
 SELECT sentiment, SUM(csat_score) score_csat
 FROM call_c
 GROUP BY sentiment
 ORDER BY sum(csat_score) DESC;
 
 -- Which reasons for calling are associated with the lowest CSAT or most negative sentiment
 SELECT reason, sum(csat_score) score_csat
 FROM call_c
 GROUP BY reason
 ORDER BY sum(csat_score) DESC; -- Service Outage: 9768 csat_score
 
 -- How does CSAT vary across channels
 SELECT channel, sum(csat_score) score_csat
 FROM call_c
 GROUP BY channel
 ORDER BY sum(csat_score) DESC; -- Call center had the highst csat_score: 22268
 
 -- is there a time_of_day or day_of-week trend in customer sentiment
 SELECT dayname(call_timestamp), sentiment
 FROM call_c;
 
 -- HOW DOES CALL DURATION VARY BY REASON FOR CALL OR CHANNEL
 SELECT  reason, sum(call_duration_in_minutes)
 FROM call_c
 GROUP BY reason
 ORDER BY sum(call_duration_in_minutes) DESC;
 
 SELECT  call_center, sum(call_duration_in_minutes) time_in_minutes
 FROM call_c
 GROUP BY call_center
ORDER BY sum(call_duration_in_minutes) DESC;
 
 -- Do longer response times correlate with lower CSAT
 SELECT  response_time, sum(csat_score) AS csat_score
 FROM call_c
 GROUP BY response_time 
ORDER BY sum(csat_score) DESC; -- Yes, response time Above SLA had lowest csat_score

-- which call centers are outliers in terms of call duration or response time
SELECT  call_center, sum(call_duration_in_minutes) duration_of_call
 FROM call_c
 GROUP BY call_center
ORDER BY sum(call_duration_in_minutes) DESC; 

-- what are peak call DAY
SELECT DAYname(call_timestamp), count(id) total_call
FROM call_c
GROUP BY DAYname(call_timestamp)
ORDER BY DAYname(call_timestamp) DESC;

-- The most common reason for call
SELECT reason, count(id) total_call
FROM call_c
GROUP BY reason
ORDER BY count(id) DESC; -- Billing question with 23462 calls

-- which call center has the highest csat
SELECT call_center, sum(csat_score) total_score
FROM call_c
GROUP BY call_center
ORDER BY sum(csat_score) DESC; -- Los Angeles/CA with 28254

-- which call center responds fastest
SELECT call_center, response_time, count(response_time)
FROM call_c
WHERE response_time = 'below SLA'
GROUP BY call_center, response_time
ORDER BY count(response_time) DESC; -- Los Angeles/CA with 3327 Below SLA response time

-- how does sentiment distribution differ across call centers
SELECT distinct(call_center), sentiment, 
count(sentiment) over(PARTITION BY call_center, sentiment ORDER BY sentiment DESC) AS sentiment_count
FROM call_c;

-- do customers from certain states/cities tend to report more negative sentiment
SELECT distinct(state), sentiment, 
count(sentiment) AS sentiment_count -- OVER(PARTITION BY state, sentiment ORDER BY sentiment DESC) AS sentiment_count
FROM call_c
WHERE sentiment = 'Negative' OR sentiment='Very Negative'
GROUP BY state, sentiment
ORDER BY count(sentiment) DESC;

-- ARE SPECIFIC reason for calling more common in certain regions
SELECT city, reason, COUNT(reason) reason_count
FROM call_c
GROUP BY city, reason
ORDER BY COUNT(reason) DESC;

--
SELECT distinct(channel), sentiment, 
count(sentiment) AS sentiment_count
FROM call_c
WHERE sentiment = 'Negative' OR sentiment='Positive'
GROUP BY channel, sentiment
ORDER BY count(sentiment) DESC;