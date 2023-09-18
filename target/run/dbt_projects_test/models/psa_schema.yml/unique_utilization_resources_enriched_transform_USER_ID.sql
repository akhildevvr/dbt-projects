select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    USER_ID as unique_field,
    count(*) as n_records

from EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources_enriched
where USER_ID is not null
group by USER_ID
having count(*) > 1



      
    ) dbt_internal_test