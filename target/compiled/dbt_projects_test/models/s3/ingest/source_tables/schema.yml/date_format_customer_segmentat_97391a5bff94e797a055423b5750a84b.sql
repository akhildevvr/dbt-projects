



SELECT COUNT(*) as cnt
FROM EIO_INGEST.S3_INGEST_STAGE.customer_segmentation_predictions
WHERE NOT to_char(FISCAL_QUARTER_END_DATE , 'YYYY-MM-DD') <> '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
having cnt > 0



