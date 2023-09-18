select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.project_forecast

where not(hard_booked_rev_currentqtr + soft_booked_rev_currentqtr = total_revenue_currentqtr)


      
    ) dbt_internal_test