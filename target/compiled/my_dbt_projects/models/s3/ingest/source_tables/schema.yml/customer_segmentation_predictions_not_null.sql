
    
    



select *
from EIO_INGEST.TENROX_TRANSFORM.customer_segmentation_predictions
where concat(PARENT_CSN,'-',FISCAL_QUARTER_END_DATE) is null


