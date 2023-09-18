/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/




with margin_variance as (
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.CUST_ADSK_MARGINVARIANCE
),
project_details as (
    SELECT
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.CUST_ADSK_SERVICESIMPACT_PROJECTDETAILS

),
 utilization_merged as 
(
   SELECT 
   *
   FROM 
   EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_hours_forecast
),
utilization_resources as 
(
   SELECT 
   *
   FROM
   EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources
),
project_details_enhanced as 
(
   SELECT 
   *
   FROM 
   EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced
),
date_info as 
(
   SELECT
   *
   FROM ADP_PUBLISH.CUSTOMER_SUCCESS_OPTIMIZED.DATE_INFO
),

consulting_eba_account_masterlist as (
    SELECT 
    *
    FROM
    EIO_INGEST.ENGAGEMENT_TRANSFORM.consulting_eba_account
),
 mv as (select 
            PLANNED_END_DATE,
            CSMLEAD,
            CS_DATE_ENGAGEMENT_SURVEY_SENT,
            GEODELIVERY,
            GOVPMDOC_DELIVERY_MANAGER,
            AC_PROJGOVERNANCE,
            PROJHEALTH_CUSTOMER,
            PROJHEALTH_OVERALL,
            PROJHEALTH_QUALITY,
            PROJHEALTH_RESOURCE,
            PROJHEALTH_SCHEDULE,
            TIMECATEGORY,
            ACCOUNTINGCONTRACTTYPE,
            REVRECTREATMENT,
            AC_SE_NAME1,
            TENROXTRACKINGNO,
            AC_SE_NAME2,
            PACKAGED_OFFERINGS,
            IFF(GS_SERVICELINE is NULL, 'Unspecified', GS_SERVICELINE) as GS_SERVICELINE,
            IFF(GS_SERVICELINE_PROJECTTYPE IS NULL,'Unspecified',GS_SERVICELINE_PROJECTTYPE) as GS_SERVICELINE_PROJECTTYPE,
            MARGINVARIANCEDESCRIPTION,
            ROWNUMBER,
            PORTFOLIOMANAGER,
            PROJECTMANAGERNAME,
            WASNEWTABLE,
            CUSTOMERNAME,
            GEO,
            PROJECTMANAGERGEO,
            GEO2,
            PORTFOLIONAME,
            EAC_COST,
            PRIORFYCOST,
            PROJECTCURRENCY,
            PROJECTNAME,
            INITIALWORKDATE,
            PROJECTCODE,
            PROJECTSTARTDATE,
            PROJECTENDDATE,
            MARGINVARIANCECATEGORY,
            ACCONTRACTTYPE,
            HRS_EAC,
            PROJECTMANAGEREEID,
            PROJECTTYPE,
            PLANHOURS,
            EAC_REVENUE,
            FINALWORKDATE,
            PLANCOST,
            DISPLAYEDCURRENCY,
            HRS_BOOKED,
            SQLSCRIPTVERSION,
            IFF(GS_SERVICELINE_PRIMARYPRODUCT IS NULL,'Unspecified',GS_SERVICELINE_PRIMARYPRODUCT) AS GS_SERVICELINE_PRIMARYPRODUCT,
            PROJECTID,
            PLANREVENUE,
            HRS_ETC,
            PROJECTSTATE,
            IFF(GS_SERVICELINE_SUB_INDUSTRY IS NULL, 'Unspecified', GS_SERVICELINE_SUB_INDUSTRY) as GS_SERVICELINE_SUB_INDUSTRY,
            cast(ESCALATION_REASON as string)  as ESCALATION_REASON,
            cast(ESCALATION_STATUSANDACTION as string) as  ESCALATION_STATUSANDACTION
            from margin_variance ),
