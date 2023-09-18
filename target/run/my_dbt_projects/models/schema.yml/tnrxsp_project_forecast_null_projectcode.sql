select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select project_code
from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.project_forecast_test
where project_code is null



      
    ) dbt_internal_test