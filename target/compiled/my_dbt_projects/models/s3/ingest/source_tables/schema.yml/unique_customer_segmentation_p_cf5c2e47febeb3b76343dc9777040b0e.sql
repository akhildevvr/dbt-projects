
    
    

select
    FISCAL_QUARTER_END_DATE as unique_field,
    count(*) as n_records

from EIO_INGEST.S3_INGEST_STAGE.customer_segmentation_predictions
where FISCAL_QUARTER_END_DATE is not null
group by FISCAL_QUARTER_END_DATE
having count(*) > 1


