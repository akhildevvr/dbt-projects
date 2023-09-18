/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



SELECT
 f.project_code, 
f.project_name , 
nvl(sum(case when billing_work_type = 'Billable' then hours end),0) as Billable_Hours ,
nvl(sum(case when billing_work_type = 'Non-Billable Project Travel' then hours end),0) as Project_Travel_Hours,
nvl(sum(case when billing_work_type = 'Business Development' then hours end),0) as Business_Development_Hours from 
(
SELECT 
uf.*,
concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME), 
ur.FORECASTED_COST_RATE as Rate, 
uf.hours * ur.FORECASTED_COST_RATE as Cost, 
iff(contains(task_name, 'Non-Billable Project Travel'),'Non-Billable Project Travel',
iff(contains(task_name, 'Business Development'), 'Business Development' , 'Billable'))  as billing_work_type,
PREVIOUS_DAY(current_date(), 'sa' )   as entry_from,
iff(ACTUAL_FORECAST = 'ACTUAL', 'Yes', iff(ACTUAL_FORECAST = 'FORECAST',iff(ENTRY_DATE >= entry_from, 'Yes', 'No'), NULL))
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_hours_forecast uf
          LEFT JOIN EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources ur ON uf.USER_NAME = concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME)
  
  ) f
WHERE f.entry_date <= date_trunc('MONTH', CURRENT_DATE())
GROUP BY
f.project_code, 
f.project_name