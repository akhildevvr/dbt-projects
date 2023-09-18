
    
    

select
    SERVICE_PURCHASE_ID as unique_field,
    count(*) as n_records

from EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_service_purchase_enriched
where SERVICE_PURCHASE_ID is not null
group by SERVICE_PURCHASE_ID
having count(*) > 1


