select distinct 
CASE WHEN Aluminium_Silicon.final_value is not  null THEN to_char (Aluminium_Silicon.final_value,'FM9990') ELSE Aluminium_Silicon.override_value END as "Al&Si (mg/kg)"
from samples
left outer join sample_results Aluminium_Silicon on samples.id = Aluminium_Silicon.sample_id and ((Aluminium_Silicon.characteristic_id = 58) or (Aluminium_Silicon.characteristic_id = 57) or (Aluminium_Silicon.characteristic_id = 23) or (Aluminium_Silicon.characteristic_id = 222))
LEFT OUTER JOIN public.clients on (samples.client_id = clients.id)
LEFT OUTER JOIN public.sample_reports on (samples.sample_report_id = sample_reports.id)
LEFT OUTER JOIN public.gmttest_templates on (samples.gmttest_template_id = gmttest_templates.id)
LEFT OUTER JOIN public.lr_jobs on (lr_jobs.id = samples.job_id)
WHERE 
  samples.job_id is not null
  AND samples.manifold = 'MANIFOLD'
  AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
  AND samples.validated_on::DATE between '2018-01-01' AND '2018-06-30'
  AND (gmttest_templates."name" !~* 'Adhoc' 
  and gmttest_templates."name" != 'FAP' 
  and gmttest_templates."name" != 'FIA') 
  and samples.computed_grade != 'UNKNOWN'
  AND clients."name" ~* 'BP Shipping limited'