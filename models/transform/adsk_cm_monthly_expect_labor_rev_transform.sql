{{ config(
    alias='adsk_cm_monthly_expect_labor_rev'
) }}
 /* ADSK_FN_CM_MONTHLY_EXPECT_LABOR_REV.sql
   @OverrideCurID   INT = NULL
  , @Placeholder01 INT = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
 */
SELECT
     ttask.projectid                                                                       AS projectid
     , TRUNC(ttimesheetentries.entrydate, 'month')                                         AS monthofexpectedlaborrev
     , (SUM(IFNULL(totaltime, 0.00)) / 3600.00)                                            AS hrsactthismonth
     , NULLIF(labor_hrs.hrs_billable_eac, 0.00)                                            AS hrs_eac
     , (SUM(IFNULL(totaltime, 0.00)) / 3600.00) / NULLIF(labor_hrs.hrs_billable_eac, 0.00) AS monthslaborpct
     , project_budget.currentbillabletime                                                  AS totallaborrevenue
     , IFNULL(((((SUM(IFNULL(totaltime, 0.00)) / 3600.00) 
         / NULLIF(labor_hrs.hrs_billable_eac, 0.00)) * fxlookup.rate)
                * project_budget.currentbillabletime), 0.00)                               AS expectedlaborrevenue
     , fxlookup.rate                                                                       AS fxrateused
     , COALESCE(project_details.projectcurrencyid, lubasecurrencyid)                       AS fromcur
     , COALESCE(overridecurid, project_details.projectcurrencyid)                          AS tocur
     , 8                                                                                   AS sqlversion_monthly_expect_labor_rev
FROM {{ source('tenrox_private', 'ttimesheetentries') }} ttimesheetentries
INNER JOIN {{ source('tenrox_private', 'ttask') }} ttask
    ON ttask.uniqueid = ttimesheetentries.taskuid 
LEFT JOIN {{ ref('adsk_cm_labor_hrs_v02_transform') }} AS labor_hrs 
    ON labor_hrs.projectid = ttask.projectid 
LEFT JOIN {{ ref('adsk_cm_project_budget_transform') }} AS project_budget 
    ON project_budget.projectid = ttask.projectid 
LEFT JOIN {{ ref('adsk_cm_project_details_transform') }} AS project_details 
    ON project_details.projectid = ttask.projectid
LEFT OUTER JOIN (
               SELECT
                    IFNULL(uniqueid, 1) AS lubasecurrencyid
                FROM {{ source('tenrox_private', 'tcurrency') }}
                WHERE currencycode = 'USD'
               ) AS basecur
-- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN (
                SELECT
                    IFNULL(uniqueid, 1) AS overridecurid
                FROM {{ source('tenrox_private', 'tcurrency') }}
                WHERE currencycode = 'USD') usdcurid
-- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN {{ ref('fcurrqexchrate_transform') }} AS fxlookup
    ON fxlookup.basecurrencyid = COALESCE(project_details.projectcurrencyid, basecur.lubasecurrencyid) 
    AND fxlookup.quotecurrencyid = COALESCE(overridecurid, project_details.projectcurrencyid) 
    AND ttimesheetentries.entrydate BETWEEN fxlookup.startdate AND fxlookup.enddate
WHERE ttimesheetentries.approved = 1 
    AND ttimesheetentries.billable = 1 
    AND TRUNC(ttimesheetentries.entrydate, 'month') < TRUNC(CURRENT_DATE(), 'month')
GROUP BY
    ttask.projectid
    , TRUNC(ttimesheetentries.entrydate, 'month')
    , nullif(labor_hrs.hrs_billable_eac, 0.00)
    , project_budget.currentbillabletime
    , fxlookup.rate
    , COALESCE(project_details.projectcurrencyid
    , lubasecurrencyid)
    , COALESCE(overridecurid, project_details.projectcurrencyid)