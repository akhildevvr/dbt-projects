/*
    -- materialized='ephemeral' transforms this to a CTE that can be referred to by other nodes in the model
*/

{{ 
    config(
        alias='tflex_usage',
        tags=['tflex_usage_transform','pre_publish_models'],
        materialized='ephemeral'
    )
}}


--Import CTE's
WITH tflex_accounts AS (
    SELECT *
    FROM {{ source('purchase_shared', 'eba_contracts')}}
    WHERE 1=1
        AND agreement_type = 'Purchasing & Services Agreement'
        AND agreement_status IN ('Active','Terminated/Expired')
        AND exhibit_type = 'Token-Flex'
),

t_eccr_agg_product_usage_dd AS (
    SELECT *
    FROM {{ source('token_flex_core_public','t_eccr_agg_product_usage_dd') }}
),

t_eccr_agg_product_usage_dd_expired AS (
    SELECT *
    FROM {{ source('token_flex_core_public','t_eccr_agg_product_usage_dd_expired') }}
),

t_eccr_token_adjustments AS (
    SELECT *
    FROM {{ source('token_flex_core_public','t_eccr_token_adjustments') }}
),

t_eccr_product_line AS (
    SELECT *
    FROM {{ source('token_flex_core_public','t_eccr_product_line') }}
),

t_pseb_product_feature AS (
    SELECT *
    FROM {{ source('token_flex_core_public','t_pseb_product_feature') }}
),

t_eccr_service_nm AS (
    SELECT *
    FROM {{ source('token_flex_core_public','t_eccr_service_nm') }}
),

flexera_core_flexdetails AS (
    SELECT *
    FROM {{ source('sales_data_hub_optimized','flexera_core_flexdetails') }}
),

flex_usage AS (
    SELECT *
    FROM {{ source('sales_data_hub_optimized','flex_usage') }}
),

flexera_core_token_adjustment AS (
    SELECT *
    FROM {{ source('sales_data_hub_optimized','flexera_core_token_adjustment') }}
),

