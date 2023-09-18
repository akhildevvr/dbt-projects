select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



with validation as (
    select
        projectid
        , eac_cost
    from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_marginvariance
),

validation_errors as (
    select *
    from validation
    where eac_cost < 0
)

select *
from validation_errors


      
    ) dbt_internal_test