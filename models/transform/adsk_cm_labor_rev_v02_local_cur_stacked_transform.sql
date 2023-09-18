{{ config(
    alias='adsk_cm_labor_rev_local_cur_v02_stacked'
) }}



WITH deffered_rev_max AS
(SELECT
 d.*
 FROM
 {{ ref('adsk_cm_monthly_deferred_rev_local_cur_stacked_transform')}} d
WHERE
dt = TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1
                                                  THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                              ELSE YEAR(CURRENT_DATE()) END) || '-'
                                      || CASE WHEN MONTH(CURRENT_DATE()) IN (2, 3, 4) THEN '02-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (5, 6, 7) THEN '05-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (8, 9, 10) THEN '08-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (11, 12, 1) THEN '11-01'
                     ELSE NULL END)
),

project AS 
(
        SELECT
        *
        FROM
        {{ source('tenrox_private','tproject')}}
),
clientinvoice AS 
(
        SELECT
        *
        FROM
        {{ source('tenrox_private','tclientinvoice')}}
),

adsk_cm_project_budget_local_cur AS
(
        SELECT
        *
        FROM
        {{ ref('adsk_cm_project_budget_local_cur_transform')}}

),

adsk_cm_labor_hrs_v02_stacked AS
(
        SELECT
        *
        FROM
        {{ ref('adsk_cm_labor_hrs_v02_stacked_transform')}}

)


 SELECT 
    tproject.uniqueid    AS projectid
    ,laborhrs.dt

     ,IFNULL(projbudget.currentbillabletime * (IFNULL(laborhrs.HRS_ACTUAL, 0.00)  
                                             / NULLIF(laborhrs.hrs_billable_eac, 0.00)),0.00) AS revlabor_actual
     
     ,IFNULL(projbudget.currentbillabletime * (IFNULL(laborhrs.HRS_FCST_BILLABLE, 0.00) 
                                                / NULLIF(laborhrs.hrs_billable_eac, 0.00)),0.00)  AS revlabor_forecast
                                                
     ,IFNULL(projbudget.currentbillabletime * (IFNULL(laborhrs.HRS_FCST_BILLABLE_SOFT, 0.00) 
                                                / NULLIF(laborhrs.hrs_billable_eac, 0.00)),0.00)  AS revlabor_forecast_soft

     , revlabor_forecast -   revlabor_forecast_soft as revlabor_forecast_hard                                  
      
     ,IFNULL(projbudget.currentbillabletime * (IFNULL(laborhrs.HRS_FCST_BILLABLE_REMAININGINQTR, 0.00) 
                                                / NULLIF(laborhrs.hrs_billable_eac, 0.00)),0.00)   AS revlabor_remaininginqtr
     ,IFNULL(projbudget.currentbillabletime * (IFNULL(laborhrs.HRS_FCST_BILLABLE_REMAININGINQTR_SOFT, 0.00) 
                                                / NULLIF(laborhrs.hrs_billable_eac, 0.00)),0.00)   AS revlabor_remaininginqtr_soft
    , revlabor_remaininginqtr - revlabor_remaininginqtr_soft as revlabor_remaininginqtr_hard
    , deferred_rev.totaldeferredrevenue             AS rev_deferred

FROM project AS tproject
INNER JOIN clientinvoice AS tclientinvoice
        ON tclientinvoice.clientid = tproject.clientid
LEFT JOIN adsk_cm_project_budget_local_cur AS projbudget
             ON projbudget.projectid = tproject.uniqueid
LEFT JOIN adsk_cm_labor_hrs_v02_stacked AS laborhrs
             ON laborhrs.projectid = tproject.uniqueid
LEFT JOIN deffered_rev_max AS deferred_rev
        ON deferred_rev.projectid = tproject.uniqueid AND deferred_rev.dt = laborhrs.dt