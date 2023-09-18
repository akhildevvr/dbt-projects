/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



SELECT
    current_date
    , ulpa.id
    , REPLACE(ulpa.name,'|', '')
    , ulpa.account_csn__c
    , ulpc.id
    , ulpc.name
    , ulpc.status__c
    , a.id
    , REPLACE(a.name,'|', '')
    , a.account_csn__c
    , ulpc.colloquial_name__c
    , CASE
          WHEN a.industry_segment__c = 'Auto & Transportation'
          THEN 'AUTO' ELSE a.parent_industry_group_summary__c
          END
    , a.industry_segment__c
    , CASE
          WHEN a.named_account_group__c is NULL THEN 'Territory'
          ELSE a.named_account_group__c END
    , a.country__c
    , CASE
          WHEN a.country__c = 'Japan' THEN 'JAPN'
          WHEN a.geo__c = 'Americas' THEN 'AMER'
          ELSE a.geo__c END
    , coalesce(ap.account_id,a.id)
    , coalesce(ap.account_name,a.name)
    , coalesce(ap.account_csn,a.account_csn__c)
    , c.id
    , c.name
    , c.status__c
    , c.agreemen_type__c
    , c.csn__c
    , e.id
    , e.name
    , CAST(e.active__c AS number)
    , e.start_date__c
    , e.end_date__c
    , e.type__c
    , e.reporting_platform__c
    , ulpc.customer_agreement_type__c
    , ulpc.customer_segmentation__c
    , c.global_agreement__c
    , CASE 
        -- Exception for Daiwa House Flexera agreements:
        -- all Daiwa House Flexera agreements must have 
        -- use Ultimate Parent ECA ID and suffix "_flexera"
        WHEN c.name IN ('JP16G-0007', 'JP18TF0012', 'JP20TFP010','JP22TFP012')
            THEN CONCAT(ulpc.id, '_flexera')

        -- Exception for Daiwa House Flexera agreements:
        -- Daiwa House CORE #1 agreements must have 
        -- use Ultimate Parent ECA ID and suffix "core_01"
        WHEN c.name IN ('JP17TF0005','JP18TF0015', 'JP20TFP011','JP22TFP013')
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

    END
    , CASE 
        -- Exception for Daiwa House Flexera agreements:
        -- all Daiwa House Flexera agreements must have 
        -- use Ultimate Parent ECA Name and suffix "_flexera"
        WHEN c.name IN ('JP16G-0007', 'JP18TF0012', 'JP20TFP010','JP22TFP012')
            THEN CONCAT(ulpc.name, '_flexera')

        -- Exception for Daiwa House Flexera agreements:
        -- Daiwa House CORE #1 agreements must have 
        -- use Ultimate Parent ECA Name and suffix "core_01"
        WHEN c.name IN ('JP17TF0005','JP18TF0015', 'JP20TFP011','JP22TFP013')
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

    End
    , e.X3RD_PARTY_ACCESS__C

FROM
    "BSD_PUBLISH"."SFDC_SHARED"."ACCOUNT" a
    JOIN "BSD_PUBLISH"."SFDC_SHARED"."END_CUSTOMER_CONTRACTS__C" c 
        ON (a.id = c.account__c)
    JOIN "BSD_PUBLISH"."SFDC_SHARED"."CONTRACT_EXHIBIT__C" e 
        ON (c.id = e.end_customer_contracts__c)
    JOIN "BSD_PUBLISH"."SFDC_SHARED"."END_CUSTOMER_CONTRACTS__C" ulpc 
        ON (ulpc.id = c.ultimate_parent_eca__c)
    JOIN "BSD_PUBLISH"."SFDC_SHARED"."ACCOUNT" ulpa 
        ON (ulpa.id = ulpc.account__c)
    LEFT JOIN (
        SELECT
            a.id AS account_id
            , a.name AS account_name
            , a.parentid AS parent_account_id
            , a.account_csn__c AS account_csn
        FROM "BSD_PUBLISH"."SFDC_SHARED"."ACCOUNT" a
        WHERE
            a.isdeleted = false
        ) ap ON (a.parentid = ap.account_id)
WHERE
    a.isdeleted = false
    AND c.isdeleted = false
    AND e.isdeleted = false

    -- filter out Bechtel Exception
    AND e.name <> 'EX-050728'

    -- filter out Autodesk Test Agreements
    AND NOT CONTAINS(LOWER(c.name), 'test')

    -- filter out  invalid agreements
    AND length(c.name) <= 11 

    -- Autodesk  Agreements
    AND NOT CONTAINS(LOWER(coalesce(ap.account_name,a.name)), 'autodesk')
   


ORDER BY ulpa.name;