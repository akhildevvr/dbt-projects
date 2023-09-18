select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select USER_UNIQUE_ID
from EIO_INGEST.ENGAGEMENT_TRANSFORM.user_list
where USER_UNIQUE_ID is null



      
    ) dbt_internal_test