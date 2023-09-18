
    
    

select
    PROJECT_UNIQUE_ID as unique_field,
    count(*) as n_records

from EIO_INGEST.ENGAGEMENT_TRANSFORM.project_budget_summary
where PROJECT_UNIQUE_ID is not null
group by PROJECT_UNIQUE_ID
having count(*) > 1


