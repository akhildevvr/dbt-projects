/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with resource_utilization_summary as
(SELECT 
*
FROM 
EIO_INGEST.ENGAGEMENT_TRANSFORM.resource_utilization_summary
),
user_list as
(SELECT 
*
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.user_list

)

SELECT 
R.*,
U.USER_FIRST_NAME, 
U.USER_LAST_NAME
FROM with resource_utilization_summary as R LEFT JOIN
user_list U ON U.USER_UNIQUE_ID = R.USER_UNIQUE_ID
WHERE UTILIZATION_NON_WORKING_HOURS > 0 AND UTILIZATION_DATE >= TRUNC(CURRENT_DATE(), 'MONTH')