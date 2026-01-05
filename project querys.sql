USE hospital_db;
SHOW TABLES;
SELECT * FROM patient;
SELECT * FROM physician;
SELECT * FROM nurse;
SELECT * FROM block;
SELECT * FROM room;
SELECT * FROM on_call;
SELECT * FROM procedures;
SELECT * FROM trained_in;
SELECT * FROM medication;
SELECT * FROM prescribes;
SELECT * FROM appointment;
SELECT * FROM stay;
SELECT * FROM undergoes;
SELECT * FROM nurse;


SELECT p.name
FROM physician p
LEFT JOIN affiliated_with a
ON p.employeeid = a.physician
WHERE a.department IS NULL;


-- 2.Write a query in SQL to obtain the name of the patients with their physicians by whom they got their preliminary treatment
SELECT pa.name AS patient, ph.name AS physician
FROM appointment a
JOIN patient pa ON a.patient = pa.ssn
JOIN physician ph ON a.physician = ph.employeeid;



-- 3.Patients and number of physicians they took appointment with
SELECT pa.name, COUNT(DISTINCT a.physician) AS total_physicians
FROM appointment a
JOIN patient pa ON a.patient = pa.ssn
GROUP BY pa.name;

-- 4.Count of unique patients who got appointment in Room C
SELECT COUNT(DISTINCT patient) AS total_patients
FROM appointment
WHERE examinationroom = 'C';

-- 5. Patients and number of rooms they visited
SELECT pa.name, COUNT(DISTINCT a.examinationroom) AS rooms_count
FROM appointment a
JOIN patient pa ON a.patient = pa.ssn
GROUP BY pa.name;

-- 6. Nurses and rooms scheduled where they assist physicians
SELECT n.name, a.examinationroom
FROM appointment a
JOIN nurse n ON a.prepnurse = n.employeeid;

-- 7.Appointment on 25 April (patient, physician, nurse, room)
SELECT 
  pa.name AS patient,
  ph.name AS physician,
  n.name AS nurse,
  a.examinationroom
FROM appointment a
JOIN patient pa ON a.patient = pa.ssn
JOIN physician ph ON a.physician = ph.employeeid
LEFT JOIN nurse n ON a.prepnurse = n.employeeid
WHERE a.start_dt = '25/4/2008';

-- 8.Patients & physicians WITHOUT nurse assistance
SELECT pa.name AS patient, ph.name AS physician
FROM appointment a
JOIN patient pa ON a.patient = pa.ssn
JOIN physician ph ON a.physician = ph.employeeid
WHERE a.prepnurse IS NULL;

-- 9.Patients, their physicians & medication
SELECT pa.name AS patient, ph.name AS physician, m.name AS medication
FROM prescribes pr
JOIN patient pa ON pr.patient = pa.ssn
JOIN physician ph ON pr.physician = ph.employeeid
JOIN medication m ON pr.medication = m.code;

-- 10. Patients with advanced (future) appointment

SELECT pa.name, ph.name AS physician
FROM appointment a
JOIN patient pa ON a.patient = pa.ssn
JOIN physician ph ON a.physician = ph.employeeid
WHERE a.start_dt > '25/4/2008';

-- 11.Count available rooms per block & floor

SELECT blockfloor, blockcode, COUNT(*) AS available_rooms
FROM room
WHERE unavailable = 'f'
GROUP BY blockfloor, blockcode;

-- 12.Floor with minimum available rooms
SELECT blockfloor
FROM room
WHERE unavailable = 'f'
GROUP BY blockfloor
ORDER BY COUNT(*) ASC
LIMIT 1;

-- 13.Patients with block, floor & room number
SELECT 
  p.name,
  r.blockfloor,
  r.blockcode,
  r.roomnumber
FROM stay s
JOIN patient p ON s.patient = p.ssn
JOIN room r ON s.roomnumber = r.roomnumber;

-- 14. Physicians who performed procedure after certificate expiry
SELECT DISTINCT ph.name, ph.position
FROM undergoes u
JOIN trained_in t ON u.physicianassist = t.physician
JOIN physician ph ON ph.employeeid = u.physicianassist
WHERE u.date > t.certificationexpires;

-- 15. Full details of expired certification procedures
SELECT 
  ph.name AS physician,
  ph.position,
  pr.name AS procedure,
  u.date AS procedure_date,
  pa.name AS patient,
  t.certificationexpires
FROM undergoes u
JOIN trained_in t ON u.physicianassist = t.physician
JOIN physician ph ON ph.employeeid = u.physicianassist
JOIN procedures pr ON pr.code = u.procedure_id
JOIN patient pa ON pa.ssn = u.patient
WHERE u.date > t.certificationexpires;
