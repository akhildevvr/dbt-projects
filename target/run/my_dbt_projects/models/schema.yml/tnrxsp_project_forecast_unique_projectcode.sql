select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    project_code as unique_field,
    count(*) as n_records

from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.project_forecast_test
where project_code is not null
group by project_code
having count(*) > 1



      
    ) dbt_internal_test