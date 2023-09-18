/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with as_is_service_purchase_details as 
(
SELECT *
FROM 
EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_service_purchase
),
as_is_exhibits as 
(
SELECT *
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_exhibits_enriched
),
as_is_service_engagements as 
(
SELECT *
FROM 
EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_service_engagements
),
as_is_tenrox_parent_projects as 
(
SELECT *
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_tenrox_parent_projects
),
as_is_child_projects as
(
SELECT *
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_tenrox_child_projects
),
as_is_ma_hours_breakdown as 
(
SELECT *
FROM 
EIO_INGEST.ENGAGEMENT_TRANSFORM.asis_ma_hours_breakdown
),

utilization_merged as 
(
SELECT *
FROM 
EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_hours_forecast
),
consultant_days_Delivered as (
SELECT
AS_IS_PD.NAME,  
AS_IS_PD.exhibit_id,
AS_IS_PD.exhibit_type,

SUM(UHF.HOURS)/8 AS Consultant_Days_Delivered_per_expiry

FROM  as_is_service_purchase_details as AS_IS_PD
LEFT JOIN as_is_exhibits  as AS_IS_EXHIBITS 
 ON AS_IS_PD.EXHIBIT_ID = AS_IS_EXHIBITS.EXHIBIT_ID
LEFT JOIN as_is_service_engagements as AS_IS_SRVC 
 ON AS_IS_EXHIBITS.EXHIBIT_ID = AS_IS_SRVC.EXHIBIT_ID
LEFT JOIN as_is_tenrox_parent_projects as AS_IS_PARENT 
 ON AS_IS_PARENT.TENROX_TRACKING_NO = AS_IS_SRVC.TENROX_TRACKING_NUMBER
LEFT JOIN as_is_child_projects AS AS_IS_CHILD 
 ON AS_IS_PARENT.PARENT_CHILD_KEY = AS_IS_CHILD.PARENT_CHILD_KEY
LEFT JOIN as_is_ma_hours_breakdown as ASIMA 
 ON ASIMA.PROJECT_CODE = AS_IS_CHILD.PROJECT_CODE
LEFT JOIN utilization_merged  as UHF 
 ON uhf.PROJECT_CODE = ASIMA.PROJECT_CODE


WHERE 
   UHF.ACTUAL_FORECAST = 'ACTUAL' 
  AND UHF.BILLABLE = TRUE
  AND UHF.TASK_CODE <> 'Project Management-Billable'
  AND UHF.TASK_CODE <> 'Project Travel-Non-Billable'
  --AND UHF.Functional_Group <> 'Functional-Project Managers'
  //and AS_IS_PD.ACCOUNT_NAME ilike '%face%'
  //and AS_IS_PD.EXHIBIT_TYPE ilike '%imple%'
  GROUP BY as_IS_PD.exhibit_id ,AS_IS_PD.ACCOUNT_NAME, AS_IS_PD.exhibit_type, AS_IS_PD.NAME
)

SELECT 
 SP.*, 
case  when SP.EXHIBIT_TYPE = 'Consulting Advisory Service' then  'AS' 
      when SP.EXHIBIT_TYPE = 'Consulting Implementation Services' then  'IS'
end as Exhibit_Type_AS_IS,

DIV0(SP.Credit_Quantity,8) as AS_IS_Days,

SUM(DIV0(SP.Credit_Quantity,8)) OVER (PARTITION BY SP.EXHIBIT_ID ORDER BY SP.Expiration_Date) as Remaining_Budget_Days,

case 
    when SP1.EXHIBIT_COUNT = 1 then 0
    else 1  
end as More_than_one_expiry_with_same_date,
cdd.Consultant_Days_Delivered_per_expiry,

case when (Remaining_Budget_Days - cdd.Consultant_Days_Delivered_per_expiry) > AS_IS_Days then AS_IS_Days
     when (Remaining_Budget_Days - cdd.Consultant_Days_Delivered_per_expiry)< 0 then 0
     else (Remaining_Budget_Days - cdd.Consultant_Days_Delivered_per_expiry)
end as Final_Remaining_Days,

AS_IS_Days - Final_Remaining_Days as Final_Days_Delivered,

case when (SP.EXPIRATION_DATE<= current_date() and Final_Remaining_Days=0)  then 0
     when (SP.EXPIRATION_DATE = current_date() and Final_Remaining_Days>0)  then 0      
     when (SP.EXPIRATION_DATE < current_date() and Final_Remaining_Days>0)  then FLOOR(MONTHS_BETWEEN(SP.EXPIRATION_DATE, current_date()))
     when (MONTH(SP.EXPIRATION_DATE) = MONTH(current_date()) AND YEAR(SP.EXPIRATION_DATE) = YEAR(current_date()) AND DAY(SP.EXPIRATION_DATE)<15) then 0
     when (MONTH(SP.EXPIRATION_DATE) = MONTH(current_date()) AND YEAR(SP.EXPIRATION_DATE) = YEAR(current_date()) AND DAY(SP.EXPIRATION_DATE)>15) then 1
     when (DATEDIFF(day, current_date(), SP.EXPIRATION_DATE) > 0 AND Final_Remaining_Days= 0) then 0
     when (DATEDIFF(day, current_date(), SP.EXPIRATION_DATE) > 0 AND Final_Remaining_Days> 0 AND DAY(current_date())<15) 
            then FLOOR(MONTHS_BETWEEN(SP.EXPIRATION_DATE, current_date()))+1
     when (SP.EXPIRATION_DATE > current_date() and Final_Remaining_Days>0)  then FLOOR(MONTHS_BETWEEN(SP.EXPIRATION_DATE, current_date()))
     when (SP.EXPIRATION_DATE >current_date() AND YEAR(SP.EXPIRATION_DATE) > YEAR(current_date()) AND Final_Remaining_Days= 0) 
            then MONTH(SP.EXPIRATION_DATE)+12-MONTH(current_date())
     else 9999
           
end as Remaining_Months,


DIV0(Final_Remaining_Days,Remaining_Months) as Catch_Up_Rate,

case when (SP.EXPIRATION_DATE< current_date() and Remaining_Months=1)  then 1
else 0
end as Conditional_format

FROM as_is_service_purchase_details as SP
LEFT JOIN consultant_days_Delivered as cdd 
ON cdd.exhibit_id = SP.EXHiBIT_ID
AND cdd.NAME = SP.NAME


LEFT JOIN
       (
        SELECT EXHIBIT_ID, EXPIRATION_DATE  ,  count(EXHIBIT_NAME) as EXHIBIT_COUNT 
        FROM as_is_service_purchase_details
        GROUP BY EXHIBIT_ID, EXPIRATION_DATE 
        ) as SP1 
 ON SP.EXHIBIT_ID  = SP1.EXHIBIT_ID 
 AND SP.EXPIRATION_DATE = SP1.EXPIRATION_DATE