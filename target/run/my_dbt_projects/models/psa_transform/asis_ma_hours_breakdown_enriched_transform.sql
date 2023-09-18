
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.asis_ma_hours_breakdown_enriched
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/




WITH as_is_ma_hours_breakdown AS 
(
    SELECT
        project_unique_id
        ,project_name
        ,project_code
        ,project_state
        ,project_manager
        ,contractual_end_date
        ,project_start_date
        ,project_end_date
        ,TO_DATE(SPLIT_PART(contract_start_date, ' ', 1)) AS contract_start_date
        ,TO_DATE(SPLIT_PART(contract_end_date, ' ', 1)) AS contract_end_date
        ,CASE
            WHEN
                contract_end_date IS NULL 
            THEN
                NULL 
            ELSE
                DATEADD(DAY, 1, TO_DATE(SPLIT_PART(contract_end_date, ' ', 1))) 
        END
        AS contract_end_date_plus_one
        , rev_forecast_contract_type
        , project_budget_current_time
        , project_budget_current_billable_time
        , consultant_time
        , pm_time
        , travel_time 
    FROM
        EIO_INGEST.ENGAGEMENT_TRANSFORM.asis_ma_hours_breakdown 
)
SELECT
    *
    ,DATEDIFF(MONTH, contract_start_date :: DATE, contract_end_date_plus_one::DATE) AS calculated_contract_month
    ,DIV0(COALESCE(DIV0(SUM("consultant_time"), 8), 0) + COALESCE(DIV0(SUM("pm_time"), 8), 0) , calculated_contract_month ) AS days_to_deliver_per_month
    ,DIV0(DIV0(SUM("consultant_time"), 8), calculated_contract_month ) AS consultant_days_to_deliver_per_month
    ,consultant_days_to_deliver_per_month * 8 AS consultant_hours_to_deliver_per_month
    ,DIV0(DIV0(SUM("pm_time"), 8), calculated_contract_month ) AS pm_days_to_deliver_per_month
    ,pm_days_to_deliver_per_month * 8 AS pm_hrs_to_deliver_per_month
    ,CASE
        WHEN
            CURRENT_DATE() < contract_start_date 
        THEN
            NULL 
        WHEN
            DATE_PART(DAY, contract_start_date ) > 15 
        THEN
            DATEDIFF(MONTH,contract_start_date,CURRENT_DATE() ) -1
        WHEN
            DATE_PART(DAY,  contract_start_date) <= 15 
        THEN
            DATEDIFF(MONTH,contract_start_date,CURRENT_DATE() ) 
    END
    AS no_of_month_executed
    ,CASE
        WHEN
            CURRENT_DATE() < contract_start_date 
        THEN
            NULL 
        ELSE
            DATEDIFF(MONTH,contract_start_date,CURRENT_DATE() )
    END
    AS no_of_months_executed_original 
FROM
    as_is_ma_hours_breakdown 
GROUP BY
    project_unique_id
    , project_name
    , project_code
    , project_state
    , project_manager
    , contractual_end_date
    , project_start_date
    , project_end_date
    , contract_start_date
    , contract_end_date
    , contract_end_date_plus_one
    , rev_forecast_contract_type
    , project_budget_current_time
    , project_budget_current_billable_time
    , consultant_time
    , pm_time
    , travel_time
  );

