
  
    

        create or replace transient table EIO_INGEST.EWS_ENRICHED_SOURCE_INGEST.ews_enriched_test_test  as
        (/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/




select
 $1:eval_date::DATE AS eval_date,$1:model_train_date::TEXT AS model_train_date,$1:t_minus::TEXT AS t_minus,$1:asset_sub_end_month::NUMBER(38, 0) AS asset_sub_end_month,$1:load_date::DATE AS load_date,$1:sfdc_opportunity_id::TEXT AS sfdc_opportunity_id,$1:account_uuid::TEXT AS account_uuid,$1:prediction::REAL AS prediction,$1:asset_sub_end_year::NUMBER(38, 0) AS asset_sub_end_year,$1:cur_price::REAL AS cur_price
from EIO_INGEST.s3_ingest_test.ews_enriched_test
        );
      
  