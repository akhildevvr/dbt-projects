select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    concat(ACCOUNT_UUID,'-',ASSET_SUB_END_MONTH,'-',ASSET_SUB_END_YEAR) as unique_field,
    count(*) as n_records

from EIO_INGEST.TENROX_TRANSFORM.ews_enriched
where concat(ACCOUNT_UUID,'-',ASSET_SUB_END_MONTH,'-',ASSET_SUB_END_YEAR) is not null
group by concat(ACCOUNT_UUID,'-',ASSET_SUB_END_MONTH,'-',ASSET_SUB_END_YEAR)
having count(*) > 1



      
    ) dbt_internal_test