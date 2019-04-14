-- View for extraction treatment statuses on first day

DROP MATERIALIZED VIEW IF EXISTS treatmentfirstday CASCADE;
CREATE MATERIALIZED VIEW treatmentfirstday AS 

SELECT trt.patientunitstayid
, MAX(CASE
	WHEN LOWER(trt.treatmentstring) LIKE '%vasopressors%' THEN 1
	ELSE 0
	END) AS pressor
, MAX(CASE
	WHEN LOWER(trt.treatmentstring) LIKE '%antiarrhythmics%' THEN 1
	ELSE 0
	END) AS antiarr
, MAX(CASE
	WHEN LOWER(trt.treatmentstring) LIKE '%antibacterials%' THEN 1
	ELSE 0
	END) AS abx
, MAX(CASE
	WHEN LOWER(trt.treatmentstring) LIKE '%sedative%' THEN 1
	ELSE 0
	END) AS sedative
, MAX(CASE
	WHEN LOWER(trt.treatmentstring) LIKE '%diuretic%' THEN 1
	ELSE 0
	END) AS diuretic
, MAX(CASE
	WHEN LOWER(trt.treatmentstring) LIKE '%blood product%' THEN 1
	ELSE 0
	END) AS blood_product
FROM treatment trt
WHERE trt.treatmentoffset <= 1440
GROUP BY patientunitstayid;