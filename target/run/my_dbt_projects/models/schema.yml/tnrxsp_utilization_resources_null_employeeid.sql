select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select employeeid
from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_utilization_resources
where employeeid is null



      
    ) dbt_internal_test