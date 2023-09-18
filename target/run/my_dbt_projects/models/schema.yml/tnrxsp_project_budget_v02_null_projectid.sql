select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select projectid
from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_project_budget_v02
where projectid is null



      
    ) dbt_internal_test