
    
    

select
    EXHIBIT_ID as unique_field,
    count(*) as n_records

from EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_exhibits_enriched
where EXHIBIT_ID is not null
group by EXHIBIT_ID
having count(*) > 1


