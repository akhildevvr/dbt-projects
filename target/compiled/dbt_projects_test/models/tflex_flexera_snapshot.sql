/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with 
tflex_flexera_snapshot as (
SELECT
    current_date as run_date
    ,tf.ultimate_parent_account_name
    ,tf.ultimate_parent_eca_name
    , tf.account_name
    , tf.agreement_id
    , tf.exhibit_id
    , tf.exhibit_name
    , tf.exhibit_start_date
    , tf.exhibit_end_date
    , tf.tflex_reporting_platform
    , fu.txn_type_nm
    , fu.flexdetailid
    -- Flexera Usage Dates
    ,year(fu.usage_dt) as Usage_Year
    ,monthname(fu.usage_dt) as usage_month
    ,trunc(to_date(fu.usage_dt), 'MONTH') as bymonth
    ,COUNT(DISTINCT fu.USER_LOGIN_ID) AS distinct_USERS
    ,SUM(fu.DURATION_MNS) AS MINUTES
    ,SUM(fu.DURATION_MNS)/60 AS HOURS
    ,sum(fu.txn_units_nbr) as Tokens
    ,sum(case when fu.multi_year_flg = True then  fu.txn_units_nbr end ) as multi_year_tokens
    ,sum(case when fu.multi_year_flg = False then  fu.txn_units_nbr end ) as annual_tokens
    ,SUM(CASE WHEN fu.TXN_TYPE_NM NOT IN ('MANUAL_CONSUMPTION','MANUAL_ADJUSTMENT') THEN fu.TXN_UNITS_NBR END) AS TOKENS_CONSUMED
    ,SUM(CASE WHEN fu.TXN_TYPE_NM IN ('MANUAL_CONSUMPTION','MANUAL_ADJUSTMENT') THEN fu.TXN_UNITS_NBR END) AS TOKENS_ADJUSTED
FROM "ADP_WORKSPACES"."CUSTOMER_SUCCESS_SHARED"."SFDC_TFLEX_ACCOUNT" tf 

    -- Join the Flexera Details Table maintained by the EEP DAR Team
    INNER JOIN "ADP_PUBLISH"."SALES_DATA_HUB_OPTIMIZED"."FLEXERA_CORE_FLEXDETAILS" fd
        ON (tf.agreement_id = fd.end_customer_contract_id)
          AND (tf.exhibit_start_date = COALESCE(TRY_TO_DATE(fd.contract_exhibit_start_date), DATE('1970-01- 01')))
          AND (tf.exhibit_end_date = COALESCE(TRY_TO_DATE(fd.contract_exhibit_end_date), DATE('1970-01- 01')))

    -- Join the Flexera Usage Table 
    INNER JOIN (
        SELECT
            fu.flexdetailid
            , fu.username                                   AS user_login_id
            , fu.user_hostname                              AS machine_nm
            , fu.user_project                               AS license_server_nm
            , date(fu.date_str)                             AS usage_dt
            , to_char(date(fu.date_str),'YYYYMMDD')         AS usage_date_key
            , fu.productlinecode                            AS product_line_cd
            , fu.feature                                    AS product_feature_cd
            , NULL                                          AS service_mktg_nm
            , NULL                                          AS service_category_nm
            , 'PRODUCT_CONSUMPTION'                         AS txn_type_nm
            , '5'                                           AS txn_type_id
            , REPLACE(contractyear, 'Year ')                AS end_customer_agreement_yr_ind
            , NULL                                          AS multi_year_flg
            , cast(fu.token_consumed AS decimal)            AS txn_units_nbr
            , cast(fu.hours_used AS decimal)  * 60          AS duration_mns
            , cast(fu.hours_used AS decimal)                AS duration_hrs
            , NULL                                          AS charged_item_id
            , NULL                                          AS src_created_dt
            , NULL                                          AS txn_dt
            , NULL                                          AS txn_qty
            , NULL                                          AS reason_cd
            , NULL                                          AS reason_txt
        -- Flexera Usage Table maintained by the EEP DAR Team
        FROM "ADP_PUBLISH"."SALES_DATA_HUB_OPTIMIZED"."FLEX_USAGE" fu
        UNION ALL
        SELECT
            fa.flexdetailid
            , NULL                                          AS user_login_id
            , NULL                                          AS machine_nm
            , 'Token Adjustment'                            AS license_server_nm
            , date(fa.adjustment_date)                      AS usage_dt
            , to_char(date(fa.adjustment_date),'YYYYMMDD')  AS usage_date_key
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
            , cast(fa.tokens_adjusted AS decimal)           AS txn_units_nbr
            , NULL                                          AS duration_mns
            , NULL                                          AS duration_hrs
            , NULL                                          AS charged_item_id
            , NULL                                          AS src_created_dt
            , NULL                                          AS txn_dt
            , fa.use_count                                  AS txn_qty
            , fa.reason                                     AS reason_cd
            , fa.adjustment_comments                        AS reason_txt
        -- Flexera Adjustments Table maintained by the EEP DAR Team
        FROM "ADP_PUBLISH"."SALES_DATA_HUB_OPTIMIZED"."FLEXERA_CORE_TOKEN_ADJUSTMENT" fa
        WHERE (fa.ADJUSTMENT_DATE,fa.TOKENS_ADJUSTED) NOT IN ( ('2021-07-30','-600000'),('2021-12-14','-4300000'),('2021-06-18','-335000'))
        ) fu ON (fu.flexdetailid = fd.flexdetailid) and
        (COALESCE(TRY_TO_DATE(fd.contract_exhibit_start_date), DATE('1970-01- 01')) <= date(fu.usage_dt)) 
        and (COALESCE(TRY_TO_DATE(fd.contract_exhibit_end_date), DATE('1970-01- 01')) >= date(fu.usage_dt))  
WHERE 
    tf.tflex_reporting_platform = 'Flexera'
    
group by
current_date 
    ,tf.ultimate_parent_account_name
    ,tf.ultimate_parent_eca_name
    , tf.account_name
    , tf.agreement_id
    , tf.exhibit_id
    , tf.exhibit_name
    , tf.exhibit_start_date
    , tf.exhibit_end_date
    , tf.tflex_reporting_platform
    ,fu.txn_type_nm
    , fu.flexdetailid
    -- Flexera Usage Dates
    ,year(fu.usage_dt)
    ,monthname(fu.usage_dt)
    ,trunc(to_date(fu.usage_dt), 'MONTH')
)

select 
* 
from tflex_flexera_snapshot

