/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with 
tflex_dd_fct_snapshot as (
select 
date('2023-02-11') as run_date
,dt
,ultimate_parent_account_name
,ultimate_parent_account_csn
,ultimate_parent_eca_name
,account_name
,account_csn
,agreement_id
,tflex_reporting_platform
,exhibit_id
,exhibit_start_date
,exhibit_end_date
,exhibit_name
,eba_analytics_name_key
,year(usage_dt) as Usage_Year
,monthname(usage_dt) as usage_month
,txn_type_nm
,trunc(to_date(usage_dt), 'MONTH') as bymonth
,COUNT(DISTINCT PRODUCT_LINE_NM) AS distinct_products
,COUNT(DISTINCT USER_LOGIN_ID) AS distinct_USERS
,SUM(DURATION_MNS) AS MINUTES
,SUM(DURATION_MNS)/60 AS HOURS
,sum(txn_units_nbr) as Tokens
,sum(case when multi_year_flg = True then  txn_units_nbr end ) as multi_year_tokens
,sum(case when multi_year_flg = False then  txn_units_nbr end ) as annual_tokens
,SUM(CASE WHEN TXN_TYPE_NM NOT IN ('MANUAL_CONSUMPTION','MANUAL_ADJUSTMENT') THEN TXN_UNITS_NBR END) AS TOKENS_CONSUMED
,SUM(CASE WHEN TXN_TYPE_NM IN ('MANUAL_CONSUMPTION','MANUAL_ADJUSTMENT') THEN TXN_UNITS_NBR END) AS TOKENS_ADJUSTED
from "ADP_WORKSPACES"."CUSTOMER_SUCCESS_SHARED"."TFLEX_USAGE_DD_FCT"
where 1=1 
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

select 
* 
from tflex_dd_fct_snapshot


  -- this filter will only be applied on an incremental run
  where run_date >= (select max(run_date) from EIO_INGEST.ENGAGEMENT_TRANSFORM.tflex_usage_dd_fct_snapshot) 
