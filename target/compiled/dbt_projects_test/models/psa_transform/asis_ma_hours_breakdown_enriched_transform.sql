/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/




with as_is_ma_hours_breakdown as ( 
SELECT
PROJECT_UNIQUE_ID,
PROJECT_NAME,
PROJECT_CODE,
PROJECT_STATE,
PROJECT_MANAGER,
CONTRACTUAL_END_DATE,
PROJECT_START_DATE,
PROJECT_END_DATE,
to_date(SPLIT_PART(CONTRACT_START_DATE, ' ', 1)) as CONTRACT_START_DATE,
case when Contract_END_DATE is null then NULL
    else Dateadd(day, 1, to_date(SPLIT_PART(Contract_END_DATE, ' ', 1)))
end as CONTRACT_END_DATE,
REV_FORECAST_CONTRACT_TYPE,
PROJECT_BUDGET_CURRENT_TIME,
PROJECT_BUDGET_CURRENT_BILLABLE_TIME,
CONSULTANT_TIME,
PM_TIME,
TRAVEL_TIME
from  EIO_INGEST.ENGAGEMENT_TRANSFORM.asis_ma_hours_breakdown )

SELECT *,
datediff(month, CONTRACT_START_DATE :: date,CONTRACT_END_DATE::date) as Calculated_Contract_Month,
DIV0(COALESCE(DIV0(SUM("Consultant_Time"),8), 0) + COALESCE(DIV0(SUM("PM_Time"),8), 0) ,Calculated_Contract_Month ) as Days_to_Deliver_per_Month,
DIV0(DIV0(SUM("Consultant_Time"),8), Calculated_Contract_Month ) as Consultant_Days_to_Deliver_per_Month,
Consultant_Days_to_Deliver_per_Month * 8 as  Consultant_Hours_to_Deliver_per_Month, 
DIV0(DIV0(SUM("PM_Time"),8), Calculated_Contract_Month ) as PM_Days_to_Deliver_per_Month,
PM_Days_to_Deliver_per_Month * 8 as PM_Hrs_to_Deliver_per_Month, 
case when current_date() < CONTRACT_START_DATE then null
     when Date_part(day, CONTRACT_START_DATE ) > 15 then MONTHS_BETWEEN(current_date(), CONTRACT_START_DATE) -1
     when Date_part(day, CONTRACT_START_DATE ) <= 15 then MONTHS_BETWEEN(current_date(), CONTRACT_START_DATE)
end as   No_of_Month_Executed, 

case when current_date() < CONTRACT_START_DATE then null
     else MONTHS_BETWEEN(current_date(), CONTRACT_START_DATE)
end as No_of_Months_Executed_original

 from  as_is_ma_hours_breakdown
 group by 
 PROJECT_UNIQUE_ID,
PROJECT_NAME,
PROJECT_CODE,
PROJECT_STATE,
PROJECT_MANAGER,
CONTRACTUAL_END_DATE,
PROJECT_START_DATE,
PROJECT_END_DATE,
 CONTRACT_START_DATE, 
 CONTRACT_END_DATE,
REV_FORECAST_CONTRACT_TYPE,
PROJECT_BUDGET_CURRENT_TIME,
PROJECT_BUDGET_CURRENT_BILLABLE_TIME,
CONSULTANT_TIME,
PM_TIME,
TRAVEL_TIME