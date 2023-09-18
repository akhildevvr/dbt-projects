



with validation as (
    select
        projectid
        , pa_sco_expense_credits
    from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_servicesimpact_projectdetails
),

validation_errors as (
    select *
    from validation
    where pa_sco_expense_credits < 0
)

select *
from validation_errors

