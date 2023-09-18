/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/




with  utilization_merged as 
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
project_details_enhanced pde 
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
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pd 
LEFT JOIN (
SELECT pdf.*,
iff(iff(di.FISCAL_YEAR is NULL, NULL,right(di.FISCAL_YEAR, 2) ) > right(left(di.CURRENT_QRTR_VALUE,4),2), left(di.CURRENT_QRTR_VALUE,4),di.FISCAL_YEAR) as FY_Project_End_Date  
FROM project_utilization_merged_resources pdf
LEFT JOIN date_info di on pdf.latest_value = di.dt
) pduf 
 ON pd.PROJECTCODE = pduf.PROJECTCODE
)

SELECT 
*
FROM 
project_utilization_merged_resources_final


/*select pd.*,
CASE WHEN pd.ACCOUNTINGCONTRACTTYPE = 'Advisory Services: ARR' then  1 
          WHEN pd.ACCOUNTINGCONTRACTTYPE ='Implementation Services: Non-ARR' then 1
          ELSE 0
    END AS AS/IS_Flag,
pduf.NonBillable_Travel_Cost,
pduf.Business_Development_Cost,
pduf.project_cost,
pduf.total_margin,
pduf.Baseline_Margin,
pduf.Billable_Margin,
pduf.total_mv,
pduf.billable_mv,
pduf.baseline_Margin_pc,
pduf.billable_Margin_pc,
pduf.total_margin_pc,
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
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pd left join (
SELECT pdf.*,
iff(iff(di.FISCAL_YEAR is NULL, NULL,right(di.FISCAL_YEAR, 2) ) > right(left(di.CURRENT_QRTR_VALUE,4),2), left(di.CURRENT_QRTR_VALUE,4),di.FISCAL_YEAR) as FY_Project_End_Date  
FROM (
SELECT
nvl(sum(case when billing_work_type = 'Non-Billable Project Travel' then cost end),0) as NonBillable_Travel_Cost, 
nvl(sum(case when billing_work_type = 'Business Development' then cost end),0) as Business_Development_Cost,
EAC_COST - NonBillable_Travel_Cost - Business_Development_Cost as project_cost,
EAC_REVENUE - project_cost - Business_Development_Cost-NonBillable_Travel_Cost as total_margin,
PLANREVENUE - PLANCOST as Baseline_Margin,
EAC_REVENUE - project_cost as Billable_Margin,
total_margin - Baseline_Margin as total_mv,
Billable_Margin - Baseline_Margin as billable_mv,
div0(Baseline_Margin , PLANREVENUE) as baseline_Margin_pc,
div0(Billable_Margin , EAC_REVENUE) as billable_Margin_pc,
div0(total_margin , EAC_REVENUE) AS total_margin_pc,
NVL(total_margin_pc - baseline_Margin_pc, 0) AS total_mv_pc,
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
EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pde 
LEFT JOIN (
SELECT 
uf.*,
concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME) as user_name, 
ur.FORECASTED_COST_RATE as Rate, 
uf.hours * ur.FORECASTED_COST_RATE as Cost, 
iff(contains(task_name, 'Non-Billable Project Travel'),'Non-Billable Project Travel',
iff(contains(task_name, 'Business Development'), 'Business Development' , 'Billable'))  as billing_work_type
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_hours_forecast uf
          LEFT JOIN EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources ur ON uf.USER_NAME = concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME)
           WHERE uf.entry_date <= date_trunc('MONTH', CURRENT_DATE())
         ) uf  ON pde.PROJECTCODE = uf.PROJECT_CODE

GROUP by
PDE.PROJECTCODE,pde.EAC_COST,pde.EAC_REVENUE,pde.PLANREVENUE,pde.PLANCOST
) pdf
LEFT JOIN "ADP_PUBLISH"."CUSTOMER_SUCCESS_OPTIMIZED"."DATE_INFO" di on pdf.latest_value = di.dt
) pduf ON pd.PROJECTCODE = pduf.PROJECTCODE
*/