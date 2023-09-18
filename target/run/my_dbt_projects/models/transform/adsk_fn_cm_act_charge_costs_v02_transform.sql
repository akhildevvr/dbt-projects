
  create or replace   view eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_act_charge_costs_v02
  
   as (
    

/* ADSK_FN_CM_ACT_CHARGE_COSTS_V02.sql
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
  TPROJECT.UNIQUEID        AS ProjectID
  , SUM(IFNULL(CASE
                WHEN 1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_All
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_Past
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_CurrentMonth
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_PastQtrs
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_EntireCurrentQtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_CompletedInQtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_Minus1Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_Minus2Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_Minus3Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_PriorQtrs
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_CustomRange
  -- Chargest flagged as LABOR-Releated. (Mostly ratable.)
  , SUM(IFNULL(CASE
                WHEN 1 = 1
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_All
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_Past
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_CurrentMonth
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_PastQtrs
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_EntireCurrentQtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_CompletedInQtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_Minus1Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_Minus2Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_Minus3Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_PriorQtrs
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd
                     AND TCHARGE.CUSTOM1 = 1 THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostLaborCharge_CustomRange
  -- Third Party Product-Costs
  , SUM(IFNULL(CASE
                WHEN 1 = 1
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_All
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_Past
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_CurrentMonth
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_PastQtrs
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_EntireCurrentQtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_CompletedInQtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_Minus1Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_Minus2Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_Minus3Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_PriorQtrs
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd
                     AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_IPProdSales_CustomRange
  -- 3rd Party-Non-Billable T&E
  , SUM(IFNULL(CASE
                WHEN 1 = 1
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_All
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_Past
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_CurrentMonth
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_PastQtrs
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_EntireCurrentQtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_CompletedInQtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_Minus1Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_Minus2Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_Minus3Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_PriorQtrs
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd
                     AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdNonBillTE_CustomRange
  -- 3rd Party-Billable Expenses
  , SUM(IFNULL(CASE
                WHEN 1 = 1
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_All
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_Past
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_CurrentMonth
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_PastQtrs
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_EntireCurrentQtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_CompletedInQtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_Minus1Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_Minus2Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_Minus3Qtr
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_PriorQtrs
  , SUM(IFNULL(CASE
                WHEN TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                     AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd
                     AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TCHARGEENTRY.AMOUNTCLIENTCURRENCY * FXRate.Rate
                ELSE 0.00
              END, 0.00)) AS ActCostCharge_3rdBillableExp_CustomRange
  , 8                      AS SQLVersion_ACT_CHARGE_COSTS
FROM eio_publish.tenrox_private.TPROJECT TPROJECT
LEFT JOIN eio_publish.tenrox_private.TTASK TTASK
            ON TTASK.PROJECTID = TPROJECT.UNIQUEID
LEFT JOIN eio_publish.tenrox_private.TCHARGEENTRY TCHARGEENTRY
            ON TCHARGEENTRY.TASKID = TTASK.UNIQUEID
           AND TCHARGEENTRY.APPROVED = 1
INNER JOIN eio_publish.tenrox_private.TCHARGE TCHARGE
       ON TCHARGE.UNIQUEID = TCHARGEENTRY.CHARGEID
      AND TCHARGE.COSTED = 1
      AND TCHARGE.CHARGETYPE = 'M'
LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_month_q_ranges_v02 AS Ranges
LEFT OUTER JOIN (SELECT
                    IFNULL(UNIQUEID, 1) AS LUBaseCurrencyID     -- if CURRENCYCODE = 'USD' has uniqueid null, it's still forced to value 1
                FROM eio_publish.tenrox_private.TCURRENCY TCURRENCY
                -- CURRENCYCODE = 'USD' means UNIQUEID is 1
                WHERE CURRENCYCODE = 'USD') BaseCUR
-- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN (
               SELECT
                    IFNULL(UNIQUEID, 1)      AS OverrideCurID
               FROM eio_publish.tenrox_private.TCURRENCY
               WHERE CURRENCYCODE = 'USD'
               ) USDCurID
-- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.fcurrqexchrate AS FXRate
             ON FXRate.BASECURRENCYID = TCHARGEENTRY.CLIENTCURRENCYID
            AND FXRate.QUOTECURRENCYID = COALESCE(OverrideCurID, TCHARGEENTRY.CLIENTCURRENCYID, LUBaseCurrencyID)    -- @OverrideCurID | @PQUOTECURRID is declared = 1 from adsk_fn_cm_marginvariance
            AND TCHARGEENTRY.CURRENTDATE BETWEEN FXRate.STARTDATE AND FXRate.ENDDATE
GROUP           BY
TPROJECT.UNIQUEID
  );

