with
  samples as (SELECT "samples".*, case when attachments.file_file_name ~* 'bdr|bdn' then 'yes' else 'no' end as "BDN" FROM "samples" LEFT OUTER JOIN "clients" ON "clients"."id" = "samples"."client_id" left outer join attachments on attachments.parent_id = samples.id WHERE "samples"."client_id" IN (SELECT "clients"."id" FROM "clients" WHERE (clients.id != 1583)) AND ("samples"."validated_on" >= '{df}' AND "samples"."validated_on" <= '{dt}'))

select distinct 
  samples.id,
  samples."BDN",
  samples.job_id,
  vessels.imo_number, 
  case samples.fuel_type_id when 1 then 'HFO' when 2 then 'MGO' else '(unknown)' end as material_type,
  coalesce(to_char(samples.bdr_density/1000, 'FM9990.0000'), 'N/S') as ADV_DENSITY,
  coalesce(to_char(samples.bdr_viscosity,'FM9990.0'), 'N/S') as ADV_VIS,
  coalesce(to_char(samples.bdr_sulphur, 'FM9990.99'), 'N/S') as ADV_SULPHUR,
  samples.sulphur_level as sulphur_level,
  results.*,
  gmttest_templates."name" "advised grade",
  samples.overall_lr_outcome
from samples
left outer join ports on samples.port_id = ports.id
left outer join attachments on attachments.parent_id = samples.id
left outer join suppliers on samples.supplier_id = suppliers.id
left outer join countries on ports.country_id = countries.id
left outer join clients on clients.id = samples.client_id
left outer join vessels on vessels.id = samples.vessel_id
LEFT OUTER JOIN gmttest_templates on (samples.gmttest_template_id = gmttest_templates.id)
left outer join sample_results Density_15C on samples.id = Density_15C.sample_id and 
                               Density_15C.characteristic_id in (3,274,35,118,120,123,125,121,122,124,119)
join lateral (select f_r_s('FM9990.00', samples.id, ARRAY[158, 370, 34, 164, 163]) as "V40_Result", 
                     f_r_s('FM9990.0', samples.id, ARRAY[4,165,166,167,168,169]) as "V50_Result",
                     CASE WHEN Density_15C.final_value is not null 
                          THEN CASE WHEN Density_15C.final_value > 2 
                          THEN to_char (Density_15C.final_value / 1000,'FM9990.9990') 
                          ELSE to_char(Density_15C.final_value,'FM9990.0000') END 
						  ELSE Density_15C.override_value END as "TESTED_DEN",
                     coalesce(nullif(f_r_s('FM9990.00', samples.id, ARRAY[231,232,358,234,33,235,233]), '0.00'), '0.01') as "Sulphur_Result",
             	     f_r_s('FM9990.00', samples.id, ARRAY[361, 249, 250, 261, 6, 248]) as "Total sediment",
                     f_r_s('FM9990.00', samples.id, ARRAY[258, 353, 257, 259, 313]) as "TSP_Result",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[58, 57, 23, 222]), '0'), '1') as "AlSi_Result"
              )results on true where samples.manifold = 'MANIFOLD'
	AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
	AND samples.computed_grade != 'UNKNOWN'
	AND samples.computed_grade != 'FIA'
	AND samples.computed_grade !~* 'Adhoc'
	AND samples.computed_grade != 'FAP'
	AND gmttest_templates."name" !~* 'Adhoc'
	AND gmttest_templates."name" != 'UNKNOWN'
	AND gmttest_templates."name" != 'FIA'
	AND gmttest_templates."name" != 'FAP'
	order by vessels.imo_number
