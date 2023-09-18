



with validation as (
    select
        projectid
        , eac_revenue
    from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_marginvariance
),

validation_errors as (
    select *
    from validation
    where eac_revenue < 0
)

select *
from validation_errors

