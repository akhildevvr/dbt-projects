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
SERVICES_PURCHASE_DETAIL as (
    SELECT
    *
    FROM
    BSD_PUBLISH.SFDC_SHARED.SERVICES_PURCHASE_DETAIL__C
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
    -- Service Purchase Details
    , sp.id                                     AS service_purchase_id
    , sp.name                                   AS name
    , sp.createddate                            AS created_date
    , sp.purchase_date__c                       AS purchase_date
    , sp.expiration_date__c                     AS expiration_date
    , sp.stand_alone__c                         AS stand_alone
    , sp.comments__c                            AS comments
    , sp.currencyisocode                        AS currencyisocode
    , sp.credit_quantity__c                     AS credit_quantity
    , sp.credit_value__c                        AS credit_value
    , sp.credits_expired__c                     AS credits_expired
    , sp.total_amount__c                        AS total_amount
    , sp.extension_credits_value__c             AS extension_credits_value
    , sp.extension_credits__c                   AS extension_credits
    FROM
       SERVICES_PURCHASE_DETAIL sp
     JOIN   CONTRACT_EXHIBIT__C e
   ON (sp.agreement_exhibit__c = e.id)
JOIN END_CUSTOMER_CONTRACTS c 
 ON (e.end_customer_contracts__c = c.id)
 JOIN TRANSACTIONAL_CSN_MAPPING t
 ON (c.account__c = t.sfdc_id)
 JOIN ACCOUNT_EDP a
     ON a.SITE_UUID_CSN = t.SITE_UUID_CSN 
WHERE
    c.isdeleted = false
    AND e.isdeleted = false
    AND sp.isdeleted = false

    AND c.status__c = 'Active'
    AND e.active__c = True
    AND c.agreemen_type__c in ('Purchasing & Services Agreement', 'Consulting Agreement')
    AND e.type__c in ('Consulting Implementation Services', 'Consulting Advisory Service')