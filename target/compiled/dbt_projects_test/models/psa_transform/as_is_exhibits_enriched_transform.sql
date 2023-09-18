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
    -- Account Details
   t.sfdc_id as account_id
    , REPLACE(a.site_name,'|', '') as account_name
    ,CASE
     	WHEN a.site_industry_segment = 'Auto & Transportation' THEN 'AUTO' 
		ELSE a.site_industry_group END AS account_industry
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
    ,case  when EXHIBIT_TYPE = 'Consulting Advisory Service' then  1 else 0 end as  AS_Flag
    ,concat('https://autodesk.lightning.force.com/lightning/r/Service_Engagement__c/' , EXHIBIT_ID , '/view') as Exhibit_URL
    ,case when EXHIBIT_TYPE ='Consulting Advisory Service' then 'AS' 
         when EXHIBIT_TYPE ='Consulting Implementation Services' then 'IS'
    end as  Exhibit_Type_AS_IS 
FROM
 TRANSACTIONAL_CSN_MAPPING t
JOIN ACCOUNT_EDP a
     ON a.SITE_UUID_CSN = t.SITE_UUID_CSN 
JOIN END_CUSTOMER_CONTRACTS c 
    ON (c.account__c = t.sfdc_id)
JOIN   CONTRACT_EXHIBIT__C e

        ON (e.end_customer_contracts__c = c.id)
  
WHERE
    c.isdeleted = false
    AND e.isdeleted = false


    AND c.status__c = 'Active'
    AND e.active__c = True
    AND c.agreemen_type__c in ('Purchasing & Services Agreement', 'Consulting Agreement')
    AND e.type__c in ('Consulting Implementation Services', 'Consulting Advisory Service')