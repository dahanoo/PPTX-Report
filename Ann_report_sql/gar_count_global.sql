select distinct case when overall_lr_outcome = 'PUCE' then 'AMBER'
when overall_lr_outcome = 'PASS' then 'GREEN'
when overall_lr_outcome = 'WARNING' then 'AMBER'
else overall_lr_outcome end as outcome, 
count(samples.id)
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
  and overall_lr_outcome != ''
group by outcome  
order by outcome   
