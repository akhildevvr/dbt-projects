
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.UTILIZATION_RESOURCE_EXCLUSION_DATES
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/


select * from 
"EIO_INGEST"."ENGAGEMENT_SHAREPOINT"."UTILIZATION_RESOURCE_EXCLUSION_DATES_SHEET_1"
  );

