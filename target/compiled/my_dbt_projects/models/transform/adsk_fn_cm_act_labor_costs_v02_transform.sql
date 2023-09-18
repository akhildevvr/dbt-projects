
/* ADSK_FN_CM_ACT_LABOR_COSTS_V02.sql
  @OverrideCurID   INT = 1
  , @RangeBegin    DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL
  , @Placeholder05 INT = NULL

  FXRate.BASECURRENCYID : @PBASECURRID = COALESCE(TTIMEENTRYRATE.COSTCURRENCYID, LUBaseCurrencyID)
  FXRate.QUOTECURRENCYID : @PQUOTECURRID = COALESCE(1, TCLIENTINVOICE.CURRENCYID, LUBaseCurrencyID)
  FXRate.STARTDATE & ENDDATE : @PDATE IS BETWEEN = TTIMESHEETENTRIES.ENTRYDATE BETWEEN
*/
SELECT
  TPROJECT.UNIQUEID        AS ProjectID
  -- Approved
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1 THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_All
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Past
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentMonthBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_NextMonthBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_CurrentMonth
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_PastQtrs
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_EntireCurrentQtr
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_CompletedInQtr
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus1QtrBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Minus1Qtr
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus2QtrBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus1QtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Minus2Qtr
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus3QtrBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus2QtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Minus3Qtr
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus3QtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_PriorQtrs
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 1
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Hist_CustomRangeBegin
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_CustomRange
  -- Unapproved
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0 THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_All
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_Past
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentMonthBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_NextMonthBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_CurrentMonth
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_PastQtrs
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_EntireCurrentQtr
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_CompletedInQtr
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus1QtrBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_Minus1Qtr
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus2QtrBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus1QtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_Minus2Qtr
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus3QtrBegins
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus2QtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_Minus3Qtr
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus3QtrBegins THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_PriorQtrs
  , SUM(IFNULL(CASE
                 WHEN TTIMESHEETENTRIES.APPROVED = 0
                      AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Hist_CustomRangeBegin
                      AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(FXRate.RATE, 0.00) * IFNULL(TTIMEENTRYRATE.COSTAMOUNTTOTAL, 0.00)
                 ELSE 0.00
               END, 0.00)) AS ActCostLabor_Unapp_CustomRange
  , 3                      AS SQLVersion_ACT_LABOR_COSTS
FROM eio_publish.tenrox_private.TTIMEENTRYRATE TTIMEENTRYRATE
LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_month_q_ranges_v02 AS Ranges        -- put back to original place, join before TTIMESHEETENTRIES
JOIN eio_publish.tenrox_private.TTIMESHEETENTRIES TTIMESHEETENTRIES
  ON TTIMEENTRYRATE.TIMEENTRYUID = TTIMESHEETENTRIES.TIMEENTRYUID
JOIN eio_publish.tenrox_private.TTASK TTASK
  ON TTASK.UNIQUEID = TTIMESHEETENTRIES.TASKUID
JOIN eio_publish.tenrox_private.TPROJECT TPROJECT
  ON TPROJECT.UNIQUEID = TTASK.PROJECTID
JOIN eio_publish.tenrox_private.TCLIENTINVOICE TCLIENTINVOICE
  ON TCLIENTINVOICE.CLIENTID = TPROJECT.CLIENTID
LEFT OUTER JOIN (SELECT
                    IFNULL(UNIQUEID, 1) AS LUBaseCurrencyID
                FROM eio_publish.tenrox_private.TCURRENCY TCURRENCY
                WHERE  CURRENCYCODE = 'USD') BaseCUR
-- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN (
               SELECT
                    IFNULL(UNIQUEID, 1)      AS OverrideCurID
               FROM eio_publish.tenrox_private.TCURRENCY
               WHERE CURRENCYCODE = 'USD'
               ) USDCurID
-- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.fcurrqexchrate AS FXRate
             ON FXRate.BASECURRENCYID = COALESCE(TTIMEENTRYRATE.COSTCURRENCYID, LUBaseCurrencyID)
            AND FXRate.QUOTECURRENCYID = COALESCE(OverrideCurID, TCLIENTINVOICE.CURRENCYID, LUBaseCurrencyID)    --@OverrideCurID | @PQUOTECURRID is declared = 1 from adsk_fn_cm_marginvariance
            AND TTIMESHEETENTRIES.ENTRYDATE BETWEEN FXRate.STARTDATE AND FXRate.ENDDATE
GROUP       BY
TPROJECT.UNIQUEID