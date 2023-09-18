
  create or replace   view eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_monthly_chrg_rev
  
   as (
    
/* ADSK_FN_CM_MONTHLY_CHRG_REV.sql
  @OverrideCurID   INT = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/

    SELECT
       TTASK.PROJECTID                                                   AS ProjectID
       , TRUNC(TCHARGEENTRY.CURRENTDATE, 'month')                        AS MonthOfChrgRev
       , SUM(IFNULL(CASE
                      WHEN TCHARGEENTRY.BILLABLE = 1 THEN
                        IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE
                        0.00
                    END, 0.00))                                          AS MonthsChrgRev_AllBillable
       -- 3rd Party-Billable Expenses     RecChrgRev_3rdBillableExp
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.BILLABLE = 1 THEN
                        IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE
                        0.00
                    END, 0.00))                                          AS MonthsChrgRev_3rdBillableExp
       -- 3rd Party-Non-Billable T&E      RecChrgRev_3rdNonBillTE
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.BILLABLE = 1 THEN
                        IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE
                        0.00
                    END, 0.00))                                          AS MonthsChrgRev_3rdNonBillTE
       -- Internal-Billable Expenses      RecChrgRev_InternalBillableExp
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.BILLABLE = 1 THEN
                        IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE
                        0.00
                    END, 0.00))                                          AS MonthsChrgRev_InternalBillableExp
       -- Internal-Non-Billable T&E       RecChrgRev_InternalNonBillTE
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.BILLABLE = 1 THEN
                        IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE
                        0.00
                    END, 0.00))                                          AS MonthsChrgRev_InternalNonBillTE
       -- Ratable Billing                 RecChrgRev_RatableBilling
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.BILLABLE = 1 THEN
                        IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE
                        0.00
                    END, 0.00))                                          AS MonthsChrgRev_RatableBilling
       -- Sys Conv-Labor Non-Billable     RecChrgRev_SysConvNonBill
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.BILLABLE = 1 THEN
                        IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE
                        0.00
                    END, 0.00))                                          AS MonthsChrgRev_SysConvNonBill
       -- Sys Conv-Labor Revenue          RecChrgRev_SysConvLaborRev
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.BILLABLE = 1 THEN
                        IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE
                        0.00
                    END, 0.00))                                          AS MonthsChrgRev_SysConvLaborRev
       -- Autodesk IP Product-Sales       MonthsChrgRev_IPProdSales
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.BILLABLE = 1 THEN
                        IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE
                        0.00
                    END, 0.00))                                          AS MonthsChrgRev_IPProdSales
       -- Third Party Product-Sales       RecChrgRev_3rdProdSales
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.BILLABLE = 1 THEN
                        IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE
                        0.00
                    END, 0.00))                                          AS MonthsChrgRev_3rdProdSales
       -- SQL Script Version Information
       , 6                                                               AS SQLVersion_MONTHLY_CHRG_REV
     FROM            eio_publish.tenrox_private.TTASK TTASK
     LEFT JOIN eio_publish.tenrox_private.TCHARGEENTRY TCHARGEENTRY
                  ON TCHARGEENTRY.TASKID = TTASK.UNIQUEID
                 AND TCHARGEENTRY.APPROVED = 1
     INNER JOIN eio_publish.tenrox_private.TCHARGE TCHARGE
                  ON TCHARGE.UNIQUEID = TCHARGEENTRY.CHARGEID
     LEFT OUTER JOIN (
                    SELECT
                        IFNULL(UNIQUEID, 1) AS LUBaseCurrencyID
                    FROM   eio_publish.tenrox_private.TCURRENCY TCURRENCY
                    WHERE  CURRENCYCODE = 'USD') BaseCUR
     -- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN (
                    SELECT
                        IFNULL(UNIQUEID, 1) AS OverrideCurID
                    FROM   eio_publish.tenrox_private.TCURRENCY TCURRENCY
                    WHERE  CURRENCYCODE = 'USD') USDCurID
     -- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.fcurrqexchrate as FXRate
                ON FXRate.BASECURRENCYID = COALESCE(TCHARGEENTRY.CURRENCYID, LUBaseCurrencyID)
                AND FXRate.QUOTECURRENCYID = COALESCE(OverrideCurID, TCHARGEENTRY.CLIENTCURRENCYID, LUBaseCurrencyID)
                AND TCHARGEENTRY.CURRENTDATE BETWEEN FXRate.STARTDATE AND FXRate.ENDDATE
     WHERE      TCHARGE.CHARGETYPE = 'M'
     GROUP           BY
      TTASK.PROJECTID
      , TRUNC(TCHARGEENTRY.CURRENTDATE, 'month')
  );

