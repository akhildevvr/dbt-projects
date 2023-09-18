/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



SELECT 
pd.eba_analytics_name_key, 
pd.projectcode,
pd.PROJECT_ID,
sum(Baseline_Margin) as baseline_margin , 
sum(project_cost) as project_cost, 
sum(Billable_Margin) as Project_Margin,
sum(total_margin) as total_margin,
baseline_Margin_pc,
billable_Margin_pc,
total_margin_pc,
billable_mv_pc,
total_mv_pc
FROM 
EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pd LEFT JOIN (
SELECT
 pdf.*,
iff(iff(di.FISCAL_YEAR is NULL, NULL,right(di.FISCAL_YEAR, 2) ) > right(left(di.CURRENT_QRTR_VALUE,4),2), left(di.CURRENT_QRTR_VALUE,4),di.FISCAL_YEAR)  as fiscal_year
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

PDE.PROJECTCODE,
iff(baseline_Margin_pc is NULL, 0, (billable_Margin_pc - baseline_Margin_pc )) as baseline_billable_delta,
iff(Baseline_Margin is NULL, 0,(total_margin_pc - baseline_Margin_pc)) as Baseline_TotalEAC_Delta,
iff(baseline_billable_delta is NULL, NULL, (iff((baseline_billable_delta >= 0.05 or baseline_billable_delta <= -0.05), 'High', 'Low' )))  as BaseLine_TotalEAC_HL_Delta
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pde 
LEFT JOIN (
SELECT 
uf.*,
concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME), 
ur.FORECASTED_COST_RATE as Rate, 
uf.hours * ur.FORECASTED_COST_RATE as Cost, 
iff(contains(task_name, 'Non-Billable Project Travel'),'Non-Billable Project Travel',
iff(contains(task_name, 'Business Development'), 'Business Development' , 'Billable'))  as billing_work_type
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_hours_forecast uf
          LEFT JOIN EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources ur ON uf.USER_NAME = concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME)
         ) uf  ON pde.PROJECTCODE = uf.PROJECT_CODE

GROUP by
PDE.PROJECTCODE,pde.EAC_COST,pde.EAC_REVENUE,pde.PLANREVENUE,pde.PLANCOST
) pdf
LEFT JOIN "ADP_PUBLISH"."CUSTOMER_SUCCESS_OPTIMIZED"."DATE_INFO" di ON pdf.latest_value = di.dt
) pduf on pd.PROJECTCODE = pduf.PROJECTCODE

group by
pd.eba_analytics_name_key, 
pd.projectcode,
pd.PROJECT_ID,
baseline_Margin_pc,
baseline_Margin_pc,
billable_Margin_pc,
total_margin_pc,
billable_mv_pc,total_mv_pc