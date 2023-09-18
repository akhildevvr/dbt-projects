
        COPY INTO ews_enriched_s3_ingest_source.ews_enriched
        FROM (
            

select
  $1:account_uuid::string as account_uuid,
  $1:sfdc_opportunity_id::string as sfdc_opportunity_id
from 
    @ews_enriched_stage

	
		
        )
	FILE_FORMAT=(TYPE=PARQUET)
        on_error = CONTINUE
    