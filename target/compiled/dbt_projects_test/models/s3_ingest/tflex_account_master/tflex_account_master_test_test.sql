/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



select
 $1:account_geo::TEXT AS account_geo,$1:parent_account_id::TEXT AS parent_account_id,$1:parent_account_name::TEXT AS parent_account_name,$1:parent_account_csn::TEXT AS parent_account_csn,$1:exhibit_id::TEXT AS exhibit_id,$1:exhibit_name::TEXT AS exhibit_name,$1:exhibit_active_status::BOOLEAN AS exhibit_active_status,$1:exhibit_start_date::DATE AS exhibit_start_date,$1:colloquial_name::TEXT AS colloquial_name,$1:industry::TEXT AS industry,$1:industry_segment::TEXT AS industry_segment,$1:named_account_group::TEXT AS named_account_group,$1:account_country::TEXT AS account_country,$1:ultimate_parent_eca_status::TEXT AS ultimate_parent_eca_status,$1:account_id::TEXT AS account_id,$1:account_name::TEXT AS account_name,$1:account_csn::TEXT AS account_csn,$1:ultimate_parent_account_id::TEXT AS ultimate_parent_account_id,$1:ultimate_parent_account_name::TEXT AS ultimate_parent_account_name,$1:ultimate_parent_account_csn::TEXT AS ultimate_parent_account_csn,$1:ultimate_parent_eca_id::TEXT AS ultimate_parent_eca_id,$1:ultimate_parent_eca_name::TEXT AS ultimate_parent_eca_name,$1:exhibit_end_date::DATE AS exhibit_end_date,$1:exhibit_type::TEXT AS exhibit_type,$1:tflex_reporting_platform::TEXT AS tflex_reporting_platform,$1:eba_agreement_type::TEXT AS eba_agreement_type,$1:eba_segmentation::TEXT AS eba_segmentation,$1:global_agreement::BOOLEAN AS global_agreement,$1:dt::TEXT AS dt,$1:eba_analytics_id_key::TEXT AS eba_analytics_id_key,$1:eba_analytics_name_key::TEXT AS eba_analytics_name_key,$1:agreement_id::TEXT AS agreement_id,$1:agreement_name::TEXT AS agreement_name,$1:agreement_status::TEXT AS agreement_status,$1:agreement_type::TEXT AS agreement_type,$1:account_csn_on_agreement_record::TEXT AS account_csn_on_agreement_record
from EIO_INGEST.s3_ingest_test.tflex_account_master_test