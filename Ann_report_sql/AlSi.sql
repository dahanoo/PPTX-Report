with
  samples as (SELECT "samples".* FROM "samples" LEFT OUTER JOIN "clients" ON "clients"."id" = "samples"."client_id" WHERE "samples"."client_id" IN (SELECT "clients"."id" FROM "clients" WHERE (clients.id != 1583)) AND ("samples"."validated_on" >= '{df}' AND "samples"."validated_on" <= '{dt}' AND "clients"."name" ~* '{cl}'))

select 
  vessels.name as ship,
  ports.name as port,
  suppliers.name as supplier,
  countries.name as country,
results."AlSi_Result"
from samples
left outer join ports on samples.port_id = ports.id
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
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[58, 57, 23, 222]), '0'), '1') as "AlSi_Result"

	)results on true where samples.manifold = 'MANIFOLD' and ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
	AND samples.computed_grade != 'UNKNOWN'
	AND samples.computed_grade != 'FIA'
	AND samples.computed_grade !~* 'Adhoc'
	AND samples.computed_grade != 'FAP'
	AND gmttest_templates."name" !~* 'Adhoc'
	AND gmttest_templates."name" != 'UNKNOWN'
	AND gmttest_templates."name" != 'FIA'
	AND gmttest_templates."name" != 'FAP'
    and "samples"."validated_on" > current_date - interval '2' year