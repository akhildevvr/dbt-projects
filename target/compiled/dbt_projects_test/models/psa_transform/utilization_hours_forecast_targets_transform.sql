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

),
utilisation_resource_exclusion_dates as
(
SELECT
*
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.UTILIZATION_RESOURCE_EXCLUSION_DATES

),
date_info as
(
SELECT
*
FROM
ADP_PUBLISH.CUSTOMER_SUCCESS_OPTIMIZED.DATE_INFO

),

employee_details as 
(
    SELECT 
    * FROM 
    EIO_INGEST.ENGAGEMENT_TRANSFORM.employee_details
),
 Utilization_Merged_derived as (
SELECT
uf.PROJECT_NAME,
uf.PROJECT_CODE,
uf.USER_NAME ,
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
concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME) as resource_name, 
ur.FORECASTED_COST_RATE as Rate, 
uf.hours * ur.FORECASTED_COST_RATE as Cost, 
iff(contains(task_name, 'Non-Billable Project Travel'),'Non-Billable Project Travel',
iff(contains(task_name, 'Business Development'), 'Business Development' , 'Billable'))  as billing_work_type,
PREVIOUS_DAY(current_date(), 'sa' )   as entry_from,
iff(ACTUAL_FORECAST = 'ACTUAL', 'Yes', iff(ACTUAL_FORECAST = 'FORECAST',iff(ENTRY_DATE >= entry_from, 'Yes', 'No'), NULL)) as valid_or_not,
cast(iff(len(trim(uf.user_id)) = 0 ,uf.RESOURCE_ID,iff(uf.user_id = 1737,uf.user_id + 1000000000,uf.user_id )) as number ) as resource_id_2,
iff(uf.RESOURCE_ID is NULL, iff(uf.user_id = 1737,uf.user_id + 1000000000,uf.user_id),uf.RESOURCE_ID ) as resource_id_a,
concat(uf.BYMONTH,'-',resource_id_2) as ByMonthResouceId_2 ,
IFF (uf.user_id is not null, ure.start_exclusion, ure1.start_exclusion) as derived_start_exclusion,
IFF (uf.user_id is not null, ure.end_exclusion,ure1.end_exclusion) as derived_end_exclusion,
 IFF (uf.entry_date >= derived_start_exclusion and uf.entry_date < derived_end_exclusion, True, False) as has_submitted_hours_during_exclusion,
IFF (has_submitted_hours_during_exclusion = True, 0,uf.HOURS ) as hours_excluded,
IFF((uf.Project_Name = 'Leave Time' and uf.Task_Name = 'Non-Paid Leave'),hours_excluded,0) as non_paid_leave,
uf.hours - hours_excluded as excluded_hours
from utilization_merged uf
LEFT JOIN  utilization_resources ur ON uf.USER_NAME = concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME)
LEFT OUTER JOIN utilisation_resource_exclusion_dates ure ON (uf.user_id=ure.user_id_)
LEFT OUTER JOIN utilisation_resource_exclusion_dates ure1 ON (uf.RESOURCE_ID=ure1.employee_id)
),
 tab AS (
    SELECT 
        to_date(um.ByMonth) as byMonth, 
        um.resource_id_2, 
        um.USER_ID, 
        um.ByMonthResouceId_2, 
        SUM(um.excluded_hours) AS Excluded_Hours, 
        SUM(um.non_paid_leave) AS Non_Paid_Hours, 
        MIN(to_date(um.derived_start_exclusion)) AS Start_Exclusion, 
        MIN(to_date(um.derived_end_exclusion)) AS End_Exclusion
    FROM Utilization_Merged_derived um
    GROUP BY 
        um.ByMonth, 
        um.resource_id_2, 
        um.USER_ID, 
        um.ByMonthResouceId_2
),

