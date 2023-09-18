
    
    

select
    projectid as unique_field,
    count(*) as n_records

from EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_project_budget_v02
where projectid is not null
group by projectid
having count(*) > 1


