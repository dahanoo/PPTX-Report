select distinct 
  vessels."name" ship,
  lr_jobs.job_name, 
  to_char (samples.date_received, 'DD-MM-YYYY') as date_received, 
  CASE when ports."name" != '' THEN initcap (replace (ports."name",',','')) ELSE 'N/S' END as port,
  samples.bunker_date,
  gmttest_templates."name" as "Ordered Grade",
  samples.sulphur_level as "Sulphur level",
  CASE when suppliers."name" != '' THEN UPPER(replace (suppliers."name",',','')) ELSE 'N/S' END as supplier,
  samples.bunker_quantity,
  CASE when samples.bdr_sulphur is not null THEN to_char(samples.bdr_sulphur, 'FM9990.90') ELSE 'N/S' END as "BDN Sulphur",
  CASE WHEN Sulphur_Content.final_value is not null THEN to_char (Sulphur_Content.final_value,'FM9990.90') ELSE Sulphur_Content.override_value END as Sulphur_Content
 
from samples
left outer join sample_results Sulphur_Content on samples.id = Sulphur_Content.sample_id and ((Sulphur_Content.characteristic_id = 231) or (Sulphur_Content.characteristic_id = 232) or (Sulphur_Content.characteristic_id = 358) or (Sulphur_Content.characteristic_id = 234) or (Sulphur_Content.characteristic_id = 33) or (Sulphur_Content.characteristic_id = 235) or (Sulphur_Content.characteristic_id = 233))
LEFT OUTER JOIN public.suppliers on (samples.supplier_id = suppliers.id) LEFT OUTER JOIN public.ports on (samples.port_id = ports.id) 
LEFT OUTER JOIN public.clients on (samples.client_id = clients.id)
LEFT OUTER JOIN public.vessels on (samples.vessel_id = vessels.id)
LEFT OUTER JOIN public.countries on (ports.country_id = countries.id)
LEFT OUTER JOIN public.regions on (ports.region_id = regions.id)
LEFT OUTER JOIN public.sample_reports on (samples.sample_report_id = sample_reports.id)
LEFT OUTER JOIN public.gmttest_templates on (samples.gmttest_template_id = gmttest_templates.id)
LEFT OUTER JOIN public.lr_jobs on (lr_jobs.id = samples.job_id)
WHERE 
  samples.job_id IS NOT NULL
  AND samples.manifold = 'MANIFOLD'
  AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
  AND samples.validated_on::DATE between '{df}' AND '{dt}'
  AND (gmttest_templates."name" !~* 'Adhoc' 
  and gmttest_templates."name" != 'FAP' 
  and gmttest_templates."name" != 'FIA') 
  and samples.computed_grade != 'UNKNOWN'
  AND clients."name" ~* '{cl}'
  and ((Sulphur_Content.final_value > 0.11 and samples.sulphur_level = 'LOW') or (Sulphur_Content.final_value > 3.67 and samples.sulphur_level = 'HIGH'))
order by date_received;