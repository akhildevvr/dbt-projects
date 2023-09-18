



select
    1
from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.project_forecast_test

where not(hard_booked_rev_currentqtr + soft_booked_rev_currentqtr = total_revenue_currentqtr)