-- Transform CTE's
eccr_tokens AS (
    -- TFLEX CORE/NLRS/NLRM Usage Table maintained by the EBSO/CORE Team
    SELECT ud.end_customer_agreement_id
        , ud.agree_nbr
        , ud.user_login_id
        , CASE
            WHEN ud.txn_type_nm IN ('CLOUD_CONSUMPTION','CLOUD_PRODUCT_CONSUMPTION') 
                THEN NULL
            WHEN ud.txn_type_nm = 'PRODUCT_CONSUMPTION' 
                THEN ud.machine_nm
            ELSE 'UNKNOWN'
            END                                AS machine_nm
        , CASE
            WHEN ud.txn_type_nm IN ('CLOUD_CONSUMPTION','CLOUD_PRODUCT_CONSUMPTION') 
                THEN 'Cloud'
            WHEN ud.txn_type_nm = 'PRODUCT_CONSUMPTION' 
                THEN ud.license_server_nm
            ELSE 'UNKNOWN'
            END                                AS license_server_nm
        , DATE(ud.usage_dt)                    AS usage_dt
        , ud.usage_date_key
        , ud.product_line_cd
        , ud.product_feature_id
        , ud.service_category_nm
        , ud.txn_type_nm
        , CASE
            WHEN ud.txn_type_nm = 'CLOUD_CONSUMPTION' THEN '1' 
            WHEN ud.txn_type_nm = 'CLOUD_PRODUCT_CONSUMPTION' THEN '2'
            WHEN ud.txn_type_nm = 'PRODUCT_CONSUMPTION' THEN '5' 
            ELSE '0'
            END                                AS txn_type_id
        , ud.end_customer_agreement_yr_ind
        , NULL AS multi_year_flg
        , ud.txn_units_nbr
        , ud.duration_mns
        , ud.duration_mns / 60              AS duration_hrs
        -- Placeholder fields for adjustments details
        , NULL                              AS charged_item_id
        , NULL                              AS src_created_dt
        , NULL                              AS txn_dt
        , NULL                              AS txn_qty
        , ud.reason_cd
        , NULL                              AS reason_txt
    FROM t_eccr_agg_product_usage_dd ud
    WHERE ud.txn_type_nm  IN ('CLOUD_CONSUMPTION', 'CLOUD_PRODUCT_CONSUMPTION',
            'PRODUCT_CONSUMPTION')
    
    UNION ALL

    -- Union the TFLEX CORE/NLRS Usage Table maintained by the EBSO/CORE Team
    -- for old expired agreements
    SELECT udex.end_customer_agreement_id
            , udex.agree_nbr
            , udex.user_login_id
            , CASE
                WHEN udex.txn_type_nm IN ('CLOUD_CONSUMPTION','CLOUD_PRODUCT_CONSUMPTION') 
                    THEN NULL
                WHEN udex.txn_type_nm IN ('MANUAL_ADJUSTMENT','MANUAL_CONSUMPTION') 
                    THEN NULL
                WHEN udex.txn_type_nm = 'PRODUCT_CONSUMPTION' 
                    THEN udex.machine_nm
                ELSE 'UNKNOWN'
             END                                    AS machine_nm
            , CASE
                WHEN udex.txn_type_nm IN ('CLOUD_CONSUMPTION','CLOUD_PRODUCT_CONSUMPTION') 
                    THEN 'Cloud'
                WHEN udex.txn_type_nm IN ('MANUAL_ADJUSTMENT','MANUAL_CONSUMPTION') 
                    THEN 'Token Adjustment'
                WHEN udex.txn_type_nm = 'PRODUCT_CONSUMPTION' 
                    THEN udex.license_server_nm
                ELSE 'UNKNOWN'
             END                                    AS license_server_nm
            , DATE(udex.usage_dt)                   AS usage_dt
            , udex.usage_date_key
            , udex.product_line_cd
            , udex.product_feature_id
            , udex.service_category_nm
            , udex.txn_type_nm
            , CASE
                WHEN udex.txn_type_nm = 'CLOUD_CONSUMPTION' THEN '1' 
                WHEN udex.txn_type_nm = 'CLOUD_PRODUCT_CONSUMPTION' THEN '2'
                WHEN udex.txn_type_nm = 'MANUAL_ADJUSTMENT' THEN '3'
                WHEN udex.txn_type_nm = 'MANUAL_CONSUMPTION' THEN '4'
                WHEN udex.txn_type_nm = 'PRODUCT_CONSUMPTION' THEN '5'
                ELSE '0' 
             END                                    AS txn_type_id
            , udex.end_customer_agreement_yr_ind
            , NULL   AS multi_year_flg
            , udex.txn_units_nbr
            , udex.duration_mns
            , udex.duration_mns / 60                AS duration_hrs
            -- Placeholder fields for adjustments details
            , NULL                                  AS charged_item_id
            , NULL                                  AS src_created_dt
            , NULL                                  AS txn_dt
            , NULL                                  AS txn_qty
            , udex.reason_cd
            , NULL                                  AS reason_txt
    FROM t_eccr_agg_product_usage_dd_expired udex

    UNION ALL

    -- Union the TFLEX CORE/NLRS Adjustments Table maintained by the EBSO/CORE Team
    -- only for agreements in T_ECCR_AGG_PRODUCT_USAGE_DD table
    SELECT ta.end_customer_agreement_id
            , ta.agree_nbr
            , NULL                                  AS user_login_id
            , NULL                                  AS machine_nm
            , 'Token Adjustment'                    AS license_server_nm
            , DATE(ta.usage_dt)                     AS usage_dt
            , ta.usage_date_key
            , ta.product_line_cd
            , NULL                                  AS product_feature_id
            , ta.service_category_nm
            , ta.txn_type_nm
            , CASE
                WHEN ta.txn_type_nm = 'MANUAL_ADJUSTMENT' THEN '3' 
                WHEN ta.txn_type_nm = 'MANUAL_CONSUMPTION' THEN '4'
                ELSE '0'
             END                                AS txn_type_id
            , ta.end_customer_agreement_yr_ind
            , ta.multi_year_flg
            , ta.txn_units_nbr
            , NULL                              AS duration_mns
            , NULL                              AS duration_hrs
            -- Adjustments details
            , ta.charged_item_id
            , ta.src_created_dt
            , ta.txn_dt
            , ta.txn_qty
            , ta.reason_cd
            , ta.reason_txt
    FROM t_eccr_token_adjustments ta
),

