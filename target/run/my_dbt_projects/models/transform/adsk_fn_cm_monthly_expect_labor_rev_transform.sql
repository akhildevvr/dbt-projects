
  create or replace   view eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_monthly_expect_labor_rev
  
   as (
    
 /* ADSK_FN_CM_MONTHLY_EXPECT_LABOR_REV.sql
   @OverrideCurID   INT = NULL
  , @Placeholder01 INT = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
 */
SELECT
  TTASK.PROJECTID                                                                                                                                                AS ProjectID
  , TRUNC(TTIMESHEETENTRIES.ENTRYDATE, 'month')                                                                                                                  AS MonthOfExpectedLaborRev
  , (SUM(IFNULL(TOTALTIME, 0.00)) / 3600.00)                                                                                                                     AS HrsActThisMonth
  , NULLIF(LABOR_HRS.Hrs_Billable_EAC, 0.00)                                                                                                                     AS Hrs_EAC
  , (SUM(IFNULL(TOTALTIME, 0.00)) / 3600.00) / NULLIF(LABOR_HRS.Hrs_Billable_EAC, 0.00)                                                                          AS MonthsLaborPct
  , PROJECT_BUDGET.CurrentBillableTime                                                                                                                           AS TotalLaborRevenue
  , IFNULL(((((SUM(IFNULL(TOTALTIME, 0.00)) / 3600.00) / NULLIF(LABOR_HRS.Hrs_Billable_EAC, 0.00)) * FXLookup.RATE) * PROJECT_BUDGET.CurrentBillableTime), 0.00) AS ExpectedLaborRevenue
  , FXLookup.RATE                                                                                                                                                AS FXRateUsed
  , COALESCE(PROJECT_DETAILS.ProjectCurrencyID, LUBaseCurrencyID)                                                                                                AS FROMCur
  , COALESCE(OverrideCurID, PROJECT_DETAILS.ProjectCurrencyID)                                                                                                  AS TOCur
  , 8                                                                                                                                                            AS SQLVersion_MONTHLY_EXPECT_LABOR_REV
FROM eio_publish.tenrox_private.TTIMESHEETENTRIES TTIMESHEETENTRIES
INNER JOIN eio_publish.tenrox_private.TTASK TTASK
        ON TTASK.UNIQUEID = TTIMESHEETENTRIES.TASKUID
LEFT JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_labor_hrs_v02 AS LABOR_HRS
             ON LABOR_HRS.ProjectID = TTASK.PROJECTID
LEFT JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_project_budget AS PROJECT_BUDGET
             ON PROJECT_BUDGET.ProjectID = TTASK.PROJECTID
LEFT JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_project_details AS PROJECT_DETAILS
             ON PROJECT_DETAILS.ProjectID = TTASK.PROJECTID
LEFT OUTER JOIN (
               SELECT
                   IFNULL(UNIQUEID, 1) AS LUBaseCurrencyID
               FROM eio_publish.tenrox_private.TCURRENCY
               WHERE  CURRENCYCODE = 'USD'
               ) AS BaseCUR
-- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN (
                SELECT
                    IFNULL(UNIQUEID, 1)      AS OverrideCurID
                FROM eio_publish.tenrox_private.TCURRENCY
                WHERE CURRENCYCODE = 'USD'
                ) USDCurID
-- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.fcurrqexchrate AS FXLookup
             ON FXLookup.BASECURRENCYID = COALESCE(PROJECT_DETAILS.ProjectCurrencyID, BaseCUR.LUBaseCurrencyID)
            AND FXLookup.QUOTECURRENCYID = COALESCE(OverrideCurID, PROJECT_DETAILS.ProjectCurrencyID)
            AND TTIMESHEETENTRIES.ENTRYDATE BETWEEN FXLookup.STARTDATE AND FXLookup.ENDDATE
WHERE           TTIMESHEETENTRIES.APPROVED = 1
            AND TTIMESHEETENTRIES.BILLABLE = 1
            AND TRUNC(TTIMESHEETENTRIES.ENTRYDATE, 'month') < TRUNC(CURRENT_DATE(), 'month')
GROUP           BY
 TTASK.PROJECTID
 , TRUNC(TTIMESHEETENTRIES.ENTRYDATE, 'month')
 , NULLIF(LABOR_HRS.Hrs_Billable_EAC, 0.00)
 , PROJECT_BUDGET.CurrentBillableTime
 , FXLookup.RATE
 , COALESCE(PROJECT_DETAILS.ProjectCurrencyID, LUBaseCurrencyID)
 , COALESCE(OverrideCurID, PROJECT_DETAILS.ProjectCurrencyID)
  );

