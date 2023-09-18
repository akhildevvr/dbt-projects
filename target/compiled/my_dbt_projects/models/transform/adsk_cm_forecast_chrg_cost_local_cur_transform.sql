
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
     /* Exclude Ratable Billing */
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_nonratable_all
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                           THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                            WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                            ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_nonratable_future
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                         WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                         ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_nonratable_currentmonth
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_nonratable_futureqtrs
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentqtrbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_nonratable_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_nonratable_remaininginqtr
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
        AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_nonratable_plus1qtr
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
        AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_nonratable_plus2qtr
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
        AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_nonratable_plus3qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_nonratable_additionalqtrs
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
                AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_nonratable_customrange
    /* Ratable Costs Only */
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_ratable_all
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ratable_future
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                         WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                         ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_ratable_currentmonth
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ratable_futureqtrs
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentqtrbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_ratable_entirecurrentqtr
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_ratable_remaininginqtr
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
        AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_ratable_plus1qtr
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
        AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_ratable_plus2qtr
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
        AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_ratable_plus3qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ratable_additionalqtrs
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Ratable Billing' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
        AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                             WHEN lubasecurrencyid = overridecurid
                                                                                 THEN trvfcblitemdata.amountbasecurrency
                                                                             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_ratable_customrange
    /* All Charge Costs */
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                            WHEN lubasecurrencyid = overridecurid
                                                                                THEN trvfcblitemdata.amountbasecurrency
                                                                            ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_all
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_currentmonthbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_future
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_currentmonthbegins AND tfcalperiod.startdate < fnc_nextmonthbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_currentmonth
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_plus1qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_futureqtrs
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_currentqtrbegins AND tfcalperiod.startdate < fnc_plus1qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_currentmonthbegins AND tfcalperiod.startdate < fnc_plus1qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_remaininginqtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_plus1qtrbegins AND tfcalperiod.startdate < fnc_plus2qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_plus1qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_plus2qtrbegins AND tfcalperiod.startdate < fnc_plus3qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_plus2qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_plus3qtrbegins AND tfcalperiod.startdate < fnc_plus4qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_plus3qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_plus4qtrbegins AND tfcalperiod.startdate < fnc_plus5qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_plus4qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_plus5qtrbegins AND tfcalperiod.startdate < fnc_plus6qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_plus5qtr
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_plus4qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_additionalqtrs
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_plus6qtrbegins THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_additional2qtrs
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
        AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                             WHEN lubasecurrencyid = overridecurid
                                                                                 THEN trvfcblitemdata.amountbasecurrency
                                                                             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_customrange
    /* Third Party Product-Costs */
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_ipprodsales_all
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ipprodsales_future
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                 WHEN lubasecurrencyid = overridecurid
                                                                                     THEN trvfcblitemdata.amountbasecurrency
                                                                                 ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ipprodsales_currentmonth
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ipprodsales_futureqtrs
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' AND tfcalperiod.startdate >= fnc_currentqtrbegins
                AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ipprodsales_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ipprodsales_remaininginqtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
                AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ipprodsales_plus1qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
                AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ipprodsales_plus2qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
                AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ipprodsales_plus3qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' AND tfcalperiod.startdate >= fnc_plus4qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ipprodsales_additionalqtrs
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = 'Third Party Product-Costs' AND tfcalperiod.startdate >= fnc_fcst_customrangebegin
                AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(
                CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                     WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                     ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_ipprodsales_customrange
    /* 3rd Party-Non-Billable T&E */
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E' THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_3rdnonbillte_all
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdnonbillte_future
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                 WHEN lubasecurrencyid = overridecurid
                                                                                     THEN trvfcblitemdata.amountbasecurrency
                                                                                 ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdnonbillte_currentmonth
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdnonbillte_futureqtrs
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentqtrbegins
                AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdnonbillte_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdnonbillte_remaininginqtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
                AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdnonbillte_plus1qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
                AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdnonbillte_plus2qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
                AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdnonbillte_plus3qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E' AND tfcalperiod.startdate >= fnc_plus4qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdnonbillte_additionalqtrs
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Non-Billable T&E'
        AND tfcalperiod.startdate >= fnc_fcst_customrangebegin AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_3rdnonbillte_customrange
    /* 3rd Party-Billable Expenses */
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses' THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_3rdbillableexp_all
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdbillableexp_future
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                AND tfcalperiod.startdate < fnc_nextmonthbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                 WHEN lubasecurrencyid = overridecurid
                                                                                     THEN trvfcblitemdata.amountbasecurrency
                                                                                 ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdbillableexp_currentmonth
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdbillableexp_futureqtrs
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentqtrbegins
                AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdbillableexp_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_currentmonthbegins
                AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdbillableexp_remaininginqtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus1qtrbegins
                AND tfcalperiod.startdate < fnc_plus2qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdbillableexp_plus1qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus2qtrbegins
                AND tfcalperiod.startdate < fnc_plus3qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdbillableexp_plus2qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus3qtrbegins
                AND tfcalperiod.startdate < fnc_plus4qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdbillableexp_plus3qtr
     , SUM(IFNULL(
        CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses' AND tfcalperiod.startdate >= fnc_plus4qtrbegins
                 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                  WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                  ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgcost_3rdbillableexp_additionalqtrs
     , SUM(IFNULL(CASE WHEN trvfcblseclabel.label = 'Cost' AND tcharge.name = '3rd Party-Billable Expenses'
        AND tfcalperiod.startdate >= fnc_fcst_customrangebegin AND tfcalperiod.startdate < fnc_fcst_customrangeend THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgcost_3rdbillableexp_customrange
     , MAX(fnc_fcst_customrangebegin)        AS fcstchrgcost_customrangebegin, MAX(fnc_fcst_customrangeend) AS fcstchrgcost_customrangeend
     , 7                                     AS sqlversion_forecast_chrg_cost
    FROM eio_publish.tenrox_private.trvfcbaseline trvfcbaseline
    LEFT OUTER JOIN eio_publish.tenrox_private.trvfcbaselinebudget trvfcbaselinebudget
        ON trvfcbaselinebudget.baselineuid = trvfcbaseline.uniqueid 
    INNER JOIN eio_publish.tenrox_private.trvfcbltmpl trvfcbltmpl 
        ON trvfcbltmpl.baselineid = trvfcbaseline.uniqueid 
    INNER JOIN eio_publish.tenrox_private.trvfcblsec trvfcblsec 
        ON trvfcblsec.bltmplid = trvfcbltmpl.uniqueid 
    INNER JOIN eio_publish.tenrox_private.trvfcblseclabel trvfcblseclabel 
        ON trvfcblseclabel.blsecid = trvfcblsec.uniqueid 
        AND trvfcblseclabel.language = 0 
        AND trvfcblseclabel.label = 'Cost' 
    INNER JOIN eio_publish.tenrox_private.trvfcblcat trvfcblcat 
        ON trvfcblcat.blsecid = trvfcblsec.uniqueid 
    INNER JOIN eio_publish.tenrox_private.trvfcblcatlabel trvfcblcatlabel 
        ON trvfcblcatlabel.blcatid = trvfcblcat.uniqueid 
        AND trvfcblcatlabel.language = 0 
        AND trvfcblcatlabel.label = 'Charges'
    INNER JOIN eio_publish.tenrox_private.trvfcblitem trvfcblitem 
        ON trvfcblitem.blcatid = trvfcblcat.uniqueid 
        AND trvfcblitem.objecttype = 129 
    INNER JOIN eio_publish.tenrox_private.trvfcblitemdata trvfcblitemdata 
        ON trvfcblitemdata.blitemid = trvfcblitem.uniqueid 
        AND trvfcblitemdata.elementtype = 1 
    INNER JOIN eio_publish.tenrox_private.tfcalperiod tfcalperiod 
        ON tfcalperiod.uniqueid = trvfcblitemdata.calperiodid 
        AND tfcalperiod.periodtype = 'M' 
        AND tfcalperiod.calid = 4 
    INNER JOIN eio_publish.tenrox_private.tcharge tcharge 
        ON tcharge.uniqueid = trvfcblitem.objectid 
        AND tcharge.chargetype = 'M' 
    RIGHT OUTER JOIN eio_publish.tenrox_private.tproject tproject 
        ON tproject.uniqueid = trvfcbaseline.projectid 
    LEFT JOIN eio_publish.tenrox_private.tclientinvoice tclientinvoice 
        ON tclientinvoice.clientid = tproject.clientid 
    LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_month_q_ranges_v02 AS ranges
    LEFT OUTER JOIN  (SELECT
                         IFNULL(uniqueid, 1) AS lubasecurrencyid
                       FROM eio_publish.tenrox_private.tcurrency tcurrency
                       WHERE  currencycode = 'USD') BasebasecurCUR
     -- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     /* only used in CUST_ADSK_MARGINVARIANCE where OverrideCurID = @USDCurID and is forced to 1, LUBaseCurrencyID is also always 1
                    SELECT  
                         @USDCurID = ISNULL(UNIQUEID, 1)  
                         FROM   TCURRENCY  
                         WHERE  CURRENCYCODE = 'USD'
                    @USDCurID = LUBaseCurrencyID = @OverrideCurID = 1
     */
     LEFT OUTER JOIN (
                    SELECT
                         IFNULL(uniqueid, 1)      AS overridecurid
                    FROM eio_publish.tenrox_private.tcurrency
                    WHERE currencycode = 'USD'
                    ) usdcurid
     -- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.fcurrqexchrate AS fxrate
                  ON  fxrate.basecurrencyid = COALESCE(tclientinvoice.currencyid, lubasecurrencyid)
                 AND  fxrate.quotecurrencyid = COALESCE(NULL, tclientinvoice.currencyid, lubasecurrencyid)
                 AND  CURRENT_DATE() BETWEEN fxrate.startdate AND fxrate.enddate
     WHERE            trvfcbaseline.iscurrent = 1
     GROUP            BY
          tproject.uniqueid