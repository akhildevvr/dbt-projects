select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from EIO_INGEST.CUSTOMER_TEST_LOG.customer_segmentation_predictions_snapshot_date_format
    
      
    ) dbt_internal_test