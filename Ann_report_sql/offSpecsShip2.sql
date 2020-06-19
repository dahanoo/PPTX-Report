select distinct 
  count(samples.id) as samples, 
  replace (clients."name",',','') as client,   
  case when vessels."name"~* '.*?\((.*?)\)' then substr(vessels."name",1,length(vessels."name") - 3 - length(substring(vessels."name" from '.*?\((.*?)\)'))) else vessels."name" end as ship,
  case when overall_lr_outcome = 'PUCE' then 'AMBER'
when overall_lr_outcome = 'PASS' then 'GREEN'
when overall_lr_outcome = 'FAIL' then 'RED'
when overall_lr_outcome = 'WARNING' then 'AMBER'
else overall_lr_outcome end as status
from samples
  LEFT OUTER JOIN public.clients on (samples.client_id = clients.id)
  LEFT OUTER JOIN public.vessels on (samples.vessel_id = vessels.id)
  LEFT OUTER JOIN public.gmttest_templates on (samples.gmttest_template_id = gmttest_templates.id)
WHERE 
  samples.job_id IS NOT NULL
  AND samples.manifold = 'MANIFOLD'
  AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
AND clients."name" ~* '{cl}'
AND samples.validated_on::DATE between '{df}' and '{dt}'
  AND (gmttest_templates."name" !~* 'Adhoc' 
  and gmttest_templates."name" != 'FAP' 
  and gmttest_templates."name" != 'FIA') 
  and samples.computed_grade != 'UNKNOWN'
 group by 
 client,   
 ship,
 status