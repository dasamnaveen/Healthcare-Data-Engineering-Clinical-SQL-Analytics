import pandas as pd
import numpy as np
from faker import Faker
import random

# Initialize Faker with Indian locale for Hyderabad context
fake = Faker('en_IN')

# Configuration
NUM_PATIENTS = 4000
HOSPITAL_CODE = "HS"
DEPARTMENTS = {
    "Cardiology": ["Dr. Sharma", "Dr. Reddy", "Dr. Kapoor"],
    "Nephrology": ["Dr. Verma", "Dr. Iyer"],
    "Pediatrics": ["Dr. Menon", "Dr. Gupta", "Dr. Joshi"],
    "General Medicine": ["Dr. Rao", "Dr. Singh", "Dr. Khan", "Dr. Das"]
}

# 1. GENERATE PATIENTS DATA
patients_list = []
for i in range(1, NUM_PATIENTS + 1):
    p_id = f"{HOSPITAL_CODE}{i:06d}"
    age = random.randint(1, 90)
    patients_list.append({
        "patient_id": p_id,
        "name": fake.name(),
        "age": age,
        "gender": random.choice(["Male", "Female", "Other"]),
        "phone": f"9{random.randint(100000000, 999999999)}",
        "email": fake.unique.email(),
        "city": "Hyderabad"
    })

df_patients = pd.DataFrame(patients_list)

# 2. GENERATE APPOINTMENTS & LAB RESULTS
appointments_list = []
lab_results_list = []
res_counter = 1

for i in range(1, NUM_PATIENTS + 1):
    app_id = f"APP{i:06d}"
    
    # Pick a random patient from our generated list
    patient = random.choice(patients_list)
    p_id = patient['patient_id']
    p_age = patient['age']
    
    # LOGIC: Ensure Age-Department Accuracy (Pediatrics < 18 only)
    if p_age < 18:
        dept = random.choice(["Pediatrics", "General Medicine"])
    else:
        dept = random.choice(["Cardiology", "Nephrology", "General Medicine"])
    
    doctor = random.choice(DEPARTMENTS[dept])
    
    # Create Appointment Record
    appointments_list.append({
        "app_id": app_id,
        "patient_id": p_id,
        "doctor_name": doctor,
        "department": dept,
        "appointment_date": fake.date_between(start_date='-1y', end_date='today'),
        "consultation_fee": random.choice([600, 800, 1200]),
        "status": random.choices(["Completed", "Cancelled", "Scheduled"], weights=[75, 5, 20])[0]
    })

    # 3. GENERATE CLINICAL LAB RESULTS (Only for Completed appointments)
    # This prevents the "Receptionist entering medical data" error
    if appointments_list[-1]["status"] == "Completed":
        if dept == "Nephrology":
            # Test 1: URR
            lab_results_list.append({
                "result_id": f"RES{res_counter:06d}", "app_id": app_id, 
                "test_name": "URR", "test_value": round(random.uniform(55, 85), 2), "unit": "%"
            })
            res_counter += 1
            # Test 2: Kt/V
            lab_results_list.append({
                "result_id": f"RES{res_counter:06d}", "app_id": app_id, 
                "test_name": "Kt/V", "test_value": round(random.uniform(1.1, 1.9), 2), "unit": "Ratio"
            })
            res_counter += 1
            
        elif dept == "Cardiology":
            # Test 1: Systolic BP
            lab_results_list.append({
                "result_id": f"RES{res_counter:06d}", "app_id": app_id, 
                "test_name": "Systolic BP", "test_value": random.randint(110, 175), "unit": "mmHg"
            })
            res_counter += 1
            
        elif dept == "General Medicine":
            lab_results_list.append({
                "result_id": f"RES{res_counter:06d}", "app_id": app_id, 
                "test_name": "Glucose", "test_value": random.randint(70, 240), "unit": "mg/dL"
            })
            res_counter += 1

# Convert to DataFrames
df_appointments = pd.DataFrame(appointments_list)
df_lab_results = pd.DataFrame(lab_results_list)

# Export to CSV
df_patients.to_csv("patients.csv", index=False)
df_appointments.to_csv("appointments.csv", index=False)
df_lab_results.to_csv("lab_results.csv", index=False)

print("--- Data Generation Complete ---")
print(f"Total Patients: {len(df_patients)}")
print(f"Total Appointments: {len(df_appointments)}")
print(f"Total Lab Records: {len(df_lab_results)}")
