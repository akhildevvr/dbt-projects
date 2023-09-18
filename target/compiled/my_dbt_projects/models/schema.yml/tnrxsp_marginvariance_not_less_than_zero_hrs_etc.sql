



with validation as (
    select
        projectid
        , hrs_etc
    from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_marginvariance
),

validation_errors as (
    select *
    from validation
    where hrs_etc < 0
)

select *
from validation_errors

