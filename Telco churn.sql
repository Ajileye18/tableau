USE rwfd;
SELECT * FROM rwfd.customer_churn;

ALTER TABLE customer_churn
CHANGE COLUMN customerID customerID VARCHAR(15);

ALTER TABLE customer_churn
CHANGE COLUMN gender gender VARCHAR(15);

ALTER TABLE customer_churn
CHANGE COLUMN SeniorCitizen SeniorCitizen INT;

ALTER TABLE customer_churn
CHANGE COLUMN Partner Partner VARCHAR(5);

ALTER TABLE customer_churn
CHANGE COLUMN Dependents Dependents VARCHAR(5);

ALTER TABLE customer_churn
CHANGE COLUMN tenure tenure INT;

ALTER TABLE customer_churn
CHANGE COLUMN PhoneService PhoneService VARCHAR(5);

ALTER TABLE customer_churn
CHANGE COLUMN MultipleLines MultipleLines VARCHAR(25);

ALTER TABLE customer_churn
CHANGE COLUMN InternetService InternetService VARCHAR(25);

ALTER TABLE customer_churn
CHANGE COLUMN OnlineSecurity OnlineSecurity VARCHAR(25);

ALTER TABLE customer_churn
CHANGE COLUMN OnlineBackup OnlineBackup VARCHAR(25);

ALTER TABLE customer_churn
CHANGE COLUMN DeviceProtection DeviceProtection VARCHAR(25);

ALTER TABLE customer_churn
CHANGE TechSupport TechSupport VARCHAR(25);

ALTER TABLE customer_churn
CHANGE StreamingTV StreamingTV VARCHAR(25);

ALTER TABLE customer_churn
CHANGE StreamingMovies StreamingMovies VARCHAR(25);

ALTER TABLE customer_churn
CHANGE Contract Contract VARCHAR(25);

ALTER TABLE customer_churn
CHANGE PaperlessBilling PaperlessBilling VARCHAR(25);

ALTER TABLE customer_churn
CHANGE PaymentMethod PaymentMethod VARCHAR(25);

ALTER TABLE customer_churn
CHANGE MonthlyCharges MonthlyCharges DECIMAL(5,2);

ALTER TABLE customer_churn
CHANGE TotalCharges TotalCharges DECIMAL(6,2);

ALTER TABLE customer_churn
CHANGE Churn Churn VARCHAR(5);

-- sTANDARDIZING THE COLUMNS
SELECT count(*), customerid
FROM customer_churn
GROUP BY customerID
HAVING count(*) > 1; -- cuatomerid is unique, no duplicate

SELECT gender
FROM customer_churn
WHERE gender <> TRIM(gender); -- no spaces

SELECT DISTINCT(gender)
FROM customer_churn;

SELECT distinct(seniorcitizen)
FROM customer_churn;

SELECT partner
FROM customer_churn
WHERE partner!=TRIM(Partner); -- no spaces

SELECT dependents
FROM customer_churn
WHERE dependents!=TRIM(Dependents); -- NO SPACES

SELect tenure
FROM customer_churn
WHERE tenure is NULL; -- no nulls

SELECT phoneservice
FROM customer_churn
WHERE PHONESERVICE !=trim(PHONESERVICE); -- NO SPACES

SELECT multiplelines
FROM customer_churn
WHERE MultipleLines!=TRIM(multiplelines); -- no spaces

SELECT distinct(internetservice)
FROM customer_churn
where internetservice!=TRIM(InternetService); -- no space

SELECT onlinesecurity
FROM customer_churn
WHERE onlinesecurity!=TRIM(onlinesecurity); -- no spaces

SELECT onlinebackup
FROM customer_churn
WHERE OnlineBackup!=Trim(OnlineBackup); -- no spaces

SELECT deviceprotection
FROM customer_churn
WHERE DeviceProtection!= TRIM(DeviceProtection); -- no space

SELECT Techsupport
FROM customer_churn
WHERE TechSupport!=TRIM(techsupport); -- No space

SELECT StreamingTV
FROM customer_churn
WHERE streamingTv!=TRIM(StreamingTV); -- no space

SELECT streamingmovies
FROM customer_churn
WHERE StreamingMovies!=TRIM(streamingmovies); -- no space

SELECT distinct(contract)
FROM customer_churn
WHERE Contract!=trim(contract); -- no space

