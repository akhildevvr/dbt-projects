

/* CUST_ADSK_SERVICESIMPACT_PROJECTDETAILS 
  @BatchSize     INT = 10000
  , @BatchNumber INT = 0
  @SQLScriptVersion = 11
  @ReportStartDate = '1990-02-01'
  @ReportStartDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @ReportStartDate), 0)  --> this is just '1990-02-01'
  
  InitialWorkDate and FinalWorkDate always 
*/

-- TMP_CUST_ADSK_SERVICESIMPACT_PROJECTDETAILS
WITH tmp_cust_adsk_servicesimpact_projectdetails AS (
    SELECT 
        ROW_NUMBER() OVER ( ORDER BY project_details.projectid)   AS rownumber
        , project_details.projectid                               AS projectid
        , project_details.clientname                              AS clientname
        , tclient.id                                              AS clientcsn
        , project_details.projectname                             AS projectname
        , project_details.projectcode                             AS projectcode
        , project_budget.currentbillabletotal                     AS planrevenue
        , udfs.adsk_geo_name                                      AS geo
        , IFNULL(fcsthrs.hrsfcst, 0.0)                            AS hrsetc
        , project_details.projectstartdate                        AS projectstartdate
        , tbl_workdates.initialworkdate                           AS initialworkdate
        , tbl_workdates.finalworkdate                             AS finalworkdate
        , project_details.projectstate                            AS projectstate
        , 11                                                      AS sqlscriptversion
        , udfs.adsk_contractstartdate                             AS contract_start_date
        , udfs.adsk_contractenddate                               AS contract_end_date
      FROM EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_details AS project_details
      INNER JOIN EIO_INGEST.TENROX_TRANSFORM.tprojectcustfld_view AS udfs
          ON udfs.projectid = project_details.projectid 
      INNER JOIN eio_publish.tenrox_private.tclient tclient
          ON tclient.uniqueid = project_details.clientid 
      LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_budget AS project_budget
          ON project_budget.projectid = project_details.projectid
      LEFT OUTER JOIN (SELECT
                         trplnbooking.projectid                                           AS projectid
                         , SUM(IFNULL(trplnbookingdetails.bookedseconds, 0.00)) / 3600.00 AS hrsfcst
                    FROM eio_publish.tenrox_private.trplnbooking trplnbooking
                    INNER JOIN eio_publish.tenrox_private.trplnbookingdetails trplnbookingdetails
                        ON trplnbookingdetails.bookingid = trplnbooking.uniqueid
                    INNER JOIN eio_publish.tenrox_private.trplnbookingattributes trplnbookingattributes
                        ON trplnbookingattributes.bookingid = trplnbooking.uniqueid
                    WHERE trplnbookingdetails.bookeddate >= DATE'1990-02-01'
                        AND trplnbooking.bookingtype = 1
                    GROUP BY trplnbooking.projectid) fcsthrs
                   ON fcsthrs.projectid = project_details.projectid
      LEFT OUTER JOIN (SELECT
                        tproject.uniqueid               AS projectid
                        , MIN(entrydate)               AS initialworkdate
                        , MAX(entrydate)               AS finalworkdate
                      FROM eio_publish.tenrox_private.ttimesheetentries ttimesheetentries
                      JOIN eio_publish.tenrox_private.ttask ttask
                          ON ttimesheetentries.taskuid = ttask.uniqueid
                      JOIN eio_publish.tenrox_private.tproject tproject 
                          ON tproject.uniqueid = ttask.projectid
                      WHERE ttimesheetentries.approved = 1
                      GROUP BY tproject.uniqueid) tbl_workdates
                        ON tbl_workdates.projectid = project_details.projectid
      WHERE project_details.projectid NOT IN (SELECT uniqueid
                                              FROM eio_publish.tenrox_private.tproject tproject 
                                              WHERE releasealias = 'A-ADMIN-00001')
            -- AND PROJECT_DETAILS.ProjectState NOT IN ('SCO-Funnel', 'Funnel', 'Booking Credit', 'FY14 Booking Credit'
            -- , 'SCO-Discarded', 'Discarded', 'Active-Internal-Utilized', 'Active-Internal-Non-Utilized'
            -- , 'Bookings Program', 'PA Review â€“ Booking', 'PA - Conversion Review')
      ORDER BY project_details.projectid
)

-- Select from TMP_CUST_ADSK_SERVICESIMPACT_PROJECTDETAILS
SELECT 
    rownumber
     , projectid
     , clientname
     , clientcsn
     , projectname
     , projectcode
     , planrevenue
     , geo
     , hrsetc
     , projectstartdate
     , initialworkdate
     , finalworkdate
     , projectstate
     , 0::BOOLEAN AS wasnewtable
     , sqlscriptversion
     , contract_start_date
     , contract_end_date
FROM tmp_cust_adsk_servicesimpact_projectdetails 
    -- WHERE RowNumber >= (0 * 10000) + 1
    -- AND RowNumber < (0 * 10000) + 10000 + 1
ORDER BY rownumber