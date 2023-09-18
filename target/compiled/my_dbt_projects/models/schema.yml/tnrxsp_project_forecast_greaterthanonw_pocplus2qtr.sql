

    



    WITH validation_errors as (
        select *
        from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.project_forecast
        where percent_complete_plus2qtr > 1
    )

    select *
    from validation_errors