SELECT paperlessbilling
FROM customer_churn
WHERE PaperlessBilling!=TRIM(paperlessbilling); -- no space

SELECT distinct(paymentmethod)
FROM customer_churn
WHERE PaymentMethod!=TRIM(PaymentMethod); -- no spaces

SELECT distinct(monthlycharges)
FROM customer_churn
WHERE monthlycharges!=TRIM(monthlycharges);  -- no spaces

SELECT Totalcharges
FROM customer_churn
WHERE TOTALCHARGES!=TRIM(TotalCharges); --  no spaces

SELECT churn
FROM customer_churn
WHERE churn!=TRIM(churn); -- no spaces

-- Total Customers
SELECT COUNT(customerid)
FROM customer_churn; -- 7032

-- Total Churned Customers
SELECT count(churn)
FROM customer_churn
WHERE churn = 'Yes'; -- 1869

-- total customers not Churn
SELECT count(churn)
FROM customer_churn
WHERE churn = 'No'; -- 5163

-- customer churn rate
WITH Ychurn AS (SELECT count(churn) yeschurn
FROM customer_churn
WHERE churn = 'Yes'),
tCustomer AS (SELECT count(churn) totalchurn
FROM customer_churn)
SELECT round(((yeschurn)/totalchurn)*100,2) churn_rate
FROM Ychurn, tcustomer; -- 26.58

-- Retention rate
WITH retention AS (SELECT count(churn) notchurned
FROM customer_churn
WHERE churn = 'No'),
total AS (SELECT COUNT(customerid) total_customer
FROM customer_churn) 
SELECT round(((notchurned/total_customer)*100),2) retention_rate
FROM retention, total; -- 73.42;

-- total revenue
SELECT SUM(totalcharges)
FROM customer_churn; -- 16056168.70

-- revenue churn
SELECT churn, SUM(Totalcharges) revenue
FROM customer_churn
WHERE churn = 'yes'
GROUP BY churn; 

-- most popular Contract by churn
SELECT contract, count(churn)
FROM customer_churn
WHERE churn='yes'
GROUP BY contract; -- month-to-month customers have been churned most

-- churn by internet service
SELECT internetservice, count(churn)
FROM customer_churn
WHERE churn='yes'
GROUP BY internetservice; -- clients using fibre optic churned the most.

-- churn by gender
SELECT gender, count(churn)
FROM customer_churn
WHERE churn='yes'
GROUP BY gender; -- Female customers are churned more

SELECT gender, count(gender)
FROM customer_churn
GROUP BY gender; -- Male = 3549 more male customers

-- churn by tenure
SELECT min(tenure), max(tenure)
FROM customer_churn; -- min=1, max=72

-- Segmentation of customers by tenure to find the segment with most churned customers

SELECT 
CASE WHEN tenure BETWEEN 1 AND 18 THEN 'New_customers'
	WHEN tenure BETWEEN 19 AND 36 THEN 'Early_adopters'
    WHEN tenure BETWEEN 37 AND 54 THEN 'Established_customers'
    WHEN tenure BETWEEN 55 AND 72 THEN 'loyal_customers'
    END tenure_segment,
    count(churn)
FROM customer_churn
WHERE churn='yes'
GROUP BY tenure_segment; -- New customers churned the most (1214)

-- do customers with multiple lines got churned?
SELECT multiplelines, count(churn)
FROM customer_churn
WHERE churn='yes'
GROUP BY multiplelines;

SELECT multiplelines, count(*) TOTAL
FROM customer_churn
GROUP BY multiplelines;

SELECT phoneservice, count(churn)
FROM customer_churn
WHERE churn='yes'
GROUP BY phoneservice;

SELECT OnlineSecurity,count(churn) -- onlinebackup, deviceprotection,
-- techsupport, streamingtv, streamingmovies, 
FROM customer_churn
WHERE churn = 'yes'
GROUP BY OnlineSecurity; -- onlinebackup, deviceprotection,
-- techsupport, streamingtv, streamingmovies;

-- churn by payment method

SELECT paymentmethod, count(churn) CHURN
FROM customer_churn
WHERE Churn= 'yes'
GROUP BY paymentmethod
ORDER BY count(churn) DESC;

SELECT paymentmethod, count(*) TOTAL
FROM customer_churn
GROUP BY paymentmethod
ORDER BY count(*) DESC;