Select 
suppliers.name as supplier, 
case when count(samples.*) >= 10 then count(samples.*) end as "supplier with count GT 10",
case when count(samples.*) < 10 then count(samples.*) end as "supplier with count LT 10"
from suppliers, samples, clients , gmttest_templates, lr_service_agreements
where 
suppliers.id = samples.supplier_id 
and clients.id = samples.client_id
and gmttest_templates.id = samples.gmttest_template_id
and lr_service_agreements.client_id = clients.id
and clients.name ~* '{cl}'
and date_received between '{df}' and '{dt}' 
and lr_service_agreements.service = 'FOB'
and samples.manifold = 'MANIFOLD'
and ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
and (gmttest_templates."name" !~* 'Adhoc' 
and gmttest_templates."name" != 'FAP' 
and gmttest_templates."name" != 'FIA') 
and samples.computed_grade != 'UNKNOWN'
group by supplier
order by "supplier with count GT 10" desc

