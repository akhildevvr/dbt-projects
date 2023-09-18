{{ config(
    alias='adsk_cm_project_budget_local_cur'
) }}
/* ADSK_FN_CM_PROJECT_BUDGET.sql 
@OverrideCurID INT

Referenced in:
ADSK_FN_CM_LABOR_REV_V02 -> refererd to only in CUST_ADSK_MARGINVARIANCE
ADSK_FN_CM_MONTHLY_EXPECT_LABOR_REV -> referenced to only in ADSK_FN_CM_MONTHLY_DEFERRED_REV which referred to in
     - ADSK_FN_CM_DEFERRED_REV which is referenced to only in ADSK_FN_CM_LABOR_REV_V02, which is only referenced to in CUST_ADSK_MARGINVARIANCE
     - CUST_ADSK_MARGINVARIANCE
ADSK_FN_CM_PROJECT_BUDGET_V02 as ALTER FUNCTION ONLY
CUST_ADSK_MARGINVARIANCE -> where @USDCURID = 1 and passed to this ADSK_FN_CM_PROJECT_BUDGET as @OverrideCurID
CUST_ADSK_SERVICESIMPACT_PROJECTDETAILS -> where 1 is passed to this ADSK_FN_CM_PROJECT_BUDGET as @OverrideCurID

@OverrideCurID = 1
*/
SELECT
    tproject.uniqueid AS projectid
     , SUM(CASE
                WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype IS NULL
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue / 3600
                 ELSE 0 END) AS baselinehrstotal
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 3
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue / 3600
               ELSE 0 END) AS baselinehrsbillable
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 4
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue / 3600
               ELSE 0 END) AS baselinehrsnonbillable
    --Budget Time/Hours - CURRENT
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype IS NULL
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue / 3600
               ELSE 0.00 END) AS currenthrstotal
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 3
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue / 3600
               ELSE 0.00 END) AS currenthrsbillable
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 4
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue / 3600
               ELSE 0.00 END) AS currenthrsnonbillable
    --Budget Costs - BASELINE
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype IS NULL
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecosttotal
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecostcharge
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 3
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecostproduct
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 4
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecosttime
    --Budget Costs - CURRENT
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype IS NULL
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcosttotal
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcostcharge
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 3
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcostproduct
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 4
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcosttime
    --Budget Billable - BASELINE
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype IS NULL
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillabletotal
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) - SUM(CASE
                                        WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                                                AND tcharge.name = 'Ratable Billing'
                                            THEN tbudgetdetailentry.baselinevalue * fxrate.rate
                                        ELSE 0.00 END) AS baselinebillablecharge
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 3
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillableproduct
     , SUM(CASE
               WHEN (tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 4
                       AND tbudgetdetailentry.objectid IS NULL)
                   /* OR (TBUDGETDETAILENTRY.ENTRYTYPE = 3
                          AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                          AND TCHARGE.NAME = 'Ratable Billing') */
                   THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillabletime
    --Budget Billable - CURRENT
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype IS NULL
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillabletotal
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) - SUM(CASE
                                        WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                                                AND tcharge.name = 'Ratable Billing'
                                            THEN tbudgetdetailentry.currentvalue * fxrate.rate
                                        ELSE 0.00 END) AS currentbillablecharge
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 3
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillableproduct
     , SUM(CASE
               WHEN (tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 4
                       AND tbudgetdetailentry.objectid IS NULL)
                   /* OR (TBUDGETDETAILENTRY.ENTRYTYPE = 3
                          AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                          AND TCHARGE.NAME = 'Ratable Billing') */
                   THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillabletime
    --Budget Non-Billable - BASELINE
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype IS NULL
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinenonbillabletotal
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 2
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinenonbillablecharge
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 3
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinenonbillableproduct
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 4
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinenonbillabletime
    --Budget Non-Billable - CURRENT
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype IS NULL
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentnonbillabletotal
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 2
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentnonbillablecharge
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 3
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentnonbillableproduct
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 4
                       AND tbudgetdetailentry.objectid IS NULL THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentnonbillabletime
    -- Breakouts
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = '3rd Party-Billable Expenses' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecostcharge3rdbillableexp
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecostcharge3rdnonbillablete
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Autodesk IP Product-Sales' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecostchargeipproductsales
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Internal-Billable Expenses' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecostchargeinternalbillableexp
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Internal-Non-Billable T&E' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecostchargeinternalnonbillte
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Third Party Product-Costs' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecostcharge3rdprodcosts
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Third Party Product-Sales' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecostcharge3rdprodsales
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2 AND tcharge.name = 'Ratable Billing'
                   THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinecostchargeratablebilling
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = '3rd Party-Billable Expenses' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcostcharge3rdbillableexp
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcostcharge3rdnonbillablete
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Autodesk IP Product-Sales' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcostchargeipproductsales
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Internal-Billable Expenses' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcostchargeinternalbillableexp
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Internal-Non-Billable T&E' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcostchargeinternalnonbillte
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Third Party Product-Costs' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcostcharge3rdprodcosts
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Third Party Product-Sales' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcostcharge3rdprodsales
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2 AND tcharge.name = 'Ratable Billing'
                   THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentcostchargeratablebilling
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = '3rd Party-Billable Expenses' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillablecharge3rdbillableexp
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillablecharge3rdnonbillablete
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Autodesk IP Product-Sales' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillablechargeipproductsales
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Internal-Billable Expenses' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillablechargeinternalbillableexp
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Internal-Non-Billable T&E' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillablechargeinternalnonbillte
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2 AND tcharge.name = 'Ratable Billing'
                   THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillablechargeratablebilling
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Third Party Product-Costs' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillablecharge3rdprodcosts
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Third Party Product-Sales' THEN tbudgetdetailentry.baselinevalue * fxrate.rate
               ELSE 0.00 END) AS baselinebillablecharge3rdprodsales
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = '3rd Party-Billable Expenses' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillablecharge3rdbillableexp
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = '3rd Party-Non-Billable T&E' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillablecharge3rdnonbillablete
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Autodesk IP Product-Sales' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillablechargeipproductsales
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Internal-Billable Expenses' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillablechargeinternalbillableexp
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Internal-Non-Billable T&E' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillablechargeinternalnonbillte
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2 AND tcharge.name = 'Ratable Billing'
                   THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillablechargeratablebilling
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Third Party Product-Costs' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillablecharge3rdprodcosts
     , SUM(CASE
               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2
                       AND tcharge.name = 'Third Party Product-Sales' THEN tbudgetdetailentry.currentvalue * fxrate.rate
               ELSE 0.00 END) AS currentbillablecharge3rdprodsales
     , 8 AS sqlversion_project_budget
