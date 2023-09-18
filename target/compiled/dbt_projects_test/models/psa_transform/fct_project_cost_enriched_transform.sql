/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/




SELECT
sum(pduf.Business_Development_Cost) as cost,
'Business Development' as work_type, 
pd.account_name,pd.projectcode ,pd.projectname
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pd 
LEFT JOIN (
SELECT
nvl(sum(case when billing_work_type = 'Non-Billable Project Travel' then cost end),0) as NonBillable_Travel_Cost, 
nvl(sum(case when billing_work_type = 'Business Development' then cost end),0) as Business_Development_Cost,
EAC_COST - NonBillable_Travel_Cost - Business_Development_Cost as project_cost,
pde.projectcode
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
          left join EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources ur on uf.USER_NAME = concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME)
         ) uf  on pde.PROJECTCODE = uf.PROJECT_CODE

GROUP by
PDE.PROJECTCODE,pde.EAC_COST,pde.EAC_REVENUE,pde.PLANREVENUE,pde.PLANCOST

) pduf on pd.PROJECTCODE = pduf.PROJECTCODE
GROUP BY
pd.account_name,pd.projectcode ,pd.projectname

union all

SELECT 
sum(pduf.NonBillable_Travel_Cost) as cost,'Non-Billable Travel' as work_type,
 pd.account_name,pd.projectcode ,pd.projectname
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pd 
LEFT JOIN (
SELECT
nvl(sum(case when billing_work_type = 'Non-Billable Project Travel' then cost end),0) as NonBillable_Travel_Cost, 
nvl(sum(case when billing_work_type = 'Business Development' then cost end),0) as Business_Development_Cost,
EAC_COST - NonBillable_Travel_Cost - Business_Development_Cost as project_cost,
pde.projectcode
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pde 
LEFT JOIN (
SELECT uf.*,
concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME), 
ur.FORECASTED_COST_RATE as Rate, 
uf.hours * ur.FORECASTED_COST_RATE as Cost, 
iff(contains(task_name, 'Non-Billable Project Travel'),'Non-Billable Project Travel',
iff(contains(task_name, 'Business Development'), 'Business Development' , 'Billable'))  as billing_work_type
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_hours_forecast uf
          LEFT JOIN EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources ur on uf.USER_NAME = concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME)
         ) uf  on pde.PROJECTCODE = uf.PROJECT_CODE

GROUP BY
PDE.PROJECTCODE,pde.EAC_COST,pde.EAC_REVENUE,pde.PLANREVENUE,pde.PLANCOST

) pduf on pd.PROJECTCODE = pduf.PROJECTCODE
GROUP BY
pd.account_name,pd.projectcode ,pd.projectname

union all

SELECT
sum(pduf.project_cost) as cost,'Other' as work_type, 
pd.account_name,pd.projectcode ,pd.projectname
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pd left join (
SELECT 
nvl(sum(case when billing_work_type = 'Non-Billable Project Travel' then cost end),0) as NonBillable_Travel_Cost, 
nvl(sum(case when billing_work_type = 'Business Development' then cost end),0) as Business_Development_Cost,
EAC_COST - NonBillable_Travel_Cost - Business_Development_Cost as project_cost,
pde.projectcode
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pde 
LEFT JOIN (
SELECT uf.*,
concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME), 
ur.FORECASTED_COST_RATE as Rate, 
uf.hours * ur.FORECASTED_COST_RATE as Cost, 
iff(contains(task_name, 'Non-Billable Project Travel'),'Non-Billable Project Travel',
iff(contains(task_name, 'Business Development'), 'Business Development' , 'Billable'))  as billing_work_type
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_hours_forecast uf
          LEFT JOIN EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources ur on uf.USER_NAME = concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME)
         ) uf  on pde.PROJECTCODE = uf.PROJECT_CODE

GROUP BY
PDE.PROJECTCODE,pde.EAC_COST,pde.EAC_REVENUE,pde.PLANREVENUE,pde.PLANCOST

) pduf on pd.PROJECTCODE = pduf.PROJECTCODE
GROUP BY
pd.account_name,pd.projectcode ,pd.projectname