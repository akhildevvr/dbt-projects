/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with proj_details_ehanced as (select 
            *
from EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced
),
forecast as (
 select *
 from EIO_INGEST.ENGAGEMENT_TRANSFORM.pac_forecast_enriched pf
 where pf.stage_name in ('Stage 1','Stage 2','Stage 3','Stage 4','Stage 5')
  ),
forecast_pivot as (
  select parent_opportunity_number,
"'Stage 1'" as PAC_Forecast_Stage1,
"'Stage 2'" as PAC_Forecast_Stage2,
"'Stage 3'" as PAC_Forecast_Stage3,
"'Stage 4'" as PAC_Forecast_Stage4,
"'Stage 5'" as PAC_Forecast_Stage5,
'Master' as project_type
  from forecast
  pivot (sum(sco_pa_credits__c) for stage_name in ('Stage 1','Stage 2','Stage 3','Stage 4','Stage 5'))
  order by parent_opportunity_number
)
select
pde.*,
es.pac_expire_prev_qtr, 
es.pac_expire_cur_qtr, 
es.pac_expire_nxt_qtr, 
es.pac_expire_nxt1_qtr,
es.pac_expire_nxt2_qtr, 
es.pac_expire_nxt_days,
fp.parent_opportunity_number,
fp.PAC_Forecast_Stage1,
fp.PAC_Forecast_Stage2,
fp.PAC_Forecast_Stage3,
fp.PAC_Forecast_Stage4,
fp.PAC_Forecast_Stage5,
fp.project_type
from proj_details_ehanced pde 
left join EIO_INGEST.ENGAGEMENT_TRANSFORM.pac_expiry_schedule_by_qtr es 
on pde.project_id = es.project_id 
left join forecast_pivot fp 
  on (pde.sfdc_opp_num = fp.parent_opportunity_number and pde.projecttype = fp.project_type)