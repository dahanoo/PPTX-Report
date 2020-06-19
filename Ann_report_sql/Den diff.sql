select distinct  
  replace (clients."name",',','')as client,   
  replace (vessels."name",',','')as ship,
  vessels.imo_number,
  round(sum(( ( (Density_15C.final_value/1000) - (samples.bdr_density/1000)  ) * to_number(samples.bunker_quantity, '00000000000d000000')  )),0) AS "Total_Diff" 
from samples
left outer join sample_results Density_15C on samples.id = Density_15C.sample_id and ((Density_15C.characteristic_id = 3) or (Density_15C.characteristic_id = 274) or (Density_15C.characteristic_id = 35) or (Density_15C.characteristic_id = 118) or (Density_15C.characteristic_id = 120) or (Density_15C.characteristic_id = 123) or (Density_15C.characteristic_id = 125) or (Density_15C.characteristic_id = 121) or (Density_15C.characteristic_id = 122) or (Density_15C.characteristic_id = 124) or (Density_15C.characteristic_id = 119))
LEFT OUTER JOIN public.clients on (samples.client_id = clients.id)
LEFT OUTER JOIN public.vessels on (samples.vessel_id = vessels.id)
LEFT OUTER JOIN public.gmttest_templates on (samples.gmttest_template_id = gmttest_templates.id)
WHERE 
  samples.job_id IS NOT NULL
  AND samples.manifold = 'MANIFOLD'
  AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
  AND samples.validated_on between timestamp '{df}' AND timestamp  '{dt}'
  AND (gmttest_templates."name" != 'Adhoc DO' and gmttest_templates."name" != 'Adhoc HFO' and gmttest_templates."name" != 'FAP' and gmttest_templates."name" != 'FIA') 
  and samples.computed_grade != 'UNKNOWN'
  and bdr_density is not null 
  and bunker_quantity is not null
  and clients.name ~* '{cl}'
  and samples.bdr_density IS NOT NULL
  AND samples.bunker_quantity != '' 
  AND samples.bdr_density IS NOT NULL 
  AND samples.bdr_density > 2 
  AND Density_15C.final_value > 2 
  
  group by clients."name", vessels."name",
  vessels.imo_number
  having sum(((Density_15C.final_value/1000) - (samples.bdr_density/1000)) * to_number(samples.bunker_quantity, '00000000000d000000')) > 5 or
  sum(((Density_15C.final_value/1000) - (samples.bdr_density/1000)) * to_number(samples.bunker_quantity, '00000000000d000000')) < -5
  order by "Total_Diff"