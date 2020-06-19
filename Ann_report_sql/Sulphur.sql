SELECT
  clients.name,
  characteristics.name, 
  round(avg(sample_results.final_value),2) as t_result, 
  case when samples.sulphur_level = 'HIGH' then 'HS' when samples.sulphur_level = 'LOW' then 'ULS' when samples.sulphur_level = 'LOW_5' then 'VLS' end ||
  case when fuel_types.name = 'Fuel Oil' then 'FO' when fuel_types.name = 'Diesel Oil' then 'DO' end as fuel_type, 
  sum(to_number(samples.bunker_quantity, '00000000000d000000')) as quantity
FROM 
  public.samples, 
  public.sample_results, 
  public.characteristics, 
  public.clients,
  fuel_types
WHERE 
  samples.client_id = clients.id AND
  samples.fuel_type_id = fuel_types.id and
  sample_results.sample_id = samples.id AND
  characteristics.id = sample_results.characteristic_id
  and validated_on::date between '{df}' and '{dt}'
  and clients.name ~* '{cl}'
  and bunker_quantity ~ '\d' 
  and characteristics.name = 'Sulphur Content'
  group by clients.name, characteristics.name,  fuel_types.name, samples.sulphur_level
  order by fuel_types.name desc, sulphur_level asc 