-- project details dataset
pj1 as (select project_id,
        pa_sco_expense_credits,
        pa_sco_labor_credits,
        master_agreement_id,
        master_agreement_nm,
        pa_master_credits_purchased,
        pa_master_contract_dt,
        pa_sco_contract_dt,
        sfdc_opp_num,
        client_csn,
        client_nm,
        pa_sco_labor_credits + pa_sco_expense_credits as pa_sco_total_credits
        from project_details ) ,
pj2 as (
     select *
     from pj1 p
     left join mv m
           on p.project_id = m.projectid),
 pj3 as (select * ,
         iff(hrs_eac = 0, 0, (hrs_booked/hrs_eac)) as percent_complete,
         pa_sco_total_credits * percent_complete as pa_sco_credits_consumed,
         iff((pa_master_credits_purchased = 0 or pa_master_credits_purchased is null ),
         0,(planrevenue/pa_master_credits_purchased)) as pa_value
         from pj2),
mp as (select
       project_id,
       MASTER_AGREEMENT_NM,
       master_agreement_id,
       pa_master_contract_dt
       from pj3
       ),
  
project_enhanced as 
                    ( select 
                    m.*, 
                    cl.ultimate_parent_eca_name,
                    cl.ultimate_parent_eca_id,
                    cl.account_csn,
                    cl.eba_analytics_name_key,
                    cl.exhibit_name,
                    cl.exhibit_active_status,
                    cl.exhibit_id,
                    cl.agreement_id,
                    cl.account_name,
                    cl.agreement_name,
                    cl.exhibit_start_date,
                    cl.exhibit_end_date
                    from mp m 
                        left join consulting_eba_account_masterlist cl
                          ON (TRIM(cl.AGREEMENT_NAME) = TRIM(m.master_agreement_id)
                          AND (cl.exhibit_start_date <= date(m.pa_master_contract_dt))
                          AND (cl.exhibit_end_date >= date(m.pa_master_contract_dt)))
             ),
 
proj_not_null as (select p.*,
                  pe.ultimate_parent_eca_name,
                  pe.ultimate_parent_eca_id,
                  pe.eba_analytics_name_key,
                  pe.exhibit_name,
                  pe.exhibit_active_status,
                  pe.exhibit_id,
                  pe.agreement_id,
                  pe.account_name,
                  pe.account_csn,
                  pe.agreement_name,
                  pe.exhibit_start_date,
                  pe.exhibit_end_date
                  from pj3 p
                  left join project_enhanced pe
                  on p.MASTER_AGREEMENT_NM = pe.MASTER_AGREEMENT_NM
                  where
                  p.master_agreement_nm is not null),
proj_null as (select *
              from pj3 p
              where p.master_agreement_nm is null),
proj_concat as (
            select nn.*
            from proj_not_null nn
            union all
            select n.*,
            NULL as ULTIMATE_PARENT_ECA_NAME,
            NULL as ULTIMATE_PARENT_ECA_ID,
            NULL as EBA_ANALYTICS_NAME_KEY,
            NULL as EXHIBIT_NAME,
            NULL as EXHIBIT_ACTIVE_STATUS,
            NULL as EXHIBIT_ID,
            NULL as AGREEMENT_ID,
            NULL as ACCOUNT_NAME,
            NULL AS ACCOUNT_CSN,
            NULL as AGREEMENT_NAME,
            NULL as EXHIBIT_START_DATE,
            NULL as EXHIBIT_END_DATE
              from proj_null n
),


