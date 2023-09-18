
  
    

        create or replace transient table EIO_INGEST.S3_INGEST_TEST.customer_segmentation_predictions_test  as
        (/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



select
 $1:fiscal_quarter_name::TEXT AS fiscal_quarter_name,$1:fiscal_quarter_end_date::DATE AS fiscal_quarter_end_date,$1:parent_csn::TEXT AS parent_csn,$1:growth_potential_band::TEXT AS growth_potential_band,$1:growth_potential_confidence_desc::TEXT AS growth_potential_confidence_desc,$1:account_segment::TEXT AS account_segment,$1:aov_band::TEXT AS aov_band,$1:aov_snapshot_date::DATE AS aov_snapshot_date,$1:model_version::TEXT AS model_version,$1:load_date::DATE AS load_date
from EIO_INGEST.s3_ingest_test.customer_segmentation_predictions_test
        );
      
  