date_info_derived as (
  select di.*, 
  iff(di.WORKING_DAY_FLAG = 1, 8, 0) as baseline_hours, 
  iff(di.dt >= current_date(), 'Future', 'Past') as past_or_future
  from date_info di
),
baseline_hours_derived as (    
    SELECT 
        uf.*,
        ur.termination_date,
        case when di.dt >= to_date(ur.hire_date) and di.dt <= to_date(ur.termination_date) then di.baseline_hours end as baseline_hours1,
        case when di.dt >= to_date(ur.hire_date) and di.dt <= previous_day(current_date(), 'sa') then di.baseline_hours end as baseline_hours2,
        di.baseline_hours as baseline_hours3,
        di.past_or_future as Past_or_Future
    FROM tab uf
    LEFT JOIN utilization_resources ur ON ur.user_id = uf.user_id
    LEFT JOIN date_info_derived di ON di.BY_MONTH = to_date(uf.ByMonth)

                   ),
baseline_hours_final as (
select bs.BYMONTH,
bs.RESOURCE_ID_2,
bs.USER_ID,
bs.BYMONTHRESOUCEID_2,
bs.EXCLUDED_HOURS,
bs.NON_PAID_HOURS,
bs.START_EXCLUSION,
bs.END_EXCLUSION,
bs.PAST_OR_FUTURE,
CASE 
            WHEN bs.TERMINATION_DATE IS NOT NULL THEN 
                CASE 
                    WHEN bs.ByMonth >= bs.Start_Exclusion AND bs.ByMonth <= bs.End_Exclusion THEN 0
                    ELSE 
                        SUM(baseline_hours1) - bs.Excluded_Hours - bs.Non_Paid_Hours
                END
            ELSE 
                CASE 
                    WHEN bs.ByMonth >= bs.Start_Exclusion AND bs.ByMonth <= bs.End_Exclusion THEN 0
                    ELSE 
                        SUM(baseline_hours2) -bs.Excluded_Hours - bs.Non_Paid_Hours
                END
        END AS Baseline_Hours,
  sum(baseline_hours3) as Forecast_Baseline
  
   from baseline_hours_derived bs 
   

group by
bs.BYMONTH,
bs.RESOURCE_ID_2,
bs.USER_ID,
bs.BYMONTHRESOUCEID_2,
bs.EXCLUDED_HOURS,
bs.NON_PAID_HOURS,
bs.START_EXCLUSION,
bs.END_EXCLUSION,
bs.PAST_OR_FUTURE,
bs.TERMINATION_DATE
),
final as (
select bsf.*, COALESCE(TRY_TO_decimal(ed.target_admin), 0.1) as Admin_percent,
  COALESCE(try_to_decimal(ed.target_BD), 0.02) as BD_percent,
  COALESCE(ed.target_billable,0.6) as Billable_percent,
  COALESCE(ed.target_productive,0.7) as Productive_percent,
  COALESCE(try_to_decimal(ed.TARGET_PROJECT_TRAVEL),0.05) as PROJECT_TRAVEL_percent,
  COALESCE(try_to_decimal(ed.TARGET_PTO),0.15) as PTO_percent,
  COALESCE(try_to_decimal(ed.TARGET_TRAINING),0.05) as TRAINING_percent,
  COALESCE(try_to_decimal(ed.TARGET_STRATEGIC),0.02) as STRATEGIC_percent,
  bsf.baseline_hours * Admin_percent as target_Admin_hours,
  bsf.baseline_hours * BD_percent as target_bd_hours,
  bsf.baseline_hours * Billable_percent as target_Billable_hour,
  bsf.baseline_hours * PROJECT_TRAVEL_percent as target_PROJECT_TRAVEL_hour,
  bsf.baseline_hours * Productive_percent as target_Productive_hour,
  bsf.baseline_hours * PTO_percent as target_PTO_hour,
  bsf.baseline_hours * TRAINING_percent as target_TRAINING_hour,
  bsf.baseline_hours * STRATEGIC_percent as target_STRATEGIC_hour
 from 
baseline_hours_final bsf left join 
 (select *, 
              ur.USER_ID as user_id,
              iff(ed.EMPLOYEE_ID is NULL, ur.USER_ID,ed.EMPLOYEE_ID ) as resource_id,
              iff( user_id is NULL, ed.EMPLOYEE_ID,user_id ) as resource_id_2
              from employee_details ed
              left join utilization_resources ur 
              on ed.EMPLOYEE_ID = ur.EMPLOYEE_ID) ed ON ed.resource_id_2 = bsf.resource_id_2
--where bsf.user_id = 171
  )
 select * from final