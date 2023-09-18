select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

    



    WITH validation_errors as (
        select *
        from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.project_forecast_test
        where percent_complete_plus5qtr > 1
    )

    select *
    from validation_errors


      
    ) dbt_internal_test