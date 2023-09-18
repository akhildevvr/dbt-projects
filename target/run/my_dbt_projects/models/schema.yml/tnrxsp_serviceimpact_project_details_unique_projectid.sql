select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    projectid as unique_field,
    count(*) as n_records

from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_servicesimpact_projectdetails
where projectid is not null
group by projectid
having count(*) > 1



      
    ) dbt_internal_test