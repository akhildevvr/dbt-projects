
  
    

        create or replace transient table eio_publish.tenrox_private.adsk_fn_cm_project_budget_v02  as
        (

select * from eio_ingest.tenrox_transform.adsk_fn_cm_project_budget_v02
        );
      
  