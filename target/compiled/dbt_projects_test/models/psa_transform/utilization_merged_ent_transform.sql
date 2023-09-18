/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with utilization_merged as
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

)

SELECT
uf.PROJECT_NAME,
uf.PROJECT_CODE,
uf.USER_NAME as project_manager,
uf.ENTRY_DATE,
uf.HOURS,
uf.ENTRY_IS_APPROVED,
uf.UTILIZED,
uf.BILLABLE,
uf.TASK_CODE,
uf.TASK_NAME,
uf.USER_ID,
uf.ACTUAL_FORECAST,
uf.TIME_CATEGORY,
uf.IS_HARD_BOOKING,
uf.RESOURCE_ID,
uf.USER_RESOURCE_GROUP,
uf.HARD_BOOKED_HOURS,
uf.SOFT_BOOKED_HOURS,
uf.BYMONTH,
uf.FISCAL_QUARTER,
uf.PROJECT_STATE,
concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME) as user_name,
ur.FORECASTED_COST_RATE as Rate,
uf.hours * ur.FORECASTED_COST_RATE as Cost,
IFF(contains(task_name, 'Non-Billable Project Travel'),'Non-Billable Project Travel',
IFF(contains(task_name, 'Business Development'), 'Business Development' , 'Billable'))  as billing_work_type,
PREVIOUS_DAY(current_date(), 'sa' )   as entry_from,
IFF(ACTUAL_FORECAST = 'ACTUAL', 'Yes', IFF(ACTUAL_FORECAST = 'FORECAST',IFF(ENTRY_DATE >= entry_from, 'Yes', 'No'), NULL)) as valid_or_not
FROM utilization_merged uf
          LEFT JOIN utilization_resources ur ON uf.USER_NAME = concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME)