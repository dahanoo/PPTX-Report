with
 samples as (SELECT "samples".* FROM "samples", lr_jobs WHERE((lr_jobs.published_at::date) <= '{dt}' AND lr_jobs.published_at::date >= '{df}') and samples.job_id = lr_jobs.id)
 SELECT samples.id as "ref",
 clients.name client,
 ports.name "port",
 laboratories.code "lab",
 interval_as_days(scheduled_collection_date - date_taken) as "collected_sampled",
 case when date_received is not null then trim(leading ' ' from interval_as_days(date_received - scheduled_collection_date)) else null end as "received_collected"

FROM "samples" 
LEFT OUTER JOIN "lr_jobs" ON "lr_jobs"."id" = "samples"."job_id" 
left join clients on clients.id = samples.client_id
left join laboratories on laboratories.id = samples.laboratory_id 
left join ports on ports.id = samples.port_id 
left join gmttest_templates on gmttest_templates.id = samples.gmttest_template_id 
left join gmt_templates on gmt_templates.id = gmttest_templates.gmt_template_id 
left join sample_rollbacks on (sample_rollbacks.sample_id = samples.id)
WHERE (lr_jobs.lr_status is null or lr_jobs.lr_status != 'Cancelled') and
  kpi_delayed_receive = 'f' 
  and manifold in ('MANIFOLD', 'Vessel Manifold', 'VESSEL MANIFOLD')
  AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
  AND (gmttest_templates."name" !~* 'Adhoc' 
  and gmttest_templates."name" != 'FAP' 
  and gmttest_templates."name" != 'FIA') 
  and samples.computed_grade != 'UNKNOWN'
  and sample_rollbacks.sample_id is null 
  and cached_vessel_name !~* 'dummy' 
  and samples.client_id != 3
  and scheduled_collection_date is not null 
  and date_taken is not null