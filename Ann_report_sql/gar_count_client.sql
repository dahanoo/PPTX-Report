select distinct 
case when overall_lr_outcome = 'PUCE' then 'AMBER'
when overall_lr_outcome = 'PASS' then 'GREEN'
when overall_lr_outcome = 'WARNING' then 'AMBER'
else overall_lr_outcome end as outcome
, count(samples.id)
from samples, gmttest_templates, clients
where samples.gmttest_template_id = gmttest_templates.id
  and samples.client_id = clients.id
  AND samples.manifold = 'MANIFOLD'
  AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
  AND samples.validated_on::DATE between '{df}' AND '{dt}'
  AND (gmttest_templates."name" !~* 'Adhoc' 
  and gmttest_templates."name" != 'FAP' 
  and gmttest_templates."name" != 'FIA') 
  and samples.computed_grade != 'UNKNOWN'
  AND clients."name" ~* '{cl}'
  and overall_lr_outcome in ('AMBER', 'GREEN' , 'PASS' , 'PUCE', 'WARNING')
group by outcome

union all

select distinct 
case when overall_lr_outcome = 'FAIL' then 'RED'
when gmttest_templates.name = 'DMA' AND Water_Content.final_value > 0.1 THEN 'RED'
when samples.computed_grade ~* '---' and overall_lr_outcome = 'RED' then 'RED'
else overall_lr_outcome end as outcome
, count(distinct samples.id)
from samples 
left outer join sample_results Water_Content on samples.id = Water_Content.sample_id and ((Water_Content.characteristic_id = 352) or (Water_Content.characteristic_id = 8) or (Water_Content.characteristic_id = 270) or (Water_Content.characteristic_id = 269) or (Water_Content.characteristic_id = 267) or (Water_Content.characteristic_id = 266) or (Water_Content.characteristic_id = 268) or (Water_Content.characteristic_id = 351)),
gmttest_templates, clients, characteristics, sample_results
where samples.gmttest_template_id = gmttest_templates.id
  and samples.client_id = clients.id
  and samples.id = sample_results.sample_id 
  AND samples.manifold = 'MANIFOLD'
  AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
  AND samples.validated_on::DATE between '{df}' AND '{dt}'
  AND (gmttest_templates."name" !~* 'Adhoc' 
  and gmttest_templates."name" != 'FAP' 
  and gmttest_templates."name" != 'FIA') 
  and samples.computed_grade != 'UNKNOWN'
  AND clients."name" ~* '{cl}'
  and overall_lr_outcome not in ('AMBER', 'GREEN' , 'PASS' , 'PUCE', 'WARNING')
group by outcome  