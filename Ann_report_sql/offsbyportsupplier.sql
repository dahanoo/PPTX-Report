with port_suppliers as (
  SELECT port_id, 
          supplier_id, 
          initcap (replace (ports."name",',',''))  as port_name,
           UPPER(replace (suppliers."name",',','')) as supplier_name,
          replace (countries."name",',','') as country_name

   FROM samples
   left outer join gmttest_templates on samples.gmttest_template_id = gmttest_templates.id
   LEFT OUTER JOIN clients on (samples.client_id = clients.id)
   LEFT OUTER JOIN ports on (ports.id = port_id)
   LEFT OUTER JOIN countries on (ports.country_id = countries.id)
   LEFT OUTER JOIN suppliers on (suppliers.id = supplier_id)
   
   WHERE clients.name ~* 'sun enter' 
     and 
     samples.validated_on::date between '2017-01-01' AND '2017-12-31'
	AND samples.manifold = 'MANIFOLD'
	AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
	AND gmttest_templates."name" !~* 'Adhoc' 
	and gmttest_templates."name" != 'FAP' 
	and gmttest_templates."name" != 'FIA' 
	and samples.computed_grade != 'UNKNOWN'
   group by 1,2,3,4,5
),
all_samples as (
   select samples.*, gmttest_templates.name as template_name, 
          port_name, supplier_name, country_name
   from port_suppliers
   join samples on samples.port_id = port_suppliers.port_id and samples.supplier_id = port_suppliers.supplier_id
   LEFT OUTER JOIN gmttest_templates on (samples.gmttest_template_id = gmttest_templates.id)
   LEFT OUTER JOIN clients on samples.client_id = clients.id
   where samples.job_id is not null
     AND samples.manifold = 'MANIFOLD'
     AND ((samples.other_method = 'Drip') or (samples.other_method = 'Autodrip'))
     AND samples.validated_on::DATE between '2017-01-01' AND '2017-12-31'
     AND samples.computed_grade != 'UNKNOWN'
     AND samples.computed_grade != 'FIA'
     AND samples.computed_grade !~* 'Adhoc'
     AND samples.computed_grade != 'FAP'
     AND gmttest_templates."name" !~* 'Adhoc'
     AND gmttest_templates."name" != 'UNKNOWN'
     AND gmttest_templates."name" != 'FIA'
     AND gmttest_templates."name" != 'FAP'
     and clients.name ~* 'sun enter' 
)

