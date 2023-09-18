

    



    WITH validation_errors as (
        select *
        from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.project_forecast_test
        where percent_complete_plus3qtr > 1
    )

    select *
    from validation_errors

