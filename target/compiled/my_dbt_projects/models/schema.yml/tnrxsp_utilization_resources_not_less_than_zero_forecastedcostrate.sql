



with validation as (
    select
        userid
        , forecastedcostrate
    from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_utilization_resources
),

validation_errors as (
    select *
    from validation
    where forecastedcostrate < 0
)

select *
from validation_errors

