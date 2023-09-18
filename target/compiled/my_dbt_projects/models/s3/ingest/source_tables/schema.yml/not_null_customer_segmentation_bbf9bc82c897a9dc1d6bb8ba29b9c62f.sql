
    
    



select concat(PARENT_CSN,'-',FISCAL_QUARTER_END_DATE)
from EIO_INGEST.S3_INGEST_STAGE.customer_segmentation_predictions
where concat(PARENT_CSN,'-',FISCAL_QUARTER_END_DATE) is null


