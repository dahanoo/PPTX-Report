SELECT 
  lr_service_agreements."REVISION", 
  clients.name,
  case when "REVISION" = 3 then 'ISO-8217-2005'
  when "REVISION" = 4 then 'ISO-8217-2012'
  when "REVISION" = 5 then 'ISO-8217-2017'
  end as revision,
  lr_service_agreements.service
FROM 
  public.lr_service_agreements, 
  public.clients
WHERE 
  lr_service_agreements.client_id = clients.id
  and clients.name ILIKE '%{cl}%'
  and lr_service_agreements.service = 'FOB'
  and lr_service_agreements.status = 'Current'
  order by clients.name
