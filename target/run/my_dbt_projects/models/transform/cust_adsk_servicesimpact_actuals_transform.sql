
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.cust_adsk_servicesimpact_actuals
  
   as (
    

/* CUST_ADSK_SERVICESIMPACT_ACTUALS.sql 
  @BatchSize     INT = 10000
  @BatchNumber INT = 0
  @SQLScriptVersion = 4
  var @SQLScriptVersion is referenced only here in CUST_ADSK_SERVICESIMPACT_ACTUALS.sql and value set to 4
*/

WITH tmp_cust_adsk_servicesimpact_actuals AS (
        SELECT 
            ROW_NUMBER()
                OVER (
                    ORDER BY t.projectid, TRUNC(tse.entrydate, 'MONTH') , pr.name
            )                                                       AS rownumber
          , t.projectid                                                                         AS projectid
          , TRUNC(tse.entrydate, 'MONTH')                                                       AS hrsmonth
          , pr.name                                                                             AS userrole
          , SUM(IFNULL(totaltime, 0.00)) / 3600.00                                              AS hrsactual
          , 4                                                                                   AS sqlscriptversion
        FROM eio_publish.tenrox_private.ttimesheetentries AS tse
        INNER JOIN eio_publish.tenrox_private.ttask AS t ON tse.taskuid = t.uniqueid
        INNER JOIN eio_publish.tenrox_private.tuserplanningrole AS upr 
            ON upr.userid = tse.useruid AND upr.isprimaryrole = 1
        INNER JOIN eio_publish.tenrox_private.tplanningrole AS pr 
            ON pr.uniqueid = upr.planningroleid
        WHERE tse.entrydate >= DATE '1990-02-01'
            AND tse.approved = 1
            AND t.projectid NOT IN (SELECT uniqueid 
                                    FROM eio_publish.tenrox_private.tproject 
                                    WHERE releasealias = 'A-ADMIN-00001')
            AND t.projectid NOT IN (
                SELECT projectid
                FROM EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_details
                WHERE
                    projectstate IN (
                        'SCO-Funnel',
                        'Funnel',
                        'Booking Credit',
                        'FY14 Booking Credit',
                        'SCO-Discarded',
                        'Discarded',
                        'Active-Internal-Utilized',
                        'Active-Internal-Non-Utilized',
                        'Bookings Program',
                        'PA Review – Booking',
                        'PA - Conversion Review'
                    )
            )
        GROUP BY t.projectid, TRUNC(tse.entrydate, 'MONTH'), pr.name
        ORDER BY t.projectid, TRUNC(tse.entrydate, 'MONTH'), pr.name
)

SELECT 
    rownumber
     , projectid
     , hrsmonth
     , userrole
     , hrsactual
     , 1::BOOLEAN                    AS wasnewtable
     , sqlscriptversion
FROM tmp_cust_adsk_servicesimpact_actuals
     -- WHERE  RowNumber >= (0 * 1000) + 1
     -- AND RowNumber < (0 * 1000) + 1000 + 1
ORDER BY rownumber
  );