select
all_samples.port_name port, all_samples.supplier_name supplier,
 case when "V50_Remark" = 'AMBER' then 'V50_a|' else '' end
 || CASE when "V50_Remark" = 'RED' then  'V50_r|' else '' end
 || CASE when "Tested_Den_Remark" = 'AMBER' then  'Tested_Den_a|' else '' end
 || CASE when "Tested_Den_Remark" = 'RED' then  'Tested_Den_r|' else '' end
 || CASE when "Water_Remark" = 'AMBER' then  'Water_a|' else '' end
 || CASE when "Water_Remark" = 'RED' then  'Water_r|' else '' end
 || CASE when "MCR_Remark" = 'AMBER' then  'MCR_a|' else '' end
 || CASE when "MCR_Remark" = 'RED' then  'MCR_r|' else '' end
 || CASE when "Sediment_Remark" = 'AMBER' then  'Sediment_a|' else '' end 
 || CASE when "Sediment_Remark" = 'RED' then  'Sediment_r|'  else '' end
 || CASE when "Sulphur_low_Remark" = 'AMBER' then  'Sulphur_low_a|' else '' end  
 || CASE when "Sulphur_low_Remark" = 'RED' then  'Sulphur_low_r|'  else '' end 
 || CASE when "Sulphur_high_Remark" = 'AMBER' then  'Sulphur_high_a|' else '' end 
 || CASE when "Sulphur_high_Remark" = 'RED' then 'Sulphur_high_r|'  else '' end
 || CASE when "PPT_Remark" = 'AMBER' then  'PPT_a|' else '' end 
 || CASE when "PPT_Remark" = 'RED' then  'PPT_r|' else '' end  
 || CASE when "Fpt_Remark" = 'AMBER' then  'Fpt_a|'  else '' end 
 || CASE when "Fpt_Remark" = 'RED' then  'Fpt_r|'  else '' end 
 || CASE when "CCAI_Remark" = 'AMBER' then  'CCAI_a|'  else '' end
 || CASE when "CCAI_Remark" = 'RED' then  'CCAI_r|'  else '' end
 || CASE when "V_Remark" = 'AMBER' then  'V_a|'  else '' end 
 || CASE when "V_Remark" = 'RED' then  'V_r|'  else '' end
 || CASE when "Na_Remark" = 'AMBER' then  'Na_a|' else '' end 
 || CASE when "Na_Remark" = 'RED' then  'Na_r|' else '' end 
 || CASE when "TAN_Remark" = 'AMBER' then  'TAN_a|'  else '' end
 || CASE when "TAN_Remark" = 'RED' then  'TAN_r|'  else '' end
 || CASE when "AlSi_Remark" = 'AMBER' then  'AlSi_a|'  else '' end
 || CASE when "AlSi_Remark" = 'RED' then  'AlSi_r|'  else '' end
 || CASE when "ULO_Remark" = 'AMBER' then  'ULO_a|' else '' end 
 || CASE when "ULO_Remark" = 'RED' then  'ULO_r|'  else '' end
 || CASE when "CI_Remark" = 'AMBER' then  'CI_a|'  else '' end
 || CASE when "CI_Remark" = 'RED' then  'CI_r|'  else '' end
 || CASE when "CFPP_Remark" = 'AMBER' then  'CFPP_a|' else '' end 
 || CASE when "CFPP_Remark" = 'RED' then  'CFPP_r|'  else '' end
 || CASE when "V40_Remark" = 'AMBER' then  'V40_a|'  else '' end
 || CASE when "V40_Remark" = 'RED' then  'V40_r|'  else '' end 
 || CASE when "HFRR_Remark" = 'AMBER' then  'HFRR_a|' else '' end 
 || CASE when "HFRR_Remark" = 'RED' then  'HFRR_r|'  else '' end
 || CASE when "V40_Remark_LT_3" = 'AMBER' then 'V40_LT_3_a|'  else '' end
 || CASE when "V40_Remark_LT_3" = 'RED' then 'V40_LT_3_r|'  else '' end
 || CASE when "Sulphur_LT_005" = 'AMBER' then 'Sulphur_LT_005_a|'  else '' end
 || CASE when "Sulphur_LT_005" = 'RED' then  'Sulphur_LT_005_r|'  else '' end
 || CASE when "MCR10_Remark" = 'AMBER' then  'MCR10_a|'  else '' end
 || CASE when "MCR10_Remark" = 'RED' then 'MCR10_r|' else '' end as "Off_limit",
 
 case when "V50_Remark" = 'AMBER' then to_char(count ("V50_Remark"), 'FM999')||'|'  else '' end
 || CASE when "V50_Remark" = 'RED' then to_char(count ("V50_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Tested_Den_Remark" = 'AMBER' then to_char(count ("Tested_Den_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Tested_Den_Remark" = 'RED' then to_char( count ("Tested_Den_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Water_Remark" = 'AMBER' then to_char( count ("Water_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Water_Remark" = 'RED' then to_char( count ("Water_Remark"), 'FM999')||'|'  else '' end
 || CASE when "MCR_Remark" = 'AMBER' then to_char( count ("MCR_Remark"), 'FM999')||'|'  else '' end
 || CASE when "MCR_Remark" = 'RED' then to_char( count ("MCR_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Sediment_Remark" = 'AMBER' then to_char( count ("Sediment_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Sediment_Remark" = 'RED' then to_char( count ("Sediment_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Sulphur_low_Remark" = 'AMBER' then to_char( count ("Sulphur_low_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Sulphur_low_Remark" = 'RED' then to_char( count ("Sulphur_low_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Sulphur_high_Remark" = 'AMBER' then to_char( count ("Sulphur_high_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Sulphur_high_Remark" = 'RED' then to_char( count ("Sulphur_high_Remark"), 'FM999')||'|'  else '' end
 || CASE when "PPT_Remark" = 'AMBER' then to_char( count ("PPT_Remark"), 'FM999')||'|'  else '' end
 || CASE when "PPT_Remark" = 'RED' then to_char( count ("PPT_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Fpt_Remark" = 'AMBER' then to_char( count ("Fpt_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Fpt_Remark" = 'RED' then to_char( count ("Fpt_Remark"), 'FM999')||'|'  else '' end
 || CASE when "CCAI_Remark" = 'AMBER' then to_char( count ("CCAI_Remark"), 'FM999')||'|'  else '' end
 || CASE when "CCAI_Remark" = 'RED' then to_char( count ("CCAI_Remark"), 'FM999')||'|'  else '' end
 || CASE when "V_Remark" = 'AMBER' then to_char( count ("V_Remark"), 'FM999')||'|'  else '' end
 || CASE when "V_Remark" = 'RED' then to_char( count ("V_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Na_Remark" = 'AMBER' then to_char( count ("Na_Remark"), 'FM999')||'|'  else '' end
 || CASE when "Na_Remark" = 'RED' then to_char( count ("Na_Remark"), 'FM999')||'|'  else '' end
 || CASE when "TAN_Remark" = 'AMBER' then to_char( count ("TAN_Remark"), 'FM999')||'|'  else '' end
 || CASE when "TAN_Remark" = 'RED' then to_char( count ("TAN_Remark"), 'FM999')||'|'  else '' end
 || CASE when "AlSi_Remark" = 'AMBER' then to_char( count ("AlSi_Remark"), 'FM999')||'|'  else '' end
 || CASE when "AlSi_Remark" = 'RED' then to_char( count ("AlSi_Remark"), 'FM999')||'|'  else '' end
 || CASE when "ULO_Remark" = 'AMBER' then to_char( count ("ULO_Remark"), 'FM999')||'|'  else '' end
 || CASE when "ULO_Remark" = 'RED' then to_char( count ("ULO_Remark"), 'FM999')||'|'  else '' end
 || CASE when "CI_Remark" = 'AMBER' then to_char( count ("CI_Remark"), 'FM999')||'|'  else '' end
 || CASE when "CI_Remark" = 'RED' then to_char( count ("CI_Remark"), 'FM999')||'|'  else '' end
 || CASE when "CFPP_Remark" = 'AMBER' then to_char( count ("CFPP_Remark"), 'FM999')||'|'  else '' end
 || CASE when "CFPP_Remark" = 'RED' then to_char( count ("CFPP_Remark"), 'FM999')||'|'  else '' end
 || CASE when "V40_Remark" = 'AMBER' then to_char( count ("V40_Remark"), 'FM999')||'|'  else '' end
 || CASE when "V40_Remark" = 'RED' then to_char( count ("V40_Remark"), 'FM999')||'|'  else '' end
 || CASE when "HFRR_Remark" = 'AMBER' then to_char( count ("HFRR_Remark") , 'FM999')||'|'  else '' end
 || CASE when "HFRR_Remark" = 'RED' then to_char( count ("HFRR_Remark"), 'FM999')||'|'  else '' end
 || CASE when "V40_Remark_LT_3" = 'AMBER' then to_char( count ("V40_Remark_LT_3"), 'FM999')||'|'  else '' end
 || CASE when "V40_Remark_LT_3" = 'RED' then to_char( count ("V40_Remark_LT_3"), 'FM999')||'|'  else '' end
 || CASE when "Sulphur_LT_005" = 'AMBER' then to_char( count ("Sulphur_LT_005"), 'FM999')||'|'  else '' end
 || CASE when "Sulphur_LT_005" = 'RED' then to_char( count ("Sulphur_LT_005"), 'FM999')||'|'  else '' end
 || CASE when "MCR10_Remark" = 'AMBER' then to_char( count ("MCR10_Remark"), 'FM999')||'|'  else '' end
 || CASE when "MCR10_Remark" = 'RED' then to_char( count ("MCR10_Remark"), 'FM999')||'|'  else '' end as "Coun_offs"
from all_samples
left outer join sample_results Density_15C on all_samples.id = Density_15C.sample_id and 
                               Density_15C.characteristic_id in (3,274,35,118,120,123,125,121,122,124,119)
left outer join gar_cap on gar_cap.grade = substr(template_name,1,6)
left outer join clients on clients.id = all_samples.client_id

join lateral (select f_r_s('FM9990.00', all_samples.id, ARRAY[158, 370, 34, 164, 163]) as "V40_Result", 
                     f_r_s('FM9990.0', all_samples.id, ARRAY[4,165,166,167,168,169]) as "V50_Result",

                     CASE WHEN Density_15C.final_value is not null 
                          THEN CASE WHEN Density_15C.final_value > 2 
                                    THEN to_char (Density_15C.final_value / 1000,'FM9990.9990') 
                                    ELSE to_char(Density_15C.final_value,'FM9990.0000') END 
                          ELSE Density_15C.override_value END as "TESTED_DEN",

                     f_r_s('FM9990', all_samples.id, ARRAY[30, 288, 85, 87]) as "CCAI_Result",
                     coalesce(nullif(f_r_s('FM9990.00', all_samples.id, ARRAY[352,8,270,269,267,266,268,351]), '0.00'), '0.05') as "Water_Result",
                     f_r_s('FM9990.0', all_samples.id, ARRAY[135,2,136,134]) as "Fpt_Result",
                     coalesce(nullif(f_r_s('FM9990.00', all_samples.id, ARRAY[231,232,358,234,33,235,233]), '0.00'), '0.01') as "Sulphur_Result",
                     f_r_s('FM9990', all_samples.id, ARRAY[213,340,11]) as "PPT_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[98, 99, 100, 302, 386, 95, 12]), '\d'), '999') as "CFPP_Result",
                     f_r_s('FM9990.00', all_samples.id, ARRAY[139, 138, 142, 141, 140, 143, 276, 144]) as "GSE_Calc",
                     f_r_s('FM9990.00', all_samples.id, ARRAY[195,196,194,198,275,31,197]) as "NSE_Calc",

                     
                     coalesce(f_r_s('FM9990.00', all_samples.id, ARRAY[258, 353, 257, 259, 313]),f_r_s('FM9990.00', all_samples.id, ARRAY[361, 249, 250, 261, 6, 248])) as "Sediment",


                     f_r_s('FM9990.00', all_samples.id, ARRAY[5,187,380,188]) as "MCR_Result",
                     f_r_s('FM9990.00', all_samples.id, ARRAY[237, 238, 14]) as "TAN_Result",
                     f_r_s('FM9990.000', all_samples.id, ARRAY[326,1,64,66,67,366,304,65,68,336]) as "Ash_Result",
       
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[58, 57, 23, 222]), '0'), '1') as "AlSi_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[21, 325, 324]), '0'), '1') as "Ca_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[311,22,309,203]), '0'), '1') as "Phosphorus_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[18, 321, 323]), '0'), '1') as "Zn",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[334,331,15]), '0'), '1') as "V_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[19,224,354]), '0'), '1') as "Na_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[335,26,333]), '0'), '1') as "Fe_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[319, 316, 318, 28]), '0'), '1') as "Mg_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[368, 210, 211, 212, 330]), '0'), '1') as "K_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[327,329,29]), '0'), '1') as "Pb_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[27,317,320]), '0'), '1') as "Ni_Result",
       
                     coalesce(nullif(f_r_s('FM9990.00', all_samples.id, ARRAY[184, 185, 189, 355]), 'Unobtainable'), '999') as "MCR10_Result",
                     coalesce(nullif(f_r_s('FM9990', all_samples.id, ARRAY[89, 13, 371, 88]), 'Unobtainable'), '999') as "CI_Result", 
                     '' as H2S,
                     f_r_s('FM9990', all_samples.id, ARRAY[178, 332, 38]) as "HFRR_Result"
              ) results on true

join lateral (select 
                     test_limits(to_number("V50_Result", 'FM9990.00'), kv_50_green, kv_50_amber) as "V50_Remark",
                     test_limits(Density_15C.final_value, den15_green, den15_amber) as "Tested_Den_Remark",
                     CASE WHEN all_samples.fuel_type_ID = 1 THEN test_limits(to_number("Water_Result", 'FM9990.00'), water_green, water_amber)
                     WHEN template_name = 'DMA' AND to_number("Water_Result", 'FM9990.00') > 0.1 THEN 'RED' end as "Water_Remark",
		     test_limits(to_number("MCR_Result", 'FM9990.00'), mcr_green, mcr_amber) as "MCR_Remark",
		     test_limits(to_number("Sediment", 'FM9990.00'), ts_green, ts_amber) as "Sediment_Remark",

			case when all_samples.sulphur_level = 'LOW' and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])), 'FM9990.00')> gar_cap.slow_green and (all_samples.validated_on >= '2015-01-01' or fuel_type_id = 2)
			and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])), 'FM9990.00') <= gar_cap.slow_amber 
			then 'AMBER'			
			when all_samples.sulphur_level = 'LOW' and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])), 'FM9990.00')> 1 and all_samples.validated_on < '2015-01-01'
			and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])), 'FM9990.00') <= 1.06 and fuel_type_id = 1
			then 'AMBER'			
			when all_samples.sulphur_level = 'LOW' and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])), 'FM9990.00') > gar_cap.slow_amber and all_samples.validated_on >= '2015-01-01' 
			then 'RED' 
			when all_samples.sulphur_level = 'LOW' and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])), 'FM9990.00') > 1.06 and all_samples.validated_on < '2015-01-01' and fuel_type_id = 1
			then 'RED' 			
			when all_samples.sulphur_level = 'LOW' and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])), 'FM9990.00') <= gar_cap.slow_green and (all_samples.validated_on >= '2015-01-01' or fuel_type_id = 2) then 'GREEN'
			when all_samples.sulphur_level = 'LOW' and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])), 'FM9990.00') <= 1 and all_samples.validated_on < '2015-01-01' and fuel_type_id = 1 then 'GREEN'
			else 'OTHER'			
			end as "Sulphur_low_Remark",
			

			case when all_samples.sulphur_level = 'HIGH' and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])),'FM9990.00') > gar_cap.shigh_green 
			and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])), 'FM9990.00') <= gar_cap.shigh_amber 
			then 'AMBER'
			when all_samples.sulphur_level = 'HIGH' and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])),'FM9990.00') > gar_cap.shigh_amber 
			then 'RED' 
			when all_samples.sulphur_level = 'HIGH' and to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])),'FM9990.00') <= gar_cap.shigh_green then 'GREEN'
			else 'OTHER'
			end as "Sulphur_high_Remark",
			
                     test_limits(to_number("PPT_Result", 'FM9990.00'), ppt_green, ppt_amber) as "PPT_Remark",  
                     case when to_number("Fpt_Result", 'FM9990.00') < 60 then 'RED' else 'GREEN' end as "Fpt_Remark",                                       
                     test_limits(to_number("CCAI_Result", 'FM9990.00'), ccai_l_green, ccai_amber) as "CCAI_Remark",
 		     test_limits(to_number("V_Result", 'FM9990'), v_green, v_amber) as "V_Remark",                    
		     test_limits(to_number("Na_Result", 'FM9990'), na_green, na_amber) as "Na_Remark",                     
		     test_limits(to_number("TAN_Result", 'FM9990.00'), an_green, an_amber) as "TAN_Remark",
 		     test_limits(to_number("AlSi_Result", 'FM9990'), alsi_green, alsi_amber) as "AlSi_Remark",                 
		     
		     case when to_number(final_string('FM9990', result_for(all_samples.id, ARRAY[21, 325, 324])), 'FM9990') > 33 and 
		     ((to_number(final_string('FM9990', result_for(all_samples.id, ARRAY[311,22,309,203])), 'FM9990') > 18) 
		     or (to_number(final_string('FM9990', result_for(all_samples.id, ARRAY[18, 321, 323])), 'FM9990') > 18)) then 'RED'		     
		     when fuel_type_id = 2 then 'OTHER'
		     else 'GREEN'
		     end as "ULO_Remark",
		     test_cetane_limits(to_number("CI_Result", 'FM9990'), 40, 35) as "CI_Remark",
		     

                     case when results."CFPP_Result" = 'Unobtainable' then 'RED' 
                     when to_number(final_string('FM9990', result_for(all_samples.id, ARRAY[98, 99, 100, 302, 386, 95, 12])), 'FM9990') < 10 then 'GREEN'
                     when to_number(final_string('FM9990', result_for(all_samples.id, ARRAY[98, 99, 100, 302, 386, 95, 12])), 'FM9990') >= 10 and
                     to_number(final_string('FM9990', result_for(all_samples.id, ARRAY[98, 99, 100, 302, 386, 95, 12])), 'FM9990') <= 20 then 'AMBER'
                     when to_number(final_string('FM9990', result_for(all_samples.id, ARRAY[98, 99, 100, 302, 386, 95, 12])), 'FM9990') > 20 then 'RED'                      
                     else 'OTHER'
                     end as "CFPP_Remark",
                     
		     test_limits(to_number("V40_Result", 'FM9990.00'), v40_green, v40_amber) as "V40_Remark",
		     test_limits(to_number("HFRR_Result", 'FM9990'), hfrr_green, hfrr_amber) as "HFRR_Remark",		     		     
		     case when to_number(final_string('FM9990.00',  result_for(all_samples.id, ARRAY[158, 370, 34, 164, 163])), 'FM9990.00') > 2
			and to_number(final_string('FM9990.00',  result_for(all_samples.id, ARRAY[158, 370, 34, 164, 163])), 'FM9990.00') <= 3 
		        then 'AMBER'
		     when to_number(final_string('FM9990.00',  result_for(all_samples.id, ARRAY[158, 370, 34, 164, 163])), 'FM9990.00') < 2 
		        then 'RED' 
		     when to_number(final_string('FM9990.00',  result_for(all_samples.id, ARRAY[158, 370, 34, 164, 163])), 'FM9990.00') >= 3 then 'GREEN'
		     else 'OTHER'
		     end as "V40_Remark_LT_3",

		     case when to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])), 'FM9990.00') < 0.05 
		       then 'AMBER'
		     when to_number(final_string('FM9990.00', result_for(all_samples.id, ARRAY[231,232,358,234,33,235,233])),'FM9990.00') >= 0.05 then 'GREEN'
		    else 'OTHER'
		    end as "Sulphur_LT_005",
		    test_limits(to_number("MCR10_Result", 'FM9990.00'), mcr_10_green, mcr_10_amber) as "MCR10_Remark"
                ) remarks on true
group by 
"Tested_Den_Remark", 
"V50_Remark", 
"Water_Remark", 
"MCR_Remark", 
"Sediment_Remark", 
"Sulphur_low_Remark", 
"Sulphur_high_Remark",
"PPT_Remark",
"Fpt_Remark", 
"CCAI_Remark", 
"V_Remark", 
"Na_Remark", 
"TAN_Remark", 
"AlSi_Remark",
"ULO_Remark",
"CI_Remark",
"CFPP_Remark",
"V40_Remark",
"HFRR_Remark",
"V40_Remark_LT_3",
"Sulphur_LT_005",
"MCR10_Remark",
all_samples.port_name, all_samples.supplier_name

order by port, supplier
