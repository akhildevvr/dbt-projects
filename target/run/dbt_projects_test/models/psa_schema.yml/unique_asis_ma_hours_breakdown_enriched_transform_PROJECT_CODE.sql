select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    PROJECT_CODE as unique_field,
    count(*) as n_records

from EIO_INGEST.ENGAGEMENT_TRANSFORM.asis_ma_hours_breakdown_enriched
where PROJECT_CODE is not null
group by PROJECT_CODE
having count(*) > 1



      
    ) dbt_internal_test