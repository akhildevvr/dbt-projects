{{ config(
    alias='adsk_cm_labor_hrs_v02'
) }}
/* ADSK_FN_CM_LABOR_HRS_V02.sql
  @RangeBegin      DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/

--DROP VIEW "EIO_INGEST"."TENROX_TRANSFORM"."ADSK_FN_CM_LABOR_HRS_V02_TEST"


WITH actuals AS (
        SELECT
            ttask.projectid AS projectid
            , SUM(IFNULL(totaltime, 0.00)) / 3600.00 AS hrsact_total_all
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_past
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate >= fnc_currentmonthbegins
                                    AND ttimesheetentries.entrydate < ranges.fnc_nextmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_currentmonth
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_pastqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                    AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_entirecurrentqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrm2begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_currentqtrm1
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate >= fnc_currentqtrm2begins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrm3begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_currentqtrm2
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate >= fnc_currentqtrm3begins
                                    AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_currentqtrm3
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_completedinqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate >= fnc_minus1qtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_minus1qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate >= fnc_minus2qtrbegins
                                    AND ttimesheetentries.entrydate < fnc_minus1qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_minus2qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate >= fnc_minus3qtrbegins
                                    AND ttimesheetentries.entrydate < fnc_minus2qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_minus3qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate < fnc_minus3qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_priorqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate >= fnc_hist_customrangebegin
                                    AND ttimesheetentries.entrydate < fnc_hist_customrangeend THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_customrange
            , SUM(IFNULL(CASE WHEN ttimesheetentries.entrydate < to_timestamp(NULL) THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_total_beforecutover
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1 THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_all
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate < (DATE_TRUNC('W', CURRENT_DATE())-1) THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_past
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentmonthbegins
                                    AND ttimesheetentries.entrydate < ranges.fnc_nextmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_currentmonth
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_pastqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                        AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                        AND ttimesheetentries.entrydate < fnc_plus1qtrbegins
                                        THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_entirecurrentqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrm2begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_currentqtrm1
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrbegins 
                                    AND ttimesheetentries.entrydate < (DATE_TRUNC('W', CURRENT_DATE())-1) THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_currentqtrm1_wk
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrm2begins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrm3begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_currentqtrm2
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrm2begins
                                    AND ttimesheetentries.entrydate < (DATE_TRUNC('W', CURRENT_DATE())-1) THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_currentqtrm2_wk
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrm3begins
                                    AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_currentqtrm3
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrm3begins
                                    AND ttimesheetentries.entrydate < (DATE_TRUNC('W', CURRENT_DATE())-1) THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_currentqtrm3_wk
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_completedinqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_minus1qtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_minus1qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_minus2qtrbegins
                                    AND ttimesheetentries.entrydate < fnc_minus1qtrbegins
                                    THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_minus2qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_minus3qtrbegins
                                    AND ttimesheetentries.entrydate < fnc_minus2qtrbegins
                                    THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_minus3qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate < fnc_minus3qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_priorqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_hist_customrangebegin
                                    AND ttimesheetentries.entrydate < fnc_hist_customrangeend THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_customrange
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate < to_timestamp(NULL) THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_beforecutover
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1 THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_all
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_past
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentmonthbegins
                                    AND ttimesheetentries.entrydate < ranges.fnc_nextmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_currentmonth
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_pastqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrbegins 
                                    AND ttimesheetentries.entrydate < fnc_plus1qtrbegins
                                    THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_entirecurrentqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrm2begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_currentqtrm1
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrm2begins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrm3begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_currentqtrm2
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrm3begins
                                    AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_currentqtrm3
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_completedinqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_minus1qtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_minus1qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_minus2qtrbegins
                                    AND ttimesheetentries.entrydate < fnc_minus1qtrbegins
                                    THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_minus2qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_minus3qtrbegins 
                                    AND ttimesheetentries.entrydate < fnc_minus2qtrbegins
                                    THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_minus3qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate < fnc_minus3qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_priorqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate >= fnc_hist_customrangebegin
                                    AND ttimesheetentries.entrydate < fnc_hist_customrangeend THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_customrange
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1
                                    AND ttimesheetentries.entrydate < to_timestamp(NULL) THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp_beforecutover
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                                    AND ttimesheetentries.funded = 0 THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_all
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                                    AND ttimesheetentries.funded = 0
                                    AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_past
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                                    AND ttimesheetentries.funded = 0
                                    AND ttimesheetentries.entrydate >= fnc_currentmonthbegins
                                    AND ttimesheetentries.entrydate < ranges.fnc_nextmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_currentmonth
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                                    AND ttimesheetentries.funded = 0
                                    AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_pastqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                                    AND ttimesheetentries.funded = 0
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                    AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_entirecurrentqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                                    AND ttimesheetentries.funded = 0
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrm2begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_currentqtrm1
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                                    AND ttimesheetentries.funded = 0
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrm2begins
                                    AND ttimesheetentries.entrydate < fnc_currentqtrm3begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_currentqtrm2
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                                    AND ttimesheetentries.funded = 0
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrm3begins
                                    AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_currentqtrm3
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                                    AND ttimesheetentries.funded = 0
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                    AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_completedinqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_minus1qtrbegins
                AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_minus1qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_minus2qtrbegins
                AND ttimesheetentries.entrydate < fnc_minus1qtrbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_minus2qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_minus3qtrbegins
                AND ttimesheetentries.entrydate < fnc_minus2qtrbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_minus3qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate < fnc_minus3qtrbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_priorqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_hist_customrangebegin
                AND ttimesheetentries.entrydate < fnc_hist_customrangeend THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_customrange
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate < to_timestamp(NULL) THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_beforecutover
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                 THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_all
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_past
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_currentmonthbegins
                AND ttimesheetentries.entrydate < ranges.fnc_nextmonthbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_currentmonth
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_pastqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_entirecurrentqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                AND ttimesheetentries.entrydate < fnc_currentqtrm2begins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_currentqtrm1
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_currentqtrm2begins
                AND ttimesheetentries.entrydate < fnc_currentqtrm3begins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_currentqtrm2
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_currentqtrm3begins
                AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_currentqtrm3
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_completedinqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_minus1qtrbegins
                AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_minus1qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_minus2qtrbegins
                AND ttimesheetentries.entrydate < fnc_minus1qtrbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_minus2qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_minus3qtrbegins
                AND ttimesheetentries.entrydate < fnc_minus2qtrbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_minus3qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate < fnc_minus3qtrbegins THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_priorqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate >= fnc_hist_customrangebegin
                AND ttimesheetentries.entrydate < fnc_hist_customrangeend THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_customrange
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 0 
                AND ttimesheetentries.funded = 0
                AND ttimesheetentries.entrydate < to_timestamp(NULL) THEN totaltime
             ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill_unapp_beforecutover
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1 THEN totaltime
                ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_all
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                    AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_past
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                            AND ttimesheetentries.entrydate >= fnc_currentmonthbegins
                            AND ttimesheetentries.entrydate < ranges.fnc_nextmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_currentmonth
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                    AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_pastqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                    AND ttimesheetentries.entrydate >= fnc_currentqtrbegins AND ttimesheetentries.entrydate < fnc_plus1qtrbegins
                                        THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_entirecurrentqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                AND ttimesheetentries.entrydate < fnc_currentqtrm2begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_currentqtrm1
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_currentqtrm2begins
                                AND ttimesheetentries.entrydate < fnc_currentqtrm3begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_currentqtrm2
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_currentqtrm3begins
                                AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_currentqtrm3
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                            AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                            AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_completedinqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_minus1qtrbegins
                                AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_minus1qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                    AND ttimesheetentries.entrydate >= fnc_minus2qtrbegins AND ttimesheetentries.entrydate < fnc_minus1qtrbegins
                                        THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_minus2qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                    AND ttimesheetentries.entrydate >= fnc_minus3qtrbegins AND ttimesheetentries.entrydate < fnc_minus2qtrbegins
                                        THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_minus3qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                    AND ttimesheetentries.entrydate < fnc_minus3qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_priorqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_hist_customrangebegin
                                AND ttimesheetentries.entrydate < fnc_hist_customrangeend THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_customrange
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate < to_timestamp(NULL) THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_beforecutover
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1 THEN totaltime
                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_all
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                    AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_past
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                            AND ttimesheetentries.entrydate >= fnc_currentmonthbegins
                            AND ttimesheetentries.entrydate < ranges.fnc_nextmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_currentmonth
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                    AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_pastqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_currentqtrbegins AND ttimesheetentries.entrydate < fnc_plus1qtrbegins
                                        THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_entirecurrentqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                AND ttimesheetentries.entrydate < fnc_currentqtrm2begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_currentqtrm1
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_currentqtrm2begins
                                AND ttimesheetentries.entrydate < fnc_currentqtrm3begins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_currentqtrm2
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_currentqtrm3begins
                                AND ttimesheetentries.entrydate < fnc_plus1qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_currentqtrm3
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_currentqtrbegins
                                AND ttimesheetentries.entrydate < fnc_currentmonthbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_completedinqtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_minus1qtrbegins
                                AND ttimesheetentries.entrydate < fnc_currentqtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_minus1qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_minus2qtrbegins AND ttimesheetentries.entrydate < fnc_minus1qtrbegins
                                        THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_minus2qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_minus3qtrbegins AND ttimesheetentries.entrydate < fnc_minus2qtrbegins
                                        THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_minus3qtr
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate < fnc_minus3qtrbegins THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_priorqtrs
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate >= fnc_hist_customrangebegin
                                AND ttimesheetentries.entrydate < fnc_hist_customrangeend THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_customrange
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1
                                AND ttimesheetentries.entrydate < to_timestamp(NULL) THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp_beforecutover
            , MAX(fnc_hist_customrangebegin) AS hrsact_customrangebegin
            , MAX(fnc_hist_customrangeend) AS hrsact_customrangeend
        FROM {{ source('tenrox_private','ttimesheetentries')}} ttimesheetentries 
        INNER JOIN {{ source('tenrox_private','ttask') }}  ttask
            ON ttimesheetentries.TASKUID = ttask.uniqueid 
        LEFT OUTER JOIN {{ ref('adsk_month_q_ranges_v02_transform') }} AS ranges
        GROUP BY ttask.projectid
),

forecast AS (
   SELECT
       trplnbooking.projectid                                            AS projectid
        , SUM(IFNULL(trplnbookingdetails.bookedseconds, 0.00)) / 3600.00 AS hrsfcst_all
        , SUM(IFNULL(
           CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_future
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
           AND trplnbookingdetails.bookeddate < ranges.fnc_nextmonthbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_currentmonth
        , SUM(IFNULL(
           CASE WHEN trplnbookingdetails.bookeddate >= ranges.fnc_nextmonthbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_futuremonths
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_futureqtrs
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_entirecurrentqtr
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
           AND trplnbookingdetails.bookeddate < fnc_currentqtrm2begins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_currentqtrm1
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrm2begins
           AND trplnbookingdetails.bookeddate < fnc_currentqtrm3begins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_currentqtrm2
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrm3begins
           AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_currentqtrm3
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
           AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_remaininginqtr
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_plus1qtr
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_plus2qtr
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_plus3qtr
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus5qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_plus4qtr
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus5qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus6qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_plus5qtr
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_additionalqtrs
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus6qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_additional2qtrs
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
           AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_customrange
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= to_timestamp(NULL) THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_aftercutover
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_all
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= (DATE_TRUNC('W', CURRENT_DATE())-1)
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_future
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                   AND trplnbookingdetails.bookeddate < ranges.fnc_nextmonthbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentmonth
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= ranges.fnc_nextmonthbegins
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_futuremonths
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_futureqtrs
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_entirecurrentqtr
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm2begins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm1
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= (DATE_TRUNC('W', CURRENT_DATE())-1)
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm2begins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm1_wk
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentqtrm2begins
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm3begins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm2
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= (DATE_TRUNC('W', CURRENT_DATE())-1)
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm3begins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm2_wk
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentqtrm3begins
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm3
        ,SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= (DATE_TRUNC('W', CURRENT_DATE())-1)
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm3_wk
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= (DATE_TRUNC('W', CURRENT_DATE())-1)
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_remaininginqtr
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_plus1qtr
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_plus2qtr
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_plus3qtr
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus5qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_plus4qtr
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus5qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus6qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_plus5qtr
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_additionalqtrs
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus6qtrbegins
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_additionalqtrs2
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
                   AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_customrange
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= to_timestamp(NULL)
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_aftercutover
        , SUM(IFNULL(CASE WHEN trplnbooking.bookingobjecttype = 700 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_gen_all
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_future
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                   AND trplnbookingdetails.bookeddate < ranges.fnc_nextmonthbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_currentmonth
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= ranges.fnc_nextmonthbegins
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_futuremonths
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_futureqtrs
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_entirecurrentqtr
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm2begins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_currentqtrm1
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentqtrm2begins
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm3begins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_currentqtrm2
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentqtrm3begins
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_currentqtrm3
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_remaininginqtr
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_plus1qtr
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_plus2qtr
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_plus3qtr
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_additionalqtrs
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
                   AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_customrange
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= to_timestamp(NULL)
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_aftercutover
       -- Start Soft Bookings Only section
        , SUM(IFNULL(CASE WHEN trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_all_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_future_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
           AND trplnbookingdetails.bookeddate < ranges.fnc_nextmonthbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_currentmonth_soft
        , SUM(IFNULL(
           CASE WHEN trplnbookingdetails.bookeddate >= ranges.fnc_nextmonthbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_futuremonths_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_futureqtrs_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_entirecurrentqtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
           AND trplnbookingdetails.bookeddate < fnc_currentqtrm2begins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_currentqtrm1_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrm2begins
           AND trplnbookingdetails.bookeddate < fnc_currentqtrm3begins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_currentqtrm2_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrm3begins
           AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_currentqtrm3_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
           AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_remaininginqtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_plus1qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_plus2qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_plus3qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_additionalqtrs_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
           AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_customrange_soft
        , SUM(IFNULL(CASE WHEN trplnbookingdetails.bookeddate >= to_timestamp(NULL) AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_aftercutover_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_all_soft
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                   AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_future_soft
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                   AND trplnbookingdetails.bookeddate < ranges.fnc_nextmonthbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentmonth_soft
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= ranges.fnc_nextmonthbegins
                   AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_futuremonths_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
           AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_futureqtrs_soft
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_entirecurrentqtr_soft
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm2begins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm1_soft
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= (DATE_TRUNC('W', CURRENT_DATE())-1)
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm2begins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm1_soft_wk
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentqtrm2begins
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm3begins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm2_soft
        ,SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= (DATE_TRUNC('W', CURRENT_DATE())-1)
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm3begins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm2_soft_wk
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_currentqtrm3begins
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm3_soft
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= (DATE_TRUNC('W', CURRENT_DATE())-1)
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_currentqtrm3_soft_wk
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= (DATE_TRUNC('W', CURRENT_DATE())-1)
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_remaininginqtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_plus1qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_plus2qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_plus3qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus5qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_plus4qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus5qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus6qtrbegins AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_plus5qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
           AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_additionalqtrs_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_plus6qtrbegins
           AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_additionalqtrs2_soft
        , SUM(IFNULL(
           CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
                   AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_billable_customrange_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbookingdetails.bookeddate >= to_timestamp(NULL)
           AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_aftercutover_soft
        , SUM(IFNULL(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_gen_all_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                   AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_future_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                   AND trplnbookingdetails.bookeddate < ranges.fnc_nextmonthbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_currentmonth_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= ranges.fnc_nextmonthbegins
                   AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_futuremonths_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                   AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_futureqtrs_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_entirecurrentqtr_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm2begins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_currentqtrm1_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentqtrm2begins
                   AND trplnbookingdetails.bookeddate < fnc_currentqtrm3begins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_currentqtrm2_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentqtrm3begins
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_currentqtrm3_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_remaininginqtr_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_plus1qtr_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_plus2qtr_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
                   AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_plus3qtr_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
                   AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_additionalqtrs_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
                   AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend AND trplnbooking.bookingtype = 2
                    THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_customrange_soft
        , SUM(IFNULL(
           CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= to_timestamp(NULL)
                   AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                ELSE 0.00 END, 0.00)) / 3600.00                          AS hrsfcst_gen_aftercutover_soft
       -- End Soft Bookings Only section
       -- Start non-billable Generic soft-bookings section
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_all_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_future_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
           AND trplnbookingdetails.bookeddate < ranges.fnc_nextmonthbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_currentmonth_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= ranges.fnc_nextmonthbegins
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_futuremonths_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_futureqtrs_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_entirecurrentqtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
           AND trplnbookingdetails.bookeddate < fnc_currentqtrm2begins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_currentqtrm1_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_currentqtrm2begins
           AND trplnbookingdetails.bookeddate < fnc_currentqtrm3begins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_currentqtrm2_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_currentqtrm3begins
           AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_currentqtrm3_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
           AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_remaininginqtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_plus1qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_plus2qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
           AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_plus3qtr_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_additionalqtrs_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
           AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_customrange_soft
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 AND trplnbookingdetails.bookeddate >= to_timestamp(NULL)
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_aftercutover_soft
       -- End non-billable Generic bookings section
        , MAX(fnc_fcst_customrangebegin)                                 AS hrsfcst_customrangebegin
        , MAX(fnc_fcst_customrangeend)                                   AS hrsfcst_customrangeend
    FROM {{ source('tenrox_private','trplnbooking') }} trplnbooking
    INNER JOIN {{ source('tenrox_private','trplnbookingdetails') }}  trplnbookingdetails ON trplnbookingdetails.bookingid = trplnbooking.uniqueid 
    INNER JOIN {{ source('tenrox_private','trplnbookingattributes') }} trplnbookingattributes ON trplnbookingattributes.bookingid = trplnbooking.uniqueid 
    INNER JOIN {{ source('tenrox_private','tprojectteamresource') }} tprojectteamresource ON tprojectteamresource.projectid = trplnbooking.projectid 
            AND tprojectteamresource.resourceid = CASE trplnbooking.bookingobjecttype 
                                                    WHEN 1 THEN trplnbooking.userid 
                                                    WHEN 700 THEN trplnbooking.roleid 
                                                END 
            AND tprojectteamresource.isrole = CASE trplnbooking.bookingobjecttype 
                                                    WHEN 1 THEN 0
                                                    WHEN 700 THEN 1
                                                END
    LEFT OUTER JOIN {{ ref('adsk_month_q_ranges_v02_transform') }} AS ranges -- ON Ranges.FNC_CURRENTDATE = TRPLNBOOKINGDETAILS.BOOKEDDATE
    WHERE trplnbookingdetails.bookedseconds > 0
    GROUP BY 
        trplnbooking.projectid
),

is_parent_child as (
 
SELECT 
CASE
           WHEN lower(LSTDESC_16.VALUE) in ( 'is parent' ) THEN
               cast(tproject.uniqueid as string)
           WHEN lower(LSTDESC_16.VALUE) IN ( 'is master', 'is child' ) THEN
               CONCAT(CAST(tproject.parentid AS STRING))
           ELSE
               CAST(tproject.uniqueid AS STRING)
       END                                                                                     as parent_child_key
     , SUM(IFNULL(actuals.hrsact_total_all, 0.00))                                             AS hrsact_total_all
     , SUM(IFNULL(actuals.hrsact_total_past, 0.00))                                            AS hrsact_total_past
     , SUM(IFNULL(actuals.hrsact_total_currentmonth, 0.00))                                    AS hrsact_total_currentmonth
     , SUM(IFNULL(actuals.hrsact_total_pastqtrs, 0.00))                                        AS hrsact_total_pastqtrs
     , SUM(IFNULL(actuals.hrsact_total_entirecurrentqtr, 0.00))                                AS hrsact_total_entirecurrentqtr
     , SUM(IFNULL(actuals.hrsact_total_currentqtrm1, 0.00))                                    AS hrsact_total_currentqtrm1
     , SUM(IFNULL(actuals.hrsact_total_currentqtrm2, 0.00))                                    AS hrsact_total_currentqtrm2
     , SUM(IFNULL(actuals.hrsact_total_currentqtrm3, 0.00))                                    AS hrsact_total_currentqtrm3
     , SUM(IFNULL(actuals.hrsact_total_completedinqtr, 0.00))                                  AS hrsact_total_completedinqtr
     , SUM(IFNULL(actuals.hrsact_total_minus1qtr, 0.00))                                       AS hrsact_total_minus1qtr
     , SUM(IFNULL(actuals.hrsact_total_minus2qtr, 0.00))                                       AS hrsact_total_minus2qtr
     , SUM(IFNULL(actuals.hrsact_total_minus3qtr, 0.00))                                       AS hrsact_total_minus3qtr
     , SUM(IFNULL(actuals.hrsact_total_priorqtrs, 0.00))                                       AS hrsact_total_priorqtrs
     , SUM(IFNULL(actuals.hrsact_total_customrange, 0.00))                                     AS hrsact_total_customrange
     , SUM(IFNULL(actuals.hrsact_total_beforecutover, 0.00))                                   AS hrsact_total_beforecutover
     , SUM(IFNULL(actuals.hrsact_all, 0.00))                                                   AS hrsact_all
     , SUM(IFNULL(actuals.hrsact_past, 0.00))                                                  AS hrsact_past
     , SUM(IFNULL(actuals.hrsact_currentmonth, 0.00))                                          AS hrsact_currentmonth
     , SUM(IFNULL(actuals.hrsact_pastqtrs, 0.00))                                              AS hrsact_pastqtrs
     , SUM(IFNULL(actuals.hrsact_entirecurrentqtr, 0.00))                                      AS hrsact_entirecurrentqtr
     , SUM(IFNULL(actuals.hrsact_currentqtrm1, 0.00))                                          AS hrsact_currentqtrm1
     , SUM(IFNULL(actuals.hrsact_currentqtrm1_wk, 0.00))                                       AS hrsact_currentqtrm1_wk
     , SUM(IFNULL(actuals.hrsact_currentqtrm2, 0.00))                                          AS hrsact_currentqtrm2
     , SUM(IFNULL(actuals.hrsact_currentqtrm2_wk, 0.00))                                       AS hrsact_currentqtrm2_wk
     , SUM(IFNULL(actuals.hrsact_currentqtrm3, 0.00))                                          AS hrsact_currentqtrm3
     , SUM(IFNULL(actuals.hrsact_currentqtrm3_wk, 0.00))                                       AS hrsact_currentqtrm3_wk
     , SUM(IFNULL(actuals.hrsact_completedinqtr, 0.00))                                        AS hrsact_completedinqtr
     , SUM(IFNULL(actuals.hrsact_minus1qtr, 0.00))                                             AS hrsact_minus1qtr
     , SUM(IFNULL(actuals.hrsact_minus2qtr, 0.00))                                             AS hrsact_minus2qtr
     , SUM(IFNULL(actuals.hrsact_minus3qtr, 0.00))                                             AS hrsact_minus3qtr
     , SUM(IFNULL(actuals.hrsact_priorqtrs, 0.00))                                             AS hrsact_priorqtrs
     , SUM(IFNULL(actuals.hrsact_customrange, 0.00))                                           AS hrsact_customrange
     , SUM(IFNULL(actuals.hrsact_beforecutover, 0.00))                                         AS hrsact_beforecutover
     , SUM(IFNULL(actuals.hrsact_unapp_all, 0.00))                                             AS hrsact_unapp_all
     , SUM(IFNULL(actuals.hrsact_unapp_past, 0.00))                                            AS hrsact_unapp_past
     , SUM(IFNULL(actuals.hrsact_unapp_currentmonth, 0.00))                                    AS hrsact_unapp_currentmonth
     , SUM(IFNULL(actuals.hrsact_unapp_pastqtrs, 0.00))                                        AS hrsact_unapp_pastqtrs
     , SUM(IFNULL(actuals.hrsact_unapp_entirecurrentqtr, 0.00))                                AS hrsact_unapp_entirecurrentqtr
     , SUM(IFNULL(actuals.hrsact_unapp_currentqtrm1, 0.00))                                    AS hrsact_unapp_currentqtrm1
     , SUM(IFNULL(actuals.hrsact_unapp_currentqtrm2, 0.00))                                    AS hrsact_unapp_currentqtrm2
     , SUM(IFNULL(actuals.hrsact_unapp_currentqtrm3, 0.00))                                    AS hrsact_unapp_currentqtrm3
     , SUM(IFNULL(actuals.hrsact_unapp_completedinqtr, 0.00))                                  AS hrsact_unapp_completedinqtr
     , SUM(IFNULL(actuals.hrsact_unapp_minus1qtr, 0.00))                                       AS hrsact_unapp_minus1qtr
     , SUM(IFNULL(actuals.hrsact_unapp_minus2qtr, 0.00))                                       AS hrsact_unapp_minus2qtr
     , SUM(IFNULL(actuals.hrsact_unapp_minus3qtr, 0.00))                                       AS hrsact_unapp_minus3qtr
     , SUM(IFNULL(actuals.hrsact_unapp_priorqtrs, 0.00))                                       AS hrsact_unapp_priorqtrs
     , SUM(IFNULL(actuals.hrsact_unapp_customrange, 0.00))                                     AS hrsact_unapp_customrange
     , SUM(IFNULL(actuals.hrsact_unapp_beforecutover, 0.00))                                   AS hrsact_unapp_beforecutover
     , SUM(IFNULL(actuals.hrsact_nonbill_all, 0.00))                                           AS hrsact_nonbill_all
     , SUM(IFNULL(actuals.hrsact_nonbill_past, 0.00))                                          AS hrsact_nonbill_past
     , SUM(IFNULL(actuals.hrsact_nonbill_currentmonth, 0.00))                                  AS hrsact_nonbill_currentmonth
     , SUM(IFNULL(actuals.hrsact_nonbill_pastqtrs, 0.00))                                      AS hrsact_nonbill_pastqtrs
     , SUM(IFNULL(actuals.hrsact_nonbill_entirecurrentqtr, 0.00))                              AS hrsact_nonbill_entirecurrentqtr
     , SUM(IFNULL(actuals.hrsact_nonbill_currentqtrm1, 0.00))                                  AS hrsact_nonbill_currentqtrm1
     , SUM(IFNULL(actuals.hrsact_nonbill_currentqtrm2, 0.00))                                  AS hrsact_nonbill_currentqtrm2
     , SUM(IFNULL(actuals.hrsact_nonbill_currentqtrm3, 0.00))                                  AS hrsact_nonbill_currentqtrm3
     , SUM(IFNULL(actuals.hrsact_nonbill_completedinqtr, 0.00))                                AS hrsact_nonbill_completedinqtr
     , SUM(IFNULL(actuals.hrsact_nonbill_minus1qtr, 0.00))                                     AS hrsact_nonbill_minus1qtr
     , SUM(IFNULL(actuals.hrsact_nonbill_minus2qtr, 0.00))                                     AS hrsact_nonbill_minus2qtr
     , SUM(IFNULL(actuals.hrsact_nonbill_minus3qtr, 0.00))                                     AS hrsact_nonbill_minus3qtr
     , SUM(IFNULL(actuals.hrsact_nonbill_priorqtrs, 0.00))                                     AS hrsact_nonbill_priorqtrs
     , SUM(IFNULL(actuals.hrsact_nonbill_customrange, 0.00))                                   AS hrsact_nonbill_customrange
     , SUM(IFNULL(actuals.hrsact_nonbill_beforecutover, 0.00))                                 AS hrsact_nonbill_beforecutover
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_all, 0.00))                                     AS hrsact_nonbill_unapp_all
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_past, 0.00))                                    AS hrsact_nonbill_unapp_past
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_currentmonth, 0.00))                            AS hrsact_nonbill_unapp_currentmonth
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_pastqtrs, 0.00))                                AS hrsact_nonbill_unapp_pastqtrs
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_entirecurrentqtr, 0.00))                        AS hrsact_nonbill_unapp_entirecurrentqtr
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_currentqtrm1, 0.00))                            AS hrsact_nonbill_unapp_currentqtrm1
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_currentqtrm2, 0.00))                            AS hrsact_nonbill_unapp_currentqtrm2
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_currentqtrm3, 0.00))                            AS hrsact_nonbill_unapp_currentqtrm3
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_completedinqtr, 0.00))                          AS hrsact_nonbill_unapp_completedinqtr
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_minus1qtr, 0.00))                               AS hrsact_nonbill_unapp_minus1qtr
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_minus2qtr, 0.00))                               AS hrsact_nonbill_unapp_minus2qtr
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_minus3qtr, 0.00))                               AS hrsact_nonbill_unapp_minus3qtr
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_priorqtrs, 0.00))                               AS hrsact_nonbill_unapp_priorqtrs
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_customrange, 0.00))                             AS hrsact_nonbill_unapp_customrange
     , SUM(IFNULL(actuals.hrsact_nonbill_unapp_beforecutover, 0.00))                           AS hrsact_nonbill_unapp_beforecutover
     , SUM(IFNULL(actuals.hrsact_utilized_all, 0.00))                                          AS hrsact_utilized_all
     , SUM(IFNULL(actuals.hrsact_utilized_past, 0.00))                                         AS hrsact_utilized_past
     , SUM(IFNULL(actuals.hrsact_utilized_currentmonth, 0.00))                                 AS hrsact_utilized_currentmonth
     , SUM(IFNULL(actuals.hrsact_utilized_pastqtrs, 0.00))                                     AS hrsact_utilized_pastqtrs
     , SUM(IFNULL(actuals.hrsact_utilized_entirecurrentqtr, 0.00))                             AS hrsact_utilized_entirecurrentqtr
     , SUM(IFNULL(actuals.hrsact_utilized_currentqtrm1, 0.00))                                 AS hrsact_utilized_currentqtrm1
     , SUM(IFNULL(actuals.hrsact_utilized_currentqtrm2, 0.00))                                 AS hrsact_utilized_currentqtrm2
     , SUM(IFNULL(actuals.hrsact_utilized_currentqtrm3, 0.00))                                 AS hrsact_utilized_currentqtrm3
     , SUM(IFNULL(actuals.hrsact_utilized_completedinqtr, 0.00))                               AS hrsact_utilized_completedinqtr
     , SUM(IFNULL(actuals.hrsact_utilized_minus1qtr, 0.00))                                    AS hrsact_utilized_minus1qtr
     , SUM(IFNULL(actuals.hrsact_utilized_minus2qtr, 0.00))                                    AS hrsact_utilized_minus2qtr
     , SUM(IFNULL(actuals.hrsact_utilized_minus3qtr, 0.00))                                    AS hrsact_utilized_minus3qtr
     , SUM(IFNULL(actuals.hrsact_utilized_priorqtrs, 0.00))                                    AS hrsact_utilized_priorqtrs
     , SUM(IFNULL(actuals.hrsact_utilized_customrange, 0.00))                                  AS hrsact_utilized_customrange
     , SUM(IFNULL(actuals.hrsact_utilized_beforecutover, 0.00))                                AS hrsact_utilized_beforecutover
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_all, 0.00))                                    AS hrsact_utilized_unapp_all
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_past, 0.00))                                   AS hrsact_utilized_unapp_past
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_currentmonth, 0.00))                           AS hrsact_utilized_unapp_currentmonth
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_pastqtrs, 0.00))                               AS hrsact_utilized_unapp_pastqtrs
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_entirecurrentqtr, 0.00))                       AS hrsact_utilized_unapp_entirecurrentqtr
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_currentqtrm1, 0.00))                           AS hrsact_utilized_unapp_currentqtrm1
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_currentqtrm2, 0.00))                           AS hrsact_utilized_unapp_currentqtrm2
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_currentqtrm3, 0.00))                           AS hrsact_utilized_unapp_currentqtrm3
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_completedinqtr, 0.00))                         AS hrsact_utilized_unapp_completedinqtr
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_minus1qtr, 0.00))                              AS hrsact_utilized_unapp_minus1qtr
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_minus2qtr, 0.00))                              AS hrsact_utilized_unapp_minus2qtr
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_minus3qtr, 0.00))                              AS hrsact_utilized_unapp_minus3qtr
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_priorqtrs, 0.00))                              AS hrsact_utilized_unapp_priorqtrs
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_customrange, 0.00))                            AS hrsact_utilized_unapp_customrange
     , SUM(IFNULL(actuals.hrsact_utilized_unapp_beforecutover, 0.00))                          AS hrsact_utilized_unapp_beforecutover
     , SUM(IFNULL(actuals.hrsact_past, 0.00) + IFNULL(actuals.hrsact_utilized_past, 0.00)
           + IFNULL(forecast.hrsfcst_future, 0.00)
          )                                                                                    AS hrs_eac_with_utilized
     , SUM(IFNULL(forecast.hrsfcst_all, 0.00))                                                 AS hrsfcst_all
     , SUM(IFNULL(forecast.hrsfcst_future, 0.00))                                              AS hrsfcst_future
     , SUM(IFNULL(forecast.hrsfcst_currentmonth, 0.00))                                        AS hrsfcst_currentmonth
     , SUM(IFNULL(forecast.hrsfcst_futuremonths, 0.00))                                        AS hrsfcst_futuremonths
     , SUM(IFNULL(forecast.hrsfcst_futureqtrs, 0.00))                                          AS hrsfcst_futureqtrs
     , SUM(IFNULL(forecast.hrsfcst_entirecurrentqtr, 0.00))                                    AS hrsfcst_entirecurrentqtr
     , SUM(IFNULL(forecast.hrsfcst_currentqtrm1, 0.00))                                        AS hrsfcst_currentqtrm1
     , SUM(IFNULL(forecast.hrsfcst_currentqtrm2, 0.00))                                        AS hrsfcst_currentqtrm2
     , SUM(IFNULL(forecast.hrsfcst_currentqtrm3, 0.00))                                        AS hrsfcst_currentqtrm3
     , SUM(IFNULL(forecast.hrsfcst_remaininginqtr, 0.00))                                      AS hrsfcst_remaininginqtr
     , SUM(IFNULL(forecast.hrsfcst_plus1qtr, 0.00))                                            AS hrsfcst_plus1qtr
     , SUM(IFNULL(forecast.hrsfcst_plus2qtr, 0.00))                                            AS hrsfcst_plus2qtr
     , SUM(IFNULL(forecast.hrsfcst_plus3qtr, 0.00))                                            AS hrsfcst_plus3qtr
     , SUM(IFNULL(forecast.hrsfcst_plus4qtr, 0.00))                                            AS hrsfcst_plus4qtr
     , SUM(IFNULL(forecast.hrsfcst_plus5qtr, 0.00))                                            AS hrsfcst_plus5qtr
     , SUM(IFNULL(forecast.hrsfcst_additionalqtrs, 0.00))                                      AS hrsfcst_additionalqtrs
     , SUM(IFNULL(forecast.hrsfcst_additional2qtrs, 0.00))                                     AS hrsfcst_additional2qtrs
     , SUM(IFNULL(forecast.hrsfcst_customrange, 0.00))                                         AS hrsfcst_customrange
     , SUM(IFNULL(forecast.hrsfcst_aftercutover, 0.00))                                        AS hrsfcst_aftercutover
     , SUM(IFNULL(actuals.hrsact_past, 0.00)) + SUM(IFNULL(forecast.hrsfcst_future, 0.00))     AS hrs_eac
     , SUM(IFNULL(forecast.hrsfcst_billable_all, 0.00))                                        AS hrsfcst_billable_all
     , SUM(IFNULL(forecast.hrsfcst_billable_future, 0.00))                                     AS hrsfcst_billable_future
     , SUM(IFNULL(forecast.hrsfcst_billable_currentmonth, 0.00))                               AS hrsfcst_billable_currentmonth
     , SUM(IFNULL(forecast.hrsfcst_billable_futuremonths, 0.00))                               AS hrsfcst_billable_futuremonths
     , SUM(IFNULL(forecast.hrsfcst_billable_futureqtrs, 0.00))                                 AS hrsfcst_billable_futureqtrs
     , SUM(IFNULL(forecast.hrsfcst_billable_entirecurrentqtr, 0.00))                           AS hrsfcst_billable_entirecurrentqtr
     , SUM(IFNULL(forecast.hrsfcst_billable_currentqtrm1, 0.00))                               AS hrsfcst_billable_currentqtrm1
     , SUM(IFNULL(forecast.hrsfcst_billable_currentqtrm1_wk, 0.00))                            AS hrsfcst_billable_currentqtrm1_wk
     , SUM(IFNULL(forecast.hrsfcst_billable_currentqtrm2, 0.00))                               AS hrsfcst_billable_currentqtrm2
     , SUM(IFNULL(forecast.hrsfcst_billable_currentqtrm2_wk, 0.00))                            AS hrsfcst_billable_currentqtrm2_wk
     , SUM(IFNULL(forecast.hrsfcst_billable_currentqtrm3, 0.00))                               AS hrsfcst_billable_currentqtrm3
     , SUM(IFNULL(forecast.hrsfcst_billable_currentqtrm3_wk, 0.00))                            AS hrsfcst_billable_currentqtrm3_wk
     , SUM(IFNULL(forecast.hrsfcst_billable_remaininginqtr, 0.00))                             AS hrsfcst_billable_remaininginqtr
     , SUM(IFNULL(forecast.hrsfcst_billable_plus1qtr, 0.00))                                   AS hrsfcst_billable_plus1qtr
     , SUM(IFNULL(forecast.hrsfcst_billable_plus2qtr, 0.00))                                   AS hrsfcst_billable_plus2qtr
     , SUM(IFNULL(forecast.hrsfcst_billable_plus3qtr, 0.00))                                   AS hrsfcst_billable_plus3qtr
     , SUM(IFNULL(forecast.hrsfcst_billable_plus4qtr, 0.00))                                   AS hrsfcst_billable_plus4qtr
     , SUM(IFNULL(forecast.hrsfcst_billable_plus5qtr, 0.00))                                   AS hrsfcst_billable_plus5qtr
     , SUM(IFNULL(forecast.hrsfcst_billable_additionalqtrs, 0.00))                             AS hrsfcst_billable_additionalqtrs
     , SUM(IFNULL(forecast.hrsfcst_billable_additionalqtrs2, 0.00))                            AS hrsfcst_billable_additionalqtrs2
     , SUM(IFNULL(forecast.hrsfcst_billable_customrange, 0.00))                                AS hrsfcst_billable_customrange
     , SUM(IFNULL(forecast.hrsfcst_billable_aftercutover, 0.00))                               AS hrsfcst_billable_aftercutover
     , SUM(IFNULL(actuals.hrsact_past, 0.00) + IFNULL(forecast.hrsfcst_billable_future, 0.00)) AS hrs_billable_eac
     , SUM(IFNULL(forecast.hrsfcst_gen_all, 0.00))                                             AS hrsfcst_gen_all
     , SUM(IFNULL(forecast.hrsfcst_gen_future, 0.00))                                          AS hrsfcst_gen_future
     , SUM(IFNULL(forecast.hrsfcst_gen_currentmonth, 0.00))                                    AS hrsfcst_gen_currentmonth
     , SUM(IFNULL(forecast.hrsfcst_gen_futuremonths, 0.00))                                    AS hrsfcst_gen_futuremonths
     , SUM(IFNULL(forecast.hrsfcst_gen_futureqtrs, 0.00))                                      AS hrsfcst_gen_futureqtrs
     , SUM(IFNULL(forecast.hrsfcst_gen_entirecurrentqtr, 0.00))                                AS hrsfcst_gen_entirecurrentqtr
     , SUM(IFNULL(forecast.hrsfcst_gen_currentqtrm1, 0.00))                                    AS hrsfcst_gen_currentqtrm1
     , SUM(IFNULL(forecast.hrsfcst_gen_currentqtrm2, 0.00))                                    AS hrsfcst_gen_currentqtrm2
     , SUM(IFNULL(forecast.hrsfcst_gen_currentqtrm3, 0.00))                                    AS hrsfcst_gen_currentqtrm3
     , SUM(IFNULL(forecast.hrsfcst_gen_remaininginqtr, 0.00))                                  AS hrsfcst_gen_remaininginqtr
     , SUM(IFNULL(forecast.hrsfcst_gen_plus1qtr, 0.00))                                        AS hrsfcst_gen_plus1qtr
     , SUM(IFNULL(forecast.hrsfcst_gen_plus2qtr, 0.00))                                        AS hrsfcst_gen_plus2qtr
     , SUM(IFNULL(forecast.hrsfcst_gen_plus3qtr, 0.00))                                        AS hrsfcst_gen_plus3qtr
     , SUM(IFNULL(forecast.hrsfcst_gen_additionalqtrs, 0.00))                                  AS hrsfcst_gen_additionalqtrs
     , SUM(IFNULL(forecast.hrsfcst_gen_customrange, 0.00))                                     AS hrsfcst_gen_customrange
     , SUM(IFNULL(forecast.hrsfcst_gen_aftercutover, 0.00))                                    AS hrsfcst_gen_aftercutover
     , SUM(IFNULL(hrsfcst_all_soft, 0.00))                                                     AS hrsfcst_all_soft
     , SUM(IFNULL(hrsfcst_future_soft, 0.00))                                                  AS hrsfcst_future_soft
     , SUM(IFNULL(hrsfcst_currentmonth_soft, 0.00))                                            AS hrsfcst_currentmonth_soft
     , SUM(IFNULL(hrsfcst_futuremonths_soft, 0.00))                                            AS hrsfcst_futuremonths_soft
     , SUM(IFNULL(hrsfcst_futureqtrs_soft, 0.00))                                              AS hrsfcst_futureqtrs_soft
     , SUM(IFNULL(hrsfcst_entirecurrentqtr_soft, 0.00))                                        AS hrsfcst_entirecurrentqtr_soft
     , SUM(IFNULL(hrsfcst_currentqtrm1_soft, 0.00))                                            AS hrsfcst_currentqtrm1_soft
     , SUM(IFNULL(hrsfcst_currentqtrm2_soft, 0.00))                                            AS hrsfcst_currentqtrm2_soft
     , SUM(IFNULL(hrsfcst_currentqtrm3_soft, 0.00))                                            AS hrsfcst_currentqtrm3_soft
     , SUM(IFNULL(hrsfcst_remaininginqtr_soft, 0.00))                                          AS hrsfcst_remaininginqtr_soft
     , SUM(IFNULL(hrsfcst_plus1qtr_soft, 0.00))                                                AS hrsfcst_plus1qtr_soft
     , SUM(IFNULL(hrsfcst_plus2qtr_soft, 0.00))                                                AS hrsfcst_plus2qtr_soft
     , SUM(IFNULL(hrsfcst_plus3qtr_soft, 0.00))                                                AS hrsfcst_plus3qtr_soft
     , SUM(IFNULL(hrsfcst_additionalqtrs_soft, 0.00))                                          AS hrsfcst_additionalqtrs_soft
     , SUM(IFNULL(hrsfcst_customrange_soft, 0.00))                                             AS hrsfcst_customrange_soft
     , SUM(IFNULL(hrsfcst_aftercutover_soft, 0.00))                                            AS hrsfcst_aftercutover_soft
     , SUM(IFNULL(hrsfcst_billable_all_soft, 0.00))                                            AS hrsfcst_billable_all_soft
     , SUM(IFNULL(hrsfcst_billable_future_soft, 0.00))                                         AS hrsfcst_billable_future_soft
     , SUM(IFNULL(hrsfcst_billable_currentmonth_soft, 0.00))                                   AS hrsfcst_billable_currentmonth_soft
     , SUM(IFNULL(hrsfcst_billable_futuremonths_soft, 0.00))                                   AS hrsfcst_billable_futuremonths_soft
     , SUM(IFNULL(hrsfcst_billable_futureqtrs_soft, 0.00))                                     AS hrsfcst_billable_futureqtrs_soft
     , SUM(IFNULL(hrsfcst_billable_entirecurrentqtr_soft, 0.00))                               AS hrsfcst_billable_entirecurrentqtr_soft
     , SUM(IFNULL(hrsfcst_billable_currentqtrm1_soft, 0.00))                                   AS hrsfcst_billable_currentqtrm1_soft
     , SUM(IFNULL(hrsfcst_billable_currentqtrm2_soft, 0.00))                                   AS hrsfcst_billable_currentqtrm2_soft
     , SUM(IFNULL(hrsfcst_billable_currentqtrm3_soft, 0.00))                                   AS hrsfcst_billable_currentqtrm3_soft
     , SUM(IFNULL(hrsfcst_billable_currentqtrm1_soft_wk, 0.00))                                AS hrsfcst_billable_currentqtrm1_soft_wk
     , SUM(IFNULL(hrsfcst_billable_currentqtrm2_soft_wk, 0.00))                                AS hrsfcst_billable_currentqtrm2_soft_wk
     , SUM(IFNULL(hrsfcst_billable_currentqtrm3_soft_wk, 0.00))                                AS hrsfcst_billable_currentqtrm3_soft_wk
     , SUM(IFNULL(hrsfcst_billable_remaininginqtr_soft, 0.00))                                 AS hrsfcst_billable_remaininginqtr_soft
     , SUM(IFNULL(hrsfcst_billable_plus1qtr_soft, 0.00))                                       AS hrsfcst_billable_plus1qtr_soft
     , SUM(IFNULL(hrsfcst_billable_plus2qtr_soft, 0.00))                                       AS hrsfcst_billable_plus2qtr_soft
     , SUM(IFNULL(hrsfcst_billable_plus3qtr_soft, 0.00))                                       AS hrsfcst_billable_plus3qtr_soft
     , SUM(IFNULL(hrsfcst_billable_plus4qtr_soft, 0.00))                                       AS hrsfcst_billable_plus4qtr_soft
     , SUM(IFNULL(hrsfcst_billable_plus5qtr_soft, 0.00))                                       AS hrsfcst_billable_plus5qtr_soft
     , SUM(IFNULL(hrsfcst_billable_additionalqtrs_soft, 0.00))                                 AS hrsfcst_billable_additionalqtrs_soft
     , SUM(IFNULL(hrsfcst_billable_additionalqtrs2_soft, 0.00))                                AS hrsfcst_billable_additionalqtrs2_soft
     , SUM(IFNULL(hrsfcst_billable_customrange_soft, 0.00))                                    AS hrsfcst_billable_customrange_soft
     , SUM(IFNULL(hrsfcst_billable_aftercutover_soft, 0.00))                                   AS hrsfcst_billable_aftercutover_soft
     , SUM(IFNULL(hrsfcst_gen_all_soft, 0.00))                                                 AS hrsfcst_gen_all_soft
     , SUM(IFNULL(hrsfcst_gen_future_soft, 0.00))                                              AS hrsfcst_gen_future_soft
     , SUM(IFNULL(hrsfcst_gen_currentmonth_soft, 0.00))                                        AS hrsfcst_gen_currentmonth_soft
     , SUM(IFNULL(hrsfcst_gen_futuremonths_soft, 0.00))                                        AS hrsfcst_gen_futuremonths_soft
     , SUM(IFNULL(hrsfcst_gen_futureqtrs_soft, 0.00))                                          AS hrsfcst_gen_futureqtrs_soft
     , SUM(IFNULL(hrsfcst_gen_entirecurrentqtr_soft, 0.00))                                    AS hrsfcst_gen_entirecurrentqtr_soft
     , SUM(IFNULL(hrsfcst_gen_currentqtrm1_soft, 0.00))                                        AS hrsfcst_gen_currentqtrm1_soft
     , SUM(IFNULL(hrsfcst_gen_currentqtrm2_soft, 0.00))                                        AS hrsfcst_gen_currentqtrm2_soft
     , SUM(IFNULL(hrsfcst_gen_currentqtrm3_soft, 0.00))                                        AS hrsfcst_gen_currentqtrm3_soft
     , SUM(IFNULL(hrsfcst_gen_remaininginqtr_soft, 0.00))                                      AS hrsfcst_gen_remaininginqtr_soft
     , SUM(IFNULL(hrsfcst_gen_plus1qtr_soft, 0.00))                                            AS hrsfcst_gen_plus1qtr_soft
     , SUM(IFNULL(hrsfcst_gen_plus2qtr_soft, 0.00))                                            AS hrsfcst_gen_plus2qtr_soft
     , SUM(IFNULL(hrsfcst_gen_plus3qtr_soft, 0.00))                                            AS hrsfcst_gen_plus3qtr_soft
     , SUM(IFNULL(hrsfcst_gen_additionalqtrs_soft, 0.00))                                      AS hrsfcst_gen_additionalqtrs_soft
     , SUM(IFNULL(hrsfcst_gen_customrange_soft, 0.00))                                         AS hrsfcst_gen_customrange_soft
     , SUM(IFNULL(hrsfcst_gen_aftercutover_soft, 0.00))                                        AS hrsfcst_gen_aftercutover_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_all_soft, 0.00))                                         AS hrsfcst_nonbill_gen_all_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_future_soft, 0.00))                                      AS hrsfcst_nonbill_gen_future_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_currentmonth_soft, 0.00))                                AS hrsfcst_nonbill_gen_currentmonth_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_futuremonths_soft, 0.00))                                AS hrsfcst_nonbill_gen_futuremonths_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_futureqtrs_soft, 0.00))                                  AS hrsfcst_nonbill_gen_futureqtrs_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_entirecurrentqtr_soft, 0.00))                            AS hrsfcst_nonbill_gen_entirecurrentqtr_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_currentqtrm1_soft, 0.00))                                AS hrsfcst_nonbill_gen_currentqtrm1_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_currentqtrm2_soft, 0.00))                                AS hrsfcst_nonbill_gen_currentqtrm2_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_currentqtrm3_soft, 0.00))                                AS hrsfcst_nonbill_gen_currentqtrm3_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_remaininginqtr_soft, 0.00))                              AS hrsfcst_nonbill_gen_remaininginqtr_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_plus1qtr_soft, 0.00))                                    AS hrsfcst_nonbill_gen_plus1qtr_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_plus2qtr_soft, 0.00))                                    AS hrsfcst_nonbill_gen_plus2qtr_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_plus3qtr_soft, 0.00))                                    AS hrsfcst_nonbill_gen_plus3qtr_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_additionalqtrs_soft, 0.00))                              AS hrsfcst_nonbill_gen_additionalqtrs_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_customrange_soft, 0.00))                                 AS hrsfcst_nonbill_gen_customrange_soft
     , SUM(IFNULL(hrsfcst_nonbill_gen_aftercutover_soft, 0.00))                                AS hrsfcst_nonbill_gen_aftercutover_soft
  
                                  
FROM {{ source('tenrox_private', 'tproject') }}  tproject
        LEFT JOIN {{ source('tenrox_private', 'tprojectcustfld') }}  a On a.PROJECTID = tproject.uniqueid
        LEFT JOIN {{ source('tenrox_private', 'tcustlst') }} AS LST_16  ON a.ADSK_MasterAgreement_ProjectType = LST_16.UNIQUEID 
        LEFT JOIN {{ source('tenrox_private', 'tcustlstdesc') }} AS LSTDESC_16  ON LST_16.UNIQUEID = LSTDESC_16.CUSTLSTID AND LSTDESC_16.LANGUAGE = 0
LEFT JOIN
    (
        SELECT DISTINCT 
            projectid AS projectid
        FROM {{ source('tenrox_private', 'ttimeentry') }} ttimeentry
        JOIN {{ source('tenrox_private', 'ttask') }} ttask
            ON ttimeentry.taskid = ttask.uniqueid
        UNION
        SELECT DISTINCT 
            trplnbooking.projectid AS projectid
        FROM {{ source('tenrox_private', 'trplnbooking') }} trplnbooking
        JOIN {{ source('tenrox_private', 'trplnbookingdetails') }} trplnbookingdetails
            ON trplnbookingdetails.bookingid = trplnbooking.uniqueid
    ) projectlinks
    ON projectlinks.projectid = tproject.uniqueid 
LEFT JOIN actuals ON actuals.projectid = projectlinks.projectid 
LEFT JOIN forecast ON forecast.projectid = projectlinks.projectid
where LSTDESC_16.VALUE in ('IS Parent','IS Child')
group by
parent_child_key 


)


--select * from is_parent_child where parent_child_key = '14989';

SELECT 
     tproject.uniqueid                                                  AS projectid
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_all
        ELSE IFNULL(actuals.hrsact_total_all, 0.00)  
  END                AS hrsact_total_all
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_past 
        ELSE IFNULL(actuals.hrsact_total_past, 0.00) 
  END                AS hrsact_total_past
  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_currentmonth
    ELSE COALESCE(actuals.hrsact_total_currentmonth, 0.00) 
  END          AS hrsact_total_currentmonth

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_pastqtrs
    ELSE COALESCE(actuals.hrsact_total_pastqtrs, 0.00)
  END                                                                   AS hrsact_total_pastqtrs

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_entirecurrentqtr
    ELSE COALESCE(actuals.hrsact_total_entirecurrentqtr, 0.00)
  END                                                                    AS hrsact_total_entirecurrentqtr

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_currentqtrm1
    ELSE COALESCE(actuals.hrsact_total_currentqtrm1, 0.00)
  END                                                                    AS hrsact_total_currentqtrm1

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_currentqtrm2
    ELSE COALESCE(actuals.hrsact_total_currentqtrm2, 0.00)
  END                                                                   AS hrsact_total_currentqtrm2

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_currentqtrm3
    ELSE COALESCE(actuals.hrsact_total_currentqtrm3, 0.00)
  END                                                                   AS hrsact_total_currentqtrm3

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_completedinqtr
    ELSE COALESCE(actuals.hrsact_total_completedinqtr, 0.00)
  END                                                                   AS hrsact_total_completedinqtr

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_minus1qtr
    ELSE COALESCE(actuals.hrsact_total_minus1qtr, 0.00)
  END                                                                   AS hrsact_total_minus1qtr

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_minus2qtr
    ELSE COALESCE(actuals.hrsact_total_minus2qtr, 0.00)
  END                                                                   AS hrsact_total_minus2qtr

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_minus3qtr
    ELSE COALESCE(actuals.hrsact_total_minus3qtr, 0.00)
  END                                                                   AS hrsact_total_minus3qtr

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_priorqtrs
    ELSE COALESCE(actuals.hrsact_total_priorqtrs, 0.00)
  END                                                                   AS hrsact_total_priorqtrs

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_customrange
    ELSE COALESCE(actuals.hrsact_total_customrange, 0.00)
  END                                                                   AS hrsact_total_customrange

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_beforecutover
    ELSE COALESCE(actuals.hrsact_total_beforecutover, 0.00)
  END                                                                   AS hrsact_total_beforecutover

  ,CASE
    WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_all
    ELSE COALESCE(actuals.hrsact_all, 0.00)
  END                                                                   AS hrsact_all

 ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_past  
        ELSE IFNULL(actuals.hrsact_past, 0.00)  
  END                     AS hrsact_past
 ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_currentmonth 
       ELSE IFNULL(actuals.hrsact_currentmonth, 0.00) 
  END               AS hrsact_currentmonth

 ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_pastqtrs  
       ELSE IFNULL(actuals.hrsact_pastqtrs, 0.00) 
  END                   AS hrsact_pastqtrs

 ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_entirecurrentqtr
       ELSE IFNULL(actuals.hrsact_entirecurrentqtr, 0.00) 
  END           AS hrsact_entirecurrentqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_currentqtrm1
       ELSE IFNULL(actuals.hrsact_currentqtrm1, 0.00) 
  END               AS hrsact_currentqtrm1
   ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_currentqtrm1_wk
       ELSE IFNULL(actuals.hrsact_currentqtrm1_wk, 0.00) 
  END               AS hrsact_currentqtrm1_wk

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_currentqtrm2
       ELSE IFNULL(actuals.hrsact_currentqtrm2, 0.00) 
  END               AS hrsact_currentqtrm2
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_currentqtrm2_wk
       ELSE IFNULL(actuals.hrsact_currentqtrm2_wk, 0.00) 
  END               AS hrsact_currentqtrm2_wk

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_currentqtrm3
       ELSE IFNULL(actuals.hrsact_currentqtrm3, 0.00) 
  END               AS hrsact_currentqtrm3
  
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_currentqtrm3_wk
       ELSE IFNULL(actuals.hrsact_currentqtrm3_wk, 0.00) 
  END               AS hrsact_currentqtrm3_wk
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_completedinqtr
       ELSE IFNULL(actuals.hrsact_completedinqtr, 0.00) 
  END             AS hrsact_completedinqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_minus1qtr
       ELSE IFNULL(actuals.hrsact_minus1qtr, 0.00) 
  END                  AS hrsact_minus1qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_minus2qtr
       ELSE IFNULL(actuals.hrsact_minus2qtr, 0.00) 
  END                  AS hrsact_minus2qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_minus3qtr
       ELSE IFNULL(actuals.hrsact_minus3qtr, 0.00) 
  END                  AS hrsact_minus3qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_priorqtrs
       ELSE IFNULL(actuals.hrsact_priorqtrs, 0.00) 
  END                  AS hrsact_priorqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_customrange
       ELSE IFNULL(actuals.hrsact_customrange, 0.00) 
  END                AS hrsact_customrange

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_beforecutover
       ELSE IFNULL(actuals.hrsact_beforecutover, 0.00) 
  END              AS hrsact_beforecutover
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_all 
       ELSE IFNULL(actuals.hrsact_unapp_all, 0.00) 
  END                  AS hrsact_unapp_all

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_past 
       ELSE IFNULL(actuals.hrsact_unapp_past, 0.00) 
  END                 AS hrsact_unapp_past

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_currentmonth 
       ELSE IFNULL(actuals.hrsact_unapp_currentmonth, 0.00) 
  END         AS hrsact_unapp_currentmonth

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_pastqtrs 
       ELSE IFNULL(actuals.hrsact_unapp_pastqtrs, 0.00) 
  END             AS hrsact_unapp_pastqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_entirecurrentqtr 
       ELSE IFNULL(actuals.hrsact_unapp_entirecurrentqtr, 0.00) 
  END     AS hrsact_unapp_entirecurrentqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_currentqtrm1 
       ELSE IFNULL(actuals.hrsact_unapp_currentqtrm1, 0.00) 
  END         AS hrsact_unapp_currentqtrm1

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_currentqtrm2 
       ELSE IFNULL(actuals.hrsact_unapp_currentqtrm2, 0.00) 
  END         AS hrsact_unapp_currentqtrm2

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_currentqtrm3 
       ELSE IFNULL(actuals.hrsact_unapp_currentqtrm3, 0.00) 
  END         AS hrsact_unapp_currentqtrm3

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_completedinqtr 
       ELSE IFNULL(actuals.hrsact_unapp_completedinqtr, 0.00) 
  END       AS hrsact_unapp_completedinqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_minus1qtr 
       ELSE IFNULL(actuals.hrsact_unapp_minus1qtr, 0.00) 
  END            AS hrsact_unapp_minus1qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_minus2qtr 
       ELSE IFNULL(actuals.hrsact_unapp_minus2qtr, 0.00) 
  END            AS hrsact_unapp_minus2qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_minus3qtr 
       ELSE IFNULL(actuals.hrsact_unapp_minus3qtr, 0.00) 
  END            AS hrsact_unapp_minus3qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_priorqtrs 
       ELSE IFNULL(actuals.hrsact_unapp_priorqtrs, 0.00) 
  END            AS hrsact_unapp_priorqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_customrange 
       ELSE IFNULL(actuals.hrsact_unapp_customrange, 0.00) 
  END          AS hrsact_unapp_customrange

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_unapp_beforecutover 
       ELSE IFNULL(actuals.hrsact_unapp_beforecutover, 0.00) 
  END        AS hrsact_unapp_beforecutover
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_all 
       ELSE IFNULL(actuals.hrsact_nonbill_all, 0.00) 
  END                AS hrsact_nonbill_all

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_past 
       ELSE IFNULL(actuals.hrsact_nonbill_past, 0.00) 
  END               AS hrsact_nonbill_past

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_currentmonth 
       ELSE IFNULL(actuals.hrsact_nonbill_currentmonth, 0.00) 
  END       AS hrsact_nonbill_currentmonth

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_pastqtrs 
       ELSE IFNULL(actuals.hrsact_nonbill_pastqtrs, 0.00) 
  END           AS hrsact_nonbill_pastqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_entirecurrentqtr 
       ELSE IFNULL(actuals.hrsact_nonbill_entirecurrentqtr, 0.00) 
  END   AS hrsact_nonbill_entirecurrentqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_currentqtrm1 
       ELSE IFNULL(actuals.hrsact_nonbill_currentqtrm1, 0.00) 
  END       AS hrsact_nonbill_currentqtrm1

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_currentqtrm2 
       ELSE IFNULL(actuals.hrsact_nonbill_currentqtrm2, 0.00) 
  END       AS hrsact_nonbill_currentqtrm2

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_currentqtrm3 
       ELSE IFNULL(actuals.hrsact_nonbill_currentqtrm3, 0.00) 
  END       AS hrsact_nonbill_currentqtrm3

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_completedinqtr 
       ELSE IFNULL(actuals.hrsact_nonbill_completedinqtr, 0.00) 
  END     AS hrsact_nonbill_completedinqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_minus1qtr 
       ELSE IFNULL(actuals.hrsact_nonbill_minus1qtr, 0.00) 
  END          AS hrsact_nonbill_minus1qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_minus2qtr 
       ELSE IFNULL(actuals.hrsact_nonbill_minus2qtr, 0.00) 
  END          AS hrsact_nonbill_minus2qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_minus3qtr 
       ELSE IFNULL(actuals.hrsact_nonbill_minus3qtr, 0.00) 
  END          AS hrsact_nonbill_minus3qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_priorqtrs 
       ELSE IFNULL(actuals.hrsact_nonbill_priorqtrs, 0.00) 
  END          AS hrsact_nonbill_priorqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_customrange 
       ELSE IFNULL(actuals.hrsact_nonbill_customrange, 0.00) 
  END        AS hrsact_nonbill_customrange

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_beforecutover 
       ELSE IFNULL(actuals.hrsact_nonbill_beforecutover, 0.00) 
  END      AS hrsact_nonbill_beforecutover
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_all 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_all, 0.00) 
  END          AS hrsact_nonbill_unapp_all

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_past 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_past, 0.00) 
  END         AS hrsact_nonbill_unapp_past

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_currentmonth 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_currentmonth, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_currentmonth

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_pastqtrs 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_pastqtrs, 0.00) 
  END     AS hrsact_nonbill_unapp_pastqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_entirecurrentqtr 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_entirecurrentqtr, 0.00) 
   END                                                                  AS hrsact_nonbill_unapp_entirecurrentqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_currentqtrm1 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_currentqtrm1, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_currentqtrm1

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_currentqtrm2 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_currentqtrm2, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_currentqtrm2

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_currentqtrm3 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_currentqtrm3, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_currentqtrm3

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_completedinqtr 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_completedinqtr, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_completedinqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_minus1qtr 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_minus1qtr, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_minus1qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_minus2qtr 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_minus2qtr, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_minus2qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_minus3qtr 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_minus3qtr, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_minus3qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_priorqtrs 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_priorqtrs, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_priorqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_customrange 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_customrange, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_customrange

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_nonbill_unapp_beforecutover 
       ELSE IFNULL(actuals.hrsact_nonbill_unapp_beforecutover, 0.00) 
  END                                                                   AS hrsact_nonbill_unapp_beforecutover
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_all 
       ELSE IFNULL(actuals.hrsact_utilized_all, 0.00) 
  END               AS hrsact_utilized_all

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_past 
       ELSE IFNULL(actuals.hrsact_utilized_past, 0.00) 
  END              AS hrsact_utilized_past

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_currentmonth 
       ELSE IFNULL(actuals.hrsact_utilized_currentmonth, 0.00) 
  END                                                                   AS hrsact_utilized_currentmonth

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_pastqtrs 
       ELSE IFNULL(actuals.hrsact_utilized_pastqtrs, 0.00) 
  END                                                                   AS hrsact_utilized_pastqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_entirecurrentqtr 
       ELSE IFNULL(actuals.hrsact_utilized_entirecurrentqtr, 0.00) 
  END                                                                   AS hrsact_utilized_entirecurrentqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_currentqtrm1 
       ELSE IFNULL(actuals.hrsact_utilized_currentqtrm1, 0.00) 
  END      AS hrsact_utilized_currentqtrm1

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_currentqtrm2 
       ELSE IFNULL(actuals.hrsact_utilized_currentqtrm2, 0.00) 
  END      AS hrsact_utilized_currentqtrm2

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_currentqtrm3 
       ELSE IFNULL(actuals.hrsact_utilized_currentqtrm3, 0.00) 
  END      AS hrsact_utilized_currentqtrm3

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_completedinqtr 
       ELSE IFNULL(actuals.hrsact_utilized_completedinqtr, 0.00) 
  END    AS hrsact_utilized_completedinqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_minus1qtr 
       ELSE IFNULL(actuals.hrsact_utilized_minus1qtr, 0.00) 
  END         AS hrsact_utilized_minus1qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_minus2qtr 
       ELSE IFNULL(actuals.hrsact_utilized_minus2qtr, 0.00) 
  END         AS hrsact_utilized_minus2qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_minus3qtr 
       ELSE IFNULL(actuals.hrsact_utilized_minus3qtr, 0.00) 
  END         AS hrsact_utilized_minus3qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_priorqtrs 
       ELSE IFNULL(actuals.hrsact_utilized_priorqtrs, 0.00) 
  END         AS hrsact_utilized_priorqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_customrange 
       ELSE IFNULL(actuals.hrsact_utilized_customrange, 0.00) 
  END       AS hrsact_utilized_customrange

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_beforecutover 
       ELSE IFNULL(actuals.hrsact_utilized_beforecutover, 0.00) 
  END     AS hrsact_utilized_beforecutover
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_all 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_all, 0.00) 
  END         AS hrsact_utilized_unapp_all

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_past 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_past, 0.00) 
  END        AS hrsact_utilized_unapp_past

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_currentmonth 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_currentmonth, 0.00) 
  END                                                                   AS hrsact_utilized_unapp_currentmonth

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_pastqtrs 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_pastqtrs, 0.00) 
  END                                                                   AS hrsact_utilized_unapp_pastqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_entirecurrentqtr 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_entirecurrentqtr, 0.00) 
  END                                                                   AS hrsact_utilized_unapp_entirecurrentqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_currentqtrm1 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_currentqtrm1, 0.00) 
  END                                                                   AS hrsact_utilized_unapp_currentqtrm1

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_currentqtrm2 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_currentqtrm2, 0.00) 
  END                                                                   AS hrsact_utilized_unapp_currentqtrm2

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_currentqtrm3 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_currentqtrm3, 0.00) 
  END                                                                   AS hrsact_utilized_unapp_currentqtrm3

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_completedinqtr 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_completedinqtr, 0.00) 
  END                                                                   AS hrsact_utilized_unapp_completedinqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_minus1qtr 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_minus1qtr, 0.00) 
  END                                                                   AS hrsact_utilized_unapp_minus1qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_minus2qtr 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_minus2qtr, 0.00) END   AS hrsact_utilized_unapp_minus2qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_minus3qtr 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_minus3qtr, 0.00) END   AS hrsact_utilized_unapp_minus3qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_priorqtrs 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_priorqtrs, 0.00) END   AS hrsact_utilized_unapp_priorqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_customrange 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_customrange, 0.00) 
  END                                                                   AS hrsact_utilized_unapp_customrange

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_utilized_unapp_beforecutover 
       ELSE IFNULL(actuals.hrsact_utilized_unapp_beforecutover, 0.00) 
  END                                                                   AS hrsact_utilized_unapp_beforecutover
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrs_eac_with_utilized
    ELSE IFNULL(actuals.hrsact_past, 0.00)
         + IFNULL(actuals.hrsact_utilized_past, 0.00)
         + IFNULL(forecast.hrsfcst_future, 0.00)    
  END                 AS hrs_eac_with_utilized
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_all 
       ELSE IFNULL(forecast.hrsfcst_all, 0.00) END                      AS hrsfcst_all

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_future 
       ELSE IFNULL(forecast.hrsfcst_future, 0.00) 
  END                   AS hrsfcst_future

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_currentmonth 
       ELSE IFNULL(forecast.hrsfcst_currentmonth, 0.00) 
  END             AS hrsfcst_currentmonth

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_futuremonths 
       ELSE IFNULL(forecast.hrsfcst_futuremonths, 0.00) 
  END             AS hrsfcst_futuremonths

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_futureqtrs 
       ELSE IFNULL(forecast.hrsfcst_futureqtrs, 0.00) 
  END               AS hrsfcst_futureqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_entirecurrentqtr 
       ELSE IFNULL(forecast.hrsfcst_entirecurrentqtr, 0.00) 
  END         AS hrsfcst_entirecurrentqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_currentqtrm1 
       ELSE IFNULL(forecast.hrsfcst_currentqtrm1, 0.00) 
  END             AS hrsfcst_currentqtrm1

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_currentqtrm2 
       ELSE IFNULL(forecast.hrsfcst_currentqtrm2, 0.00) 
  END             AS hrsfcst_currentqtrm2

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_currentqtrm3 
       ELSE IFNULL(forecast.hrsfcst_currentqtrm3, 0.00) 
  END             AS hrsfcst_currentqtrm3

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_remaininginqtr 
       ELSE IFNULL(forecast.hrsfcst_remaininginqtr, 0.00) 
  END           AS hrsfcst_remaininginqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_plus1qtr 
       ELSE IFNULL(forecast.hrsfcst_plus1qtr, 0.00) 
  END                 AS hrsfcst_plus1qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_plus2qtr 
       ELSE IFNULL(forecast.hrsfcst_plus2qtr, 0.00) 
  END                 AS hrsfcst_plus2qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_plus3qtr 
       ELSE IFNULL(forecast.hrsfcst_plus3qtr, 0.00) 
  END                 AS hrsfcst_plus3qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_plus4qtr 
       ELSE IFNULL(forecast.hrsfcst_plus4qtr, 0.00) 
  END                 AS hrsfcst_plus4qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_plus5qtr 
       ELSE IFNULL(forecast.hrsfcst_plus5qtr, 0.00) 
  END                 AS hrsfcst_plus5qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_additionalqtrs 
       ELSE IFNULL(forecast.hrsfcst_additionalqtrs, 0.00) 
  END           AS hrsfcst_additionalqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_additional2qtrs 
       ELSE IFNULL(forecast.hrsfcst_additional2qtrs, 0.00) 
  END          AS hrsfcst_additional2qtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_customrange 
       ELSE IFNULL(forecast.hrsfcst_customrange, 0.00) 
  END              AS hrsfcst_customrange

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_aftercutover 
       ELSE IFNULL(forecast.hrsfcst_aftercutover, 0.00) 
  END             AS hrsfcst_aftercutover
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN  ipc.hrs_eac
    ELSE IFNULL(actuals.hrsact_past, 0.00)
         + IFNULL(forecast.hrsfcst_future, 0.00)     
  END                   AS hrs_eac
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_all 
       ELSE IFNULL(forecast.hrsfcst_billable_all, 0.00) 
  END             AS hrsfcst_billable_all

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_future 
       ELSE IFNULL(forecast.hrsfcst_billable_future, 0.00) 
  END          AS hrsfcst_billable_future

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentmonth 
       ELSE IFNULL(forecast.hrsfcst_billable_currentmonth, 0.00) 
  END    AS hrsfcst_billable_currentmonth

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_futuremonths 
       ELSE IFNULL(forecast.hrsfcst_billable_futuremonths, 0.00) 
  END    AS hrsfcst_billable_futuremonths

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_futureqtrs 
       ELSE IFNULL(forecast.hrsfcst_billable_futureqtrs, 0.00) 
  END      AS hrsfcst_billable_futureqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_entirecurrentqtr 
       ELSE IFNULL(forecast.hrsfcst_billable_entirecurrentqtr, 0.00) 
  END                                                                   AS hrsfcst_billable_entirecurrentqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm1 
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm1, 0.00) 
  END    AS hrsfcst_billable_currentqtrm1
 ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm1_wk
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm1_wk, 0.00) 
  END    AS hrsfcst_billable_currentqtrm1_wk

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm2 
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm2, 0.00) 
  END    AS hrsfcst_billable_currentqtrm2
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm2_wk
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm2_wk, 0.00) 
  END    AS hrsfcst_billable_currentqtrm2_wk

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm3 
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm3, 0.00) 
  END    AS hrsfcst_billable_currentqtrm3

 ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm3_wk 
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm3_wk, 0.00) 
  END    AS hrsfcst_billable_currentqtrm3_wk
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_remaininginqtr 
       ELSE IFNULL(forecast.hrsfcst_billable_remaininginqtr, 0.00) 
  END  AS hrsfcst_billable_remaininginqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_plus1qtr 
       ELSE IFNULL(forecast.hrsfcst_billable_plus1qtr, 0.00) 
  END        AS hrsfcst_billable_plus1qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_plus2qtr 
       ELSE IFNULL(forecast.hrsfcst_billable_plus2qtr, 0.00) 
  END        AS hrsfcst_billable_plus2qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_plus3qtr 
       ELSE IFNULL(forecast.hrsfcst_billable_plus3qtr, 0.00) 
  END        AS hrsfcst_billable_plus3qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_plus4qtr 
       ELSE IFNULL(forecast.hrsfcst_billable_plus4qtr, 0.00) 
  END        AS hrsfcst_billable_plus4qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_plus5qtr 
       ELSE IFNULL(forecast.hrsfcst_billable_plus5qtr, 0.00) 
  END        AS hrsfcst_billable_plus5qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_additionalqtrs 
       ELSE IFNULL(forecast.hrsfcst_billable_additionalqtrs, 0.00) 
  END  AS hrsfcst_billable_additionalqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_additionalqtrs2 
       ELSE IFNULL(forecast.hrsfcst_billable_additionalqtrs2, 0.00) 
  END AS hrsfcst_billable_additionalqtrs2

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_customrange 
       ELSE IFNULL(forecast.hrsfcst_billable_customrange, 0.00) 
  END     AS hrsfcst_billable_customrange

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_aftercutover 
       ELSE IFNULL(forecast.hrsfcst_billable_aftercutover, 0.00) 
  END    AS hrsfcst_billable_aftercutover
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' then ipc.hrs_billable_eac 
        ELSE (IFNULL(actuals.hrsact_past, 0.00)
         + IFNULL(forecast.hrsfcst_billable_future, 0.00)) 
  END          AS hrs_billable_eac
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_all 
       ELSE IFNULL(forecast.hrsfcst_gen_all, 0.00) 
  END                  AS hrsfcst_gen_all

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_future 
       ELSE IFNULL(forecast.hrsfcst_gen_future, 0.00) 
  END               AS hrsfcst_gen_future

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_currentmonth 
       ELSE IFNULL(forecast.hrsfcst_gen_currentmonth, 0.00) 
  END         AS hrsfcst_gen_currentmonth

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_futuremonths 
       ELSE IFNULL(forecast.hrsfcst_gen_futuremonths, 0.00) 
  END         AS hrsfcst_gen_futuremonths

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_futureqtrs 
       ELSE IFNULL(forecast.hrsfcst_gen_futureqtrs, 0.00) 
  END           AS hrsfcst_gen_futureqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_entirecurrentqtr 
       ELSE IFNULL(forecast.hrsfcst_gen_entirecurrentqtr, 0.00) 
  END     AS hrsfcst_gen_entirecurrentqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_currentqtrm1 
       ELSE IFNULL(forecast.hrsfcst_gen_currentqtrm1, 0.00) 
  END         AS hrsfcst_gen_currentqtrm1

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_currentqtrm2 
       ELSE IFNULL(forecast.hrsfcst_gen_currentqtrm2, 0.00) 
  END         AS hrsfcst_gen_currentqtrm2

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_currentqtrm3 
       ELSE IFNULL(forecast.hrsfcst_gen_currentqtrm3, 0.00) 
  END         AS hrsfcst_gen_currentqtrm3

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_remaininginqtr 
       ELSE IFNULL(forecast.hrsfcst_gen_remaininginqtr, 0.00) 
  END       AS hrsfcst_gen_remaininginqtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_plus1qtr 
       ELSE IFNULL(forecast.hrsfcst_gen_plus1qtr, 0.00) 
  END             AS hrsfcst_gen_plus1qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_plus2qtr 
       ELSE IFNULL(forecast.hrsfcst_gen_plus2qtr, 0.00) 
  END             AS hrsfcst_gen_plus2qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_plus3qtr 
       ELSE IFNULL(forecast.hrsfcst_gen_plus3qtr, 0.00) 
  END             AS hrsfcst_gen_plus3qtr

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_additionalqtrs 
       ELSE IFNULL(forecast.hrsfcst_gen_additionalqtrs, 0.00) 
  END       AS hrsfcst_gen_additionalqtrs

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_customrange 
       ELSE IFNULL(forecast.hrsfcst_gen_customrange, 0.00) 
  END          AS hrsfcst_gen_customrange

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_aftercutover 
       ELSE IFNULL(forecast.hrsfcst_gen_aftercutover, 0.00) 
  END         AS hrsfcst_gen_aftercutover
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_all_soft 
       ELSE IFNULL(forecast.hrsfcst_all_soft, 0.00) 
  END                 AS hrsfcst_all_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_future_soft 
       ELSE IFNULL(forecast.hrsfcst_future_soft, 0.00) 
  END              AS hrsfcst_future_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_currentmonth_soft 
       ELSE IFNULL(forecast.hrsfcst_currentmonth_soft, 0.00) 
  END        AS hrsfcst_currentmonth_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_futuremonths_soft 
       ELSE IFNULL(forecast.hrsfcst_futuremonths_soft, 0.00) 
  END        AS hrsfcst_futuremonths_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_futureqtrs_soft 
       ELSE IFNULL(forecast.hrsfcst_futureqtrs_soft, 0.00) 
  END          AS hrsfcst_futureqtrs_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_entirecurrentqtr_soft 
       ELSE IFNULL(forecast.hrsfcst_entirecurrentqtr_soft, 0.00) 
  END    AS hrsfcst_entirecurrentqtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_currentqtrm1_soft 
       ELSE IFNULL(forecast.hrsfcst_currentqtrm1_soft, 0.00) 
  END        AS hrsfcst_currentqtrm1_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_currentqtrm2_soft 
       ELSE IFNULL(forecast.hrsfcst_currentqtrm2_soft, 0.00) 
  END        AS hrsfcst_currentqtrm2_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_currentqtrm3_soft 
       ELSE IFNULL(forecast.hrsfcst_currentqtrm3_soft, 0.00) 
  END        AS hrsfcst_currentqtrm3_soft
  
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_remaininginqtr_soft 
       ELSE IFNULL(forecast.hrsfcst_remaininginqtr_soft, 0.00) 
  END      AS hrsfcst_remaininginqtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_plus1qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_plus1qtr_soft, 0.00) 
  END            AS hrsfcst_plus1qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_plus2qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_plus2qtr_soft, 0.00) 
  END            AS hrsfcst_plus2qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_plus3qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_plus3qtr_soft, 0.00) 
  END            AS hrsfcst_plus3qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_additionalqtrs_soft 
       ELSE IFNULL(forecast.hrsfcst_additionalqtrs_soft, 0.00) 
  END      AS hrsfcst_additionalqtrs_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_customrange_soft 
       ELSE IFNULL(forecast.hrsfcst_customrange_soft, 0.00) 
  END         AS hrsfcst_customrange_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_aftercutover_soft 
       ELSE IFNULL(forecast.hrsfcst_aftercutover_soft, 0.00) 
  END        AS hrsfcst_aftercutover_soft
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_all_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_all_soft, 0.00) 
  END AS hrsfcst_billable_all_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_future_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_future_soft, 0.00) 
  END     AS hrsfcst_billable_future_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentmonth_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_currentmonth_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_currentmonth_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_futuremonths_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_futuremonths_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_futuremonths_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_futureqtrs_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_futureqtrs_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_futureqtrs_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_entirecurrentqtr_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_entirecurrentqtr_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_entirecurrentqtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm1_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm1_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_currentqtrm1_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm2_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm2_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_currentqtrm2_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm3_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm3_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_currentqtrm3_soft
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm1_soft_wk 
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm1_soft_wk, 0.00) 
  END                                                                   AS hrsfcst_billable_currentqtrm1_soft_wk

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm2_soft_wk
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm2_soft_wk, 0.00) 
  END                                                                   AS hrsfcst_billable_currentqtrm2_soft_wk

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_currentqtrm3_soft_wk 
       ELSE IFNULL(forecast.hrsfcst_billable_currentqtrm3_soft_wk, 0.00) 
  END                                                                   AS hrsfcst_billable_currentqtrm3_soft_wk
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_remaininginqtr_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_remaininginqtr_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_remaininginqtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_plus1qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_plus1qtr_soft, 0.00) 
  END   AS hrsfcst_billable_plus1qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_plus2qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_plus2qtr_soft, 0.00) 
  END   AS hrsfcst_billable_plus2qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_plus3qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_plus3qtr_soft, 0.00) 
  END   AS hrsfcst_billable_plus3qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_plus4qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_plus4qtr_soft, 0.00) 
  END   AS hrsfcst_billable_plus4qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_plus5qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_plus5qtr_soft, 0.00) 
  END   AS hrsfcst_billable_plus5qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_additionalqtrs_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_additionalqtrs_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_additionalqtrs_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_additionalqtrs2_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_additionalqtrs2_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_additionalqtrs2_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_customrange_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_customrange_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_customrange_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_billable_aftercutover_soft 
       ELSE IFNULL(forecast.hrsfcst_billable_aftercutover_soft, 0.00) 
  END                                                                   AS hrsfcst_billable_aftercutover_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_all_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_all_soft, 0.00) 
  END                                                                   AS hrsfcst_gen_all_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_future_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_future_soft, 0.00) 
  END          AS hrsfcst_gen_future_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_currentmonth_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_currentmonth_soft, 0.00) 
  END    AS hrsfcst_gen_currentmonth_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_futuremonths_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_futuremonths_soft, 0.00) 
  END    AS hrsfcst_gen_futuremonths_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_futureqtrs_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_futureqtrs_soft, 0.00) 
  END      AS hrsfcst_gen_futureqtrs_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_entirecurrentqtr_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_entirecurrentqtr_soft, 0.00) 
  END                                                                   AS hrsfcst_gen_entirecurrentqtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_currentqtrm1_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_currentqtrm1_soft, 0.00) 
  END    AS hrsfcst_gen_currentqtrm1_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_currentqtrm2_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_currentqtrm2_soft, 0.00) 
  END    AS hrsfcst_gen_currentqtrm2_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_currentqtrm3_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_currentqtrm3_soft, 0.00) 
  END    AS hrsfcst_gen_currentqtrm3_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_remaininginqtr_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_remaininginqtr_soft, 0.00) 
  END  AS hrsfcst_gen_remaininginqtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_plus1qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_plus1qtr_soft, 0.00) 
  END        AS hrsfcst_gen_plus1qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_plus2qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_plus2qtr_soft, 0.00) 
  END        AS hrsfcst_gen_plus2qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_plus3qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_plus3qtr_soft, 0.00) 
  END        AS hrsfcst_gen_plus3qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_additionalqtrs_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_additionalqtrs_soft, 0.00) 
  END  AS hrsfcst_gen_additionalqtrs_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_customrange_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_customrange_soft, 0.00) 
  END     AS hrsfcst_gen_customrange_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_gen_aftercutover_soft 
       ELSE IFNULL(forecast.hrsfcst_gen_aftercutover_soft, 0.00) 
  END    AS hrsfcst_gen_aftercutover_soft
  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_all_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_all_soft, 0.00) 
  END     AS hrsfcst_nonbill_gen_all_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_future_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_future_soft, 0.00) 
  END  AS hrsfcst_nonbill_gen_future_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_currentmonth_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_currentmonth_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_currentmonth_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_futuremonths_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_futuremonths_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_futuremonths_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_futureqtrs_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_futureqtrs_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_futureqtrs_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_entirecurrentqtr_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_entirecurrentqtr_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_entirecurrentqtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_currentqtrm1_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_currentqtrm1_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_currentqtrm1_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_currentqtrm2_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_currentqtrm2_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_currentqtrm2_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_currentqtrm3_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_currentqtrm3_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_currentqtrm3_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_remaininginqtr_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_remaininginqtr_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_remaininginqtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_plus1qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_plus1qtr_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_plus1qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_plus2qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_plus2qtr_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_plus2qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_plus3qtr_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_plus3qtr_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_plus3qtr_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_additionalqtrs_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_additionalqtrs_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_additionalqtrs_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_customrange_soft 
       ELSE IFNULL(forecast.hrsfcst_nonbill_gen_customrange_soft, 0.00) 
  END                                                                   AS hrsfcst_nonbill_gen_customrange_soft

  ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsfcst_nonbill_gen_aftercutover_soft
    ELSE IFNULL(forecast.hrsfcst_nonbill_gen_aftercutover_soft, 0.00) 
  END         
                                                                        AS hrsfcst_nonbill_gen_aftercutover_soft
  ,actuals.hrsact_total_all AS hrsact_total_all_org
  ,actuals.hrsact_total_past AS hrsact_total_past_org
  ,actuals.hrsact_past AS hrsact_past_org
  ,actuals.hrsact_pastqtrs AS hrsact_pastqtrs_org
  ,actuals.hrsact_currentqtrm1 AS hrsact_currentqtrm1_org
  ,actuals.hrsact_currentqtrm2 AS hrsact_currentqtrm2_org
  ,actuals.hrsact_currentqtrm3 AS hrsact_currentqtrm3_org
  ,(IFNULL(actuals.hrsact_past, 0.00)
         + IFNULL(forecast.hrsfcst_billable_future, 0.00)) 
                                AS hrs_billable_eac_org
  ,forecast.hrsfcst_billable_all AS hrsfcst_billable_all_org
  ,forecast.hrsfcst_billable_currentqtrm1 AS hrsfcst_billable_currentqtrm1_org
  ,forecast.hrsfcst_billable_currentqtrm2 AS hrsfcst_billable_currentqtrm2_org
  ,forecast.hrsfcst_billable_currentqtrm3 AS hrsfcst_billable_currentqtrm3_org
  ,forecast.hrsfcst_billable_plus1qtr AS hrsfcst_billable_plus1qtr_org
  ,forecast.hrsfcst_billable_plus2qtr AS hrsfcst_billable_plus2qtr_org
  ,forecast.hrsfcst_billable_plus3qtr AS hrsfcst_billable_plus3qtr_org
  ,forecast.hrsfcst_billable_plus4qtr AS hrsfcst_billable_plus4qtr_org
  ,forecast.hrsfcst_billable_plus5qtr AS hrsfcst_billable_plus5qtr_org
  ,forecast.hrsfcst_billable_additionalqtrs AS hrsfcst_billable_additionalqtrs_org
  ,forecast.hrsfcst_billable_additionalqtrs2 AS hrsfcst_billable_additionalqtrs2_org
  , actuals.hrsact_customrangebegin                                  AS hrsact_customrangebegin
  , actuals.hrsact_customrangeend                                    AS hrsact_customrangeend
  , forecast.hrsfcst_customrangebegin                                AS hrsfcst_customrangebegin
  , forecast.hrsfcst_customrangeend                                  AS hrsfcst_customrangeend
  , ipc.parent_child_key                                             AS parent_child_key
  , LSTDESC_16.VALUE                                                 AS adsk_masteragreement_projecttype
  , 22                                                               AS sqlversion_labor_hrs

FROM {{ source('tenrox_private', 'tproject') }}  tproject
        LEFT JOIN {{ source('tenrox_private', 'tprojectcustfld') }}  a On a.PROJECTID = tproject.uniqueid
        LEFT JOIN {{ source('tenrox_private', 'tcustlst') }} AS LST_16  ON a.ADSK_MasterAgreement_ProjectType = LST_16.UNIQUEID 
        LEFT JOIN {{ source('tenrox_private', 'tcustlstdesc') }} AS LSTDESC_16  ON LST_16.UNIQUEID = LSTDESC_16.CUSTLSTID AND LSTDESC_16.LANGUAGE = 0
LEFT JOIN
    (
        SELECT DISTINCT 
            projectid AS projectid
        FROM {{ source('tenrox_private', 'ttimeentry') }} ttimeentry
        JOIN {{ source('tenrox_private', 'ttask') }} ttask
            ON ttimeentry.taskid = ttask.uniqueid
        UNION
        SELECT DISTINCT 
            trplnbooking.projectid AS projectid
        FROM {{ source('tenrox_private', 'trplnbooking') }} trplnbooking
        JOIN {{ source('tenrox_private', 'trplnbookingdetails') }} trplnbookingdetails
            ON trplnbookingdetails.bookingid = trplnbooking.uniqueid
    ) projectlinks
    ON projectlinks.projectid = tproject.uniqueid 
LEFT JOIN actuals ON actuals.projectid = projectlinks.projectid 
LEFT JOIN forecast ON forecast.projectid = projectlinks.projectid
left join is_parent_child ipc on ipc.parent_child_key = tproject.uniqueid 

  
  
  
  