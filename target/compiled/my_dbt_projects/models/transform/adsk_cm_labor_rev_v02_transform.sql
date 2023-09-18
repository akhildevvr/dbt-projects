
/* ADSK_FN_CM_LABOR_REV_V02
  @OverrideCurID   INT = NULL
  , @RangeBegin    DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL
  , @Placeholder05 INT = NULL
*/
SELECT 
    tproject.uniqueid                                                                                    AS projectid
     , IFNULL(projbudget.currentbillabletime, 0.00)                                                      AS laborrevenue_total
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsact_past, 0.00)  
                                             / NULLIF(hrs_billable_eac, 0.00)), 0.00)                    AS revlabor_past
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsact_pastqtrs, 0.00) 
                                             / NULLIF(hrs_billable_eac, 0.00)), 0.00)                    AS revlabor_pastqtrs
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsact_priorqtrs, 0.00) 
                                             / NULLIF(hrs_billable_eac, 0.00)), 0.00)                    AS revlabor_priorqtrs
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsact_minus3qtr, 0.00) 
                                             / NULLIF(hrs_billable_eac, 0.00)), 0.00)                    AS revlabor_minus3qtr
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsact_minus2qtr, 0.00) 
                                             / NULLIF(hrs_billable_eac, 0.00)), 0.00)                    AS revlabor_minus2qtr
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsact_minus1qtr, 0.00) 
                                             / NULLIF(hrs_billable_eac, 0.00)), 0.00)                    AS revlabor_minus1qtr
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsact_completedinqtr, 0.00) 
                                             / NULLIF(hrs_billable_eac, 0.00)), 0.00)                    AS revlabor_completedinqtr
     , IFNULL(projbudget.currentbillabletime * ((IFNULL(hrsact_completedinqtr, 0.00)
                                            + IFNULL(hrsfcst_billable_remaininginqtr, 0.00))
                                            / NULLIF(hrs_billable_eac, 0.00)), 0.00)                     AS revlabor_currentqtr
     , IFNULL(deferred_rev.totaldeferredrevenue, 0.00)                                                   AS rev_deferred
     , IFNULL(deferred_rev.totaldeferredrevenue, 0.00) + (projbudget.currentbillabletime
                                             * (IFNULL(hrsfcst_billable_currentmonth, 0.00) 
                                             / NULLIF(hrs_billable_eac, 0.00)))                          AS revlabor_currentmonth
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_currentmonth, 0.00) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_currentmonthfcstonly
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_remaininginqtr, 0.00) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_remaininginqtr
     , IFNULL(projbudget.currentbillabletime * ((IFNULL(hrsfcst_billable_remaininginqtr, 0.00)
                                                - IFNULL(hrsfcst_billable_remaininginqtr_soft, 0.00)) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_remaininginqtr_hard
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_future, 0.00) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_future
     , IFNULL( projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_plus1qtr, 0.00) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_plus1qtr
     , IFNULL(projbudget.currentbillabletime * ((IFNULL(hrsfcst_billable_plus1qtr, 0.00)
                                                - IFNULL(hrsfcst_billable_plus1qtr_soft, 0.00)) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_plus1qtr_hard
     , IFNULL( projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_plus2qtr, 0.00) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_plus2qtr
     , IFNULL(projbudget.currentbillabletime * ((IFNULL(hrsfcst_billable_plus2qtr, 0.00)
                                               - IFNULL(hrsfcst_billable_plus2qtr_soft, 0.00)) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_plus2qtr_hard
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_plus3qtr, 0.00) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_plus3qtr
     , IFNULL(projbudget.currentbillabletime * ((IFNULL(hrsfcst_billable_plus3qtr, 0.00)
                                                - IFNULL(hrsfcst_billable_plus3qtr_soft, 0.00)) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_plus3qtr_hard
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_plus4qtr, 0.00) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_plus4qtr
     , IFNULL(projbudget.currentbillabletime * ((IFNULL(hrsfcst_billable_plus4qtr, 0.00)
                                                - IFNULL(hrsfcst_billable_plus4qtr_soft, 0.00)) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_plus4qtr_hard
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_plus5qtr, 0.00) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_plus5qtr
     , IFNULL(projbudget.currentbillabletime * ((IFNULL(hrsfcst_billable_plus5qtr, 0.00)
                                                   - IFNULL(hrsfcst_billable_plus5qtr_soft, 0.00)) 
                                                   / NULLIF(hrs_billable_eac, 0.00)), 0.00)              AS revlabor_plus5qtr_hard
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_futureqtrs, 0.00) 
                                                   / NULLIF(hrs_billable_eac, 0.00)), 0.00)              AS revlabor_futureqtrs
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_additionalqtrs, 0.00)
                                                   / NULLIF(hrs_billable_eac, 0.00)), 0.00)              AS revlabor_additionalqtrs
     , IFNULL(projbudget.currentbillabletime * ((IFNULL(hrsfcst_billable_additionalqtrs, 0.00)
                                                - IFNULL(hrsfcst_billable_additionalqtrs_soft, 0.00)) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_additionalqtrs_hard
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsfcst_billable_additionalqtrs2, 0.00)
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_additionalqtrs2
     , IFNULL(projbudget.currentbillabletime * ((IFNULL(hrsfcst_billable_additionalqtrs2, 0.00)
                                                - IFNULL(hrsfcst_billable_additionalqtrs2_soft, 0.00)) 
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_additionalqtrs2_hard
     , IFNULL(projbudget.currentbillabletime * (IFNULL(hrsact_customrange 
                                                + hrsfcst_billable_customrange, 0.00)
                                                / NULLIF(hrs_billable_eac, 0.00)), 0.00)                 AS revlabor_customrange
     , fnc_hist_customrangebegin                                                                         AS revlabor_customrangebegin
     , fnc_fcst_customrangeend                                                                           AS revlabor_customrangeend
     , 12                                                                                                AS sqlversion_labor_rev
FROM eio_publish.tenrox_private.tproject tproject
INNER JOIN eio_publish.tenrox_private.tclientinvoice tclientinvoice
    ON tclientinvoice.clientid = tproject.clientid
LEFT JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_budget AS projbudget 
    ON projbudget.projectid = tproject.uniqueid 
LEFT JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_labor_hrs_v02 AS laborhrs
    ON laborhrs.projectid = tproject.uniqueid 
LEFT JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_deferred_rev AS deferred_rev
    ON deferred_rev.projectid = tproject.uniqueid 
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_month_q_ranges_v02 AS ranges