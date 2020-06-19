SELECT
  distinct
  ports.name, 
  array_agg(distinct ' '||suppliers.name) as suppliers
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
  samples.validated_on between timestamp '{df}' and '{dt}'
  group by ports.name
  order by ports.name;
