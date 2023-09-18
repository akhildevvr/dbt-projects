
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.service_engagement_details
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



SELECT
  a.id                                        AS account_id
  , a.name                                    AS account_name
  , a.account_csn__c                          AS account_csn
  , se.id                                     AS service_engagement_id
  , se.name                                   AS name
  , se.service_engagement_name__c             AS service_engagement_name
  , se.description__c                         AS description
  , se.status__c                              AS stage_name
  , se.sub_status__c                          AS sub_stage_name
  , se.end_customer_agreement_name__c         AS agreement_name
  , se.end_customer_agreement__c              AS agreement_id
  , se.agreement_exhibit_name__c              AS exhibit_name
  , se.agreement_exhibit__c                   AS exhibit_id
  , se.tenrox_project_code__c                 AS tenrox_tracking_number
  , se.close_date__c                          AS close_date
  , se.target_start_date__c                   AS target_start_date
  , se.target_end_date__c                     AS target_end_date
  , se.contract_type__c                       AS contract_type
  , se.csp_required__c                        AS csp_required
  , se.currencyisocode                        AS currencyisocode
  , se.delivery_geo__c                        AS delivery_geo
  , se.delivery_language__c                   AS delivery_language
  , se.high_level_business_scope__c           AS high_level_business_scope
  , se.hours__c                               AS hours
  , se.production_assurance_credits_pac__c    AS production_assurance_credits_pac
  , se.total_amount__c                        AS total_amount
  , se.opportunity__c                         AS opportunity
  , se.ownerid                                AS ownerid
  , se.primary_product_name__c                AS primary_product_name
  , se.primary_product__c                     AS primary_product
  , se.recordtypeid                           AS recordtypeid
  , se.service_catalog_id__c                  AS service_catalog_id
  , se.service_line__c                        AS service_line
  , se.service_type__c                        AS service_type
  , se.work_at_risk__c                        AS work_at_risk
  , se.Credit_Type__c                         AS credit_type
  , se.createddate                            AS created_date
FROM
  BSD_PUBLISH.SFDC_SHARED.SERVICE_ENGAGEMENT__C se
  LEFT JOIN BSD_PUBLISH.SFDC_SHARED.ACCOUNT a ON (se.account__c = a.id)
WHERE
  se.isdeleted = false  AND  tenrox_tracking_number is null  and stage_name in ('Qualification','Identification','Solution Proposal','On Hold') AND close_date is not null
ORDER BY service_engagement_id
  );

