select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select PROJECT_CODE
from EIO_INGEST.ENGAGEMENT_TRANSFORM.asis_ma_hours_breakdown_enriched
where PROJECT_CODE is null



      
    ) dbt_internal_test