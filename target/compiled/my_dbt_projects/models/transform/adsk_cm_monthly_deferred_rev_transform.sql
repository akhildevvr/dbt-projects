
/* ADSK_FN_CM_MONTHLY_DEFERRED_REV
  @OverrideCurID   INT = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/
SELECT 
     IFNULL(calitems.projectid, monthly_rec_rev.projectid)                            AS projectid
     , IFNULL(calitems.monthtoinclude, monthly_rec_rev.monthrecognized)               AS revenuemonth
     , IFNULL(monthly_chrg_rev.monthschrgrev_allbillable, 0.00)                       AS chrgrevenue
     , IFNULL(monthly_expect_labor_rev.expectedlaborrevenue, 0.00)                    AS expectedlaborrevenue
     , IFNULL(monthly_chrg_rev.monthschrgrev_allbillable, 0.00)
        + IFNULL(monthly_expect_labor_rev.expectedlaborrevenue, 0.00)                 AS totalexpectedrevenue
     , IFNULL(monthly_rec_rev.recognizedrevenue, 0.00)                                AS recognizedrevenue
     , IFNULL(monthly_rec_rev.recognizedrevenue, 0.00) 
         - (IFNULL(monthly_chrg_rev.monthschrgrev_allbillable, 0.00)
        + IFNULL(monthly_expect_labor_rev.expectedlaborrevenue, 0.00))                AS deferredrevenue
     , SUM((IFNULL(monthly_chrg_rev.monthschrgrev_allbillable, 0.00)
        + IFNULL(monthly_expect_labor_rev.expectedlaborrevenue, 0.00))
                   - IFNULL(monthly_rec_rev.recognizedrevenue, 0.00))
           OVER ( PARTITION BY IFNULL(calitems.projectid, monthly_rec_rev.projectid)) AS totaldeferredrevenue
     , 9                                                                              AS sqlversion_monthly_deferred_rev
FROM (SELECT
      tproject.uniqueid           AS projectid
      , tfcalperiod.startdate     AS monthtoinclude
    FROM eio_publish.tenrox_private.tfcalperiod tfcalperiod
    INNER JOIN eio_publish.tenrox_private.tproject tproject
      ON tfcalperiod.startdate >= TRUNC(tproject.startdate, 'MONTH') 
      AND tfcalperiod.startdate <= CASE 
                                      WHEN tproject.enddate > DATEADD('MONTH', 1, TRUNC(CURRENT_DATE(), 'MONTH')) 
                                          THEN DATEADD('MONTH', 1, TRUNC(CURRENT_DATE(), 'MONTH')) 
                                      ELSE tproject.enddate 
                                  END 
      AND tfcalperiod.periodtype = 'M' 
      AND tfcalperiod.calid = 4) calitems
FULL OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_monthly_expect_labor_rev AS monthly_expect_labor_rev
    ON monthly_expect_labor_rev.projectid = calitems.projectid 
    AND monthly_expect_labor_rev.monthofexpectedlaborrev = calitems.monthtoinclude 
FULL OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_monthly_chrg_rev AS monthly_chrg_rev 
    ON monthly_chrg_rev.projectid = calitems.projectid 
    AND monthly_chrg_rev.monthofchrgrev < TRUNC(CURRENT_DATE(), 'MONTH') 
    AND monthly_chrg_rev.monthofchrgrev = calitems.monthtoinclude 
FULL OUTER JOIN (SELECT 
                    projectid
                    , monthrecognized
                    , recognizedrevenue 
                FROM EIO_INGEST.TENROX_TRANSFORM.adsk_cm_monthly_rec_rev 
                WHERE monthrecognized IS NOT NULL) monthly_rec_rev 
    ON monthly_rec_rev.projectid = calitems.projectid 
    AND monthly_rec_rev.monthrecognized = calitems.monthtoinclude
    WHERE COALESCE(monthly_expect_labor_rev.projectid, monthly_chrg_rev.projectid, monthly_rec_rev.projectid) IS NOT NULL