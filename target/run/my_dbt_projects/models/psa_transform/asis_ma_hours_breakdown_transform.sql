
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.asis_ma_hours_breakdown
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



SELECT 
p.PROJECT_UNIQUE_ID, 
p.PROJECT AS PROJECT_NAME,
p.PROJECT_CODE,
p.PROJECT_STATE, 
concat(u.USER_FIRST_NAME,' ',u.USER_LAST_NAME) as PROJECT_MANAGER, 
p.PLANNED_END_DATE as contractual_end_date,
p.Project_Start AS PROJECT_START_DATE, 
p.Project_End AS PROJECT_END_DATE,
p.Contract_Start_Date, 
p.Contract_End_Date,
p.Rev_Forecast_Contract_Type, 
b.Project_Budget_Current_Time,
b.Project_Budget_Current_Billable_Time,
(b.Project_Budget_Current_Billable_Time/1.2) AS CONSULTANT_TIME,
(b.Project_Budget_Current_Billable_Time) - (CONSULTANT_TIME) AS PM_TIME,
b.Project_Budget_Current_Non_Billable_Time AS TRAVEL_TIME
FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.project_list p LEFT JOIN
EIO_INGEST.ENGAGEMENT_TRANSFORM.project_budget_summary  b ON P.PROJECT_UNIQUE_ID = B.PROJECT_UNIQUE_ID LEFT JOIN
EIO_INGEST.ENGAGEMENT_TRANSFORM.user_list u ON U.User_Unique_ID  = P.Project_Manager_Unique_ID
WHERE P.Rev_Forecast_Contract_Type IN ('Implementation Services: Non-ARR','Advisory Services: ARR')
  );

