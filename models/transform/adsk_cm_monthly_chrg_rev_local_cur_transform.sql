{{ config(
    alias='adsk_cm_monthly_chrg_rev_local_cur'
) }}
/* ADSK_FN_CM_MONTHLY_CHRG_REV.sql
  @OverrideCurID   INT = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/

    SELECT
        CASE
           WHEN lower(parent_child.adsk_master_projecttype) in ( 'is parent' ) THEN
               ttask.projectid  
           WHEN lower(parent_child.adsk_master_projecttype) IN ( 'is master', 'is child' ) THEN
               parent_child.parentid 
           ELSE
               ttask.projectid
        END                                                                                                                               AS projectid
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
     FROM            {{ source('tenrox_private', 'ttask') }} ttask
     LEFT JOIN {{ source('tenrox_private', 'tchargeentry') }} tchargeentry
                  ON tchargeentry.taskid = ttask.uniqueid
                 AND tchargeentry.approved = 1
     INNER JOIN {{ source('tenrox_private', 'tcharge') }} tcharge
                  ON tcharge.uniqueid = tchargeentry.chargeid
     LEFT JOIN (
        SELECT  
            tproject.uniqueid AS projectid
            ,tproject.parentid as parentid
            ,LSTDESC_16.VALUE as adsk_master_projecttype
        
        FROM 
            {{ source('tenrox_private', 'tproject') }}  tproject
        LEFT JOIN {{ source('tenrox_private', 'tprojectcustfld') }}  a On a.PROJECTID = tproject.uniqueid
        LEFT JOIN {{ source('tenrox_private', 'tcustlst') }} AS LST_16  ON a.ADSK_MasterAgreement_ProjectType = LST_16.UNIQUEID 
        LEFT JOIN {{ source('tenrox_private', 'tcustlstdesc') }} AS LSTDESC_16  ON LST_16.UNIQUEID = LSTDESC_16.CUSTLSTID AND LSTDESC_16.LANGUAGE = 0
                ) parent_child ON parent_child.projectid = ttask.projectid
     LEFT OUTER JOIN (
                    SELECT
                        IFNULL(uniqueid, 1) AS lubasecurrencyid
                    FROM   {{ source('tenrox_private', 'tcurrency') }} tcurrency
                    WHERE  currencycode = 'USD') basecur
     -- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN (
                    SELECT
                        IFNULL(uniqueid, 1) AS overridecurid
                    FROM   {{ source('tenrox_private', 'tcurrency') }} tcurrency
                    WHERE  currencycode = 'USD') usdcurid
     -- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN {{ ref('fcurrqexchrate_transform') }} as fxrate
                ON fxrate.basecurrencyid = COALESCE(tchargeentry.currencyid, lubasecurrencyid)
                AND fxrate.quotecurrencyid = COALESCE(NULL, tchargeentry.clientcurrencyid, lubasecurrencyid)
                AND tchargeentry.currentdate BETWEEN fxrate.startdate AND fxrate.enddate
     WHERE      tcharge.chargetype = 'M'
     GROUP BY
      CASE
           WHEN lower(parent_child.adsk_master_projecttype) in ( 'is parent' ) THEN
               ttask.projectid  
           WHEN lower(parent_child.adsk_master_projecttype) IN ( 'is master', 'is child' ) THEN
               parent_child.parentid 
           ELSE
               ttask.projectid
       END
      , TRUNC(tchargeentry.currentdate, 'month')