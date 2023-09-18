/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with utilization_forecast as (
    SELECT 
    *
    FROM
    EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_forecast
),

utilization_hours as (
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.CUST_ADSK_UTILIZATION_HOURS
),

utilization_union as (
select
project_name,
project_code,
cast(user_name as string) as user_name,
cast(entry_date as date) as entry_date,
TOTAL_TIME AS HOURS,
entry_is_approved,
utilized,
billable,
task_code,
task_name,
user_id,
'ACTUAL' as actual_forecast ,
NULL AS time_category,
NULL AS  is_hard_booking,
NULL AS  resource_id,
NULL AS  user_resource_group,
NULL AS ROLE_NAME
from utilization_hours uh
where (cast(entry_date as date) < previous_day(current_date(), 'Saturday ') )
union all
select
project_name,
project_code,
cast(USER_NAME as string) as USER_NAME,
cast(entry_date as date) as entry_date,
cast(hours as float) as hours,
NULL AS entry_is_approved,
NULL as utilized,
NULL as billable,
NULL as task_code,
NULL AS task_name,
NULL AS user_id,
'FORECAST' AS actual_forecast,
time_category,
is_hard_booking,
resource_id,
user_resource_group,
ROLE_NAME
       from utilization_forecast uf
where (cast(entry_date as date) >= previous_day(current_date(), 'Saturday '))
)

select uu.*,
case when is_hard_booking =1 then hours end as hard_booked_hours,
case when is_hard_booking =0 then hours end as soft_booked_hours,
trunc(entry_date, 'MONTH') as bymonth,
di.FISCAL_QUARTER,
pd.projectstate as project_state
from utilization_union uu
left join ADP_PUBLISH.CUSTOMER_SUCCESS_OPTIMIZED.DATE_INFO di
on di.dt = uu.entry_date
left join EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced pd
on uu.project_code = pd.projectcode