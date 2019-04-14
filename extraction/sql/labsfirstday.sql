-- This query pivots lab values taken in the first 24 hours of a patient's ICU stay
-- Since all eICU stays are centered upon the ICU stay, this uses ICU entry offsets
-- not admission to hospital offsets.

DROP MATERIALIZED VIEW IF EXISTS labsfirstday CASCADE;
CREATE materialized VIEW labsfirstday AS

SELECT
  pvt.uniquepid, pvt.patienthealthsystemstayid, pvt.patientunitstayid
  , MIN(CASE WHEN labname = 'anion gap' THEN labresult ELSE null END) as ANIONGAP_min
  , MAX(CASE WHEN labname = 'anion gap' THEN labresult ELSE null END) as ANIONGAP_max
  , MIN(CASE WHEN labname = 'albumin' THEN labresult ELSE null END) as ALBUMIN_min
  , MAX(CASE WHEN labname = 'albumin' THEN labresult ELSE null END) as ALBUMIN_max
  , MIN(CASE WHEN labname = 'amylase' THEN labresult ELSE null END) as AMYLASE_min
  , MAX(CASE WHEN labname = 'amylase' THEN labresult ELSE null END) as AMYLASE_max
  -- , MIN(CASE WHEN labname = '-bands' THEN labresult ELSE null END) as BANDS_min
  -- , MAX(CASE WHEN labname = '-bands' THEN labresult ELSE null END) as BANDS_max
  , MIN(CASE WHEN labname = 'Base Excess' THEN labresult ELSE null END) as BASEEXCESS_min
  , MAX(CASE WHEN labname = 'Base Excess' THEN labresult ELSE null END) as BASEEXCESS_max
  , MIN(CASE WHEN labname = 'bicarbonate' OR labname = 'HCO3' THEN labresult ELSE null END) as BICARBONATE_min
  , MAX(CASE WHEN labname = 'bicarbonate' OR labname = 'HCO3' THEN labresult ELSE null END) as BICARBONATE_max
  , MIN(CASE WHEN labname = 'BUN' THEN labresult ELSE null end) as BUN_min
  , MAX(CASE WHEN labname = 'BUN' THEN labresult ELSE null end) as BUN_max
  , MIN(CASE WHEN labname = 'BNP' THEN labresult ELSE null end) as BNP_min
  , MAX(CASE WHEN labname = 'BNP' THEN labresult ELSE null end) as BNP_max
  , MIN(CASE WHEN labname = 'CPK' THEN labresult ELSE null end) as CPK_min
  , MAX(CASE WHEN labname = 'CPK' THEN labresult ELSE null end) as CPK_max
  , MIN(CASE WHEN labname = 'total bilirubin' THEN labresult ELSE null END) as BILIRUBIN_min
  , MAX(CASE WHEN labname = 'total bilirubin' THEN labresult ELSE null END) as BILIRUBIN_max
  , MIN(CASE WHEN labname = 'calcium' THEN labresult ELSE null END) as CALCIUM_min
  , MAX(CASE WHEN labname = 'calcium' THEN labresult ELSE null END) as CALCIUM_max
  , MIN(CASE WHEN labname = 'ionized calcium' THEN labresult ELSE null END) as IONCALCIUM_min
  , MAX(CASE WHEN labname = 'ionized calcium' THEN labresult ELSE null END) as IONCALCIUM_max
  , MIN(CASE WHEN labname = 'creatinine' THEN labresult ELSE null END) as CREATININE_min
  , MAX(CASE WHEN labname = 'creatinine' THEN labresult ELSE null END) as CREATININE_max
  , MIN(CASE WHEN labname = 'chloride' THEN labresult ELSE null END) as CHLORIDE_min
  , MAX(CASE WHEN labname = 'chloride' THEN labresult ELSE null END) as CHLORIDE_max
  , MIN(CASE WHEN labname = 'glucose' THEN labresult ELSE null END) as GLUCOSE_min
  , MAX(CASE WHEN labname = 'glucose' THEN labresult ELSE null END) as GLUCOSE_max
  , MIN(CASE WHEN labname = 'fibrinogen' THEN labresult ELSE null END) as FIBRINOGEN_min
  , MAX(CASE WHEN labname = 'fibrinogen' THEN labresult ELSE null END) as FIBRINOGEN_max
  , MIN(CASE WHEN labname = 'Hct' THEN labresult ELSE null END) as HEMATOCRIT_min
  , MAX(CASE WHEN labname = 'Hct' THEN labresult ELSE null END) as HEMATOCRIT_max
  , MIN(CASE WHEN labname = 'Hgb' THEN labresult ELSE null END) as HEMOGLOBIN_min
  , MAX(CASE WHEN labname = 'Hgb' THEN labresult ELSE null END) as HEMOGLOBIN_max
  , MIN(CASE WHEN labname = 'lactate' THEN labresult ELSE null END) as LACTATE_min
  , MAX(CASE WHEN labname = 'lactate' THEN labresult ELSE null END) as LACTATE_max
  , MIN(CASE WHEN labname = 'lipase' THEN labresult ELSE null END) as LIPASE_min
  , MAX(CASE WHEN labname = 'lipase' THEN labresult ELSE null END) as LIPASE_max
  , MIN(CASE WHEN labname = '-lymphs' THEN labresult ELSE null END) as LYMPHS_min
  , MAX(CASE WHEN labname = '-lymphs' THEN labresult ELSE null END) as LYMPHS_max
  , MIN(CASE WHEN labname = 'magnesium' THEN labresult ELSE null END) as MAGNESIUM_min
  , MAX(CASE WHEN labname = 'magnesium' THEN labresult ELSE null END) as MAGNESIUM_max
  , MIN(CASE WHEN labname = 'paO2' THEN labresult ELSE null END) as PAO2_min
  , MAX(CASE WHEN labname = 'paO2' THEN labresult ELSE null END) as PAO2_max
  , MIN(CASE WHEN labname = 'pH' THEN labresult ELSE null END) as PH_min
  , MAX(CASE WHEN labname = 'pH' THEN labresult ELSE null END) as PH_max
  , MIN(CASE WHEN labname = 'platelets x 1000' THEN labresult ELSE null END) as PLATELET_min
  , MAX(CASE WHEN labname = 'platelets x 1000' THEN labresult ELSE null END) as PLATELET_max
  , MIN(CASE WHEN labname = '-polys' THEN labresult ELSE null END) as PMN_min
  , MAX(CASE WHEN labname = '-polys' THEN labresult ELSE null END) as PMN_max
  , MIN(CASE WHEN labname = 'phosphate' THEN labresult ELSE null END) as PHOSPHATE_min
  , MAX(CASE WHEN labname = 'phosphate' THEN labresult ELSE null END) as PHOSPHATE_max
  , MIN(CASE WHEN labname = 'potassium' THEN labresult ELSE null END) as POTASSIUM_min
  , MAX(CASE WHEN labname = 'potassium' THEN labresult ELSE null END) as POTASSIUM_max
  , MIN(CASE WHEN labname = 'PTT' THEN labresult ELSE null END) as PTT_min
  , MAX(CASE WHEN labname = 'PTT' THEN labresult ELSE null END) as PTT_max
  , MIN(CASE WHEN labname = 'PT - INR' THEN labresult ELSE null END) as INR_min
  , MAX(CASE WHEN labname = 'PT - INR' THEN labresult ELSE null END) as INR_max
  , MIN(CASE WHEN labname = 'PT' THEN labresult ELSE null END) as PT_min
  , MAX(CASE WHEN labname = 'PT' THEN labresult ELSE null END) as PT_max
  , MIN(CASE WHEN labname = 'sodium' THEN labresult ELSE null END) as SODIUM_min
  , MAX(CASE WHEN labname = 'sodium' THEN labresult ELSE null end) as SODIUM_max
  , MIN(CASE WHEN labname = 'troponin - I' THEN labresult ELSE null END) as TROPI_min
  , MAX(CASE WHEN labname = 'troponin - I' THEN labresult ELSE null end) as TROPI_max
  , MIN(CASE WHEN labname = 'troponin - T' THEN labresult ELSE null END) as TROPT_min
  , MAX(CASE WHEN labname = 'troponin - T' THEN labresult ELSE null end) as TROPT_max
  , MIN(CASE WHEN labname = 'WBC x 1000' THEN labresult ELSE null end) as WBC_min
  , MAX(CASE WHEN labname = 'WBC x 1000' THEN labresult ELSE null end) as WBC_max

FROM
( -- begin query that extracts the data
  SELECT p.uniquepid, p.patienthealthsystemstayid, p.patientunitstayid, le.labname
  , le.labresult AS labresult
  FROM patient p
  LEFT JOIN lab le
    ON p.patientunitstayid = le.patientunitstayid
    AND le.labresultoffset <= 1440
    AND labresult IS NOT null AND labresult > 0 -- lab values cannot be 0 and cannot be negative
) pvt
GROUP BY pvt.uniquepid, pvt.patienthealthsystemstayid, pvt.patientunitstayid
ORDER BY pvt.uniquepid, pvt.patienthealthsystemstayid, pvt.patientunitstayid;
