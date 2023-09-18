
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_service_engagements
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with TRANSACTIONAL_CSN_MAPPING as 
(
    SELECT 
    *
    FROM
    ADP_PUBLISH.ACCOUNT_OPTIMIZED.TRANSACTIONAL_CSN_MAPPING_OPTIMIZED
),
ACCOUNT_EDP AS 
(
    SELECT 
    *
    FROM
   ADP_PUBLISH.ACCOUNT_OPTIMIZED.ACCOUNT_EDP_OPTIMIZED
),

END_CUSTOMER_CONTRACTS AS (
    SELECT
    *
    FROM
    BSD_PUBLISH.SFDC_SHARED.END_CUSTOMER_CONTRACTS__C
),
CONTRACT_EXHIBIT__C AS (
    SELECT
    *
    FROM
    BSD_PUBLISH.SFDC_SHARED.CONTRACT_EXHIBIT__C
),
SERVICE_ENGAGEMENT__C as (
    SELECT
    *
    FROM
    BSD_PUBLISH.SFDC_SHARED.SERVICE_ENGAGEMENT__C
)


    SELECT
    -- Account Details
    t.sfdc_id as account_id
    , REPLACE(a.site_name,'|', '') as account_name
    -- Agreement Details
    , c.id                                      AS agreement_id
    , c.name                                    AS agreement_name
    , c.agreemen_type__c                        AS agreement_type
    , c.status__c                               AS agreement_status
    -- Exhibit Details
    , e.id                                      AS exhibit_id
    , e.name                                    AS exhibit_name
    , e.type__c                                 AS exhibit_type
    , e.active__c                               AS exhibit_status
    , e.start_date__c                           AS exhibit_start_date
    , e.end_date__c                             AS exhibit_end_date
    -- SE Details
    , se.id                                     AS service_engagement_id
    , se.name                                   AS name
    , se.service_engagement_name__c             AS service_engagement_name
    , se.description__c                         AS description
    , se.status__c                              AS status_name
    , se.sub_status__c                          AS sub_status_name
    , se.tenrox_project_code__c                 AS tenrox_tracking_number
    , seat.sfdc_id                                   AS se_account_id
    , sea.site_name                                  AS se_account_name
    , seat.account_csn                          AS se_account_csn
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
    , se.createddate                            AS created_date
    , se.related_engagement__c                  AS related_engagement
FROM
    SERVICE_ENGAGEMENT__C se
  JOIN   CONTRACT_EXHIBIT__C e
   ON (se.agreement_exhibit__c = e.id)
JOIN END_CUSTOMER_CONTRACTS c 
 ON (e.end_customer_contracts__c = c.id)
 JOIN TRANSACTIONAL_CSN_MAPPING t
 ON (c.account__c = t.sfdc_id)
 JOIN ACCOUNT_EDP a
     ON a.SITE_UUID_CSN = t.SITE_UUID_CSN 
  JOIN TRANSACTIONAL_CSN_MAPPING seat 
  ON (se.account__c = seat.sfdc_id)
  JOIN ACCOUNT_EDP sea 
  ON sea.SITE_UUID_CSN = seat.SITE_UUID_CSN 
WHERE
    c.isdeleted = false
    AND e.isdeleted = false
    AND se.isdeleted = false
    AND c.status__c = 'Active'
    AND e.active__c = True
    AND c.agreemen_type__c in ('Purchasing & Services Agreement', 'Consulting Agreement')
    AND e.type__c in ('Consulting Implementation Services', 'Consulting Advisory Service')
    AND se.contract_type__c in ('Enterprise Business Agreement (EBA)', 'Change Order - AS/IS',
     'Customer Service Order (CSO)', 'Customer Task Order (CTO)')
    AND se.status__c in ('Delivery', 'Closed Out')
    AND se.tenrox_project_code__c <> ''
ORDER BY account_name
  );

