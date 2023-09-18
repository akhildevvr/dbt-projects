
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_cm_monthly_chrg_rev
  
   as (
    
/* ADSK_FN_CM_MONTHLY_CHRG_REV.sql
  @OverrideCurID   INT = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/

    SELECT
         ttask.projectid                                                                                                                  AS projectid
         , TRUNC(tchargeentry.currentdate, 'month')                                                                                       AS monthofchrgrev
         , SUM(IFNULL(CASE
                          WHEN tchargeentry.billable = 1 THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                              AS monthschrgrev_allbillable
        -- 3rd Party-Billable Expenses     RecChrgRev_3rdBillableExp
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                              AS monthschrgrev_3rdbillableexp
        -- 3rd Party-Non-Billable T&E      RecChrgRev_3rdNonBillTE
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                              AS monthschrgrev_3rdnonbillte
        -- Internal-Billable Expenses      RecChrgRev_InternalBillableExp
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                              AS monthschrgrev_internalbillableexp
        -- Internal-Non-Billable T&E       RecChrgRev_InternalNonBillTE
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                              AS monthschrgrev_internalnonbillte
        -- Ratable Billing                 RecChrgRev_RatableBilling
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Ratable Billing' 
                          AND tchargeentry.billable = 1 THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                              AS monthschrgrev_ratablebilling
        -- Sys Conv-Labor Non-Billable     RecChrgRev_SysConvNonBill
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                              AS monthschrgrev_sysconvnonbill
        -- Sys Conv-Labor Revenue          RecChrgRev_SysConvLaborRev
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Sys Conv-Labor Revenue' 
                          AND tchargeentry.billable = 1 THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                              AS monthschrgrev_sysconvlaborrev
        -- Autodesk IP Product-Sales       MonthsChrgRev_IPProdSales
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                              AS monthschrgrev_ipprodsales
        -- Third Party Product-Sales       RecChrgRev_3rdProdSales
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                              AS monthschrgrev_3rdprodsales
        -- SQL Script Version Information
         , 6                                                                                                                              AS sqlversion_monthly_chrg_rev
FROM eio_publish.tenrox_private.ttask ttask
LEFT JOIN
    eio_publish.tenrox_private.tchargeentry tchargeentry
    ON tchargeentry.taskid = ttask.uniqueid
    AND tchargeentry.approved = 1
INNER JOIN
    eio_publish.tenrox_private.tcharge tcharge
    ON tcharge.uniqueid = tchargeentry.chargeid
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
        FROM eio_publish.tenrox_private.tcurrency tcurrency
        WHERE currencycode = 'USD'
    ) usdcurid
-- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN
    EIO_INGEST.TENROX_TRANSFORM.fcurrqexchrate AS fxrate
    ON fxrate.basecurrencyid = COALESCE(tchargeentry.currencyid, lubasecurrencyid)
    AND fxrate.quotecurrencyid
    = COALESCE(overridecurid, tchargeentry.clientcurrencyid, lubasecurrencyid)
    AND tchargeentry.currentdate BETWEEN fxrate.startdate AND fxrate.enddate
WHERE tcharge.chargetype = 'M'
GROUP BY ttask.projectid, TRUNC(tchargeentry.currentdate, 'month')
  );

