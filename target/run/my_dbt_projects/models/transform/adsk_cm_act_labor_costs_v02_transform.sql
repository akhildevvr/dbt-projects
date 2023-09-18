
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_cm_act_labor_costs_v02
  
   as (
    
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
     tproject.uniqueid AS projectid
    -- Approved
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_all
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.entrydate < fnc_currentmonthbegins
                           THEN IFNULL(fxrate.rate, 0.00) * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_past
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.entrydate >= fnc_currentmonthbegins
        AND ttimesheetentries.entrydate < fnc_nextmonthbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_currentmonth
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.entrydate < fnc_currentqtrbegins
                           THEN IFNULL(fxrate.rate, 0.00) * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_pastqtrs
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
        AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
        AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_completedinqtr
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.entrydate >= fnc_minus1qtrbegins
        AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_minus1qtr
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.entrydate >= fnc_minus2qtrbegins
        AND ttimesheetentries.entrydate < fnc_minus1qtrbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_minus2qtr
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.entrydate >= fnc_minus3qtrbegins
        AND ttimesheetentries.entrydate < fnc_minus2qtrbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_minus3qtr
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.entrydate < fnc_minus3qtrbegins
                           THEN IFNULL(fxrate.rate, 0.00) * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_priorqtrs
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.entrydate >= fnc_hist_customrangebegin
        AND ttimesheetentries.entrydate < fnc_hist_customrangeend THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_customrange
    -- Unapproved
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_all
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.entrydate < fnc_currentmonthbegins
                           THEN IFNULL(fxrate.rate, 0.00) * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_past
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.entrydate >= fnc_currentmonthbegins
        AND ttimesheetentries.entrydate < fnc_nextmonthbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_currentmonth
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.entrydate < fnc_currentqtrbegins
                           THEN IFNULL(fxrate.rate, 0.00) * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_pastqtrs
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
        AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
        AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_completedinqtr
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.entrydate >= fnc_minus1qtrbegins
        AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_minus1qtr
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.entrydate >= fnc_minus2qtrbegins
        AND ttimesheetentries.entrydate < fnc_minus1qtrbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_minus2qtr
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.entrydate >= fnc_minus3qtrbegins
        AND ttimesheetentries.entrydate < fnc_minus2qtrbegins THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_minus3qtr
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.entrydate < fnc_minus3qtrbegins
                           THEN IFNULL(fxrate.rate, 0.00) * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_priorqtrs
     , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.entrydate >= fnc_hist_customrangebegin
        AND ttimesheetentries.entrydate < fnc_hist_customrangeend THEN IFNULL(fxrate.rate, 0.00)
        * IFNULL(ttimeentryrate.costamounttotal, 0.00)
                       ELSE 0.00 END, 0.00)) AS actcostlabor_unapp_customrange
     , 3 AS sqlversion_act_labor_costs
FROM eio_publish.tenrox_private.ttimeentryrate ttimeentryrate
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_month_q_ranges_v02 AS ranges  -- put back to original place, join before TTIMESHEETENTRIES
JOIN eio_publish.tenrox_private.ttimesheetentries ttimesheetentries 
     ON ttimeentryrate.timeentryuid = ttimesheetentries.timeentryuid
JOIN eio_publish.tenrox_private.ttask ttask ON ttask.uniqueid = ttimesheetentries.taskuid
JOIN eio_publish.tenrox_private.tproject tproject ON tproject.uniqueid = ttask.projectid
JOIN eio_publish.tenrox_private.tclientinvoice tclientinvoice ON tclientinvoice.clientid = tproject.clientid
LEFT OUTER JOIN
    (
        SELECT IFNULL(uniqueid, 1) AS lubasecurrencyid 
        FROM eio_publish.tenrox_private.tcurrency tcurrency 
        WHERE currencycode = 'USD'
    ) basecur
-- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN
    (SELECT IFNULL(uniqueid, 1) AS overridecurid 
        FROM eio_publish.tenrox_private.tcurrency 
    WHERE currencycode = 'USD') usdcurid
-- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN
    EIO_INGEST.TENROX_TRANSFORM.fcurrqexchrate AS fxrate
    ON fxrate.basecurrencyid = COALESCE(ttimeentryrate.costcurrencyid, lubasecurrencyid)
    AND fxrate.quotecurrencyid = COALESCE(overridecurid, tclientinvoice.currencyid, lubasecurrencyid)  -- @OverrideCurID | @PQUOTECURRID is declared = 1 from adsk_fn_cm_marginvariance
    AND ttimesheetentries.entrydate BETWEEN fxrate.startdate AND fxrate.enddate
GROUP BY tproject.uniqueid
  );

