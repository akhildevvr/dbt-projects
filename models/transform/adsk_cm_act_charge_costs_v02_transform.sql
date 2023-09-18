{{ config(
    alias='adsk_cm_act_charge_costs_v02'
) }}

/* adsk_cm_act_charge_costs_v02.sql
  @OverrideCurID   INT = 1
  , @RangeBegin    DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL
  , @Placeholder05 INT = NULL
  
	FXRate.BASECURRENCYID : @PBASECURRID=TCHARGEENTRY.CLIENTCURRENCYID
    FXRate.QUOTECURRENCYID : @PQUOTECURRID=COALESCE(1, TCHARGEENTRY.CLIENTCURRENCYID, LUBaseCurrencyID)
    FXRate.STARTDATE & ENDDATE : @PDATE=TCHARGEENTRY.CURRENTDATE
*/
SELECT 
    tproject.uniqueid AS projectid
     , SUM(IFNULL(CASE WHEN 1 = 1 THEN tchargeentry.amountclientcurrency * fxrate.rate
                                                       ELSE 0.00 END, 0.00)) AS actcostcharge_all
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_currentmonthbegins THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_past
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentmonthbegins AND tchargeentry.currentdate < fnc_nextmonthbegins
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_currentmonth
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_currentqtrbegins THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_pastqtrs
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentqtrbegins AND tchargeentry.currentdate < fnc_plus1qtrbegins
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentqtrbegins AND tchargeentry.currentdate < fnc_currentmonthbegins
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_completedinqtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus1qtrbegins AND tchargeentry.currentdate < fnc_currentqtrbegins
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_minus1qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus2qtrbegins AND tchargeentry.currentdate < fnc_minus1qtrbegins
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_minus2qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus3qtrbegins AND tchargeentry.currentdate < fnc_minus2qtrbegins
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_minus3qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_minus3qtrbegins THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_priorqtrs
     , SUM(IFNULL(CASE WHEN tchargeentry.currentdate >= fnc_hist_customrangebegin
        AND tchargeentry.currentdate < fnc_hist_customrangeend THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostcharge_customrange
    -- Chargest flagged as LABOR-Releated. (Mostly ratable.)
     , SUM(IFNULL(CASE WHEN 1 = 1 AND tcharge.custom1 = 1 THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostlaborcharge_all
     , SUM(IFNULL(CASE WHEN tchargeentry.currentdate < fnc_currentmonthbegins AND tcharge.custom1 = 1
                           THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostlaborcharge_past
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentmonthbegins AND tchargeentry.currentdate < fnc_nextmonthbegins
                AND tcharge.custom1 = 1 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostlaborcharge_currentmonth
     , SUM(IFNULL(CASE WHEN tchargeentry.currentdate < fnc_currentqtrbegins AND tcharge.custom1 = 1
                           THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostlaborcharge_pastqtrs
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentqtrbegins AND tchargeentry.currentdate < fnc_plus1qtrbegins
                AND tcharge.custom1 = 1 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostlaborcharge_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentqtrbegins AND tchargeentry.currentdate < fnc_currentmonthbegins
                AND tcharge.custom1 = 1 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostlaborcharge_completedinqtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus1qtrbegins AND tchargeentry.currentdate < fnc_currentqtrbegins
                AND tcharge.custom1 = 1 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostlaborcharge_minus1qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus2qtrbegins AND tchargeentry.currentdate < fnc_minus1qtrbegins
                AND tcharge.custom1 = 1 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostlaborcharge_minus2qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus3qtrbegins AND tchargeentry.currentdate < fnc_minus2qtrbegins
                AND tcharge.custom1 = 1 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostlaborcharge_minus3qtr
     , SUM(IFNULL(CASE WHEN tchargeentry.currentdate < fnc_minus3qtrbegins AND tcharge.custom1 = 1
                           THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostlaborcharge_priorqtrs
     , SUM(IFNULL(CASE WHEN tchargeentry.currentdate >= fnc_hist_customrangebegin
        AND tchargeentry.currentdate < fnc_hist_customrangeend AND tcharge.custom1 = 1
                           THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostlaborcharge_customrange
    -- Third Party Product-Costs
     , SUM(IFNULL(CASE WHEN 1 = 1 AND tcharge.name = 'Third Party Product-Costs'
                           THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_all
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_currentmonthbegins AND tcharge.name = 'Third Party Product-Costs'
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_past
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentmonthbegins AND tchargeentry.currentdate < fnc_nextmonthbegins
                AND tcharge.name = 'Third Party Product-Costs' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_currentmonth
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_currentqtrbegins AND tcharge.name = 'Third Party Product-Costs'
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_pastqtrs
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentqtrbegins AND tchargeentry.currentdate < fnc_plus1qtrbegins
                AND tcharge.name = 'Third Party Product-Costs' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentqtrbegins AND tchargeentry.currentdate < fnc_currentmonthbegins
                AND tcharge.name = 'Third Party Product-Costs' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_completedinqtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus1qtrbegins AND tchargeentry.currentdate < fnc_currentqtrbegins
                AND tcharge.name = 'Third Party Product-Costs' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_minus1qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus2qtrbegins AND tchargeentry.currentdate < fnc_minus1qtrbegins
                AND tcharge.name = 'Third Party Product-Costs' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_minus2qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus3qtrbegins AND tchargeentry.currentdate < fnc_minus2qtrbegins
                AND tcharge.name = 'Third Party Product-Costs' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_minus3qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_minus3qtrbegins AND tcharge.name = 'Third Party Product-Costs'
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_priorqtrs
     , SUM(IFNULL(CASE WHEN tchargeentry.currentdate >= fnc_hist_customrangebegin
        AND tchargeentry.currentdate < fnc_hist_customrangeend AND tcharge.name = 'Third Party Product-Costs'
                           THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostcharge_ipprodsales_customrange
    -- 3rd Party-Non-Billable T&E
     , SUM(IFNULL(CASE WHEN 1 = 1 AND tcharge.name = '3rd Party-Non-Billable T&E'
                           THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_all
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_currentmonthbegins AND tcharge.name = '3rd Party-Non-Billable T&E'
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_past
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentmonthbegins AND tchargeentry.currentdate < fnc_nextmonthbegins
                AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_currentmonth
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_currentqtrbegins AND tcharge.name = '3rd Party-Non-Billable T&E'
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_pastqtrs
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentqtrbegins AND tchargeentry.currentdate < fnc_plus1qtrbegins
                AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentqtrbegins AND tchargeentry.currentdate < fnc_currentmonthbegins
                AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_completedinqtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus1qtrbegins AND tchargeentry.currentdate < fnc_currentqtrbegins
                AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_minus1qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus2qtrbegins AND tchargeentry.currentdate < fnc_minus1qtrbegins
                AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_minus2qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus3qtrbegins AND tchargeentry.currentdate < fnc_minus2qtrbegins
                AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_minus3qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_minus3qtrbegins AND tcharge.name = '3rd Party-Non-Billable T&E'
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_priorqtrs
     , SUM(IFNULL(CASE WHEN tchargeentry.currentdate >= fnc_hist_customrangebegin
        AND tchargeentry.currentdate < fnc_hist_customrangeend AND tcharge.name = '3rd Party-Non-Billable T&E'
                           THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostcharge_3rdnonbillte_customrange
    -- 3rd Party-Billable Expenses
     , SUM(IFNULL(CASE WHEN 1 = 1 AND tcharge.name = '3rd Party-Billable Expenses'
                           THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_all
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_currentmonthbegins AND tcharge.name = '3rd Party-Billable Expenses'
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_past
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentmonthbegins AND tchargeentry.currentdate < fnc_nextmonthbegins
                AND tcharge.name = '3rd Party-Billable Expenses' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_currentmonth
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_currentqtrbegins AND tcharge.name = '3rd Party-Billable Expenses'
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_pastqtrs
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentqtrbegins AND tchargeentry.currentdate < fnc_plus1qtrbegins
                AND tcharge.name = '3rd Party-Billable Expenses' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_entirecurrentqtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_currentqtrbegins AND tchargeentry.currentdate < fnc_currentmonthbegins
                AND tcharge.name = '3rd Party-Billable Expenses' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_completedinqtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus1qtrbegins AND tchargeentry.currentdate < fnc_currentqtrbegins
                AND tcharge.name = '3rd Party-Billable Expenses' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_minus1qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus2qtrbegins AND tchargeentry.currentdate < fnc_minus1qtrbegins
                AND tcharge.name = '3rd Party-Billable Expenses' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_minus2qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate >= fnc_minus3qtrbegins AND tchargeentry.currentdate < fnc_minus2qtrbegins
                AND tcharge.name = '3rd Party-Billable Expenses' THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_minus3qtr
     , SUM(IFNULL(
        CASE WHEN tchargeentry.currentdate < fnc_minus3qtrbegins AND tcharge.name = '3rd Party-Billable Expenses'
                 THEN tchargeentry.amountclientcurrency * fxrate.rate
             ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_priorqtrs
     , SUM(IFNULL(CASE WHEN tchargeentry.currentdate >= fnc_hist_customrangebegin
        AND tchargeentry.currentdate < fnc_hist_customrangeend AND tcharge.name = '3rd Party-Billable Expenses'
                           THEN tchargeentry.amountclientcurrency * fxrate.rate
                       ELSE 0.00 END, 0.00)) AS actcostcharge_3rdbillableexp_customrange
     , 8 AS sqlversion_act_charge_costs
FROM {{ source('tenrox_private', 'tproject') }} tproject
LEFT JOIN {{ source('tenrox_private', 'ttask') }} ttask ON ttask.projectid = tproject.uniqueid
LEFT JOIN {{ source('tenrox_private', 'tchargeentry') }} tchargeentry
     ON tchargeentry.taskid = ttask.uniqueid AND tchargeentry.approved = 1
INNER JOIN
    {{ source('tenrox_private', 'tcharge') }} tcharge
    ON tcharge.uniqueid = tchargeentry.chargeid
    AND tcharge.costed = 1
    AND tcharge.chargetype = 'M'
LEFT OUTER JOIN {{ ref('adsk_month_q_ranges_v02_transform') }} AS ranges
LEFT OUTER JOIN(SELECT 
                  IFNULL(uniqueid, 1) AS lubasecurrencyid  -- if CURRENCYCODE = 'USD' has uniqueid null, it's still forced to value 1
               FROM {{ source('tenrox_private', 'tcurrency') }} tcurrency
               -- CURRENCYCODE = 'USD' means UNIQUEID is 1
               WHERE currencycode = 'USD') basecur
-- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN(SELECT 
                  IFNULL(uniqueid, 1) AS overridecurid 
               FROM {{ source('tenrox_private', 'tcurrency') }} 
               WHERE currencycode = 'USD'
               ) usdcurid
-- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN {{ ref('fcurrqexchrate_transform') }} AS fxrate
            ON fxrate.basecurrencyid = tchargeentry.clientcurrencyid
            AND fxrate.quotecurrencyid = COALESCE(overridecurid, tchargeentry.clientcurrencyid, lubasecurrencyid)  -- @OverrideCurID | @PQUOTECURRID is declared = 1 from adsk_fn_cm_marginvariance
            AND tchargeentry.currentdate BETWEEN fxrate.startdate AND fxrate.enddate
GROUP           BY
tproject.uniqueid