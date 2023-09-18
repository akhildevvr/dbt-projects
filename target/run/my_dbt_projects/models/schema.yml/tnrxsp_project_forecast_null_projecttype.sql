select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select adsk_masteragreement_projecttype
from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.project_forecast_test
where adsk_masteragreement_projecttype is null



      
    ) dbt_internal_test