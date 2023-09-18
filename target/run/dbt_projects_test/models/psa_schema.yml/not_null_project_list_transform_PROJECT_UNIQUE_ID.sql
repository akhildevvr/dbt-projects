select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select PROJECT_UNIQUE_ID
from EIO_INGEST.ENGAGEMENT_TRANSFORM.project_list
where PROJECT_UNIQUE_ID is null



      
    ) dbt_internal_test