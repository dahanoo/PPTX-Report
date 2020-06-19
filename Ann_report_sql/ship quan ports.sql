SELECT
  distinct
  vessels.name,
  sum(to_number(samples.bunker_quantity, '00000000000d000000')) as quantity,
  array_agg(distinct ' '||ports.name) as ports 
FROM 
  public.samples, 
  public.clients, 
  public.ports, 
  public.vessels,
  suppliers
WHERE 
  samples.port_id = ports.id AND
  samples.client_id = clients.id AND
  samples.vessel_id = vessels.id and 
  samples.supplier_id = suppliers.id and
  clients.name ~* '{cl}' and
  samples.validated_on between timestamp '{df}' and '{dt}' and
  bunker_quantity ~ '\d' 
  group by vessels.name 
  order by vessels.name;
