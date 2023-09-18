
  create or replace   view eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_project_budget
  
   as (
    
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
       TPROJECT.UNIQUEID     AS ProjectID
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 1
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE IS NULL
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE / 3600
               ELSE 0
             END)            AS BaselineHrsTotal
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 1
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 3
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE / 3600
               ELSE 0
             END)            AS BaselineHrsBillable
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 1
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 4
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE / 3600
               ELSE 0
             END)            AS BaselineHrsNonBillable
       --Budget Time/Hours - CURRENT
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 1
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE IS NULL
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE / 3600
               ELSE 0.00
             END)            AS CurrentHrsTotal
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 1
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 3
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE / 3600
               ELSE 0.00
             END)            AS CurrentHrsBillable
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 1
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 4
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE / 3600
               ELSE 0.00
             END)            AS CurrentHrsNonBillable
       --Budget Costs - BASELINE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE IS NULL
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostTotal
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostCharge
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 3
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostProduct
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 4
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostTime
       --Budget Costs - CURRENT
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE IS NULL
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostTotal
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostCharge
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 3
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostProduct
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 4
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostTime
       --Budget Billable - BASELINE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE IS NULL
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableTotal
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END) - SUM(CASE
                          WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                               AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                               AND TCHARGE.NAME = 'Ratable Billing' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
                          ELSE 0.00
                        END) AS BaselineBillableCharge
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 3
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableProduct
       , SUM(CASE
               WHEN (TBUDGETDETAILENTRY.ENTRYTYPE = 3
                     AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 4
                     AND TBUDGETDETAILENTRY.OBJECTID IS NULL)
             /* OR (TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Ratable Billing') */
             THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableTime
       --Budget Billable - CURRENT
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE IS NULL
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableTotal
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END) - SUM(CASE
                          WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                               AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                               AND TCHARGE.NAME = 'Ratable Billing' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
                          ELSE 0.00
                        END) AS CurrentBillableCharge
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 3
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableProduct
       , SUM(CASE
               WHEN (TBUDGETDETAILENTRY.ENTRYTYPE = 3
                     AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 4
                     AND TBUDGETDETAILENTRY.OBJECTID IS NULL)
             /* OR (TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Ratable Billing') */
             THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableTime
       --Budget Non-Billable - BASELINE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 4
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE IS NULL
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineNonBillableTotal
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 4
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineNonBillableCharge
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 4
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 3
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineNonBillableProduct
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 4
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 4
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineNonBillableTime
       --Budget Non-Billable - CURRENT
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 4
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE IS NULL
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentNonBillableTotal
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 4
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentNonBillableCharge
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 4
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 3
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentNonBillableProduct
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 4
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 4
                    AND TBUDGETDETAILENTRY.OBJECTID IS NULL THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentNonBillableTime
       -- Breakouts
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostCharge3rdBillableExp
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostCharge3rdNonBillableTE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Autodesk IP Product-Sales' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostChargeIPProductSales
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Internal-Billable Expenses' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostChargeInternalBillableExp
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Internal-Non-Billable T&E' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostChargeInternalNonBillTE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostCharge3rdProdCosts
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Third Party Product-Sales' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostCharge3rdProdSales
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Ratable Billing' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineCostChargeRatableBilling
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostCharge3rdBillableExp
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostCharge3rdNonBillableTE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Autodesk IP Product-Sales' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostChargeIPProductSales
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Internal-Billable Expenses' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostChargeInternalBillableExp
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Internal-Non-Billable T&E' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostChargeInternalNonBillTE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostCharge3rdProdCosts
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Third Party Product-Sales' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostCharge3rdProdSales
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 2
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Ratable Billing' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentCostChargeRatableBilling
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableCharge3rdBillableExp
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableCharge3rdNonBillableTE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Autodesk IP Product-Sales' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableChargeIPProductSales
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Internal-Billable Expenses' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableChargeInternalBillableExp
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Internal-Non-Billable T&E' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableChargeInternalNonBillTE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Ratable Billing' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableChargeRatableBilling
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableCharge3rdProdCosts
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Third Party Product-Sales' THEN TBUDGETDETAILENTRY.BASELINEVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS BaselineBillableCharge3rdProdSales
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableCharge3rdBillableExp
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableCharge3rdNonBillableTE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Autodesk IP Product-Sales' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableChargeIPProductSales
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Internal-Billable Expenses' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableChargeInternalBillableExp
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Internal-Non-Billable T&E' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableChargeInternalNonBillTE
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Ratable Billing' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableChargeRatableBilling
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Third Party Product-Costs' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableCharge3rdProdCosts
       , SUM(CASE
               WHEN TBUDGETDETAILENTRY.ENTRYTYPE = 3
                    AND TBUDGETDETAILENTRY.ENTRYSUBTYPE = 2
                    AND TCHARGE.NAME = 'Third Party Product-Sales' THEN TBUDGETDETAILENTRY.CURRENTVALUE * FXRate.RATE
               ELSE 0.00
             END)            AS CurrentBillableCharge3rdProdSales
       , 8                   AS SQLVersion_PROJECT_BUDGET
     FROM eio_publish.tenrox_private.TPROJECT TPROJECT
     LEFT JOIN eio_publish.tenrox_private.TBUDGETDETAIL TBUDGETDETAIL
                  ON TBUDGETDETAIL.OBJECTID = TPROJECT.UNIQUEID
     LEFT JOIN eio_publish.tenrox_private.TBUDGETDETAILLIST TBUDGETDETAILLIST
                  ON TBUDGETDETAIL.OBJECTTYPE = 2
                 AND TBUDGETDETAIL.UNIQUEID = TBUDGETDETAILLIST.BUDGETDETAILEDID
     LEFT JOIN eio_publish.tenrox_private.TBUDGETDETAILENTRY TBUDGETDETAILENTRY
                  ON TBUDGETDETAILLIST.UNIQUEID = TBUDGETDETAILENTRY.BUDGETDETAILEDLISTID
     LEFT JOIN eio_publish.tenrox_private.TCHARGE TCHARGE
                  ON TCHARGE.UNIQUEID = TBUDGETDETAILENTRY.OBJECTID
     LEFT JOIN eio_publish.tenrox_private.TCLIENT TCLIENT
                  ON TCLIENT.UNIQUEID = TPROJECT.CLIENTID
     LEFT JOIN eio_publish.tenrox_private.TCLIENTINVOICE TCLIENTINVOICE
                  ON TCLIENTINVOICE.CLIENTID = TCLIENT.UNIQUEID
     LEFT JOIN (
                    SELECT
                        CURRENCYID
                    FROM eio_publish.tenrox_private.TSYSDEFS TSYSDEFS
                    WHERE  UNIQUEID = 1
                    ) BASECURRENCY
     LEFT OUTER JOIN (
                    SELECT
                        IFNULL(UNIQUEID, 1) AS LUBaseCurrencyID
                    FROM eio_publish.tenrox_private.TCURRENCY TCURRENCY
                    WHERE  CURRENCYCODE = 'USD'
                    ) BaseCUR
     -- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN (
                    SELECT
                         IFNULL(UNIQUEID, 1)      AS OverrideCurID
                    FROM eio_publish.tenrox_private.TCURRENCY
                    WHERE CURRENCYCODE = 'USD'
                    ) USDCurID
     -- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
    LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.fcurrqexchrate as FXRate
               /*from original Tenrox Proc: FCURRQEXCHRATE
                 WHERE dbo.TCURRASSOC.BASECURRENCYID=@PBASECURRID
	                    AND dbo.TCURRASSOC.QUOTECURRENCYID=@PQUOTECURRID
	                    AND @PDATE BETWEEN dbo.TCURRRATE.STARTDATE AND dbo.TCURRRATE.ENDDATE 
               */
                ON FXRate.BASECURRENCYID = COALESCE(TCLIENTINVOICE.CURRENCYID, TBUDGETDETAIL.BILLCURRENCYID, LUBaseCurrencyID)
                -- traced back to final table CUST_ADSK_MARGINVARIANCE where @OverrideCurID  = @USDCurID = 1 
                -- as well as final table CUST_ADSK_SERVICESIMPACT_PROJECTDETAILS where value passed = 1
                AND FXRate.QUOTECURRENCYID = COALESCE(OverrideCurID, TCLIENTINVOICE.CURRENCYID, TBUDGETDETAIL.BILLCURRENCYID, LUBaseCurrencyID)
                AND CURRENT_DATE() BETWEEN FXRate.STARTDATE AND FXRate.ENDDATE
     GROUP           BY
      TPROJECT.UNIQUEID
  );

