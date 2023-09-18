
    
    

select
    SERVICE_ENGAGEMENT_ID as unique_field,
    count(*) as n_records

from EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_service_engagements
where SERVICE_ENGAGEMENT_ID is not null
group by SERVICE_ENGAGEMENT_ID
having count(*) > 1


