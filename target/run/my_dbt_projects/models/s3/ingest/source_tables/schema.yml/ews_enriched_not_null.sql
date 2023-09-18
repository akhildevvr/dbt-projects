select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select concat(ACCOUNT_UUID,'-',ASSET_SUB_END_MONTH,'-',ASSET_SUB_END_YEAR)
from EIO_INGEST.TENROX_TRANSFORM.ews_enriched
where concat(ACCOUNT_UUID,'-',ASSET_SUB_END_MONTH,'-',ASSET_SUB_END_YEAR) is null



      
    ) dbt_internal_test