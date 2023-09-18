
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.project_details_enhanced
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with mv as (select 
            PLANNED_END_DATE,
            CSMLEAD,
            CS_DATE_ENGAGEMENT_SURVEY_SENT,
            GEODELIVERY,
            GOVPMDOC_DELIVERY_MANAGER,
            AC_PROJGOVERNANCE,
            PROJHEALTH_CUSTOMER,
            PROJHEALTH_OVERALL,
            PROJHEALTH_QUALITY,
            PROJHEALTH_RESOURCE,
            PROJHEALTH_SCHEDULE,
            TIMECATEGORY,
            ACCOUNTINGCONTRACTTYPE,
            REVRECTREATMENT,
            AC_SE_NAME1,
            TENROXTRACKINGNO,
            AC_SE_NAME2,
            PACKAGED_OFFERINGS,
            GS_SERVICELINE,
            GS_SERVICELINE_PROJECTTYPE,
            MARGINVARIANCEDESCRIPTION,
            ROWNUMBER,
            PORTFOLIOMANAGER,
            PROJECTMANAGERNAME,
            WASNEWTABLE,
            CUSTOMERNAME,
            GEO,
            PROJECTMANAGERGEO,
            GEO2,
            PORTFOLIONAME,
            EAC_COST,
            PRIORFYCOST,
            PROJECTCURRENCY,
            PROJECTNAME,
            INITIALWORKDATE,
            PROJECTCODE,
            PROJECTSTARTDATE,
            PROJECTENDDATE,
            MARGINVARIANCECATEGORY,
            ACCONTRACTTYPE,
            HRS_EAC,
            PROJECTMANAGEREEID,
            PROJECTTYPE,
            PLANHOURS,
            EAC_REVENUE,
            FINALWORKDATE,
            PLANCOST,
            DISPLAYEDCURRENCY,
            HRS_BOOKED,
            SQLSCRIPTVERSION,
            GS_SERVICELINE_PRIMARYPRODUCT,
            PROJECTID,
            PLANREVENUE,
            HRS_ETC,
            PROJECTSTATE,
            GS_SERVICELINE_SUB_INDUSTRY,
            cast(ESCALATION_REASON as string)  as ESCALATION_REASON,
            cast(ESCALATION_STATUSANDACTION as string) as  ESCALATION_STATUSANDACTION
            from EIO_PUBLISH.TENROX_PRIVATE.CUST_ADSK_MARGINVARIANCE ),
-- project details dataset
pj1 as (select project_id,
        pa_sco_expense_credits,
        pa_sco_labor_credits,
        master_agreement_id,
        master_agreement_nm,
        pa_master_credits_purchased,
        pa_master_contract_dt,
        pa_sco_contract_dt,
        sfdc_opp_num,pa_sco_labor_credits + pa_sco_expense_credits as pa_sco_total_credits
        from EIO_PUBLISH.TENROX_PRIVATE.CUST_ADSK_SERVICESIMPACT_PROJECTDETAILS ) ,
pj2 as (
     select *
     from pj1 p
     left join mv m
           on p.project_id = m.projectid),
 pj3 as (select * ,
         iff(hrs_eac = 0, 0, (hrs_booked/hrs_eac)) as percent_complete,
         pa_sco_total_credits * percent_complete as pa_sco_credits_consumed,
         iff((pa_master_credits_purchased = 0 or pa_master_credits_purchased is null ),
         0,(planrevenue/pa_master_credits_purchased)) as pa_value
         from pj2),
mp as (select
       project_id,
       MASTER_AGREEMENT_NM,
       master_agreement_id,
       pa_master_contract_dt
       from pj3
       where PROJECTTYPE = 'Master'),
