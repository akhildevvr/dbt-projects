
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_budget_v02
  
   as (
    

/* ADSK_FN_CM_PROJECT_BUDGET_V02
  @OverrideCurID    INT
  , @FXRateDateMode INT = 1
 1 = GETDATE(), 2 = TPROJECT.STARTDATE, 3 = TPROJECTCUSTFLD_VIEW.ADSK_Master_ContractDate [Defaults to TPROJECT.STARTDATE if NULL]

  , @Placeholder03  INT = NULL
  , @Placeholder04  INT = NULL
  , @Placeholder05  INT = NULL
*/
    SELECT 
         tproject.uniqueid AS projectid
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 1
            AND tbudgetdetailentry.entrysubtype IS NULL AND tbudgetdetailentry.objectid IS NULL
                                                        THEN tbudgetdetailentry.baselinevalue / 3600
                                                    ELSE 0 END) AS baselinehrstotal
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 3
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue / 3600
                    ELSE 0 END) AS baselinehrsbillable
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 4
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue / 3600
                    ELSE 0 END) AS baselinehrsnonbillable
        --budget time/hours - current
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype IS NULL
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue / 3600
                      ELSE 0.00 END) AS currenthrstotal, SUM(CASE WHEN tbudgetdetailentry.entrytype = 1
            AND tbudgetdetailentry.entrysubtype = 3 AND tbudgetdetailentry.objectid IS NULL
                                                                      THEN tbudgetdetailentry.currentvalue / 3600
                                                                  ELSE 0.00 END) AS currenthrsbillable
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 4
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue / 3600
                    ELSE 0.00 END) AS currenthrsnonbillable
        --budget costs - baseline
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype IS NULL
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                      ELSE 0.00 END) AS baselinecosttotal, SUM(CASE WHEN tbudgetdetailentry.entrytype = 2
            AND tbudgetdetailentry.entrysubtype = 2 AND tbudgetdetailentry.objectid IS NULL
                                                                        THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                                                                    ELSE 0.00 END) AS baselinecostcharge
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 3
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinecostproduct
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 4
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinecosttime
        --budget costs - current
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype IS NULL
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
                      ELSE 0.00 END) AS currentcosttotal
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2
            AND tbudgetdetailentry.entrysubtype = 2 AND tbudgetdetailentry.objectid IS NULL
                                                                       THEN tbudgetdetailentry.currentvalue * fxrate.rate
                                                                   ELSE 0.00 END) AS currentcostcharge
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 3
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentcostproduct
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 4
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentcosttime
        --budget billable - baseline
        , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype IS NULL
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                      ELSE 0.00 END) AS baselinebillabletotal
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3
            AND tbudgetdetailentry.entrysubtype = 2 AND tbudgetdetailentry.objectid IS NULL
                                                                            THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                                                                        ELSE 0.00 END)
            - SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                AND tcharge.name = 'Ratable Billing' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                       ELSE 0.00 END) AS baselinebillablecharge
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 3
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinebillableproduct
         , SUM(CASE WHEN (tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 4
            AND tbudgetdetailentry.objectid IS NULL)
                        /* OR (TBUDGETDETAILENTRY.ENTRYTYPE = 3
                        AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                        AND TCHARGE.NAME = 'Ratable Billing') */
                        THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinebillabletime
        --budget billable - current
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype IS NULL
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
                      ELSE 0.00 END) AS currentbillabletotal
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3
            AND tbudgetdetailentry.entrysubtype = 2 AND tbudgetdetailentry.objectid IS NULL
                                                                           THEN tbudgetdetailentry.currentvalue * fxrate.rate
                                                                       ELSE 0.00 END)
            - SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                AND tcharge.name = 'Ratable Billing' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                       ELSE 0.00 END) AS currentbillablecharge
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 3
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentbillableproduct
         , SUM(CASE WHEN (tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 4
            AND tbudgetdetailentry.objectid IS NULL)
                        /* OR (TBUDGETDETAILENTRY.ENTRYTYPE = 3
                        AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                        AND TCHARGE.NAME = 'Ratable Billing') */
                        THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentbillabletime
        --budget non-billable - baseline
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype IS NULL
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                      ELSE 0.00 END) AS baselinenonbillabletotal
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 4
            AND tbudgetdetailentry.entrysubtype = 2 AND tbudgetdetailentry.objectid IS NULL
                                                                               THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                                                                           ELSE 0.00 END) AS baselinenonbillablecharge
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 3
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinenonbillableproduct
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 4
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinenonbillabletime
        --budget non-billable - current
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype IS NULL
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
                      ELSE 0.00 END) AS currentnonbillabletotal
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 4
            AND tbudgetdetailentry.entrysubtype = 2 AND tbudgetdetailentry.objectid IS NULL
                                                                              THEN tbudgetdetailentry.currentvalue * fxrate.rate
                                                                          ELSE 0.00 END) AS currentnonbillablecharge
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 3
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentnonbillableproduct
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 4
            AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentnonbillabletime
        -- Breakouts
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = '3rd Party-Billable Expenses' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinecostcharge3rdbillableexp
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinecostcharge3rdnonbillablete
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Autodesk IP Product-Sales' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinecostchargeipproductsales
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Internal-Billable Expenses' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinecostchargeinternalbillableexp
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Internal-Non-Billable T&E' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinecostchargeinternalnonbillte
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Third Party Product-Costs' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinecostcharge3rdprodcosts
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Third Party Product-Sales' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinecostcharge3rdprodsales
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Ratable Billing' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinecostchargeratablebilling
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = '3rd Party-Billable Expenses' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentcostcharge3rdbillableexp
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentcostcharge3rdnonbillablete
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Autodesk IP Product-Sales' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentcostchargeipproductsales
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Internal-Billable Expenses' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentcostchargeinternalbillableexp
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Internal-Non-Billable T&E' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentcostchargeinternalnonbillte
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Third Party Product-Costs' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentcostcharge3rdprodcosts
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Third Party Product-Sales' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentcostcharge3rdprodsales
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Ratable Billing' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentcostchargeratablebilling
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = '3rd Party-Billable Expenses' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinebillablecharge3rdbillableexp
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinebillablecharge3rdnonbillablete
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Autodesk IP Product-Sales' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinebillablechargeipproductsales
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Internal-Billable Expenses' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinebillablechargeinternalbillableexp
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Internal-Non-Billable T&E' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinebillablechargeinternalnonbillte
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Ratable Billing' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinebillablechargeratablebilling
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Third Party Product-Costs' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinebillablecharge3rdprodcosts
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Third Party Product-Sales' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                    ELSE 0.00 END) AS baselinebillablecharge3rdprodsales
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = '3rd Party-Billable Expenses' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentbillablecharge3rdbillableexp
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentbillablecharge3rdnonbillablete
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Autodesk IP Product-Sales' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentbillablechargeipproductsales
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Internal-Billable Expenses' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentbillablechargeinternalbillableexp
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Internal-Non-Billable T&E' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentbillablechargeinternalnonbillte
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Ratable Billing' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentbillablechargeratablebilling
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Third Party Product-Costs' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentbillablecharge3rdprodcosts
         , SUM(CASE WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
            AND tcharge.name = 'Third Party Product-Sales' THEN tbudgetdetailentry.currentvalue * fxrate.rate
                    ELSE 0.00 END) AS currentbillablecharge3rdprodsales
         , 1 AS sqlversion_project_budget_v02
    FROM eio_publish.tenrox_private.tproject tproject
    LEFT OUTER JOIN
        eio_publish.tenrox_private.tbudgetdetail tbudgetdetail ON tbudgetdetail.objectid = tproject.uniqueid
    LEFT OUTER JOIN
        eio_publish.tenrox_private.tbudgetdetaillist tbudgetdetaillist
        ON tbudgetdetail.objecttype = 2
        AND tbudgetdetail.uniqueid = tbudgetdetaillist.budgetdetailedid
    LEFT OUTER JOIN
        eio_publish.tenrox_private.tbudgetdetailentry tbudgetdetailentry
        ON tbudgetdetaillist.uniqueid = tbudgetdetailentry.budgetdetailedlistid
    LEFT OUTER JOIN eio_publish.tenrox_private.tcharge tcharge ON tcharge.uniqueid = tbudgetdetailentry.objectid
    LEFT OUTER JOIN eio_publish.tenrox_private.tclient tclient ON tclient.uniqueid = tproject.clientid
    LEFT OUTER JOIN
        eio_publish.tenrox_private.tclientinvoice tclientinvoice ON tclientinvoice.clientid = tclient.uniqueid
    LEFT OUTER JOIN
        EIO_INGEST.TENROX_TRANSFORM.tprojectcustfld_view tprojectcustfld_view
        ON tproject.uniqueid = tprojectcustfld_view.projectid
    LEFT OUTER JOIN
        (   
            SELECT 
               currencyid 
            FROM eio_publish.tenrox_private.tsysdefs tsysdefs 
            WHERE uniqueid = 1
         ) basecurrency
    LEFT OUTER JOIN
        (
            SELECT IFNULL(uniqueid, 1) AS lubasecurrencyid
            FROM eio_publish.tenrox_private.tcurrency tcurrency
            WHERE currencycode = 'USD'
        ) basecur
    LEFT OUTER JOIN
        EIO_INGEST.TENROX_TRANSFORM.fcurrqexchrate AS fxrate
        ON fxrate.basecurrencyid = COALESCE(tclientinvoice.currencyid, tbudgetdetail.billcurrencyid, lubasecurrencyid)
        AND fxrate.quotecurrencyid = COALESCE(tclientinvoice.currencyid, tbudgetdetail.billcurrencyid, lubasecurrencyid)
        AND CURRENT_DATE() BETWEEN fxrate.startdate AND fxrate.enddate
    /*                  CASE
                             @FXRateDateMode
                             WHEN 1 THEN GETDATE()
                             WHEN 2 THEN TPROJECT.STARTDATE
                             WHEN 3 THEN IFNULL(CONVERT(DATETIME, TPROJECTCUSTFLD_VIEW.ADSK_Master_ContractDate), TPROJECT.STARTDATE)
                         END) FXRate
    */
    GROUP BY tproject.uniqueid
  );

