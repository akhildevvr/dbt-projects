
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.pac_forecast
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



SELECT
              o.id as opportunity_id
              ,o.end_customer_geo__c as geo
              ,o.sales_region__c as sales_region
              ,o.opportunity_number__c as opportunity_number
              ,o.stagename as stage_name
              ,o.forecastcategoryname as forecast_category_name
              ,o.forecastcategory as forecast_category
              ,o.projected_fiscal_year__c as projected_fiscal_year
              ,o.projected_fiscal_quarter__c as projected_fiscal_quarter
              ,o.opportunity_name as opportunity_name
              ,o.accountid as sfdc_account_id
              ,a.account_name as account_name
              ,u.opportunity_owner as opportunity_owner
              ,o.ac_solution_type__c as cs_service_line
              ,o.contract_type__c as contract_type
              ,o.ac_close_date__c as ac_close_date
              ,o.ac_forecast_category__c as ac_forecast_category
              ,o.closedate as close_date
              ,o.currencyisocode as currency_iso_code
              ,o.ac_total_amount__c as ac_total_amount
              ,o.parent_opportunity_id__c as parent_opportunity_id
              ,p.parent_opportunity_number as parent_opportunity_number
              ,p.parent_stagename as parent_stage_name
              ,p.parent_forecastcategory as parent_forecast_category
              ,p.parent_opportunity_name as parent_opportunity_name
              ,p.parent_account_id as parent_account_id
              ,o.sco_pa_credits__c
                 
          FROM
               
              (SELECT
                  o.id
                  ,o.end_customer_geo__c
                  ,o.sales_region__c
                  ,o.opportunity_number__c
                  ,o.stagename
                  ,o.forecastcategoryname
                  ,o.forecastcategory
                  ,o.projected_fiscal_year__c
                  ,o.projected_fiscal_quarter__c
                  ,o.name as opportunity_name
                  ,o.accountid
                  ,o.ownerid
                  ,o.ac_solution_type__c
                  ,o.contract_type__c
                  ,o.ac_close_date__c
                  ,o.ac_forecast_category__c
                  ,o.closedate
                  ,o.currencyisocode
                  ,o.ac_total_amount__c
                  ,o.parent_opportunity_id__c
                  ,o.sco_pa_credits__c
                    
              FROM BSD_PUBLISH.SFDC_SHARED.OPPORTUNITY o
 
                   
              WHERE
                  o.isdeleted = false
                  and o.contract_type__c = 'SCO') o
 
          --
          -- Joining the opportunity table to identify parent opportunities 
          --
          LEFT JOIN
              (SELECT
                  o.id as parent_opportunity_id
                  ,o.opportunity_number__c as parent_opportunity_number
                  ,o.stagename as parent_stagename
                  ,o.forecastcategory as parent_forecastcategory
                  ,o.name as parent_opportunity_name
                  ,o.accountid as parent_account_id
              FROM BSD_PUBLISH.SFDC_SHARED.OPPORTUNITY o
 
                  -- Joining the distinct opportunities
                  JOIN
                      (SELECT
                          distinct(parent_opportunity_id__c) as parentid
                          FROM BSD_PUBLISH.SFDC_SHARED.OPPORTUNITY o
 
                               
 
                          WHERE
                            isdeleted = false
                            and contract_type__c = 'SCO') p on o.id = parentid
 
                  
              ) p ON o.parent_opportunity_id__c = p.parent_opportunity_id
           
          
          LEFT JOIN
                 
              (SELECT
                  id
                  ,name as opportunity_owner
              FROM BSD_PUBLISH.SFDC_SHARED.USER u
 
                   
                  JOIN
                      (SELECT
                          distinct(ownerid) as ownerid
                      FROM BSD_PUBLISH.SFDC_SHARED.OPPORTUNITY o
 
                      WHERE
                      isdeleted = false
                      and contract_type__c = 'SCO') t on u.id = t.ownerid
 
                   
 
              ) u ON u.id = o.ownerid
 
          --
          -- Joining the account table to ifentify account names
          --
          LEFT JOIN
                 
              (
              SELECT
                   t.sfdc_id as id
                 , a.site_name as account_name
                 
              FROM ADP_PUBLISH.ACCOUNT_OPTIMIZED.TRANSACTIONAL_CSN_MAPPING_OPTIMIZED t
                   JOIN ADP_PUBLISH.ACCOUNT_OPTIMIZED.ACCOUNT_EDP_OPTIMIZED a
                             on a.SITE_UUID_CSN = t.SITE_UUID_CSN 
                  JOIN
                      (SELECT
                          distinct(accountid) as accountid
                      FROM BSD_PUBLISH.SFDC_SHARED.OPPORTUNITY o
 
                          
 
                      WHERE
                          isdeleted = false
                          and contract_type__c = 'SCO') o on t.sfdc_id = accountid
 
              ) a ON a.id = o.accountid
  );

