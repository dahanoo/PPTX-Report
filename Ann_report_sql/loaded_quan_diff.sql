with
  samples as (SELECT "samples".* FROM "samples" LEFT OUTER JOIN "clients" ON "clients"."id" = "samples"."client_id" WHERE "samples"."client_id" IN (SELECT "clients"."id" FROM "clients" WHERE (clients.id != 1583)) AND ("samples"."validated_on" >= '{df}' AND "samples"."validated_on" <= '{dt}' AND "clients"."name" ~* '{cl}'))
select 
  samples.job_id,
  samples.id, 
  clients.name as client,
  REPLACE (REGEXP_REPLACE(vessels."name", E'\\ \\(.+?\\)', '', 'g'),',','') as ship, 
  vessels.imo_number, 
  to_char (samples.date_received, 'DD-MM-YYYY') as date_received,
  samples.bunker_date,
  samples.manifold,
  samples.other_method,
  to_char (samples.date_taken, 'DD-MM-YYYY') as sampling_date,
  to_char (samples.validated_on, 'DD-MM-YYYY') as validated_on,
  ports.name as port,
  suppliers.name as supplier,
  countries.name as country,
  case samples.fuel_type_id when 1 then 'HFO' when 2 then 'MGO' else '(unknown)' end as material_type,
  samples.bdr_density/1000 as ADV_DENSITY,
  samples.bdr_viscosity as ADV_VIS,
  samples.bdr_sulphur as ADV_SULPHUR,
  samples.sulphur_level as sulphur_level,
  samples.bunker_quantity,
results.*,
samples.computed_grade,
overall_lr_outcome

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

                     f_r_s('FM9990', samples.id, ARRAY[30, 288, 85, 87]) as "CCAI_Result",
                     coalesce(nullif(f_r_s('FM9990.00', samples.id, ARRAY[352,8,270,269,267,266,268,351]), '0.00'), '0.05') as "Water_Result",
                     f_r_s('FM9990.0', samples.id, ARRAY[135,2,136,134]) as "Fpt_Result",
                     coalesce(nullif(f_r_s('FM9990.00', samples.id, ARRAY[231,232,358,234,33,235,233]), '0.00'), '0.01') as "Sulphur_Result",
                     f_r_s('FM9990', samples.id, ARRAY[213,340,11]) as "PPT_Result",
                     f_r_s('FM9990', samples.id, ARRAY[98, 99, 100, 302, 386, 12, 95]) as "CFPP_Result",
                     f_r_s('FM9990.00', samples.id, ARRAY[139, 138, 142, 141, 140, 143, 276, 144]) as "GSE_Calc",
                     f_r_s('FM9990.00', samples.id, ARRAY[195,196,194,198,275,31,197]) as "NSE_Calc",              
		     f_r_s('FM9990.00', samples.id, ARRAY[361, 249, 250, 261, 6, 248]) as "Total sediment",
                     f_r_s('FM9990.00', samples.id, ARRAY[258, 353, 257, 259, 313]) as "TSP_Result",
                     f_r_s('FM9990.00', samples.id, ARRAY[5,187,380,188]) as "MCR_Result",
                     f_r_s('FM9990.00', samples.id, ARRAY[237, 238, 14]) as "TAN_Result",
                     f_r_s('FM9990.000', samples.id, ARRAY[326,1,64,66,67,366,304,65,68,336]) as "Ash_Result",
                     
		     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[314, 357, 315, 16]), '0'), '1') as "Aluminium",	     
		     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[312, 17, 310]), '0'), '1') as "Silicon",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[58, 57, 23, 222]), '0'), '1') as "AlSi_Result",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[21, 325, 324]), '0'), '1') as "Ca_Result",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[311,22,309,203]), '0'), '1') as "Phosphorus_Result",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[18, 321, 323]), '0'), '1') as "Zn",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[334,331,15]), '0'), '1') as "V_Result",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[19,224,354]), '0'), '1') as "Na_Result",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[335,26,333]), '0'), '1') as "Fe_Result",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[319, 316, 318, 28]), '0'), '1') as "Mg_Result",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[368, 210, 211, 212, 330]), '0'), '1') as "K_Result",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[327,329,29]), '0'), '1') as "Pb_Result",
                     coalesce(nullif(f_r_s('FM9990', samples.id, ARRAY[27,317,320]), '0'), '1') as "Ni_Result",
       
                     f_r_s('FM9990.00', samples.id, ARRAY[184, 185, 189, 355]) as "MCR10_Result",
                     f_r_s('FM9990', samples.id, ARRAY[89, 13, 371, 88]) as "CI_Result",
                     '' as H2S,
                     f_r_s('FM9990', samples.id, ARRAY[178, 332, 38]) as "HFRR_Result",
                     f_r_s('FM9990', samples.id, ARRAY[103, 104, 105, 350, 109, 10, 322, 106, 107, 108, 111, 374, 110]) as "Compat_result"
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
        and "samples"."validated_on" > current_date - interval '2' year