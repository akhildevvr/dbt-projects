/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/




with resource_allocation_details as (
    SELECT 
    *
    FROM 
    EIO_INGEST.ENGAGEMENT_TRANSFORM.resource_allocation_details

),
project_list as (
    SELECT 
    *
    FROM 
    EIO_INGEST.ENGAGEMENT_TRANSFORM.project_list
),
user_list as (
    SELECT
    *
    FROM
    EIO_INGEST.ENGAGEMENT_TRANSFORM.user_list
),

portfolio as (
    SELECT 
    *
    FROM
     EIO_PUBLISH.TENROX_PRIVATE.TPORTFOLIO
),

planning_role as (
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TPLANNINGROLE
),

map_data as (
    SELECT
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TMAPDATA
)

SELECT 
A.PROJECT_UNIQUE_ID AS PROJECT_ID,
P.PROJECT as PROJECT_NAME,
P.PROJECT_CODE,
P.SAP_Project_ID,
concat(Us.USER_LAST_NAME,', ',Us.USER_FIRST_NAME) as PROJECT_MANAGER,
P.PROJECT_STATE,po.name AS PORTFOLIO,
P.REGION,
P.Time_Category,
r.role AS role_name,
iff(U.User_ID = '', NULL,U.User_ID) AS RESOURCE_ID, 
iff(U.User_ID is null, r.role, concat(U.USER_LAST_NAME,', ',U.USER_FIRST_NAME)) as user_name,
A.Resource_Allocation_Date AS ENTRY_DATE,
A.Resource_Allocation_Soft_Booking_Hours ,
A.Resource_Allocation_Hard_Booking_Hours,
iff(A.Resource_Allocation_Soft_Booking_Hours = 0 , 
    A.Resource_Allocation_Hard_Booking_Hours, 
    A.Resource_Allocation_Soft_Booking_Hours ) as HOURS,
U.USER_RESOURCE_GROUP,
RESOURCE_ALLOCATION_IS_HARD_BOOKING AS is_hard_booking, 
P.Delivery_Geo 
          FROM resource_allocation_details A INNER JOIN
          project_list P ON A.PROJECT_UNIQUE_ID = P.PROJECT_UNIQUE_ID left JOIN
          user_list Us ON Us.User_Unique_ID = p.Project_Manager_Unique_ID left join 
          user_list U ON U.User_Unique_ID = A.User_Unique_ID left join 
          portfolio po on po.uniqueid = P.Portfolio_Unique_ID left join
          (SELECT        
          TPLANNINGROLE.UNIQUEID AS Role_Unique_ID, 
          TPLANNINGROLE.ID AS Role_ID, 
          TPLANNINGROLE.NAME AS Role, 
          TPLANNINGROLE.DESCRIPTION AS Role_Description,
          TPLANNINGROLE.ACCESSTYPE AS Role_Is_Active, 
          TPLANNINGROLE.HOURLYBILLINGRATE AS Role_Hourly_Billing_Rate, 
          TPLANNINGROLE.HOURLYCOSTRATE AS Role_Hourly_Cost_Rate,
          TMAPDATA.FIELDDESC AS Role_Type, 
          TPLANNINGROLE.RESGROUPID AS Resource_Group_Unique_ID
          FROM             planning_role TPLANNINGROLE  INNER JOIN
                                    map_data TMAPDATA  ON TMAPDATA.TABLENAME = 'ROLETYPE' AND TMAPDATA.LANGUAGE = 0 AND TMAPDATA.FIELDKEY = TPLANNINGROLE.ROLETYPE) r on r.Role_Unique_ID = A.Role_Unique_ID
          where A.Resource_Allocation_Date >= TRUNC(CURRENT_DATE(), 'MONTH')  and  A.Resource_Allocation_Date < DATEADD(year, 2, TRUNC(CURRENT_DATE(), 'MONTH'))
          group by
          A.PROJECT_UNIQUE_ID,
          P.PROJECT,
          P.PROJECT_CODE,
          P.SAP_Project_ID,
          concat(Us.USER_LAST_NAME,', ',Us.USER_FIRST_NAME),
          po.name,P.REGION,
          P.Time_Category,
          U.User_ID, 
          A.RESOURCE_ALLOCATION_UNIQUE_ID,  
          A.Resource_Allocation_Date,
          A.Resource_Allocation_Soft_Booking_Hours,
          A.Resource_Allocation_Hard_Booking_Hours,
          U.USER_RESOURCE_GROUP,
          P.PROJECT_STATE,
          r.role,
          RESOURCE_ALLOCATION_IS_HARD_BOOKING , 
          P.Delivery_Geo,
          iff(U.User_ID is null, r.role, concat(U.USER_LAST_NAME,', ',U.USER_FIRST_NAME))