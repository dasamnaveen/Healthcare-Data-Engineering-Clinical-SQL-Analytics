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

/* 1. The Business Problem: The hospital administration wants to evaluate the overall 
	clinical performance of the Nephrology department and track patient volume. */
SELECT 
    a.doctor_name,
    COUNT(a.app_id) AS total_patients_seen,
    ROUND(AVG(l.test_value), 2) AS average_urr_score,
    MAX(l.test_value) AS highest_urr_recorded
FROM appointments a
JOIN lab_results l ON a.app_id = l.app_id
WHERE a.department = 'Nephrology' AND l.test_name = 'URR'
GROUP BY a.doctor_name
HAVING COUNT(a.app_id) > 10;

/* 2. The Business Problem: The hospital needs to identify the busiest months of the year for scheduling additional staff, 
	and they want to calculate the exact current age of patients rather than relying on the static age column. */

SELECT 
    EXTRACT(MONTH FROM appointment_date) AS month_of_year,
    COUNT(app_id) AS total_monthly_appointments,
    SUM(consultation_fee) AS monthly_revenue
FROM appointments
WHERE status = 'Completed'
GROUP BY EXTRACT(MONTH FROM appointment_date)
ORDER BY total_monthly_appointments DESC;

/* 3. The Business Problem: A doctor needs a comprehensive "Patient Report Card" that pulls the patient's contact info, 
	their appointment status, and their latest lab results into one single, readable view. */
SELECT 
    p.patient_id,
    p.name AS patient_name,
    p.phone,
    a.department,
    a.appointment_date,
    l.test_name,
    l.test_value,
    l.unit
FROM patients p
INNER JOIN appointments a ON p.patient_id = a.patient_id
LEFT JOIN lab_results l ON a.app_id = l.app_id
WHERE a.status = 'Completed' AND a.appointment_date >= '2025-01-01'
ORDER BY a.appointment_date DESC;

/* 4. The Situation: The Hospital Director is reviewing the Nephrology department's performance for the year 2025. 
	They are concerned about both the financial revenue and the clinical quality of the dialysis treatments being provided by the staff doctors.
	They need a summary report that flags which doctors might need a performance review based on their patients Urea Reduction Ratio (URR) scores, 
	alongside their monthly patient volume. */
    
-- LAYER 4: The Math (What we want to see in the final report)
SELECT 
    a.doctor_name, # a is the shorthand nickname for appointment
    EXTRACT(MONTH FROM a.appointment_date) AS appointment_month,
    COUNT(a.app_id) AS total_appointments,
    SUM(a.consultation_fee) AS total_revenue,
    ROUND(AVG(l.test_value), 2) AS average_urr_score

-- LAYER 1: The Foundation (Connecting the required tables)
FROM appointments a
JOIN lab_results l ON a.app_id = l.app_id

-- LAYER 2: The Pre-Filters (Removing irrelevant data before calculating)
WHERE a.department = 'Nephrology'
  AND a.status = 'Completed'
  AND EXTRACT(YEAR FROM a.appointment_date) = 2025
  AND l.test_name = 'URR'

-- LAYER 3: The Grouping (Organizing the calculations by Doctor and Month)
GROUP BY 
    a.doctor_name,
    EXTRACT(MONTH FROM a.appointment_date)

-- LAYER 5: The Post-Filters (Filtering the grouped results based on Director's rules)
HAVING 
    AVG(l.test_value) < 65 
    OR SUM(a.consultation_fee) > 5000

-- Sorting the final output chronologically, then by worst clinical score first
ORDER BY 
    appointment_month ASC,
    average_urr_score ASC;