flexera_tokens AS (
    -- Flexera Usage Table maintained by the EEP DAR Team
    SELECT fu.flexdetailid
        , fu.username                                   AS user_login_id
        , fu.user_hostname                              AS machine_nm
        , fu.user_project                               AS license_server_nm
        , DATE(fu.DATE_STR)                             AS usage_dt
        , TO_CHAR(DATE(fu.date_str),'YYYYMMDD')         AS usage_date_key
        , fu.productlinecode                            AS product_line_cd
        , fu.feature                                    AS product_feature_cd
        , NULL                                          AS service_mktg_nm
        , NULL                                          AS service_category_nm
        , 'PRODUCT_CONSUMPTION'                         AS txn_type_nm
        , '5'                                           AS txn_type_id
        , REPLACE(contractyear, 'Year ')                AS end_customer_agreement_yr_ind
        , NULL                                          AS multi_year_flg
        , CAST(fu.token_consumed AS DECIMAL)            AS txn_units_nbr
        , CAST(fu.hours_used AS DECIMAL)  * 60          AS duration_mns
        , CAST(fu.hours_used AS DECIMAL)                AS duration_hrs
        , NULL                                          AS charged_item_id
        , NULL                                          AS src_created_dt
        , NULL                                          AS txn_dt
        , NULL                                          AS txn_qty
        , NULL                                          AS reason_cd
        , NULL                                          AS reason_txt
    FROM flex_usage fu

    UNION ALL

    -- Flexera Adjustments Table maintained by the EEP DAR Team
    SELECT fa.flexdetailid
        , NULL                                          AS user_login_id
        , NULL                                          AS machine_nm
        , 'Token Adjustment'                            AS license_server_nm
        , DATE(fa.adjustment_date)                      AS usage_dt
        , TO_CHAR(DATE(fa.adjustment_date),'YYYYMMDD')  AS usage_date_key
        , fa.product_line_code                          AS product_line_cd
        , NULL                                          AS product_feature_cd
        , NULL                                          AS service_mktg_nm
        , NULL                                          AS service_category_nm
        , CASE 
            WHEN 
                reason = 'Off network'  THEN 'MANUAL_CONSUMPTION'
            ELSE 'MANUAL_ADJUSTMENT'
            END                                         AS txn_type_nm
        , CASE 
            WHEN 
                reason = 'Off network'  THEN '4'
            ELSE '3'
            END                                         AS txn_type_id
        , REPLACE(adjcontractyear, 'Year ')             AS end_customer_agreement_yr_ind
        , NULL                                          AS multi_year_flg
        , CASE WHEN (DATE(fa.adjustment_date) >= DATE'2022-12-01') 
                    AND (fa.tokens_adjusted IS NULL) 
            THEN CAST(fa.use_count AS DECIMAL) 
            ELSE CAST(fa.tokens_adjusted AS DECIMAL) 
        END                                             AS txn_units_nbr
        , NULL                                          AS duration_mns
        , NULL                                          AS duration_hrs
        , NULL                                          AS charged_item_id
        , NULL                                          AS src_created_dt
        , NULL                                          AS txn_dt
        , fa.use_count                                  AS txn_qty
        , fa.reason                                     AS reason_cd
        , fa.adjustment_comments                        AS reason_txt
    FROM flexera_core_token_adjustment fa
),

