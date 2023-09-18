/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/




select
 $1:t_minus::TEXT AS t_minus,$1:account_uuid::TEXT AS account_uuid,$1:eval_date::DATE AS eval_date,$1:sfdc_opportunity_id::TEXT AS sfdc_opportunity_id,$1:asset_sub_end_month::NUMBER(38, 0) AS asset_sub_end_month,$1:load_date::DATE AS load_date,$1:prediction::REAL AS prediction,$1:model_train_date::TEXT AS model_train_date,$1:cur_price::REAL AS cur_price,$1:asset_sub_end_year::NUMBER(38, 0) AS asset_sub_end_year
from EIO_INGEST.S3_INGEST_STAGE.ews_enriched_ext