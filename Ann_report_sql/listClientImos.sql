select distinct vessels.name from samples, vessels, clients
where samples.vessel_id = vessels.id and
samples.client_id = clients.id and
validated_on between '{df}' and '{dt}' and
clients.name ~* '{cl}' and     
samples.port_id is not null
and samples.supplier_id is not null
AND samples.manifold = 'MANIFOLD'
AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
order by vessels.name