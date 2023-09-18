

/* CUST_ADSK_MARGINVARIANCE
  @BatchSize     INT = 10000  
  @BatchNumber INT = 0 
  @SQLScriptVersion = 6
  SET @RightNow = GETDATE()  
  SET @BeginingOfCurrentFY = CONVERT(DATETIME, '2/1/' + CONVERT(NVARCHAR(4), CASE MONTH(@RightNow) WHEN 1 THEN YEAR(@RightNow) - 1 ELSE YEAR(@RightNow) END))
  This gets the current FY start date from the current date, already used in adsk_month_q_ranges_v02 AS @CutoverDate

    @USDCurID forced to 1
  SELECT  
  @USDCurID = ISNULL(UNIQUEID, 1)  
  FROM   TCURRENCY  
  WHERE  CURRENCYCODE = 'USD'  
  Unique ID of CURRENCYCODE = 'USD' is 1
*/
WITH tmp_cust_adsk_marginvariance AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY project_details.projectid)        AS rownumber
        , project_details.projectid                                   AS projectid
        , projectcode                                                 AS projectcode
        , projectname                                                 AS projectname
        , portfolioname                                               AS portfolioname
        , adsk_geo_name                                               AS geo
        , CASE portfoliomanagername WHEN 'Bruce Hickey' THEN 'M&E'
                                    ELSE pm_site_active.name END      AS geo2
        , clientname                                                  AS customername
        , projectmanageremployeeid                                    AS projectmanagereeid
        , projectmanagername                                          AS projectmanagername
        , pm_site_active.name                                         AS projectmanagergeo
        , portfoliomanagername                                        AS portfoliomanager
        , projectstate                                                AS projectstate
        , adsk_masteragreement_projecttype                            AS projecttype
        , projectstartdate                                            AS projectstartdate
        , projectenddate                                              AS projectenddate
        , projectcurrency                                             AS projectcurrency
        , currentbillabletotal * IFNULL(rate, 1.00)                   AS planrevenue
        , currentcosttotal * IFNULL(rate, 1.00)                       AS plancost
        , currenthrsbillable + currenthrsnonbillable                  AS planhours
        , (IFNULL(hrsact_past, 0.00) + IFNULL(hrsact_nonbill_past, 0.00)
            + IFNULL(hrsact_utilized_past, 0.00) 
            + IFNULL(hrsfcst_future, 0.00))                           AS hrs_eac
        , IFNULL(labor_hrs.hrsact_all, 0.00)                          AS hrs_booked
        -- Hrs_ETC = Hrs_EAC - Hrs_Booked  
        , ((IFNULL(hrsact_past, 0.00) + IFNULL(hrsact_nonbill_past, 0.00)
                + IFNULL(hrsact_utilized_past, 0.00) + IFNULL(hrsfcst_future, 0.00))
                - IFNULL(labor_hrs.hrsact_all, 0.00))                 AS hrs_etc
        , ((IFNULL(revlabor_past, 0.00) + IFNULL(revlabor_future, 0.00)
            + IFNULL(recchrgrev_allbillable_past, 0.00) 
            + IFNULL(fcstchrgrev_allbillable_future, 0.00)))          AS eac_revenue
        , ((IFNULL(actcostlabor_past, 0.00) 
            + IFNULL(actcostcharge_past, 0.00)
            + IFNULL(fcstcostlabor_future, 0.00) 
            + IFNULL(fcstchrgcost_future, 0.00)))                     AS eac_cost
        , ((IFNULL(actcostlabor_customrange, 0.00)
            + IFNULL(actcostcharge_customrange, 0.00)))               AS priorfycost
        , initialworkdate                                             AS initialworkdate
        , CASE WHEN projectstate IN ('Completed', 'TECO', 'Closed',
                                     'End Time Capture', 'PA Review-Completion',
                                     'SCO-Completed', 'SCO-Closed', 'Archive')
                   THEN finalworkdate END                             AS finalworkdate
        , adsk_planned_end_date                                       AS planned_end_date
        , adsk_accountingcontracttype                                 AS accountingcontracttype
        , adsk_revrectreatment                                        AS revrectreatment
        , project_details.tenroxtrackingno
FROM EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_details AS project_details
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.tprojectcustfld_view ON tprojectcustfld_view.projectid = project_details.projectid
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_const_curr AS const_curr ON const_curr.currencycode = project_details.projectcurrency
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_budget AS project_budget ON project_budget.projectid = project_details.projectid
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_act_charge_costs_v02 AS act_charge_costs ON act_charge_costs.projectid = project_details.projectid
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_act_labor_costs_v02 AS act_labor_costs ON act_labor_costs.projectid = project_details.projectid
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_forecast_chrg_rev_v02 AS forecast_chrg_rev ON forecast_chrg_rev.projectid = project_details.projectid
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_forecast_chrg_cost AS forecast_chrg_cost ON forecast_chrg_cost.projectid = project_details.projectid
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_forecast_labor_costs AS forecast_labor_costs ON forecast_labor_costs.projectid = project_details.projectid
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_labor_hrs_v02 AS labor_hrs ON labor_hrs.projectid = project_details.projectid
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_labor_rev_v02 AS labor_rev ON labor_rev.projectid = project_details.projectid
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_rec_chrg_rev_v02 AS rec_chrg_rev ON rec_chrg_rev.projectid = project_details.projectid
LEFT OUTER JOIN eio_publish.tenrox_private.tuser tuser ON tuser.uniqueid = project_details.projectmanagerid
LEFT OUTER JOIN eio_publish.tenrox_private.tsite pm_site_active ON pm_site_active.uniqueid = tuser.activesiteid
LEFT OUTER JOIN
 (  
  SELECT
      tproject.uniqueid               AS projectid
      , MIN(entrydate)                AS initialworkdate
      , MAX(entrydate)               AS finalworkdate
    FROM eio_publish.tenrox_private.ttimesheetentries ttimesheetentries
    JOIN eio_publish.tenrox_private.ttask ttask ON ttimesheetentries.taskuid = ttask.uniqueid 
    JOIN eio_publish.tenrox_private.tproject tproject ON tproject.uniqueid = ttask.projectid
    WHERE ttimesheetentries.approved = 1
    GROUP BY tproject.uniqueid
 ) tbl_workdates ON tbl_workdates.projectid = project_details.projectid 
WHERE projectname NOT LIKE 'ZZ-%'
)

SELECT
     rownumber
     , projectid
     , projectcode
     , projectname
     , portfolioname
     , geo
     , geo2
     , customername
     , projectmanagereeid
     , projectmanagername
     , projectmanagergeo
     , portfoliomanager
     , projectstate
     , projecttype
     , projectstartdate
     , projectenddate
     , projectcurrency
     , planrevenue
     , plancost
     , planhours
     , hrs_eac
     , hrs_booked
     , hrs_etc
     , eac_revenue
     , eac_cost
     , priorfycost
     , initialworkdate
     , finalworkdate
     , 'Const USD'                      AS displayedcurrency
     , 1::BOOLEAN                       AS wasnewtable
     , 6                                AS sqlscriptversion
     , planned_end_date
     , accountingcontracttype
     , revrectreatment
     , tenroxtrackingno
FROM tmp_cust_adsk_marginvariance
     -- WHERE  RowNumber >= (@BatchNumber * @BatchSize) + 1  
     -- AND RowNumber < (@BatchNumber * @BatchSize) + @BatchSize + 1  
ORDER BY rownumber