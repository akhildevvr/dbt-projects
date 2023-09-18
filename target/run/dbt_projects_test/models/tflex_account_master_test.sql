
  
    

        create or replace transient table ADP_WORKSPACES.CUSTOMER_SUCCESS_SHARED.tflex_account_master_test  as
        (/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



copy into EIO_INGEST.S3_INGEST_TEST.tflex_account_master_test
  from @s3_stage
  FILE_FORMAT=(TYPE=PARQUET)
  match_by_column_name = case_insensitive
  on_error = CONTINUE
        );
      
  