select distinct 
  samples.job_id, 
  samples.id,
  REPLACE (REGEXP_REPLACE(vessels."name", E'\\ \\(.+?\\)', '', 'g'),',','') as "SHIP", 
  vessels.imo_number,
  to_char (samples.date_taken, 'dd-mm-yyyy') as sampling_date,  
  samples.manifold, 
  CASE WHEN Aluminium_Silicon.final_value = 0 THEN to_char(1,'FM9990') else to_char (Aluminium_Silicon.final_value,'FM9990') END as "AlSi",
  CASE WHEN Water_Content.final_value = 0 THEN to_char(0.05,'FM9990.90') else to_char (Water_Content.final_value,'FM9990.90') END as "H2O"
from samples
  left outer join sample_results Aluminium_Silicon on samples.id = Aluminium_Silicon.sample_id and ((Aluminium_Silicon.characteristic_id = 58) or (Aluminium_Silicon.characteristic_id = 57) or (Aluminium_Silicon.characteristic_id = 23) or (Aluminium_Silicon.characteristic_id = 222))
  left outer join sample_results Water_Content on samples.id = Water_Content.sample_id and ((Water_Content.characteristic_id = 352) or (Water_Content.characteristic_id = 8) or (Water_Content.characteristic_id = 270) or (Water_Content.characteristic_id = 269) or (Water_Content.characteristic_id = 267) or (Water_Content.characteristic_id = 266) or (Water_Content.characteristic_id = 268) or (Water_Content.characteristic_id = 351))
  LEFT OUTER JOIN public.clients on (samples.client_id = clients.id)
  LEFT OUTER JOIN public.vessels on (samples.vessel_id = vessels.id)
  LEFT OUTER JOIN public.fuel_types on (samples.fuel_type_id = fuel_types.id)
  LEFT OUTER JOIN public.sample_reports on (samples.sample_report_id = sample_reports.id)
  LEFT OUTER JOIN public.gmttest_templates on (samples.gmttest_template_id = gmttest_templates.id)
WHERE 
  --samples.job_id IS NOT NULL
  (samples.manifold ~* 'IN' or samples.manifold ~* 'OUT' or samples.manifold = 'ENGINE RAIL')
  and samples.validated_on between timestamp '{df}' and timestamp '{dt}'
  AND clients."name" ~* '{cl}'
  AND gmttest_templates."name" = 'FAP'  
  order by "SHIP", samples.job_id;