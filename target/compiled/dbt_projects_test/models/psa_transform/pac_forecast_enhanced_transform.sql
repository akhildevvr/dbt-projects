/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with pac_forecast_input as (

SELECT
              opportunity_id
              ,geo
              ,sales_region
              ,opportunity_number
              ,stage_name
              ,forecast_category_name
              ,forecast_category
              ,projected_fiscal_year
              ,projected_fiscal_quarter
              ,opportunity_name
              ,sfdc_account_id
              ,account_name
              ,opportunity_owner
              ,cs_service_line
              ,contract_type
              ,ac_close_date
              ,ac_forecast_category
              ,close_date
              ,currency_iso_code
              ,ac_total_amount
              ,parent_opportunity_id
              ,parent_opportunity_number
              ,parent_stage_name
              ,parent_forecast_category
              ,parent_opportunity_name
              ,parent_account_id
              ,sco_pa_credits__c
from EIO_INGEST.ENGAGEMENT_TRANSFORM.pac_forecast ), 
 
pac_forecast_supplementary as (
  select Opportunity_Number
            ,CS_SERVICE_LINE
            ,CS_PRIMARY_PRODUCT
            ,PA_CREDIT_VALUE_CONVERTED_CURRENCY
            ,PA_CREDIT_VALUE_CONVERTED_
            ,AC_DELIVERY_GEO
            ,CS_PROJECT_TYPE_L_1
            ,CS_PROJECT_TYPE_L_2
            ,CS_SOLUTION_PRODUCT
            ,PACKAGE_OFFERING 
  from EIO_INGEST.ENGAGEMENT_SHAREPOINT.PACFORECAST_SUPPLEMENTARY
   
 )
  
 select  pfi.* 
            ,pfs.CS_PRIMARY_PRODUCT
            ,pfs.PA_CREDIT_VALUE_CONVERTED_CURRENCY
            ,pfs.PA_CREDIT_VALUE_CONVERTED_
            ,pfs.AC_DELIVERY_GEO
            ,pfs.CS_PROJECT_TYPE_L_1
            ,pfs.CS_PROJECT_TYPE_L_2
            ,pfs.CS_SOLUTION_PRODUCT
            ,pfs.PACKAGE_OFFERING 
from pac_forecast_input pfi 
left join pac_forecast_supplementary pfs 
on pfi.opportunity_number = pfs.opportunity_number