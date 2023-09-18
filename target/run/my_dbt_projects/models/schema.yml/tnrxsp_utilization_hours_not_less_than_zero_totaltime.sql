select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



with validation as (
    select
        projectcode || '_' || userid    as projectcode_userid
        , totaltime
    from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_utilization_hours
),

validation_errors as (
    select *
    from validation
    where totaltime < 0
)

select *
from validation_errors


      
    ) dbt_internal_test