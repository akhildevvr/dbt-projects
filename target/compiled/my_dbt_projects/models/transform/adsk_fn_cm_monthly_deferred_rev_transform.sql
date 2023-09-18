
/* ADSK_FN_CM_MONTHLY_DEFERRED_REV
  @OverrideCurID   INT = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/
    SELECT
      IFNULL(CalItems.ProjectID, MONTHLY_REC_REV.ProjectID)                                                               AS ProjectID
      , IFNULL(CalItems.MonthToInclude, MONTHLY_REC_REV.MonthRecognized)                                                  AS RevenueMonth
      , IFNULL(MONTHLY_CHRG_REV.MonthsChrgRev_AllBillable, 0.00)                                                          AS ChrgRevenue
      , IFNULL(MONTHLY_EXPECT_LABOR_REV.ExpectedLaborRevenue, 0.00)                                                       AS ExpectedLaborRevenue
      , IFNULL(MONTHLY_CHRG_REV.MonthsChrgRev_AllBillable, 0.00)
       + IFNULL(MONTHLY_EXPECT_LABOR_REV.ExpectedLaborRevenue, 0.00)                                                      AS TotalExpectedRevenue
      , IFNULL(MONTHLY_REC_REV.RecognizedRevenue, 0.00)                                                                   AS RecognizedRevenue
      , IFNULL(MONTHLY_REC_REV.RecognizedRevenue, 0.00) - (IFNULL(MONTHLY_CHRG_REV.MonthsChrgRev_AllBillable, 0.00)
                                                          + IFNULL(MONTHLY_EXPECT_LABOR_REV.ExpectedLaborRevenue, 0.00))  AS DeferredRevenue
      , SUM((IFNULL(MONTHLY_CHRG_REV.MonthsChrgRev_AllBillable, 0.00)
            + IFNULL(MONTHLY_EXPECT_LABOR_REV.ExpectedLaborRevenue, 0.00)) - IFNULL(MONTHLY_REC_REV.RecognizedRevenue, 0.00))
         OVER(
           PARTITION BY IFNULL(CalItems.ProjectID, MONTHLY_REC_REV.ProjectID))                                            AS TotalDeferredRevenue
      , 9                                                                                                                 AS SQLVersion_MONTHLY_DEFERRED_REV
    FROM            (SELECT
                      TPROJECT.UNIQUEID       AS ProjectID
                      , TFCALPERIOD.STARTDATE AS MonthToInclude
                    FROM eio_publish.tenrox_private.TFCALPERIOD TFCALPERIOD
                    INNER JOIN eio_publish.tenrox_private.TPROJECT TPROJECT
                            ON TFCALPERIOD.STARTDATE >= TRUNC(TPROJECT.STARTDATE, 'MONTH')
                           AND TFCALPERIOD.STARTDATE <= CASE
                                                          WHEN TPROJECT.ENDDATE > DATEADD('MONTH', 1, TRUNC(CURRENT_DATE(), 'MONTH'))
                                                            THEN DATEADD('MONTH', 1, TRUNC(CURRENT_DATE(), 'MONTH'))
                                                          ELSE TPROJECT.ENDDATE
                                                        END
                           AND TFCALPERIOD.PERIODTYPE = 'M'
                           AND TFCALPERIOD.CALID = 4) CalItems
    FULL OUTER JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_monthly_expect_labor_rev as MONTHLY_EXPECT_LABOR_REV
                ON MONTHLY_EXPECT_LABOR_REV.ProjectID = CalItems.ProjectID
               AND MONTHLY_EXPECT_LABOR_REV.MonthOfExpectedLaborRev = CalItems.MonthToInclude
    FULL OUTER JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_monthly_chrg_rev as MONTHLY_CHRG_REV
                ON MONTHLY_CHRG_REV.ProjectID = CalItems.ProjectID
               AND MONTHLY_CHRG_REV.MonthOfChrgRev < TRUNC(CURRENT_DATE(), 'MONTH')
               AND MONTHLY_CHRG_REV.MonthOfChrgRev = CalItems.MonthToInclude
    FULL OUTER JOIN (SELECT
                      ProjectID
                      , MonthRecognized
                      , RecognizedRevenue
                    FROM eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_monthly_rec_rev
                    WHERE  MonthRecognized IS NOT NULL) MONTHLY_REC_REV
                ON MONTHLY_REC_REV.ProjectID = CalItems.ProjectID
               AND MONTHLY_REC_REV.MonthRecognized = CalItems.MonthToInclude
    WHERE           COALESCE(MONTHLY_EXPECT_LABOR_REV.ProjectID, MONTHLY_CHRG_REV.ProjectID, MONTHLY_REC_REV.ProjectID) IS NOT NULL