
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_cm_forecast_chrg_rev_v02
  
   as (
    
/* ADSK_FN_CM_FORECAST_CHRG_COST
  @OverrideCurID  INT
  , @RangeBegin   DATETIME = NULL
  , @RangeEnd     DATETIME = NULL
  , @CutoverDate  DATETIME = NULL
  , @Placeholder5 INT = NULL

Used only in CUST_ADSK_MARGINVARIANCE where @OverrideCurID = @USDCurID is forced set to 1
and LUBaseCurrencyID is forced set to 1 as well

Therefore:
CASE
     WHEN @OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY   --> @OverrideCurID is always 1 and IS NEVER NULL
     WHEN LUBaseCurrencyID = @OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY  --> LUBaseCurrencyID = 1 and therefore @USDCurID = LUBaseCurrencyID
     ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
 END
*/

SELECT 
     tproject.uniqueid                     AS projectid
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_allbillable_all
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_allbillable_future
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_currentmonthbegins AND tfcalperiod.startdate < fnc_nextmonthbegins
                           THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                            WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                            ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_allbillable_currentmonth
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_allbillable_futureqtrs
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_currentqtrbegins AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_allbillable_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_currentmonthbegins AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_allbillable_remaininginqtr
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_plus1qtrbegins AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_allbillable_plus1qtr
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_plus2qtrbegins AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_allbillable_plus2qtr
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_plus3qtrbegins AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_allbillable_plus3qtr
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_plus4qtrbegins AND tfcalperiod.startdate < fnc_plus5qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_allbillable_plus4qtr
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_plus5qtrbegins AND tfcalperiod.startdate < fnc_plus6qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_allbillable_plus5qtr
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_allbillable_additionalqtrs
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_plus6qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_allbillable_additionalqtrs2
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND tfcalperiod.startdate >= fnc_fcst_customrangebegin AND tfcalperiod.startdate < fnc_fcst_customrangeend
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_allbillable_customrange
    -- All BUT Ratable
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_all
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                           THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                            WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                            ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_future
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                         WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                         ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_currentmonth
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_nonratablebillable_futureqtrs
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentqtrbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_remaininginqtr
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
        AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_plus1qtr
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
        AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_plus2qtr
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
        AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_plus3qtr
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus4qtrbegins
        AND tfcalperiod.startdate < fnc_plus5qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_plus4qtr
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus5qtrbegins
        AND tfcalperiod.startdate < fnc_plus6qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_plus5qtr
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_nonratablebillable_additionalqtrs
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus6qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_nonratablebillable_additionalqtrs2
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
                AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_nonratablebillable_customrange
    -- IPProdSales
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                              WHEN lubasecurrencyid = overridecurid
                                                                                  THEN trvfcblitemdata.amountbasecurrency
                                                                              ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_ipprodsales_all
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ipprodsales_future
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                         WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                         ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ipprodsales_currentmonth
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ipprodsales_futureqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tfcalperiod.startdate >= fnc_currentqtrbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ipprodsales_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ipprodsales_remaininginqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
        AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ipprodsales_plus1qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
        AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ipprodsales_plus2qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
        AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ipprodsales_plus3qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ipprodsales_additionalqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
        AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                             WHEN lubasecurrencyid = overridecurid
                                                                                 THEN trvfcblitemdata.amountbasecurrency
                                                                             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ipprodsales_customrange
    -- Ratable Billing
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Ratable Billing' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                              WHEN lubasecurrencyid = overridecurid
                                                                                  THEN trvfcblitemdata.amountbasecurrency
                                                                              ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ratablebilling_all
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ratablebilling_future
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins AND tfcalperiod.startdate < fnc_nextmonthbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_ratablebilling_currentmonth
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ratablebilling_futureqtrs
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentqtrbegins AND tfcalperiod.startdate < fnc_plus1qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_ratablebilling_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins AND tfcalperiod.startdate < fnc_plus1qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_ratablebilling_remaininginqtr
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus1qtrbegins AND tfcalperiod.startdate < fnc_plus2qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_ratablebilling_plus1qtr
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus2qtrbegins AND tfcalperiod.startdate < fnc_plus3qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_ratablebilling_plus2qtr
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus3qtrbegins AND tfcalperiod.startdate < fnc_plus4qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_ratablebilling_plus3qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ratablebilling_additionalqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
        AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                             WHEN lubasecurrencyid = overridecurid
                                                                                 THEN trvfcblitemdata.amountbasecurrency
                                                                             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ratablebilling_customrange
    -- IP3rdSales
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Third Party Product-Sales' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                              WHEN lubasecurrencyid = overridecurid
                                                                                  THEN trvfcblitemdata.amountbasecurrency
                                                                              ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_3rdprodsales_all
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Third Party Product-Sales' AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdprodsales_future
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Third Party Product-Sales' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                         WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                         ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdprodsales_currentmonth
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Third Party Product-Sales' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdprodsales_futureqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Third Party Product-Sales' AND tfcalperiod.startdate >= fnc_currentqtrbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdprodsales_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Third Party Product-Sales' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdprodsales_remaininginqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Third Party Product-Sales' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
        AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdprodsales_plus1qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Third Party Product-Sales' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
        AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdprodsales_plus2qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Third Party Product-Sales' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
        AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdprodsales_plus3qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Third Party Product-Sales' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdprodsales_additionalqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Third Party Product-Sales' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
        AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                             WHEN lubasecurrencyid = overridecurid
                                                                                 THEN trvfcblitemdata.amountbasecurrency
                                                                             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdprodsales_customrange
     , SUM(IFNULL(
        CASE WHEN tcharge.name = '3rd Party-Billable Expenses' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_3rdbillableexp_all
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdbillableexp_future
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                         WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                         ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdbillableexp_currentmonth
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdbillableexp_futureqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentqtrbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdbillableexp_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdbillableexp_remaininginqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
        AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdbillableexp_plus1qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
        AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdbillableexp_plus2qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
        AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdbillableexp_plus3qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdbillableexp_additionalqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
        AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                             WHEN lubasecurrencyid = overridecurid
                                                                                 THEN trvfcblitemdata.amountbasecurrency
                                                                             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdbillableexp_customrange
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Internal-Billable Expenses' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                               WHEN lubasecurrencyid = overridecurid
                                                                                   THEN trvfcblitemdata.amountbasecurrency
                                                                               ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_internalbillableexp_all
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalbillableexp_future
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                         WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                         ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalbillableexp_currentmonth
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalbillableexp_futureqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentqtrbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalbillableexp_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalbillableexp_remaininginqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
        AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalbillableexp_plus1qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
        AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalbillableexp_plus2qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
        AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalbillableexp_plus3qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalbillableexp_additionalqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Billable Expenses' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
        AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                             WHEN lubasecurrencyid = overridecurid
                                                                                 THEN trvfcblitemdata.amountbasecurrency
                                                                             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalbillableexp_customrange
     , SUM(IFNULL(
        CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                               WHEN lubasecurrencyid = overridecurid
                                                                                   THEN trvfcblitemdata.amountbasecurrency
                                                                               ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_3rdnonbillte_all
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdnonbillte_future
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                         WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                         ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdnonbillte_currentmonth
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdnonbillte_futureqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentqtrbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdnonbillte_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdnonbillte_remaininginqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
        AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdnonbillte_plus1qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
        AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdnonbillte_plus2qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
        AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdnonbillte_plus3qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdnonbillte_additionalqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
        AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                             WHEN lubasecurrencyid = overridecurid
                                                                                 THEN trvfcblitemdata.amountbasecurrency
                                                                             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_3rdnonbillte_customrange
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                              WHEN lubasecurrencyid = overridecurid
                                                                                  THEN trvfcblitemdata.amountbasecurrency
                                                                              ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_internalnonbillte_all
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalnonbillte_future
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                         WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                         ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalnonbillte_currentmonth
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalnonbillte_futureqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentqtrbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalnonbillte_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalnonbillte_remaininginqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
        AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalnonbillte_plus1qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
        AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalnonbillte_plus2qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
        AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalnonbillte_plus3qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalnonbillte_additionalqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
        AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                             WHEN lubasecurrencyid = overridecurid
                                                                                 THEN trvfcblitemdata.amountbasecurrency
                                                                             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_internalnonbillte_customrange
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_sysconvnonbill_all
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_sysconvnonbill_future
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                         WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                         ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_sysconvnonbill_currentmonth
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_sysconvnonbill_futureqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tfcalperiod.startdate >= fnc_currentqtrbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_sysconvnonbill_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_sysconvnonbill_remaininginqtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
        AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_sysconvnonbill_plus1qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
        AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_sysconvnonbill_plus2qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
        AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_sysconvnonbill_plus3qtr
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_sysconvnonbill_additionalqtrs
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
        AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                             WHEN lubasecurrencyid = overridecurid
                                                                                 THEN trvfcblitemdata.amountbasecurrency
                                                                             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_sysconvnonbill_customrange
     , MAX(fnc_fcst_customrangebegin)        AS fcstchrgrev_customrangebegin, MAX(fnc_fcst_customrangeend) AS fcstchrgrev_customrangeend
     , 15                                    AS sqlversion_forecast_chrg_rev
    FROM eio_publish.tenrox_private.trvfcbaseline trvfcbaseline
    LEFT OUTER JOIN
        eio_publish.tenrox_private.trvfcbaselinebudget trvfcbaselinebudget
        ON trvfcbaselinebudget.baselineuid = trvfcbaseline.uniqueid
    INNER JOIN
        eio_publish.tenrox_private.trvfcbltmpl trvfcbltmpl
        ON trvfcbltmpl.baselineid = trvfcbaseline.uniqueid
    INNER JOIN
        eio_publish.tenrox_private.trvfcblsec trvfcblsec 
        ON trvfcblsec.bltmplid = trvfcbltmpl.uniqueid
    INNER JOIN
        eio_publish.tenrox_private.trvfcblseclabel trvfcblseclabel
        ON trvfcblseclabel.blsecid = trvfcblsec.uniqueid
        AND trvfcblseclabel.language = 0
    INNER JOIN eio_publish.tenrox_private.trvfcblcat trvfcblcat 
      ON trvfcblcat.blsecid = trvfcblsec.uniqueid
    INNER JOIN
        eio_publish.tenrox_private.trvfcblcatlabel trvfcblcatlabel
        ON trvfcblcatlabel.blcatid = trvfcblcat.uniqueid
        AND trvfcblcatlabel.language = 0
    INNER JOIN
        eio_publish.tenrox_private.trvfcblitem trvfcblitem 
          ON trvfcblitem.blcatid = trvfcblcat.uniqueid
    INNER JOIN
        eio_publish.tenrox_private.trvfcblitemdata trvfcblitemdata
        ON trvfcblitemdata.blitemid = trvfcblitem.uniqueid
    INNER JOIN
        eio_publish.tenrox_private.tfcalperiod tfcalperiod
        ON tfcalperiod.uniqueid = trvfcblitemdata.calperiodid
        AND tfcalperiod.periodtype = 'M'
        AND tfcalperiod.calid = 4
    LEFT JOIN
        eio_publish.tenrox_private.tcharge tcharge
        ON CASE trvfcblitem.objecttype WHEN 129 THEN tcharge.uniqueid
    END = trvfcblitem.objectid
        AND tcharge.chargetype = 'M'
    RIGHT OUTER JOIN
        eio_publish.tenrox_private.tproject tproject 
        ON tproject.uniqueid = trvfcbaseline.projectid
    LEFT JOIN
        eio_publish.tenrox_private.tclientinvoice tclientinvoice
        ON tclientinvoice.clientid = tproject.clientid
    LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_month_q_ranges_v02 AS ranges
    LEFT OUTER JOIN
        (
            SELECT IFNULL(uniqueid, 1) AS lubasecurrencyid
            FROM eio_publish.tenrox_private.tcurrency tcurrency
            WHERE currencycode = 'USD'
        ) basecur
    -- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID
    LEFT OUTER JOIN
        (
            SELECT IFNULL(uniqueid, 1) AS overridecurid
            FROM eio_publish.tenrox_private.tcurrency
            WHERE currencycode = 'USD'
        ) usdcurid
    -- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID
    LEFT OUTER JOIN
        EIO_INGEST.TENROX_TRANSFORM.fcurrqexchrate AS fxrate
        ON fxrate.basecurrencyid = COALESCE(tclientinvoice.currencyid, lubasecurrencyid)
        -- only used in CUST_ADSK_MARGINVARIANCE WHERE @OverrideCurID = @USDCurID and is forced to 1,
        -- LUBaseCurrencyID is also always 1
        AND fxrate.quotecurrencyid = COALESCE(overridecurid, tclientinvoice.currencyid, lubasecurrencyid)
        AND CURRENT_DATE() BETWEEN fxrate.startdate AND fxrate.enddate
    WHERE
        trvfcbaseline.iscurrent = 1
        AND trvfcblitemdata.elementtype = 1
        AND trvfcblseclabel.label = 'Revenue'
        AND trvfcblcatlabel.label = 'Charges'
        AND trvfcblitem.objecttype = 129
        AND trvfcblitemdata.elementtype = 1
    GROUP BY tproject.uniqueid
  );

