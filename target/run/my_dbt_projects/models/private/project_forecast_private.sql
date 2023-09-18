
  
    

        create or replace transient table eio_publish.tenrox_private.project_forecast  as
        (

SELECT
	
    *

FROM 
eio_ingest.tenrox_transform.project_forecast
        );
      
  