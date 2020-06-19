select distinct
vessels.name,
substr(vessels.imo_number,1,7) as imo,
overall_lr_outcome,
case when overall_lr_outcome = 'GREEN' then count(overall_lr_outcome)
when overall_lr_outcome = 'AMBER' then count(overall_lr_outcome)
when overall_lr_outcome = 'RED' then count(overall_lr_outcome) end as "Total_tested"
   from samples
   LEFT OUTER JOIN gmttest_templates on samples.gmttest_template_id = gmttest_templates.id
   LEFT OUTER JOIN clients on samples.client_id = clients.id
   LEFT OUTER JOIN vessels on samples.vessel_id = vessels.id
   where samples.job_id is not null
     AND samples.manifold = 'MANIFOLD'
     AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
     AND samples.validated_on::DATE between '{df}' AND '{dt}'
     AND samples.computed_grade != 'UNKNOWN'
     AND samples.computed_grade != 'FIA'
     AND samples.computed_grade !~* 'Adhoc'
     AND samples.computed_grade != 'FAP'
     AND gmttest_templates."name" !~* 'Adhoc'
     AND gmttest_templates."name" != 'UNKNOWN'
     AND gmttest_templates."name" != 'FIA'
     AND gmttest_templates."name" != 'FAP'
     AND clients.name ~* '{cl}'
  group by vessels.name, imo, overall_lr_outcome
  order by vessels.name, imo, overall_lr_outcome


	     

