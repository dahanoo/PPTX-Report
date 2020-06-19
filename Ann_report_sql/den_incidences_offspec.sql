select distinct 
  initcap (vessels."name") ship,
  lr_jobs.job_name, 
  CASE when ports."name" != '' THEN initcap (replace (ports."name",',','')) ELSE 'N/S' END as port,
  samples.bunker_date,
  gmttest_templates."name" as "Ordered Grade",
  CASE when suppliers."name" != '' THEN initcap(replace (suppliers."name",',','')) ELSE 'N/S' END as supplier,
  samples.bunker_quantity,
  CASE when samples.bdr_density is not null THEN to_char(samples.bdr_density / 1000, 'FM9990.9999') ELSE 'N/S' END as "BDN density",
  CASE WHEN Density_15C.final_value is not null THEN CASE WHEN Density_15C.final_value > 2 THEN to_char (Density_15C.final_value / 1000,'FM9990.9990') ELSE to_char(Density_15C.final_value,'FM9990.9990') END ELSE Density_15C.override_value END as "DEN15",
  CASE when samples.bdr_density is not null THEN to_char((samples.bdr_density/1000) - (Density_15C.final_value/1000), 'FM9990.9999') else 'N/S' end as diff
  
from samples
left outer join sample_results Density_15C on samples.id = Density_15C.sample_id and ((Density_15C.characteristic_id = 3) or (Density_15C.characteristic_id = 274) or (Density_15C.characteristic_id = 35) or (Density_15C.characteristic_id = 118) or (Density_15C.characteristic_id = 120) or (Density_15C.characteristic_id = 123) or (Density_15C.characteristic_id = 125) or (Density_15C.characteristic_id = 121) or (Density_15C.characteristic_id = 122) or (Density_15C.characteristic_id = 124) or (Density_15C.characteristic_id = 119))
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
  AND samples.validated_on::DATE between timestamp '{df}' and timestamp '{dt}'
  AND (gmttest_templates."name" !~* 'Adhoc' 
  and gmttest_templates."name" != 'FAP' 
  and gmttest_templates."name" != 'FIA') 
  and samples.computed_grade != 'UNKNOWN'
  AND clients."name" ~* '{cl}'
  and samples.bdr_density - Density_15C.final_value > 10
order by bunker_date