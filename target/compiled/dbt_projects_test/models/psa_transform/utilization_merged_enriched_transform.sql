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
project_details_enhanced as
(
SELECT
*
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced

),
asis_ma_hours_breakdown as
(
SELECT
*
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.asis_ma_hours_breakdown

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

date_info_derived as (
  select di.*, 
  iff(di.WORKING_DAY_FLAG = 1, 8, 0) as baseline_hours, 
  iff(di.dt >= current_date(), 'Future', 'Past') as past_or_future
  from date_info di
)

SELECT
uf.PROJECT_NAME,
uf.PROJECT_CODE,
uf.USER_NAME AS user_name ,
concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME) as resource_name,
uf.role_name,
uf.ENTRY_DATE,
uf.HOURS,
uf.ENTRY_IS_APPROVED,
uf.UTILIZED,
uf.BILLABLE,
uf.TASK_CODE,
uf.TASK_NAME,
uf.USER_ID,
uf.ACTUAL_FORECAST,
uf.time_category,
PDE.timecategory as time_category_actual ,
IFF (uf.IS_HARD_BOOKING = 1, True, iff(uf.IS_HARD_BOOKING is NULL, NULL, False) ) as is_hard_booking,
uf.RESOURCE_ID,
uf.USER_RESOURCE_GROUP,
uf.HARD_BOOKED_HOURS,
uf.SOFT_BOOKED_HOURS,
uf.BYMONTH,
uf.FISCAL_QUARTER,
uf.PROJECT_STATE,
ur.FORECASTED_COST_RATE as Rate,
uf.hours * ur.FORECASTED_COST_RATE as Cost,
IFF(contains(task_name, 'Non-Billable Project Travel'),'Non-Billable Project Travel',
   IFF(contains(task_name, 'Business Development'), 'Business Development' , 'Billable'))  as billing_work_type,
PREVIOUS_DAY(current_date(), 'sa' )   as entry_from,
IFF(ACTUAL_FORECAST = 'ACTUAL', 'Yes', IFF(ACTUAL_FORECAST = 'FORECAST',IFF(ENTRY_DATE >= entry_from, 'Yes', 'No'), NULL)) as valid_or_not,
IFF(len(trim(uf.user_id)) = 0 ,uf.RESOURCE_ID,IFF(uf.user_id = 1737,uf.user_id + 1000000000,uf.user_id )) as resource_id_2,
IFF(uf.RESOURCE_ID is NULL, IFF(uf.user_id = 1737,uf.user_id + 1000000000,uf.user_id),uf.RESOURCE_ID ) as resource_id_a,
concat(uf.BYMONTH,'-',resource_id_2) as ByMonthResouceId_2 ,
CASE WHEN LEFT(UF.user_name,1)='3'
     THEN 'Yes' else 'No' 
END as Is_3rd_Party,
CASE WHEN (LEFT(UF.User_Name,1) = '3' or
     LEFT(UF.User_Name,1) = '1' or
     LEFT(UF.User_Name,7) = 'Machine' or
     UF.User_Name = 'Business Consultant' or
     UF.User_Name = 'Implementation Consultant' or
     UF.User_Name = 'Technical Consultant' or
     UF.User_Name = 'Project Manager' or
     UF.User_Name = 'Solution Architect' or
     UF.User_Name = 'Unassigned') THEN 1 else 0
END as   Generic_Resource,
datediff(month, current_date(), UF.ENTRY_DATE) as Month_Count,
IFF( task_name in ('Volunteering','PTO / Holiday'), 'PTO', 
    IFF( task_code in ('Non-Billable Project Travel','Project Travel-Non-Billable') and contains(uf.Project_Name,'Advisory Services') = false 
        and contains(uf.Project_Name,'Implementation Services') = false and contains(uf.Project_Name,'IS ') = false and contains(uf.Project_Name,'IAS ') = false, 'Project Travel',
        IFF( task_code in ('Business Development-Non-Billable','Business Development') and PDE.timecategory = 'Customer' , 'Bus Dev',
         IFF( task_code in ('Training as an Attendee'), 'Training', 
             IFF( PDE.timecategory is NULL and uf.Project_Name != 'Leave Time' and task_name != 'Non-Paid Leave' and task_code !='Training as an Attendee' 
                 and task_code !='Non-Billable Project Travel' or PDE.timecategory in ('Admin','Internal Investment'), 'Internal Activities',
         IFF( PDE.timecategory in ('Customer') , 'Billable', IFF( PDE.timecategory in ('Productive Utilized') , 'Productive Utilized Projects', PDE.timecategory ))))))) 
         as category_actuals,
CASE WHEN category_actuals = 'Billable'
     THEN  UF.HOURS else 0 
END  as Billable_Hours,
CASE WHEN (Generic_Resource = 1 and Task_Name = NULL)
     THEN 1 else 0 
END as Gen_Res_and_Empty_Task,
to_date(SPLIT_PART(asima.CONTRACT_START_DATE, ' ', 1)) as CONTRACT_START_DATE,

CASE WHEN asima.Contract_END_DATE is null THEN NULL
    else Dateadd(day, 1, to_date(SPLIT_PART(asima.Contract_END_DATE, ' ', 1)))
