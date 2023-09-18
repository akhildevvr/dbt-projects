
    
    

select
    PROJECT_ID as unique_field,
    count(*) as n_records

from EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced
where PROJECT_ID is not null
group by PROJECT_ID
having count(*) > 1


