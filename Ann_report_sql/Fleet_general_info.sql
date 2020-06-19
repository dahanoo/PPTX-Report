--count of ships
select count(vessels.*)
from vessels, lr_service_agreements, lr_service_agreements_vessels, clients where 
lr_service_agreements.id = lr_service_agreements_vessels.lr_service_agreement_id
and lr_service_agreements_vessels.vessel_id = vessels.id
and lr_service_agreements.client_id = clients.id
and clients.name ~*  '{cl}'
and lr_service_agreements.service = 'FOB'

union all

--count of samples submitted

select count(samples.*)
from samples
left outer join clients on samples.client_id = clients.id
left outer join lr_service_agreements on lr_service_agreements.client_id = clients.id where
lr_service_agreements.service = 'FOB'
and clients.name ~*  '{cl}'
and samples.validated_on::DATE between '{df}' and '{dt}'

union all

--count of samples submitted Manifold/Drip

select count(samples.*)
from samples, lr_service_agreements, clients, gmttest_templates where 
samples.client_id = clients.id
and samples.gmttest_template_id = gmttest_templates.id 
AND clients."name" ~* '{cl}'
AND samples.validated_on::DATE between '{df}' and '{dt}'
and lr_service_agreements.client_id = clients.id
and lr_service_agreements.service = 'FOB'
and samples.manifold = 'MANIFOLD'
and ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
and (gmttest_templates."name" !~* 'Adhoc' 
and gmttest_templates."name" != 'FAP' 
and gmttest_templates."name" != 'FIA') 
and samples.computed_grade != 'UNKNOWN'
and gmttest_templates."name" != 'Supplementary'

union all

--count of samples submitted FSA

select count(samples.*)
from samples, lr_service_agreements, clients, gmttest_templates where 
samples.client_id = clients.id
and samples.gmttest_template_id = gmttest_templates.id 
and clients.name ~*  '{cl}'
and samples.validated_on::date between '{df}' and '{dt}'
and lr_service_agreements.client_id = clients.id
and lr_service_agreements.service = 'FOB'
and gmttest_templates."name" in ('FAP' , 'FAP ADHOC')

union all

--count of samples submitted others

select count(samples.id)
from samples, clients, gmttest_templates
where 
samples.client_id = clients.id
and samples.gmttest_template_id = gmttest_templates.id 
and clients.name ~*  '{cl}'
and samples.validated_on::date between '{df}' and '{dt}'
and (samples.manifold != 'MANIFOLD'
or ((samples.other_method != 'Drip') or (samples.other_method != 'Autodrip')) and (lower(substr(gmttest_templates."name",1,1)) not in ('r', 'd'))
or samples.other_method not in ('Drip', 'Autodrip')) 
and gmttest_templates.name !='FAP'

union all

-- sample bottle kits dispatched

SELECT  
  case when sum(consumables_order_items.quantity) = 0 then 0 else sum(consumables_order_items.quantity) end as consumable_orders
FROM 
  public.consumables_order_items, 
  public.consumables_orders, 
  public.clients, 
  public.items
WHERE 
  consumables_order_items.consumables_order_id = consumables_orders.id AND
  consumables_order_items.item_id = items.id AND
  clients.id = consumables_orders.client_id and
  consumables_orders.completed_at::date between '{df}' and '{dt}' and
  clients.name ~*  '{cl}' and 
  items.name = 'FOBAS SAMPLE BOTTLE KIT'

union all

--Avg analysis TaT

SELECT 

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
samples.validated_on::date between '{df}' and '{dt}' and
gmt_templates.lr_template = 't' and
kpi_delayed_receive = 'f' and 
gmt_templates.lr_grade_name != 'FIA' and
gmt_templates.name != 'Adhoc HFO' and 
gmt_templates.name != 'Adhoc DO' and
lr_jobs.job_name is not null and
sample_rollbacks.sample_id is null and
clients.name ~* '{cl}'
and samples.kpi_allowance = 24
and samples.validated_on is not null

union all 

-- Investigations

SELECT 
  count(lr_jobs.job_name) "INVS"
FROM 
  public.lr_jobs, 
  public.samples, 
  public.clients
WHERE 
  lr_jobs.id = samples.job_id AND
  samples.client_id = clients.id
  and published_at::date between '{df}' and '{dt}' 
  and job_name ~* 'INVE'
  and clients.name ~* '{cl}'