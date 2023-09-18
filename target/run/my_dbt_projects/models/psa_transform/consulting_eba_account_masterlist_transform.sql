
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.consulting_eba_account
  
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
)
SELECT
    current_date as dt
    , s.sfdc_id as ultimate_parent_account_id
    , REPLACE(ulpa.site_name,'|', '') as ultimate_parent_account_name
    , s.account_csn as ultimate_parent_account_csn
    , ulpc.id as ultimate_parent_eca_id
    , ulpc.name as ultimate_parent_eca_name
    , ulpc.status__c as ultimate_parent_eca_status
    , t.sfdc_id as account_id
    , t.account_csn as account_csn
    , REPLACE(a.site_name,'|', '') as account_name
    , ulpc.colloquial_name__c as colloquial_name
    , CASE
          WHEN a.site_industry_group = 'Auto & Transportation'
          THEN 'AUTO'
          END as industry
    , a.site_industry_segment as industry_segment
    , CASE
          WHEN  a.site_named_account_group_static is NULL THEN 'Territory'
          ELSE  a.site_named_account_group_static END as named_account_group
    , a.site_country_name as account_country
    , CASE
          WHEN a.site_country_name = 'Japan' THEN 'JAPN'
          WHEN a.site_geo = 'Americas' THEN 'AMER'
          ELSE a.site_geo END as account_geo
    , coalesce(ap.account_id,t.sfdc_id) as parent_account_id
    , coalesce(ap.account_name,a.site_name) as parent_account_name
    , coalesce(ap.account_csn,t.account_csn) as parent_account_csn
    , c.id as agreement_id
    , c.name as agreement_name
    , c.status__c as agreement_status
    , c.agreemen_type__c as agreement_type
    , c.csn__c as account_csn_on_agreement_record
    , e.id as exhibit_id
    , e.name as exhibit_name
    , CAST(e.active__c AS number) as exhibit_active_status
    , e.start_date__c as exhibit_start_date
    , e.end_date__c as exhibit_end_date
    , e.type__c as exhibit_type
    , e.reporting_platform__c as tflex_reporting_platform
    , ulpc.customer_agreement_type__c as eba_agreement_type
    , ulpc.customer_segmentation__c as eba_segmentation
    , c.global_agreement__c as global_agreement
    , CASE
        -- Exception for Daiwa House Flexera agreements:
        -- all Daiwa House Flexera agreements must have
        -- use Ultimate Parent ECA ID and suffix "_flexera"
        WHEN c.name IN ('JP16G-0007', 'JP18TF0012', 'JP20TFP010')
            THEN CONCAT(ulpc.id, '_flexera')
 
        -- Exception for Daiwa House Flexera agreements:
        -- Daiwa House CORE #1 agreements must have
        -- use Ultimate Parent ECA ID and suffix "core_01"
        WHEN c.name IN ('JP17TF0005','JP18TF0015', 'JP20TFP011')
            THEN CONCAT(ulpc.id, '_core_01')
 
        -- Exception for Vinci Eurovia:
        -- use specific Ultimate Parent ECA ID
        WHEN c.name  = 'FR21TFP009'
            THEN 'a3Y3g000000PC29EAG'
 
        -- Exception for FMC TECHNOLOGIES INC (TECHNIP second active EBA):
        -- use Ultimate Parent ECA Name and Agreement Name
        WHEN c.name  = 'US21TFP011'
            THEN CONCAT(ulpc.id,'_',c.id)
 
        -- For the rest of agreements Ultimate Parent ECA ID
        ELSE ulpc.id
 
     END as eba_analytics_id_key
    , CASE
        -- Exception for Daiwa House Flexera agreements:
        -- all Daiwa House Flexera agreements must have
        -- use Ultimate Parent ECA Name and suffix "_flexera"
        WHEN c.name IN ('JP16G-0007', 'JP18TF0012', 'JP20TFP010')
            THEN CONCAT(ulpc.name, '_flexera')
 
        -- Exception for Daiwa House Flexera agreements:
        -- Daiwa House CORE #1 agreements must have
        -- use Ultimate Parent ECA Name and suffix "core_01"
        WHEN c.name IN ('JP17TF0005','JP18TF0015', 'JP20TFP011')
            THEN CONCAT(ulpc.name, '_core_01')
 
        -- Exception for Vinci Eurovia:
        -- use specific Ultimate Parent ECA Name
        WHEN c.name  = 'FR21TFP009'
            THEN 'ECA-5101665300'
 
        -- Exception for FMC TECHNOLOGIES INC (TECHNIP second active EBA):
        -- use Ultimate Parent ECA Name and Agreement Name
        WHEN c.name  = 'US21TFP011'
            THEN CONCAT(ulpc.name,'_',c.name)
 
        -- For the rest of agreements use Ultimate Parent ECA Name
        ELSE ulpc.name
END as eba_analytics_name_key
FROM
TRANSACTIONAL_CSN_MAPPING t
JOIN ACCOUNT_EDP a
ON a.SITE_UUID_CSN = t.SITE_UUID_CSN
  
JOIN END_CUSTOMER_CONTRACTS c 
    ON (t.sfdc_id = c.account__c)
JOIN CONTRACT_EXHIBIT__C e 
    ON (c.id = e.end_customer_contracts__c)
JOIN END_CUSTOMER_CONTRACTS ulpc
    ON (ulpc.id = c.ultimate_parent_eca__c)
join  TRANSACTIONAL_CSN_MAPPING s
    on s.sfdc_id = ulpc.account__c
join ACCOUNT_EDP ulpa
     on ulpa.SITE_UUID_CSN = s.SITE_UUID_CSN
       
left join (
        SELECT
            t.sfdc_id AS account_id
            , a.site_name AS account_name
            , t.account_csn  AS account_csn
        FROM TRANSACTIONAL_CSN_MAPPING t
        join ACCOUNT_EDP a
              on a.SITE_UUID_CSN = t.SITE_UUID_CSN
        ) ap ON (a.CORPORATE_PARENT_CSN_STATIC = ap.account_csn)
          
WHERE
     c.isdeleted = false
    AND e.isdeleted = false
  
    -- filter out Bechtel Exception
    AND e.name <> 'EX-050728'
  
    -- filter out Autodesk Test Agreements
    AND NOT CONTAINS(LOWER(c.name), 'test')
  
    -- filter out  invalid agreements
    AND length(c.name) <= 11
      
  
    -- Autodesk  Agreements
    AND NOT CONTAINS(LOWER(coalesce(ap.account_name,a.site_name)), 'autodesk')
 
    AND c.agreemen_type__c = 'Purchasing & Services Agreement'
    AND c.status__c IN ('Active','Terminated/Expired')
    AND e.type__c IN ('Consulting','Consulting Implementation Services','Consulting Advisory Service')
  );

