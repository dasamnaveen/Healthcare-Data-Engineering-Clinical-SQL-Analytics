-- 1. Create the Database
CREATE DATABASE IF NOT EXISTS MyHospitalDB;
USE MyHospitalDB;

-- 2. Create Patients Table
-- Focus: PRIMARY KEY, UNIQUE, and CHECK constraints
CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY, -- Format: HS000001
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(10),
    phone VARCHAR(15) UNIQUE, -- Prevents duplicate contact entries
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50) DEFAULT 'Hyderabad',
    CONSTRAINT chk_patient_age CHECK (age >= 0 AND age <= 120)
);
SELECT * FROM patients;

-- 3. Create Appointments Table
-- Focus: FOREIGN KEY and status validation
CREATE TABLE appointments (
    app_id VARCHAR(10) PRIMARY KEY, -- Format: APP000001
    patient_id VARCHAR(10),
    doctor_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    appointment_date DATE NOT NULL,
    consultation_fee DECIMAL(10, 2),
    status VARCHAR(20),
    -- Linking appointment to a valid patient
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) 
        ON DELETE CASCADE,
    -- Restricting status to specific values
    CONSTRAINT chk_app_status CHECK (status IN ('Completed', 'Cancelled', 'Scheduled')),
    CONSTRAINT chk_fee CHECK (consultation_fee > 0)
);
SELECT * FROM appointments;


-- 4. Create Lab Results Table
-- Focus: High-precision medical data validation
CREATE TABLE lab_results (
    result_id VARCHAR(10) PRIMARY KEY, -- Format: RES000001
    app_id VARCHAR(10),
    test_name VARCHAR(50) NOT NULL,
    test_value DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20),
    -- Linking result to a valid appointment
    FOREIGN KEY (app_id) REFERENCES appointments(app_id)
        ON DELETE CASCADE,
    -- Example of a complex clinical constraint
    CONSTRAINT chk_test_value CHECK (test_value >= 0)
);

# Applying Joins 

-- Inner Join
# For Patients table and appointments table
SELECT 
    *
FROM
    patients AS p
        INNER JOIN
    appointments AS a ON p.patient_id = a.patient_id;

# For appointments table and lab_results table
SELECT 
    *
FROM
    appointments AS a
        INNER JOIN
    lab_results AS l ON a.app_id = l.app_id;
    
-- Left Join
SELECT 
    *
FROM
    appointments AS a
        LEFT JOIN
    lab_results AS l ON a.app_id = l.app_id;
    
-- Right Join
SELECT 
    *
FROM
    appointments AS a
        RIGHT JOIN
    lab_results AS l ON a.app_id = l.app_id;
    
-- Outer Join / Full Outer Join
SELECT 
    *
FROM
    appointments AS a
        LEFT JOIN
    lab_results AS l ON a.app_id = l.app_id
UNION
SELECT 
    *
FROM
    appointments AS a
        RIGHT JOIN
    lab_results AS l ON a.app_id = l.app_id;
    
-- Left Exclusive Join
SELECT 
    *
FROM
    appointments AS a
        LEFT JOIN
    lab_results AS l ON a.app_id = l.app_id
    WHERE l.result_id IS Null;
    
-- Right Exclusive Join
SELECT 
    *
FROM
    appointments AS a
        RIGHT JOIN
    lab_results AS l ON a.app_id = l.app_id
    WHERE a.status = 'completed';

-- Exclusive Outer Join    
SELECT 
    *
FROM
    appointments AS a
        LEFT JOIN
    lab_results AS l ON a.app_id = l.app_id
    WHERE l.result_id IS Null
UNION
SELECT 
    *
FROM
    appointments AS a
        RIGHT JOIN
    lab_results AS l ON a.app_id = l.app_id
    WHERE a.status = 'completed';
    
-- Natural Join
SELECT 
    *
FROM
    patients
        NATURAL JOIN
    appointments;
    
-- Cross Join /  Cartesian Join
SELECT 
    *
FROM
    appointments
        CROSS JOIN
    lab_results;
    
-- Self Join
SELECT 
    a1.patient_id,
    a1.app_id AS first_appointment_id,
    a1.appointment_date AS first_visit_date,
    a2.app_id AS follow_up_appointment_id,
    a2.appointment_date AS follow_up_date,
    a1.department
FROM appointments a1
JOIN appointments a2 
    ON a1.patient_id = a2.patient_id -- Match records belonging to the same patient
WHERE a1.app_id <> a2.app_id         -- CRITICAL: Prevent the row from matching with itself
  AND a1.appointment_date < a2.appointment_date; -- Prevents showing duplicates like (Visit 1, Visit 2) AND (Visit 2, Visit 1)
    
-- Sub Queries
-- Find patients who are older than the hospital's average patient age.
SELECT 
    name, age, city
FROM
    patients
WHERE
    age > (SELECT 
            AVG(age)
        FROM
            patients); -- Here, the average age is 45.0848
            
-- Find all appointments for patients who live in 'Hyderabad'.
SELECT
	app_id, doctor_name, appointment_date