proj_details_enhanced_distinct as 
(
select 
PROJECT_ID,
client_csn,
client_nm ,
PA_SCO_EXPENSE_CREDITS,
PA_SCO_LABOR_CREDITS,
MASTER_AGREEMENT_ID,
MASTER_AGREEMENT_NM,
PA_MASTER_CREDITS_PURCHASED,
PA_MASTER_CONTRACT_DT,
PA_SCO_CONTRACT_DT,
SFDC_OPP_NUM,
PA_SCO_TOTAL_CREDITS,
PLANNED_END_DATE,
CSMLEAD,
CS_DATE_ENGAGEMENT_SURVEY_SENT,
GEODELIVERY,
GOVPMDOC_DELIVERY_MANAGER,
AC_PROJGOVERNANCE,
PROJHEALTH_CUSTOMER,
PROJHEALTH_OVERALL,
PROJHEALTH_QUALITY,
PROJHEALTH_RESOURCE,
PROJHEALTH_SCHEDULE,
TIMECATEGORY,
ACCOUNTINGCONTRACTTYPE,
REVRECTREATMENT,
AC_SE_NAME1,
TENROXTRACKINGNO,
AC_SE_NAME2,
PACKAGED_OFFERINGS,
GS_SERVICELINE,
GS_SERVICELINE_PROJECTTYPE,
MARGINVARIANCEDESCRIPTION,
ROWNUMBER,
PORTFOLIOMANAGER,
PROJECTMANAGERNAME,
WASNEWTABLE,
CUSTOMERNAME,
GEO,
PROJECTMANAGERGEO,
GEO2,
PORTFOLIONAME,
EAC_COST,
PRIORFYCOST,
PROJECTCURRENCY,
PROJECTNAME,
INITIALWORKDATE,
PROJECTCODE,
PROJECTSTARTDATE,
PROJECTENDDATE,
MARGINVARIANCECATEGORY,
ACCONTRACTTYPE,
HRS_EAC,
PROJECTMANAGEREEID,
PROJECTTYPE,
PLANHOURS,
EAC_REVENUE,
FINALWORKDATE,
PLANCOST,
DISPLAYEDCURRENCY,
HRS_BOOKED,
SQLSCRIPTVERSION,
GS_SERVICELINE_PRIMARYPRODUCT,
PROJECTID,
PLANREVENUE,
HRS_ETC,
PROJECTSTATE,
GS_SERVICELINE_SUB_INDUSTRY,
ESCALATION_REASON,
ESCALATION_STATUSANDACTION,
PERCENT_COMPLETE,
PA_SCO_CREDITS_CONSUMED,
PA_VALUE,
ULTIMATE_PARENT_ECA_NAME,
ULTIMATE_PARENT_ECA_ID,
EBA_ANALYTICS_NAME_KEY,
EXHIBIT_NAME,
EXHIBIT_ACTIVE_STATUS,
EXHIBIT_ID,
AGREEMENT_ID,
ACCOUNT_NAME,
ACCOUNT_CSN,
AGREEMENT_NAME,
EXHIBIT_START_DATE,
EXHIBIT_END_DATE
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY PROJECT_ID ORDER BY AGREEMENT_NAME ASC) rn
    FROM proj_concat)