FROM {{ source('tenrox_private', 'tproject') }} tproject
LEFT JOIN {{ source('tenrox_private', 'tbudgetdetail') }} tbudgetdetail
    ON tbudgetdetail.objectid = tproject.uniqueid 
LEFT JOIN {{ source('tenrox_private', 'tbudgetdetaillist') }} tbudgetdetaillist 
    ON tbudgetdetail.objecttype = 2 
    AND tbudgetdetail.uniqueid = tbudgetdetaillist.budgetdetailedid 
LEFT JOIN {{ source('tenrox_private', 'tbudgetdetailentry') }} tbudgetdetailentry 
    ON tbudgetdetaillist.uniqueid = tbudgetdetailentry.budgetdetailedlistid 
LEFT JOIN {{ source('tenrox_private', 'tcharge') }} tcharge 
    ON tcharge.uniqueid = tbudgetdetailentry.objectid 
LEFT JOIN {{ source('tenrox_private', 'tclient') }} tclient 
    ON tclient.uniqueid = tproject.clientid 
LEFT JOIN {{ source('tenrox_private', 'tclientinvoice') }} tclientinvoice 
    ON tclientinvoice.clientid = tclient.uniqueid
LEFT JOIN (
               SELECT
                   currencyid
               FROM {{ source('tenrox_private', 'tsysdefs') }} tsysdefs
               WHERE  uniqueid = 1
               ) basecurrency
LEFT OUTER JOIN (
               SELECT
                   IFNULL(uniqueid, 1) AS lubasecurrencyid
               FROM {{ source('tenrox_private', 'tcurrency') }} tcurrency
               WHERE  currencycode = 'USD'
               ) basecur
-- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN (
               SELECT
                    IFNULL(uniqueid, 1)      AS overridecurid
               FROM {{ source('tenrox_private', 'tcurrency') }}
               WHERE currencycode = 'USD'
               ) usdcurid
-- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN {{ ref('fcurrqexchrate_transform') }} AS fxrate
    /*from original Tenrox Proc: FCURRQEXCHRATE
            WHERE dbo.TCURRASSOC.BASECURRENCYID=@PBASECURRID
                   AND dbo.TCURRASSOC.QUOTECURRENCYID=@PQUOTECURRID
                   AND @PDATE BETWEEN dbo.TCURRRATE.STARTDATE AND dbo.TCURRRATE.ENDDATE
          */
    ON fxrate.basecurrencyid = COALESCE(tclientinvoice.currencyid, tbudgetdetail.billcurrencyid, lubasecurrencyid) 
    -- traced back to final table CUST_ADSK_MARGINVARIANCE where @OverrideCurID  = @USDCurID = 1
    -- as well as final table CUST_ADSK_SERVICESIMPACT_PROJECTDETAILS where value passed = 1
    AND fxrate.quotecurrencyid = COALESCE(NULL, tclientinvoice.currencyid, tbudgetdetail.billcurrencyid, lubasecurrencyid) 
    AND CURRENT_DATE () BETWEEN fxrate.startdate AND fxrate.enddate
GROUP BY 
     tproject.uniqueid