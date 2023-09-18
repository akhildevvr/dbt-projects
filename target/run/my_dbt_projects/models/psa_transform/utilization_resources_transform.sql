
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



SELECT
* 
FROM EIO_PUBLISH.TENROX_PRIVATE.CUST_ADSK_UTILIZATION_RESOURCES
  );