-- Final CTE
tflex_usage AS (
    -- Consolidated CORE (NLRS/NLRM) tokens
    SELECT a.ultimate_parent_account_id
        , a.ultimate_parent_account_csn
        , a.ultimate_parent_account_name
        , a.ultimate_parent_eca_id
        , a.ultimate_parent_eca_name
        , a.account_id
        , a.account_name
        , a.account_csn
        , a.parent_account_id
        , a.parent_account_csn
        , a.parent_account_name
        , a.agreement_id
        , a.agreement_name
        , a.agreement_status
        , a.agreement_type
        , a.exhibit_id
        , a.exhibit_name
        , a.exhibit_active_status
        , a.exhibit_start_date
        , a.exhibit_end_date
        , a.exhibit_type
        , a.tflex_reporting_platform
        , et.agree_nbr                          AS agreement_number
        , a.eba_analytics_id_key
        , a.eba_analytics_name_key
        ------------------------------------------------------------------------------
        -- Tflex User Data
        , et.user_login_id
        , et.machine_nm                         AS machine_name
        , et.license_server_nm                  AS license_server_name
        -- Tflex Usage Dates
        , et.usage_dt
        , et.usage_date_key
        -- Token Flex Product Data
        , et.product_line_cd
        , pl.product_line_nm                    AS product_line_name
        -- Token Flex Product Feature (Version) Data
        , et.product_feature_id
        , pf.product_feature_cd
        , pf.product_release_cd
        -- Token Flex Service Data
        , sn.service_mktg_nm                    AS service_mktg_name
        -- Unified Product Name - Product name for Desktop and Cloud Products, Manual Consumption
        -- Service Name for Cloud Services
        -- Token Adjustment for Manual Adjustments
        , CASE
            WHEN et.txn_type_nm = 'CLOUD_CONSUMPTION'
                THEN sn.service_mktg_nm
            WHEN et.txn_type_nm IN ('MANUAL_CONSUMPTION', 'PRODUCT_CONSUMPTION',
                                    'CLOUD_PRODUCT_CONSUMPTION')
                THEN pl.product_line_nm
            WHEN et.txn_type_nm = 'MANUAL_ADJUSTMENT'
                THEN 'Token Adjustment'
            ELSE 'UNKNOWN'
        END                                     AS product_name
        , CASE
            WHEN et.txn_type_nm = 'PRODUCT_CONSUMPTION'
                THEN CONCAT(pl.product_line_nm, ' ', pf.product_release_cd)
            WHEN et.txn_type_nm IN ('MANUAL_CONSUMPTION', 'CLOUD_PRODUCT_CONSUMPTION')
                THEN pl.product_line_nm
            WHEN et.txn_type_nm = 'CLOUD_CONSUMPTION'
                THEN sn.service_mktg_nm
            WHEN et.txn_type_nm = 'MANUAL_ADJUSTMENT'
                THEN 'Token Adjustment'
        END                                     AS product_version
        -- Additional Information on Usage
        , et.service_category_nm                AS service_category_name
        , et.txn_type_nm                        AS txn_type_name
        , et.txn_type_id
        , et.end_customer_agreement_yr_ind
        , et.multi_year_flg
        -- Tokens, Usage Time
        , et.txn_units_nbr
        , et.duration_mns
        , et.duration_hrs
        -- Token Flex Adjustments Information
        , et.charged_item_id
        , et.src_created_dt
        , et.txn_dt
        , et.txn_qty
        , et.reason_cd
        , CASE
            WHEN et.agree_nbr IN
                    ('110003302315', '110003300867', '110003300867',
                    '110003294491', '110003423141', '110003288214',
                    '110003830762', '110003085408', '110003139969',
                    '110003299464', '110002894181', '110003660879',
                    '110002834422', '110003288000', '110003186675',
                    '110003846659', '110003839864', '110003606361',
                    '110002875917', '110002782463', '110003245612',
                    '110003327117', '110003369305', '110003353110',
                    '110003839864', '110003839864', '110003359366',
                    '110003410981', '110003402697', '110003830762',
                    '110003858891', '110003369900', '110003286836',
                    '110003830256', '110003843244', '110003329241',
                    '110002958388', '110003395756', '110003835136',
                    '110003655442', '110002944413', '110003748810',
                    '110003827242', '110003771976', '110003273863',
                    '110003666005', '110003187252', '110003757376',
                    '110003830256', '110003158257', '110003375564',
                    '110003300867', '110003761092', '110002903454',
                    '110002890135', '110003300867', '110003060706',
                    '110003050045', '110003724075', '110003769256',
                    '110003028033', '110003336464', '110003372952',
                    '110002854263', '110003301539', '110003072025') 
                AND TRUNC(usage_dt, 'MONTH') = DATE '2022-01-01'
                AND txn_type_nm = 'MANUAL_ADJUSTMENT'
                THEN 'BIM 360 Enterprise Unlimited'
            ELSE et.reason_txt
          END                                   AS reason_txt
    FROM tflex_accounts a -- Token Flex Account and Agreement Data
            -- Join the ECCR tokens created in above CTE's
            INNER JOIN eccr_tokens et
                        ON (a.agreement_id = et.end_customer_agreement_id)
                            AND (a.exhibit_start_date <= DATE(et.usage_dt))
                            AND (a.exhibit_end_date >= DATE(et.usage_dt))

        -- Join the TFLEX Product Line Table maintained by the EBSO/CORE Team
            LEFT JOIN t_eccr_product_line pl
                    ON (et.product_line_cd = pl.product_line_cd)

        -- Join the Token Flex Product Feature (Version) Table maintained by the EBSO/CORE Team
            LEFT JOIN t_pseb_product_feature pf
                    ON (et.product_feature_id = TO_CHAR(pf.product_feature_id))

        -- Join the Token Flex Service Table maintained by the EBSO/CORE Team
            LEFT JOIN t_eccr_service_nm sn
                    ON (et.product_feature_id = sn.service_cd)
    WHERE 1 = 1
    AND a.tflex_reporting_platform IN ('NLRS', 'NLRM')

    UNION ALL

    -- Union with consolidated Flexera tokens
    SELECT a.ultimate_parent_account_id
        , a.ultimate_parent_account_csn
        , a.ultimate_parent_account_name
        , a.ultimate_parent_eca_id
        , a.ultimate_parent_eca_name
        , a.account_id
        , a.account_name
        , a.account_csn
        , a.parent_account_id
        , a.parent_account_csn
        , a.parent_account_name
        , a.agreement_id
        , a.agreement_name
        , a.agreement_status
        , a.agreement_type
        , a.exhibit_id
        , a.exhibit_name
        , a.exhibit_active_status
        , a.exhibit_start_date
        , a.exhibit_end_date
        , a.exhibit_type
        , a.tflex_reporting_platform
        , NULL                           AS agreement_number
        , a.eba_analytics_id_key
        , a.eba_analytics_name_key
        ------------------------------------------------------------------------------
        -- Flexera User Data
        -- Business Rule - use Machine Name as USer Login ID for three products:
        -- Arnold, VRED Render and VRED CORE
        , CASE
            WHEN ft.product_line_cd IN ('RCMVRD', 'ARNOL', 'VRDSRV')
                THEN ft.machine_nm
            ELSE ft.user_login_id
        END                                 AS user_login_id
        , ft.machine_nm                     AS machine_name
        , ft.license_server_nm
        -- Flexera Usage Dates
        , ft.usage_dt
        , ft.usage_date_key
        -- Token Flex Product Data
        , ft.product_line_cd
        , pl.product_line_nm                AS product_line_name
        -- Token Flex Product Feature (Version) Data
        , TO_CHAR(pf.product_feature_id)    AS product_feature_id
        , ft.product_feature_cd
        , pf.product_release_cd             AS product_release_cd
        -- Token Flex Service Data
        , ft.service_mktg_nm                AS service_mktg_name
        -- Unified Product Name - Product name for Desktop and Cloud Products
        -- Service Name for Cloud Services
        -- Token Adjustment for Manual Adjustments
        , CASE
            WHEN ft.txn_type_nm IN ('MANUAL_CONSUMPTION', 'PRODUCT_CONSUMPTION')
                THEN pl.product_line_nm
            WHEN ft.txn_type_nm = 'MANUAL_ADJUSTMENT'
                THEN 'Token Adjustment'
            ELSE 'UNKNOWN'
        END                                 AS product_name
        , CASE
            WHEN txn_type_nm = 'PRODUCT_CONSUMPTION'
                THEN CONCAT(pl.product_line_nm, ' ', pf.product_release_cd)
            WHEN txn_type_nm = 'MANUAL_CONSUMPTION'
                THEN pl.product_line_nm
            WHEN ft.txn_type_nm = 'MANUAL_ADJUSTMENT'
                THEN 'Token Adjustment'
        END                                 AS product_version
        -- Additional Information on Usage
        , ft.service_category_nm            AS service_category_name
        , ft.txn_type_nm                    AS txn_type_name
        , ft.txn_type_id
        , ft.end_customer_agreement_yr_ind
        , ft.multi_year_flg
        -- Tokens, Usage Time
        , ft.txn_units_nbr
        , ft.duration_mns
        , ft.duration_hrs
        -- Token Flex Adjustments Information
        , ft.charged_item_id
        , ft.src_created_dt
        , ft.txn_dt
        , ft.txn_qty
        , ft.reason_cd
        , ft.reason_txt
    FROM tflex_accounts a -- Token Flex Account and Agreement Data
            -- Join the Flexera Details Table maintained by the EEP DAR Team
            INNER JOIN flexera_core_flexdetails fd
                        ON (a.agreement_id = fd.end_customer_contract_id)
                            AND (a.exhibit_start_date =
                                COALESCE(TRY_TO_DATE(fd.contract_exhibit_start_date), DATE('1970-01- 01')))
                            AND (a.exhibit_end_date = 
                                COALESCE(TRY_TO_DATE(fd.contract_exhibit_end_date), DATE('1970-01- 01')))

        -- Join the Flexera tokens created in above CTE's
            INNER JOIN flexera_tokens ft
                        ON (fd.flexdetailid = ft.flexdetailid)
                            AND (TRY_TO_DATE(fd.contract_exhibit_start_date) <= DATE(ft.usage_dt))
                            AND (TRY_TO_DATE(fd.contract_exhibit_end_date) >= DATE(ft.usage_dt))

        -- Join the TFLEX Product Line Table maintained by the EBSO/CORE Team
            LEFT JOIN t_eccr_product_line pl
                    ON (ft.product_line_cd = pl.product_line_cd)

        -- Join the Token Flex Product Feature (Version) Table maintained by the EBSO/CORE Team
            LEFT JOIN t_pseb_product_feature pf
                    ON (ft.product_feature_cd = pf.product_feature_cd)
    WHERE 1 = 1
    AND a.tflex_reporting_platform = 'Flexera'
)

SELECT *
FROM tflex_usage

