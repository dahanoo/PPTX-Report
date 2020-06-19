select distinct 
replace (vessels."name",',','')as "Ship",
vessels.imo_number as "IMO Number",
to_char (samples.date_taken, 'DD-MM-YYYY') as "Bunker date",  
CASE when ports."name" != '' THEN initcap (replace (ports."name",',','')) ELSE 'N/S' END as "Port",
CASE when suppliers."name" != '' THEN UPPER(replace (suppliers."name",',','')) ELSE 'N/S' END as "Supplier",
CASE WHEN Aluminium.final_value is not null THEN to_char (Aluminium.final_value,'FM9990') ELSE Aluminium.override_value END as "Al (mg/kg",
CASE WHEN Silicon.final_value is not null THEN to_char (Silicon.final_value,'FM9990') ELSE Silicon.override_value END as "Si (mg/kg)",
CASE WHEN Aluminium_Silicon.final_value is not  null THEN to_char (Aluminium_Silicon.final_value,'FM9990') ELSE Aluminium_Silicon.override_value END as "Al&Si (mg/kg)"
from samples
left outer join sample_results Aluminium on samples.id = Aluminium.sample_id and ((Aluminium.characteristic_id = 357) or (Aluminium.characteristic_id = 314) or (Aluminium.characteristic_id = 315) or (Aluminium.characteristic_id = 16)) 
left outer join sample_results Aluminium_Silicon on samples.id = Aluminium_Silicon.sample_id and ((Aluminium_Silicon.characteristic_id = 58) or (Aluminium_Silicon.characteristic_id = 57) or (Aluminium_Silicon.characteristic_id = 23) or (Aluminium_Silicon.characteristic_id = 222))
left outer join sample_results Silicon on samples.id = Silicon.sample_id and ((Silicon.characteristic_id = 310) or (Silicon.characteristic_id = 17) or (Silicon.characteristic_id = 312))
LEFT OUTER JOIN public.suppliers on (samples.supplier_id = suppliers.id) LEFT OUTER JOIN public.ports on (samples.port_id = ports.id) 
LEFT OUTER JOIN public.clients on (samples.client_id = clients.id)
LEFT OUTER JOIN public.vessels on (samples.vessel_id = vessels.id)
LEFT OUTER JOIN public.fuel_types on (samples.fuel_type_id = fuel_types.id)
LEFT OUTER JOIN public.countries on (ports.country_id = countries.id)
LEFT OUTER JOIN public.regions on (ports.region_id = regions.id)
LEFT OUTER JOIN public.sample_reports on (samples.sample_report_id = sample_reports.id)
LEFT OUTER JOIN public.gmttest_templates on (samples.gmttest_template_id = gmttest_templates.id)
LEFT OUTER JOIN public.lr_jobs on (lr_jobs.id = samples.job_id)
WHERE 
  samples.job_id is not null
  AND samples.manifold = 'MANIFOLD'
  AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
  AND samples.validated_on::DATE between '{df}' AND '{dt}'
  AND (gmttest_templates."name" !~* 'Adhoc' 
  and gmttest_templates."name" != 'FAP' 
  and gmttest_templates."name" != 'FIA') 
  and samples.computed_grade != 'UNKNOWN'
  AND clients."name" ~* '{cl}'
  order by "Ship"
