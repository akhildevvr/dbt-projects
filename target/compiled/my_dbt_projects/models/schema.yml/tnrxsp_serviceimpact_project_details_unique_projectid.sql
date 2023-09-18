
    
    

select
    projectid as unique_field,
    count(*) as n_records

from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_servicesimpact_projectdetails
where projectid is not null
group by projectid
having count(*) > 1