FROM 
	appointments
WHERE 
	patient_id IN (SELECT 
		patient_id
	FROM 
		patients
	WHERE 
		city = 'Hyderabad');
        
-- Identify the details of the most expensive consultation ever charged.
SELECT 
    app_id, patient_id, department, consultation_fee
FROM
    appointments
WHERE
    consultation_fee = (SELECT 
            MAX(consultation_fee)
        FROM
            appointments);
            
-- Find patients who have NEVER booked an appointment.
SELECT
	patient_id, name, phone
FROM 
	patients
WHERE
	patient_id NOT IN (SELECT
		patient_id 
	FROM
		appointments);
        
-- Show each patient's name alongside the total count of appointments they've had.
SELECT
	name,
	(SELECT 
		COUNT(*)
	FROM
		appointments a
	WHERE
		a.patient_id = p.patient_id) AS 'Total Visits'
FROM patients p;	

-- Correlated Subqueries & Basic Derived Tables
-- Find appointments where the fee is higher than the average fee for THAT specific department.
SELECT 
    app_id, department, consultation_fee
FROM
    appointments a1
WHERE
    consultation_fee > (SELECT 
            AVG(consultation_fee)
        FROM
            appointments a2
        WHERE
            a1.department = a2.department);
            
-- Create a demographic breakdown using a Derived Table.
SELECT 
    age_category, COUNT(*) AS total_patients
FROM
    (SELECT 
        CASE
                WHEN age < 18 THEN 'Pediatric (<18)'
                WHEN age BETWEEN 18 AND 60 THEN 'Adult (18-60)'
		ELSE 'Senior (>60)'
        END AS age_category
    FROM
        patients) AS patient_demographics
GROUP BY age_category;

-- Find patients who have had a lab test recorded.
SELECT 
    p.name, p.phone
FROM
    patients p
WHERE
    EXISTS( SELECT 
            1
        FROM
            appointments a
                JOIN
            lab_results l ON a.app_id = l.app_id
        WHERE
            a.patient_id = p.patient_id);
            
-- Find doctors whose total revenue exceeds ₹10,000 using a Derived Table.
SELECT 
    doctor_name, total_revenue
FROM
    (SELECT 
        doctor_name, SUM(consultation_fee) AS total_revenue
    FROM
        appointments
    WHERE
        status = 'Completed'
    GROUP BY doctor_name) AS doctor_financials
WHERE
    total_revenue > 10000;
    
-- Find appointments that cost more than ALL appointments in the Pediatrics department.	
SELECT 
    app_id, doctor_name, department, consultation_fee
FROM
    appointments
WHERE
    consultation_fee > ALL (SELECT 
            consultation_fee
        FROM
            appointments
        WHERE
            department = 'Pediatrics');
            
-- Complex Derived Tables & Multi-Level Nesting
-- Find the exact details of each patient's MOST RECENT appointment using a derived table.
SELECT 
    a.patient_id,
    p.name,
    a.appointment_date,
    a.department,
    a.doctor_name
FROM
    appointments a
        JOIN
    patients p ON a.patient_id = p.patient_id
        JOIN
    (SELECT 
        patient_id, MAX(appointment_date) AS latest_date
    FROM
        appointments
    GROUP BY patient_id) AS latest_visits ON a.patient_id = latest_visits.patient_id
        AND a.appointment_date = latest_visits.latest_date;
        
-- Find departments whose average consultation fee is higher than the hospital's overall average fee.
SELECT 
    department, AVG(consultation_fee) AS dept_avg_fee
FROM
    appointments
GROUP BY department
HAVING AVG(consultation_fee) > (SELECT 
        AVG(consultation_fee)
    FROM
        appointments);
        
-- Find Cardiology patients who never got their Blood Pressure checked.
SELECT 
    p.name, a.app_id, a.appointment_date
FROM
    patients p
        JOIN
    appointments a ON p.patient_id = a.patient_id
WHERE
    a.department = 'Cardiology'
        AND NOT EXISTS( SELECT 
            1
        FROM
            lab_results l
        WHERE
            l.app_id = a.app_id
                AND l.test_name = 'Systolic BP');
                
-- Identify the "Top Performing Doctor" in Nephrology based on the highest average URR score.
SELECT 
    doctor_name, avg_urr
FROM
    (SELECT 
        a.doctor_name, AVG(l.test_value) AS avg_urr
    FROM
        appointments a
    JOIN lab_results l ON a.app_id = l.app_id
    WHERE
        a.department = 'Nephrology'
            AND l.test_name = 'URR'
    GROUP BY a.doctor_name) AS doctor_scores
ORDER BY avg_urr DESC
LIMIT 1;

-- Find lab tests where the value was higher than the average for that specific test type.
SELECT 
    a.patient_id, l.test_name, l.test_value, l.unit
FROM
    lab_results l
        JOIN
    appointments a ON l.app_id = a.app_id
WHERE
    l.test_value > (SELECT 
            AVG(test_value)
        FROM
            lab_results l2
        WHERE
            l.test_name = l2.test_name);