consulting_master_list as (
SELECT
    current_date as dt
    , s.sfdc_id as ultimate_parent_account_id
    , REPLACE(ulpa.site_name,'|', '') as ultimate_parent_account_name
    , s.account_csn as ultimate_parent_account_csn
    , ulpc.id as ultimate_parent_eca_id
    , ulpc.name as ultimate_parent_eca_name
    , ulpc.status__c as ultimate_parent_eca_status
    , t.sfdc_id as account_id
    , REPLACE(a.site_name,'|', '') as account_name
    , t.account_csn as account_csn
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
 from
ADP_PUBLISH.ACCOUNT_OPTIMIZED.TRANSACTIONAL_CSN_MAPPING_OPTIMIZED t
join ADP_PUBLISH.ACCOUNT_OPTIMIZED.ACCOUNT_EDP_OPTIMIZED a
on a.SITE_UUID_CSN = t.SITE_UUID_CSN
  
JOIN BSD_PUBLISH.SFDC_SHARED.END_CUSTOMER_CONTRACTS__C c 
    ON (t.sfdc_id = c.account__c)
JOIN BSD_PUBLISH.SFDC_SHARED.CONTRACT_EXHIBIT__C e 
    ON (c.id = e.end_customer_contracts__c)
JOIN BSD_PUBLISH.SFDC_SHARED.END_CUSTOMER_CONTRACTS__C ulpc
    ON (ulpc.id = c.ultimate_parent_eca__c)
join  ADP_PUBLISH.ACCOUNT_OPTIMIZED.TRANSACTIONAL_CSN_MAPPING_OPTIMIZED s
    on s.sfdc_id = ulpc.account__c
join ADP_PUBLISH.ACCOUNT_OPTIMIZED.ACCOUNT_EDP_OPTIMIZED ulpa
     on ulpa.SITE_UUID_CSN = s.SITE_UUID_CSN
       
left join (
        SELECT
            t.sfdc_id AS account_id
            , a.site_name AS account_name
            , t.account_csn  AS account_csn
        FROM ADP_PUBLISH.ACCOUNT_OPTIMIZED.TRANSACTIONAL_CSN_MAPPING_OPTIMIZED t
        join ADP_PUBLISH.ACCOUNT_OPTIMIZED.ACCOUNT_EDP_OPTIMIZED a
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
),
  
project_enhanced as ( select m.*, cl.ultimate_parent_eca_name,cl.ultimate_parent_eca_id,cl.eba_analytics_name_key,
                     cl.exhibit_name,cl.exhibit_active_status,cl.exhibit_id,cl.agreement_id,cl.account_name,cl.agreement_name,
                     cl.exhibit_start_date,cl.exhibit_end_date
                     from mp m left join consulting_master_list cl
                        ON (cl.AGREEMENT_NAME = RTRIM(m.master_agreement_id)
                          AND (cl.exhibit_start_date <= date(m.pa_master_contract_dt))
                          AND (cl.exhibit_end_date >= date(m.pa_master_contract_dt)))
             ),
 
proj_not_null as (select p.*,
                  pe.ultimate_parent_eca_name,
                  pe.ultimate_parent_eca_id,
                  pe.eba_analytics_name_key,
                  pe.exhibit_name,
                  pe.exhibit_active_status,
                  pe.exhibit_id,
                  pe.agreement_id,
                  pe.account_name,
                  pe.agreement_name,
                  pe.exhibit_start_date,
                  pe.exhibit_end_date
                  from pj3 p
                  left join project_enhanced pe
                  on p.MASTER_AGREEMENT_NM = pe.MASTER_AGREEMENT_NM
                  where
                  p.master_agreement_nm is not null),
proj_null as (select *
              from pj3 p
              where p.master_agreement_nm is null),
proj_concat as (
            select nn.*
            from proj_not_null nn
            union all
            select n.*,
            NULL as ULTIMATE_PARENT_ECA_NAME,
            NULL as ULTIMATE_PARENT_ECA_ID,
            NULL as EBA_ANALYTICS_NAME_KEY,
            NULL as EXHIBIT_NAME,
            NULL as EXHIBIT_ACTIVE_STATUS,
            NULL as EXHIBIT_ID,
            NULL as AGREEMENT_ID,
            NULL as ACCOUNT_NAME,
            NULL as AGREEMENT_NAME,
            NULL as EXHIBIT_START_DATE,
            NULL as EXHIBIT_END_DATE
              from proj_null n
),
proj_de_cte AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY PROJECT_ID order by project_id) rn
    FROM proj_concat
)

select 
PROJECT_ID,
PA_SCO_EXPENSE_CREDITS,
PA_SCO_LABOR_CREDITS,
MASTER_AGREEMENT_ID,
MASTER_AGREEMENT_NM,
PA_MASTER_CREDITS_PURCHASED,
PA_MASTER_CONTRACT_DT,
PA_SCO_CONTRACT_DT,
SFDC_OPP_NUM,
PA_SCO_TOTAL_CREDITS,
PLANNED_END_DATE,
CSMLEAD,
CS_DATE_ENGAGEMENT_SURVEY_SENT,
GEODELIVERY,
GOVPMDOC_DELIVERY_MANAGER,
AC_PROJGOVERNANCE,
PROJHEALTH_CUSTOMER,
PROJHEALTH_OVERALL,
PROJHEALTH_QUALITY,
PROJHEALTH_RESOURCE,
PROJHEALTH_SCHEDULE,
TIMECATEGORY,
ACCOUNTINGCONTRACTTYPE,
REVRECTREATMENT,
AC_SE_NAME1,
TENROXTRACKINGNO,
AC_SE_NAME2,
PACKAGED_OFFERINGS,
GS_SERVICELINE,
GS_SERVICELINE_PROJECTTYPE,
MARGINVARIANCEDESCRIPTION,
ROWNUMBER,
PORTFOLIOMANAGER,
PROJECTMANAGERNAME,
WASNEWTABLE,
CUSTOMERNAME,
GEO,
PROJECTMANAGERGEO,
GEO2,
PORTFOLIONAME,
EAC_COST,
PRIORFYCOST,
PROJECTCURRENCY,
PROJECTNAME,
INITIALWORKDATE,
PROJECTCODE,
PROJECTSTARTDATE,
PROJECTENDDATE,
MARGINVARIANCECATEGORY,
ACCONTRACTTYPE,
HRS_EAC,
PROJECTMANAGEREEID,
PROJECTTYPE,
PLANHOURS,
EAC_REVENUE,
FINALWORKDATE,
PLANCOST,
DISPLAYEDCURRENCY,
HRS_BOOKED,
SQLSCRIPTVERSION,
GS_SERVICELINE_PRIMARYPRODUCT,
PLANREVENUE,
HRS_ETC,
PROJECTSTATE,
GS_SERVICELINE_SUB_INDUSTRY,
ESCALATION_REASON,
ESCALATION_STATUSANDACTION,
PERCENT_COMPLETE,
PA_SCO_CREDITS_CONSUMED,
PA_VALUE,
ULTIMATE_PARENT_ECA_NAME,
ULTIMATE_PARENT_ECA_ID,
EBA_ANALYTICS_NAME_KEY,
EXHIBIT_NAME,
EXHIBIT_ACTIVE_STATUS,
EXHIBIT_ID,
AGREEMENT_ID,
ACCOUNT_NAME,
AGREEMENT_NAME,
EXHIBIT_START_DATE,
EXHIBIT_END_DATE
FROM proj_de_cte
WHERE rn = 1
  );

