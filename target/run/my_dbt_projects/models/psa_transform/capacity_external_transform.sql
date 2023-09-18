
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.CAPACITY_EXTERNAL
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/


select * 
from 
EIO_INGEST.ENGAGEMENT_SHAREPOINT.CAPACITY_EXTERNAL_SHEET_1
  );

