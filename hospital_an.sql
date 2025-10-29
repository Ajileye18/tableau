USE hospital;
-- Analysing the 'Patients' Table
SELECT * FROM hospital.patients;

-- Convert the arrival_date and departure_date columns to proper MYSQL date format
UPDATE Patients
SET arrival_date = str_to_date(arrival_date, '%Y-%m-%d');

UPDATE Patients
SET departure_date = str_to_date(departure_date, '%Y-%m-%d');

-- segment patients using the Age column
SELECT MIN(AGE), MAX(AGE) FROM patients;

SELECT Patient_demo, count(Patient_demo) AS patient_count, ROUND((count(Patient_demo)/1000)*100,2) AS patient_per,
avg(satisfaction) AS satisfaction_avg -- WRITE SUBQUERY TO COUNT THE DEMOGRAPHIC DISTRIBUTION
FROM(
SELECT patient_id, age, satisfaction, CASE WHEN AGE <= 17 THEN 'Children'
			WHEN AGE BETWEEN 18 AND 40 THEN 'YOUTHS'
            WHEN AGE BETWEEN 41 AND 59 THEN 'Adults'
            WHEN AGE > 60 THEN 'Aged'
            END Patient_demo
FROM patients) TT
WHERE Patient_demo IS NOT NULL
GROUP BY Patient_demo;

-- Calcuate patients overall satisfaction ratings BY SERVICE

SELECT service, avg(satisfaction) satisfaction_avg
FROM Patients
GROUP BY service;

-- Monthly Average Satisfaction
SELECT MONTH(departure_date) departure_month, avg(satisfaction) satisfaction_avg
FROM Patients
GROUP BY MONTH(departure_date)
ORDER BY MONTH(departure_date) ASC;

-- patients treatment period

SELECT name, datediff(departure_date, arrival_date) AS day_before_discharge
FROM patients
ORDER BY datediff(departure_date, arrival_date) desc;

-- ANALYSE STAFF_SCHEDULE table

-- STAFF DEMOGRAPHY by role

SELECT  role, COUNT(DISTINCT staff_id) staff_population
FROM staff_schedule
GROUP BY role
ORDER BY COUNT(staff_id) DESC;
-- staff attitude to work
SELECT staff_name, role,
COUNT(CASE WHEN present = 1 THEN 1 END) AS present_days,
 COUNT(CASE WHEN present = 0 THEN 0 END) AS absent_days
FROM staff_schedule
GROUP BY staff_name, role
ORDER BY COUNT(CASE WHEN present = 1 THEN 1 END) DESC;

-- ANALYSING STAFF table
-- NO of staff available for each service unit
SELECT  service, count(CASE WHEN role ='doctor' THEN 'doctor' END) AS dr_population,
count(CASE WHEN role ='nurse' THEN 'nurse' END) AS Nr_population,
count(CASE WHEN role ='nursing_assistant' THEN 'nursing_assistant' END) AS Asst_Nr_population,
(count(CASE WHEN role ='doctor' THEN 'doctor' END)+
count(CASE WHEN role ='nursing_assistant' THEN 'nursing_assistant' END)+
count(CASE WHEN role ='nurse' THEN 'nurse' END)) AS total_staff
FROM staff
GROUP BY service;

-- Analysing services_weekly table
-- TOTAL PATIENTS REQUEST
SELECT SUM(patients_request) count_of_patients
FROM services_weekly; -- '13493'

-- TOTAL PATIENTS ADMITTED
SELECT SUM(patients_admitted) patients_admitted
FROM services_weekly; -- '5851'

SELECT SUM(patients_refused) patients_rejected
FROM services_weekly; -- '7642'

-- Average of Available Bed Space
SELECT AVG(available_beds) FROM services_weekly; -- 30.3462

-- Average Available Bed_spaces by service
SELECT service, AVG(available_beds) FROM services_weekly
GROUP BY service;

-- HOSPITAL ADMISSION RATE
SELECT ROUND((SUM(patients_admitted)/SUM(patients_request))*100,2) admission_rate
FROM services_weekly; -- '43.36'

-- HOSPITAL REJECTION RATE
SELECT ROUND((SUM(patients_refused)/SUM(patients_request))*100,2) rejection_rate
FROM services_weekly; -- '56.64'

-- REJECTION & admission RATE BY SERVICE
SELECT service, 
sum(patients_request) patient_requests,
 SUM(patients_admitted) patient_admitted,
 SUM(patients_refused) patient_refused,
 concat(ROUND((SUM(patients_admitted)/SUM(patients_request))*100,2), '%') admission_rate,
concat(ROUND((SUM(patients_refused)/SUM(patients_request))*100,2),'%') rejection_rate
 FROM services_weekly
 GROUP BY Service;

-- average staff morale
SELECT staff_name, ROUND(AVG(staff_morale),2) Avg_staff_morale
FROM services_weekly SW
JOIN Staff st ON st.service=sw.service
GROUP BY staff_name;

-- OVERALL AVERAGE STAFF MORALE
SELECT ROUND(AVG(staff_morale),2) Avg_staff_morale
FROM services_weekly; -- 72.57

-- when is  staff morale at the highest
SELECT event, ROUND(AVG(staff_morale),2) Avg_staff_morale
FROM services_weekly
GROUP BY event;
-- WHAT ARE THE EVENTS OUR STAFF ARE ATTENDING TO

SELECT event, COUNT(event)
FROM services_weekly
GROUP BY event; -- 

-- WHICH EVENT CONTRIBUTE TO PATIENT_REQUEST OF PATIENTS
SELECT event, SUM(patients_request) patients_request
FROM services_weekly
GROUP BY event;

-- ADMISSION TREND
SELECT date_format(arrival_date, '%Y-%m') month_admitted, SUM(patients_admitted) total_patients,
sum(sum(patients_admitted)) OVER(ORDER BY date_format(arrival_date, '%Y-%m')) admission_running_total
FROM services_weekly sw 
LEFT JOIN patients p ON  p.service=sw.service
GROUP BY date_format(arrival_date, '%Y-%m');

WITH patients_details SELECT date_format(arrival_date, '%Y-%m') month_admitted,
date_format(departure_date, '%Y-%m') month_discharged
FROM patients