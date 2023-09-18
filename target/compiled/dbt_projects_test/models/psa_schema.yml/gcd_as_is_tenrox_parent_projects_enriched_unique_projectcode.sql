
    
    

select
    PROJECT_CODE as unique_field,
    count(*) as n_records

from EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_tenrox_parent_projects_enriched
where PROJECT_CODE is not null
group by PROJECT_CODE
having count(*) > 1


