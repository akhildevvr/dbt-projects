
    
    

select
    projectcode as unique_field,
    count(*) as n_records

from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.cust_adsk_marginvariance
where projectcode is not null
group by projectcode
having count(*) > 1