WHERE rn = 1
),
utilization_merged_resources as 
(
   SELECT 
uf.*,
concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME) as user_name, 
ur.FORECASTED_COST_RATE as Rate, 
uf.hours * ur.FORECASTED_COST_RATE as Cost, 
iff(contains(task_name, 'Non-Billable Project Travel'),'Non-Billable Project Travel',
iff(contains(task_name, 'Business Development'), 'Business Development' , 'Billable'))  as billing_work_type
FROM utilization_merged uf
          LEFT JOIN utilization_resources ur ON uf.USER_NAME = concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME)
           WHERE uf.entry_date <= date_trunc('MONTH', CURRENT_DATE())

),
project_utilization_merged_resources as 
(
SELECT
nvl(sum(case when billing_work_type = 'Non-Billable Project Travel' then cost end),0) as NonBillable_Travel_Cost, 
nvl(sum(case when billing_work_type = 'Business Development' then cost end),0) as Business_Development_Cost,
EAC_COST - NonBillable_Travel_Cost - Business_Development_Cost as project_cost,
EAC_REVENUE - project_cost as project_margin,
EAC_REVENUE - project_cost - Business_Development_Cost-NonBillable_Travel_Cost as total_margin,
PLANREVENUE - PLANCOST as Baseline_Margin,
EAC_REVENUE - project_cost as Billable_Margin,
Billable_Margin - Baseline_Margin as project_mv,
total_margin - Baseline_Margin as total_mv,
Billable_Margin - Baseline_Margin as billable_mv,
div0(Baseline_Margin , PLANREVENUE) as baseline_Margin_pc,
div0(Billable_Margin , EAC_REVENUE) as billable_Margin_pc,
div0(total_margin , EAC_REVENUE) AS total_margin_pc,
div0(project_margin , EAC_REVENUE) AS project_margin_pc,
NVL(total_margin_pc - baseline_Margin_pc, 0) AS total_mv_pc,
NVL(project_margin_pc - baseline_Margin_pc,0) as project_mv_pc,
NVL(billable_Margin_pc - baseline_Margin_pc, 0) as billable_mv_pc,
max(uf.entry_date) as latest_value,
--iff(iff(di.FISCAL_YEAR is NULL, NULL,right(di.FISCAL_YEAR, 2) ) > right(left(di.CURRENT_QRTR_VALUE,4),2), left(di.CURRENT_QRTR_VALUE,4),di.FISCAL_YEAR),
PDE.PROJECTCODE,
iff(baseline_Margin_pc is NULL, 0, (billable_Margin_pc - baseline_Margin_pc )) as baseline_billable_delta,
iff(Baseline_Margin is NULL, 0,(total_margin_pc - baseline_Margin_pc)) as Baseline_TotalEAC_Delta,
iff(baseline_billable_delta is NULL, NULL, (iff((baseline_billable_delta >= 0.05 or baseline_billable_delta <= -0.05), 'High', 'Low' )))  as BaseLine_TotalEAC_HL_Delta,
iff(baseline_billable_delta < -0.1, 'a. < -10', iff(baseline_billable_delta >=-0.1 and baseline_billable_delta < - 0.05, 'b. -10 -> -5',
                                                   iff(baseline_billable_delta >=-0.05 and baseline_billable_delta < 0, 'c. -5 -> 0',
                                                      iff(baseline_billable_delta >=-0 and baseline_billable_delta < 0.05, 'd. 0 -> 5',
                                                         iff(baseline_billable_delta >=0.05 and baseline_billable_delta < 0.1, 'e. 5 -> 10',
                                                            iff(baseline_billable_delta >=0.1, 'f. > 10',NULL)))))) as Baseline_Billable_Delta_Ranges,
SPLIT_PART(Baseline_Billable_Delta_Ranges, '.', 2) as Billable_Var_Range,
iff(Baseline_TotalEAC_Delta < -0.1, 'a. < -10', iff(Baseline_TotalEAC_Delta >=-0.1 and Baseline_TotalEAC_Delta < - 0.05, 'b. -10 -> -5',
                                                   iff(Baseline_TotalEAC_Delta >=-0.05 and Baseline_TotalEAC_Delta < 0, 'c. -5 -> 0',
                                                      iff(Baseline_TotalEAC_Delta >=-0 and Baseline_TotalEAC_Delta < 0.05, 'd. 0 -> 5',
                                                         iff(Baseline_TotalEAC_Delta >=0.05 and Baseline_TotalEAC_Delta < 0.1, 'e. 5 -> 10',
                                                            iff(Baseline_TotalEAC_Delta >=0.1, 'f. > 10',NULL)))))) as Baseline_TotalEAC_Delta_Ranges,

SPLIT_PART(Baseline_TotalEAC_Delta_Ranges, '.', 2) as Total_Var_Range 
FROM 
proj_details_enhanced_distinct pde 
LEFT JOIN utilization_merged_resources uf  ON pde.PROJECTCODE = uf.PROJECT_CODE

GROUP by
PDE.PROJECTCODE,pde.EAC_COST,pde.EAC_REVENUE,pde.PLANREVENUE,pde.PLANCOST
),
project_utilization_merged_resources_final as 
(
   select pd.*,
CASE WHEN pd.ACCOUNTINGCONTRACTTYPE = 'Advisory Services: ARR' then  1 
          WHEN pd.ACCOUNTINGCONTRACTTYPE ='Implementation Services: Non-ARR' then 1
          ELSE 0
    END AS AS_IS_Flag,
pduf.NonBillable_Travel_Cost,
pduf.Business_Development_Cost,
pduf.project_cost,
pduf.project_margin,
pduf.total_margin,
pduf.Baseline_Margin,
pduf.Billable_Margin,
pduf.project_mv,
pduf.total_mv,
pduf.billable_mv,
pduf.baseline_Margin_pc,
pduf.billable_Margin_pc,
pduf.project_margin_pc,
pduf.total_margin_pc,
pduf.project_mv_pc,
pduf.total_mv_pc,
pduf.billable_mv_pc,
pduf.latest_value,
pduf.baseline_billable_delta,
pduf.Baseline_TotalEAC_Delta,
pduf.BaseLine_TotalEAC_HL_Delta,
pduf.Baseline_Billable_Delta_Ranges,
pduf.Billable_Var_Range,
pduf.Baseline_TotalEAC_Delta_Ranges,
pduf.Total_Var_Range,
pduf.FY_Project_End_Date
FROM proj_details_enhanced_distinct pd 
LEFT JOIN (
SELECT pdf.*,
iff(iff(di.FISCAL_YEAR is NULL, NULL,right(di.FISCAL_YEAR, 2) ) > right(left(di.CURRENT_QRTR_VALUE,4),2), left(di.CURRENT_QRTR_VALUE,4),di.FISCAL_YEAR) as FY_Project_End_Date  
FROM project_utilization_merged_resources pdf
LEFT JOIN date_info di on pdf.latest_value = di.dt
) pduf 
 ON pd.PROJECTCODE = pduf.PROJECTCODE
)

