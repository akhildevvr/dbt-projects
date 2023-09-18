select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



SELECT COUNT(*) as cnt
FROM EIO_INGEST.S3_INGEST_STAGE.customer_segmentation_predictions
WHERE NOT to_char(AOV_SNAPSHOT_DATE , 'YYYY-MM-DD') <> '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
having cnt > 0




      
    ) dbt_internal_test