END as Contract_End_Date,
CASE
  WHEN uf.user_id IS NOT NULL AND uf.resource_id IS NULL THEN
ur1.functional_group 
  WHEN uf.user_id IS NULL AND uf.resource_id IS NOT NULL THEN
 ur2.functional_group 
  ELSE
    NULL
END as Functional_Group,
 IFF (uf.user_id is not null, ure.start_exclusion, ure1.start_exclusion) as derived_start_exclusion,
  IFF (uf.user_id is not null, ure.end_exclusion,ure1.end_exclusion) as derived_end_exclusion,
   IFF (entry_date >= derived_start_exclusion and entry_date < derived_end_exclusion, True, False) as has_submitted_hours_during_exclusion,
 IFF (has_submitted_hours_during_exclusion = True, 0,uf.HOURS ) as NET_TOTAL_TIME,
 IFF(category_actuals = 'Billable' ,NET_TOTAL_TIME,0) as Actual_Billable,
 IFF(category_actuals = 'Productive Utilized Projects' and UPPER(actual_forecast) = 'ACTUAL' ,NET_TOTAL_TIME,0) as Productive_Utilized_Projects,
 IFF ( category_actuals = 'Bus Dev', NET_TOTAL_TIME, 0 ) as bus_dev,
  IFF( ((task_code in ( 'Non-Billable Project Travel', 'Project Travel-Non-Billable')) and (contains(uf.Project_Name,'Advisory Services') = false and contains(uf.Project_Name,'Implementation Services') = false
          and contains(uf.Project_Name, 'IS ') = false and contains(uf.Project_Name, 'AS ') = false)) ,NET_TOTAL_TIME,0) as project_travel,
 IFF(task_name in ('Volunteering','PTO / Holiday') ,NET_TOTAL_TIME, 0) as PTO,
 IFF(uf.Project_Name = 'Leave Time' and Task_Name = 'Non-Paid Leave',NET_TOTAL_TIME,0) as non_paid_leave,
 uf.hours - NET_TOTAL_TIME as excluded_hours, -- Whats the difference between  NET_TOTAL_TIME and excluded_hours
IFF ((IFF(LEN(ur1.title) >1, ur1.title , ur1.user_first_name )) is NULL,'Not Found', (IFF(LEN(ur1.title) >1, ur1.title , ur1.user_first_name )))   as user_role,
IFF( contains(uf.Project_Name,'RM Training'), 'Training' ,
     IFF( contains(uf.Project_Name,'Travel Time') , 'Training',
     IFF( contains(uf.time_category,'Customer') , 'Billable' ,
     IFF( UPPER(uf.project_state)=UPPER('Funnel') and is_hard_booking = true , 'Bus Dev' ,
     IFF( UPPER(uf.project_state)=UPPER('Internal Investment - KPI utilized')  , 'Productive Utilized Projects' ,
     IFF( uf.time_category='Internal Investment'  , 'Internal Activities',
     IFF( uf.time_category='Admin'  , 'Internal Activities' ,
     IFF( contains(uf.Project_Name,'Overhead') , 'Internal Activities' ,
     IFF( contains(PDE.timecategory,'Leave') , 'Leave Time' ,
     IFF( len(trim(uf.time_category)) > 0 , uf.time_category,
     IFF( len(trim(PDE.timecategory)) > 0 , category_actuals,
     IFF( len(trim(uf.Project_Name)) > 0 , uf.Project_Name ,
      uf.actual_forecast
)))))))))))) as Category_FCST ,
IFF(Category_FCST = 'Billable' ,uf.HOURS,0) as FCST_Billable,
IFF(UPPER(uf.actual_forecast)=UPPER('FORECAST'), FCST_Billable, 0) as FCST_Billable_F, 
IFF(UPPER(uf.actual_forecast)=UPPER('ACTUAL'), Actual_Billable, 0) as FCST_Billable_A,
FCST_Billable_F + FCST_Billable_A as FCST_Billable_A_F,
di.baseline_hours,
di.past_or_future
FROM utilization_merged uf
LEFT JOIN  utilization_resources ur
                                     ON uf.USER_NAME = concat(ur.USER_LAST_NAME,', ',ur.USER_FIRST_NAME)
LEFT JOIN project_details_enhanced as PDE
                                     on (UF.PROJECT_CODE = PDE.PROJECTCODE )
LEFT JOIN asis_ma_hours_breakdown asima
                                     on (UF.project_code = ASIMA.project_code )
LEFT JOIN utilization_resources ur1
                                     on ur1.user_id = uf.user_id
                                     and ur1.user_id <> 510
LEFT JOIN utilization_resources ur2
                                     on ur2.employee_id = uf.resource_id
                                     and ur2.user_id <> 510
LEFT JOIN utilisation_resource_exclusion_dates ure
                                     ON (uf.user_id=ure.user_id_)
LEFT JOIN utilisation_resource_exclusion_dates ure1
                                     ON (uf.RESOURCE_ID=ure1.employee_id)
LEFT JOIN date_info_derived di ON di.DT = to_date(uf.ENTRY_DATE)