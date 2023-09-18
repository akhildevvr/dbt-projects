



with validation as (
    select
        projectid
        , plancost
    from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_marginvariance
),

validation_errors as (
    select *
    from validation
    where plancost < 0
)

select *
from validation_errors

