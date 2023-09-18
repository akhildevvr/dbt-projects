select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select USER_ID
from EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources_enriched
where USER_ID is null



      
    ) dbt_internal_test