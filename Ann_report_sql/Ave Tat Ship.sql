SELECT 
--cached_vessel_name AS "Ship",

round(avg(to_number(interval_as_days(samples.validated_on - date_taken), 'FM9999D00')),0) as "days_between",
 
round(avg(to_number(interval_as_days(samples.validated_on - scheduled_collection_date), 'FM9999D00')),0) as "days_in_transit",

round(avg(to_number(interval_as_hours(lr_jobs.published_at - samples.date_received), 'FM9999D99S'))/24,2) as "labTaT"

FROM "samples" 
LEFT OUTER JOIN "lr_jobs" ON "lr_jobs"."id" = "samples"."job_id" 
left join laboratories on laboratories.id = samples.laboratory_id 
left join ports on ports.id = samples.port_id 
left join gmttest_templates on gmttest_templates.id = samples.gmttest_template_id 
left join gmt_templates on gmt_templates.id = gmttest_templates.gmt_template_id 
left join sample_rollbacks on (sample_rollbacks.sample_id = samples.id),
clients
WHERE (lr_jobs.lr_status is null or lr_jobs.lr_status != 'Cancelled') and
clients.id = samples.client_id and
samples.validated_on between timestamp '{df}' AND timestamp '{dt}' and
gmt_templates.lr_template = 't' and
kpi_delayed_receive = 'f' and 
gmt_templates.lr_grade_name != 'FIA' and
gmt_templates.name != 'Adhoc HFO' and 
gmt_templates.name != 'Adhoc DO' and
lr_jobs.job_name is not null and
sample_rollbacks.sample_id is null and
clients.name ~* '{cl}'
and samples.kpi_allowance = 24
and to_number(interval_as_hours(lr_jobs.published_at - samples.validated_on), 'FM9999D99S') < 200
and samples.validated_on is not null
group by clients.name
order by clients.name
