-- This query summarizes the patients first 24 hour vitals after admission to
-- the ICU. eICU contains both periodic and aperiodic vitals, and we will end
-- up wanting the aperiodic pressures becasue the patients have tons of missing
-- periodic pressures.

SET search_path TO eicu_crd;

DROP MATERIALIZED VIEW IF EXISTS vitalsfirstday CASCADE;
CREATE MATERIALIZED VIEW vitalsfirstday AS
 
WITH periodic AS (
	SELECT vppvt.patientunitstayid
	, MIN(vppvt.HR) as HR_Min
	, MAX(vppvt.HR) as HR_Max
	, AVG(vppvt.HR) as HR_Mean
	, MIN(vppvt.SBP) as SBP_periodic_Min
	, MAX(vppvt.SBP) as SBP_periodic_Max
	, AVG(vppvt.SBP) as SBP_periodic_Mean
	, MIN(vppvt.DBP) as DBP_periodic_Min
	, MAX(vppvt.DBP) as DBP_periodic_Max
	, AVG(vppvt.DBP) as DBP_periodic_Mean
	, MIN(vppvt.MAP) as MAP_periodic_Min
	, MAX(vppvt.MAP) as MAP_periodic_Max
	, AVG(vppvt.MAP) as MAP_periodic_Mean
	, MIN(vppvt.RR) as RR_Min
	, MAX(vppvt.RR) as RR_Max
	, AVG(vppvt.RR) as RR_Mean
	, MIN(vppvt.SpO2) as SpO2_Min -- This is a data quality issue; they call this SaO2
	, MAX(vppvt.SpO2) as SpO2_Max -- and we assume its SpO2. But SaO2 refers to ABG
	, AVG(vppvt.SpO2) as SpO2_Mean -- in other places.
	, MIN(vppvt.TempC) as TempC_Min
	, MAX(vppvt.TempC) as TempC_Max
	, AVG(vppvt.TempC) as TempC_Mean

	-- Perfrom max sanity checks; we will assume under 0 is impossible, but 
	-- otherwise no lower bound checks since may be values collected during code.
	FROM (
		SELECT vp.patientunitstayid
		, CASE 
			WHEN vp.heartrate > 300 OR vp.heartrate < 0 THEN null 
			ELSE vp.heartrate 
			END as HR
		, CASE 
			WHEN vp.systemicsystolic > 200 OR vp.systemicsystolic < 0 THEN null 
			ELSE vp.systemicsystolic 
			END as SBP
		, CASE 
			WHEN vp.systemicdiastolic > 100 OR vp.systemicdiastolic < 0 THEN null 
			ELSE vp.systemicdiastolic 
			END as DBP
		, CASE 
			WHEN vp.systemicmean > 100 OR vp.systemicmean < 0 THEN null 
			ELSE vp.systemicmean 
			END as MAP
		, CASE 
			WHEN vp.respiration > 60 OR vp.respiration < 0 THEN null 
			ELSE vp.respiration 
			END as RR
		, CASE 
			WHEN vp.sao2 > 100 OR vp.sao2 < 0 THEN null 
			ELSE vp.sao2 
			END as SpO2
		, CASE 
			WHEN vp.temperature > 45 OR vp.temperature < 0 THEN null 
			ELSE vp.temperature 
			END as tempC
		FROM vitalperiodic vp
		WHERE vp.observationoffset <= 1440
	) AS vppvt

	GROUP BY vppvt.patientunitstayid
	ORDER BY vppvt.patientunitstayid
)
, aperiodic AS (
	SELECT vapvt.patientunitstayid
	, MIN(vapvt.SBP) as SBP_aperiodic_Min
	, MAX(vapvt.SBP) as SBP_aperiodic_Max
	, AVG(vapvt.SBP) as SBP_aperiodic_Mean
	, MIN(vapvt.DBP) as DBP_aperiodic_Min
	, MAX(vapvt.DBP) as DBP_aperiodic_Max
	, AVG(vapvt.DBP) as DBP_aperiodic_Mean
	, MIN(vapvt.MAP) as MAP_aperiodic_Min
	, MAX(vapvt.MAP) as MAP_aperiodic_Max
	, AVG(vapvt.MAP) as MAP_aperiodic_Mean

	-- Perfrom max sanity checks; we will assume under 0 is impossible, but 
	-- otherwise no lower bound checks since may be values collected during code.
	FROM (
		SELECT va.patientunitstayid
		, CASE 
			WHEN va.noninvasivesystolic > 200 OR va.noninvasivesystolic < 0 THEN null 
			ELSE va.noninvasivesystolic 
			END as SBP
		, CASE 
			WHEN va.noninvasivediastolic > 100 OR va.noninvasivediastolic < 0 THEN null 
			ELSE va.noninvasivediastolic 
			END as DBP
		, CASE 
			WHEN va.noninvasivemean > 100 OR va.noninvasivemean < 0 THEN null 
			ELSE va.noninvasivemean 
			END as MAP
		FROM vitalaperiodic va
		WHERE va.observationoffset <= 1440
	) AS vapvt

	GROUP BY vapvt.patientunitstayid
	ORDER BY vapvt.patientunitstayid
)

SELECT pp.patientunitstayid
	, pp.HR_Min
	, pp.HR_Max
	, pp.HR_Mean
	, pp.SBP_periodic_Min
	, pp.SBP_periodic_Max
	, pp.SBP_periodic_Mean
	, pp.DBP_periodic_Min
	, pp.DBP_periodic_Max
	, pp.DBP_periodic_Mean
	, pp.MAP_periodic_Min
	, pp.MAP_periodic_Max
	, pp.MAP_periodic_Mean
	, ap.SBP_aperiodic_Min
	, ap.SBP_aperiodic_Max
	, ap.SBP_aperiodic_Mean
	, ap.DBP_aperiodic_Min
	, ap.DBP_aperiodic_Max
	, ap.DBP_aperiodic_Mean
	, ap.MAP_aperiodic_Min
	, ap.MAP_aperiodic_Max
	, ap.MAP_aperiodic_Mean
	, pp.RR_Min
	, pp.RR_Max
	, pp.RR_Mean
	, pp.SpO2_Min 
	, pp.SpO2_Max
	, pp.SpO2_Mean
	, pp.TempC_Min
	, pp.TempC_Max
	, pp.TempC_Mean
FROM periodic pp
LEFT JOIN aperiodic ap
ON pp.patientunitstayid = ap.patientunitstayid;
