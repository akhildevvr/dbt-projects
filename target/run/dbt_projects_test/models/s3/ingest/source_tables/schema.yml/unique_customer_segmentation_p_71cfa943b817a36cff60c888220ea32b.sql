select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    concat(PARENT_CSN,'-',FISCAL_QUARTER_END_DATE) as unique_field,
    count(*) as n_records

from EIO_INGEST.S3_INGEST_STAGE.customer_segmentation_predictions
where concat(PARENT_CSN,'-',FISCAL_QUARTER_END_DATE) is not null
group by concat(PARENT_CSN,'-',FISCAL_QUARTER_END_DATE)
having count(*) > 1



      
    ) dbt_internal_test