
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_hours
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



SELECT
ROW_NUMBER,
USER_ID,
USER_NAME,
ENTRY_DATE,
LIMIT_DATE,
TOTAL_TIME AS HOURS,
PROJECT_CODE,
PROJECT_NAME,
TASK_NAME,
BILLABLE,
UTILIZED,
ENTRY_IS_APPROVED,
TASK_CODE,
WAS_NEW_TABLE,
SQL_SCRIPT_VERSION
FROM EIO_PUBLISH.TENROX_PRIVATE.CUST_ADSK_UTILIZATION_HOURS
  );