SELECT 
PROJECT_ID,
CLIENT_CSN,
CLIENT_NM AS CLIENT_NAME,
PA_SCO_EXPENSE_CREDITS,
PA_SCO_LABOR_CREDITS,
MASTER_AGREEMENT_ID,
MASTER_AGREEMENT_NM,
PA_MASTER_CREDITS_PURCHASED,
PA_MASTER_CONTRACT_DT as PA_MASTER_CONTRACT_DATE,
PA_SCO_CONTRACT_DT AS PA_SCO_CONTRACT_DATE,
SFDC_OPP_NUM,
PA_SCO_TOTAL_CREDITS,
PLANNED_END_DATE,
CSMLEAD AS CSM_LEAD,
CS_DATE_ENGAGEMENT_SURVEY_SENT,
GEODELIVERY as GEO_DELIVERY,
GOVPMDOC_DELIVERY_MANAGER,
AC_PROJGOVERNANCE AS AC_PROJ_GOVERNANCE,
PROJHEALTH_CUSTOMER,
PROJHEALTH_OVERALL,
PROJHEALTH_QUALITY,
PROJHEALTH_RESOURCE,
PROJHEALTH_SCHEDULE,
TIMECATEGORY AS TIME_CATEGORY,
ACCOUNTINGCONTRACTTYPE AS ACCOUNTING_CONTRACT_TYPE,
REVRECTREATMENT,
AC_SE_NAME1,
TENROXTRACKINGNO AS TENROX_TRACKING_NO,
AC_SE_NAME2,
PACKAGED_OFFERINGS,
GS_SERVICELINE AS SERVICE_LINE,
GS_SERVICELINE_PROJECTTYPE AS SERVICE_LINE_PROJECT_TYPE,
MARGINVARIANCEDESCRIPTION AS MARGIN_VARIANCE_DESCRIPTION,
ROWNUMBER AS ROW_NUMBER,
PORTFOLIOMANAGER AS PORTFOLIO_MANAGER,
PROJECTMANAGERNAME AS PROJECT_MANAGER_NAME,
WASNEWTABLE AS WAS_NEW_TABLE,
CUSTOMERNAME AS CUSTOMER_NAME,
GEO,
PROJECTMANAGERGEO AS PROJECT_MANAGER_GEO,
GEO2,
PORTFOLIONAME AS PORTFOLIO_NAME,
EAC_COST,
PRIORFYCOST AS PRIOR_FY_COST,
PROJECTCURRENCY AS PROJECT_CURRENCY,
PROJECTNAME AS PROJECT_NAME,
INITIALWORKDATE AS INITIAL_WORK_DATE,
PROJECTCODE AS PROJECT_CODE,
PROJECTSTARTDATE AS PROJECT_START_DATE,
PROJECTENDDATE AS PROJECT_END_DATE,
MARGINVARIANCECATEGORY AS MARGIN_VARIANCE_CATEGORY,
ACCONTRACTTYPE AS AC_CONTRACT_TYPE,
HRS_EAC AS HOURS_EAC,
PROJECTMANAGEREEID AS PROJECT_MANAGER_EEID,
PROJECTTYPE AS PROJECT_TYPE,
PLANHOURS AS PLAN_HOURS,
EAC_REVENUE,
FINALWORKDATE AS FINAL_WORK_DATE,
PLANCOST AS PLAN_COST,
DISPLAYEDCURRENCY AS DISPLAYED_CURRENCY,
HRS_BOOKED AS HOURS_BOOKED,
SQLSCRIPTVERSION,
GS_SERVICELINE_PRIMARYPRODUCT AS SERVICE_LINE_PRIMARY_PRODUCT,
PLANREVENUE AS PLAN_REVENUE,
HRS_ETC as HOURS_ETC,
PROJECTSTATE AS PROJECT_STATE,
GS_SERVICELINE_SUB_INDUSTRY AS SERVICE_LINE_SUB_INDUSTRY,
ESCALATION_REASON,
ESCALATION_STATUSANDACTION as ESCALATION_STATUS_AND_ACTION,
PERCENT_COMPLETE,
PA_SCO_CREDITS_CONSUMED,
PA_VALUE,
ULTIMATE_PARENT_ECA_NAME,
ULTIMATE_PARENT_ECA_ID,
EBA_ANALYTICS_NAME_KEY,
EXHIBIT_NAME,
EXHIBIT_ACTIVE_STATUS,
EXHIBIT_ID,
AGREEMENT_ID,
ACCOUNT_NAME,
ACCOUNT_CSN,
AGREEMENT_NAME,
EXHIBIT_START_DATE,
EXHIBIT_END_DATE,
AS_IS_FLAG,
NONBILLABLE_TRAVEL_COST,
BUSINESS_DEVELOPMENT_COST,
PROJECT_COST,
project_margin,
TOTAL_MARGIN,
BASELINE_MARGIN,
BILLABLE_MARGIN,
project_mv,
TOTAL_MV,
BILLABLE_MV,
BASELINE_MARGIN_PC,
BILLABLE_MARGIN_PC,
project_margin_pc,
TOTAL_MARGIN_PC,
project_mv_pc,
TOTAL_MV_PC,
BILLABLE_MV_PC,
LATEST_VALUE,
BASELINE_BILLABLE_DELTA,
BASELINE_TOTALEAC_DELTA,
BASELINE_TOTALEAC_HL_DELTA,
BASELINE_BILLABLE_DELTA_RANGES,
BILLABLE_VAR_RANGE,
BASELINE_TOTALEAC_DELTA_RANGES,
TOTAL_VAR_RANGE,
FY_PROJECT_END_DATE
FROM 
project_utilization_merged_resources_final