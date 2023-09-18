
    
    

select
    userid as unique_field,
    count(*) as n_records

from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_utilization_resources
where userid is not null
group by userid
having count(*) > 1


