
 /* ADSK_FN_CM_MONTHLY_EXPECT_LABOR_REV.sql
   @OverrideCurID   INT = NULL
  , @Placeholder01 INT = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
 */

  with ttask_timesheet as (
 
 SELECT
   CASE
           WHEN lower(parent_child.adsk_master_projecttype) in ( 'is parent' ) THEN
               ttask.projectid  
           WHEN lower(parent_child.adsk_master_projecttype) IN ( 'is master', 'is child' ) THEN
               parent_child.parentid 
           ELSE
               ttask.projectid
       END                                                                                AS projectid      
     , TRUNC(ttimesheetentries.entrydate, 'month')                                         AS monthofexpectedlaborrev
     , (SUM(IFNULL(totaltime, 0.00)) / 3600.00)                                            AS hrsactthismonth
     ,ttimesheetentries.entrydate                                                          AS entrydate

FROM eio_publish.tenrox_private.ttimesheetentries ttimesheetentries
INNER JOIN eio_publish.tenrox_private.ttask ttask
    ON ttask.uniqueid = ttimesheetentries.taskuid
 LEFT JOIN
(SELECT  
 tproject.uniqueid AS projectid
 ,tproject.parentid as parentid
 ,LSTDESC_16.VALUE as adsk_master_projecttype
 
 FROM 
    eio_publish.tenrox_private.tproject  tproject
        LEFT JOIN eio_publish.tenrox_private.tprojectcustfld  a On a.PROJECTID = tproject.uniqueid
        LEFT JOIN eio_publish.tenrox_private.tcustlst AS LST_16  ON a.ADSK_MasterAgreement_ProjectType = LST_16.UNIQUEID 
        LEFT JOIN eio_publish.tenrox_private.tcustlstdesc AS LSTDESC_16  ON LST_16.UNIQUEID = LSTDESC_16.CUSTLSTID AND LSTDESC_16.LANGUAGE = 0
) parent_child ON parent_child.projectid = ttask.projectid

WHERE ttimesheetentries.approved = 1
    AND ttimesheetentries.billable = 1
     and TRUNC(ttimesheetentries.entrydate, 'month') < TRUNC(CURRENT_DATE (), 'month') --and parent_child.parentid  IN (15007)
GROUP BY
 CASE
           WHEN lower(parent_child.adsk_master_projecttype) in ( 'is parent' ) THEN
               ttask.projectid  
           WHEN lower(parent_child.adsk_master_projecttype) IN ( 'is master', 'is child' ) THEN
               parent_child.parentid 
           ELSE
               ttask.projectid
       END                                                                                   
     --,ttask.projectid                                                                     
     , TRUNC(ttimesheetentries.entrydate, 'month')
   ,ttimesheetentries.entrydate    
     )
 
 
 SELECT 
    ttask.projectid     AS projectid
    ,ttask.monthofexpectedlaborrev AS monthofexpectedlaborrev
    ,sum(hrsactthismonth) AS hrsactthismonth
    ,NULLIF(labor_hrs.hrs_billable_eac, 0.00)                                            AS hrs_eac
    ,SUM(hrsactthismonth) / NULLIF(labor_hrs.hrs_billable_eac, 0.00) AS monthslaborpct
    ,project_budget.currentbillabletime                                                  AS totallaborrevenue
    ,IFNULL(
        (((SUM(hrsactthismonth) / NULLIF(labor_hrs.hrs_billable_eac, 0.00)) * fxlookup.rate)
                * project_budget.currentbillabletime), 0.00)                             AS expectedlaborrevenue
    ,fxlookup.rate                                                                       AS fxrateused
    ,COALESCE(project_details.projectcurrencyid, lubasecurrencyid)                       AS fromcur
    ,COALESCE(overridecurid, project_details.projectcurrencyid)                          AS tocur
FROM ttask_timesheet AS ttask
LEFT JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_labor_hrs_v02 AS labor_hrs
    ON labor_hrs.projectid = ttask.projectid
LEFT JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_budget_local_cur AS project_budget
    ON project_budget.projectid = ttask.projectid
LEFT JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_details AS project_details
    ON project_details.projectid = ttask.projectid
 LEFT OUTER JOIN (
               SELECT
                   IFNULL(uniqueid, 1) AS lubasecurrencyid
               FROM eio_publish.tenrox_private.tcurrency 
               WHERE  currencycode = 'USD'
               ) AS basecur
-- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN (
                SELECT
                    IFNULL(uniqueid, 1)      AS overridecurid
                FROM eio_publish.tenrox_private.tcurrency
                WHERE currencycode = 'USD'
                ) usdcurid
-- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.fcurrqexchrate AS fxlookup
    ON fxlookup.basecurrencyid = COALESCE(project_details.projectcurrencyid, basecur.lubasecurrencyid)
    AND fxlookup.quotecurrencyid = COALESCE(NULL, project_details.projectcurrencyid)
    AND ttask.entrydate BETWEEN fxlookup.startdate AND fxlookup.enddate

GROUP BY
ttask.projectid
    , ttask.monthofexpectedlaborrev
    , NULLIF(labor_hrs.hrs_billable_eac, 0.00)
    , project_budget.currentbillabletime
    , fxlookup.rate
    , COALESCE(project_details.projectcurrencyid, lubasecurrencyid)
    , COALESCE(overridecurid, project_details.projectcurrencyid)