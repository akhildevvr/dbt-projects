
/* ADSK_FN_CM_LABOR_HRS_V02.sql
  @RangeBegin      DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/

with Actuals as (
    SELECT
        TTASK.PROJECTID                          AS ProjectID
        , SUM(IFNULL(TOTALTIME, 0.00)) / 3600.00 AS HrsAct_Total_All
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_Past
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentMonthBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Ranges.Fnc_NextMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_CurrentMonth
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_PastQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_EntireCurrentQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM2Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_CurrentQtrM1
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM2Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM3Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_CurrentQtrM2
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM3Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_CurrentQtrM3
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_CompletedInQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus1QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_Minus1Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus2QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_Minus2Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus3QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus2QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_Minus3Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus3QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_PriorQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Hist_CustomRangeBegin 
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Hist_CustomRangeEnd THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_CustomRange
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.ENTRYDATE < TO_TIMESTAMP(NULL) THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Total_BeforeCutover
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1 THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_All
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Past
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentMonthBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Ranges.Fnc_NextMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_CurrentMonth
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_PastQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_EntireCurrentQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM2Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_CurrentQtrM1
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM2Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM3Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_CurrentQtrM2
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM3Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_CurrentQtrM3
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_CompletedInQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus1QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Minus1Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus2QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Minus2Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus3QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus2QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Minus3Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus3QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_PriorQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Hist_CustomRangeBegin
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Hist_CustomRangeEnd THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_CustomRange
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < TO_TIMESTAMP(NULL) THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_BeforeCutover
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1 THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_All
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_Past
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentMonthBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Ranges.Fnc_NextMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_CurrentMonth
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_PastQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_EntireCurrentQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM2Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_CurrentQtrM1
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM2Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM3Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_CurrentQtrM2
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM3Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_CurrentQtrM3
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_CompletedInQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus1QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_Minus1Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus2QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_Minus2Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus3QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus2QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_Minus3Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus3QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_PriorQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Hist_CustomRangeBegin
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Hist_CustomRangeEnd THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_CustomRange
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < TO_TIMESTAMP(NULL) THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Unapp_BeforeCutover
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0 THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_All
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Past
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentMonthBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Ranges.Fnc_NextMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_CurrentMonth
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_PastQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_EntireCurrentQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM2Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_CurrentQtrM1
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM2Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM3Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_CurrentQtrM2
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM3Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_CurrentQtrM3
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_CompletedInQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus1QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Minus1Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus2QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Minus2Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus3QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus2QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Minus3Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus3QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_PriorQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Hist_CustomRangeBegin
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Hist_CustomRangeEnd THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_CustomRange
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE < TO_TIMESTAMP(NULL) THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_BeforeCutover
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0 THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_All
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_Past
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentMonthBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Ranges.Fnc_NextMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_CurrentMonth
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_PastQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_EntireCurrentQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM2Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_CurrentQtrM1
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM2Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM3Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_CurrentQtrM2
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM3Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_CurrentQtrM3
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_CompletedInQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus1QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_Minus1Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus2QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_Minus2Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus3QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus2QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_Minus3Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus3QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_PriorQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Hist_CustomRangeBegin
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Hist_CustomRangeEnd THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_CustomRange
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.BILLABLE = 0
                            AND TTIMESHEETENTRIES.FUNDED = 0
                            AND TTIMESHEETENTRIES.ENTRYDATE < TO_TIMESTAMP(NULL) THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_NonBill_Unapp_BeforeCutover
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1 THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_All
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Past
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentMonthBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Ranges.Fnc_NextMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_CurrentMonth
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_PastQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_EntireCurrentQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM2Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_CurrentQtrM1
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM2Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM3Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_CurrentQtrM2
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM3Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_CurrentQtrM3
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_CompletedInQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus1QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Minus1Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus2QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Minus2Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus3QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus2QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Minus3Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus3QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_PriorQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Hist_CustomRangeBegin
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Hist_CustomRangeEnd THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_CustomRange
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 1
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < TO_TIMESTAMP(NULL) THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_BeforeCutover
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1 THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_All
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_Past
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentMonthBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Ranges.Fnc_NextMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_CurrentMonth
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_PastQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_EntireCurrentQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM2Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_CurrentQtrM1
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM2Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrM3Begins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_CurrentQtrM2
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrM3Begins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Plus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_CurrentQtrM3
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_CurrentQtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentMonthBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_CompletedInQtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus1QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_CurrentQtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_Minus1Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus2QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus1QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_Minus2Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Minus3QtrBegins
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus2QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_Minus3Qtr
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Minus3QtrBegins THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_PriorQtrs
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE >= Fnc_Hist_CustomRangeBegin
                            AND TTIMESHEETENTRIES.ENTRYDATE < Fnc_Hist_CustomRangeEnd THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_CustomRange
        , SUM(IFNULL(CASE
                       WHEN TTIMESHEETENTRIES.APPROVED = 0
                            AND TTIMESHEETENTRIES.FUNDED = 1
                            AND TTIMESHEETENTRIES.ENTRYDATE < TO_TIMESTAMP(NULL) THEN TOTALTIME
                       ELSE NULL
                     END, 0.00)) / 3600.00       AS HrsAct_Utilized_Unapp_BeforeCutover
        , MAX(Fnc_Hist_CustomRangeBegin)         AS HrsAct_CustomRangeBegin
        , MAX(Fnc_Hist_CustomRangeEnd)           AS HrsAct_CustomRangeEnd
    FROM eio_publish.tenrox_private.TTIMESHEETENTRIES TTIMESHEETENTRIES 
    INNER JOIN eio_publish.tenrox_private.TTASK TTASK ON TTIMESHEETENTRIES.TASKUID = TTASK.UNIQUEID
    LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_month_q_ranges_v02 AS Ranges
    GROUP BY    TTASK.PROJECTID
),

Forecast as (
    SELECT
        TRPLNBOOKING.PROJECTID                                           AS ProjectID
        , SUM(IFNULL(TRPLNBOOKINGDETAILS.BOOKEDSECONDS, 0.00)) / 3600.00 AS HrsFcst_All
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Future
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Ranges.Fnc_NextMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_CurrentMonth
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Ranges.Fnc_NextMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_FutureMonths
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_FutureQtrs
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_EntireCurrentQtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM2Begins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_CurrentQtrM1
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM2Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM3Begins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_CurrentQtrM2
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM3Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_CurrentQtrM3
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_RemainingInQtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Plus1Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Plus2Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Plus3Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus5QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Plus4Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus5QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus6QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Plus5Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_AdditionalQtrs
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus6QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Additional2Qtrs
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_CustomRange
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= TO_TIMESTAMP(NULL) THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_AfterCutover
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_All
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Future
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Ranges.Fnc_NextMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_CurrentMonth
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Ranges.Fnc_NextMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_FutureMonths
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_FutureQtrs
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_EntireCurrentQtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM2Begins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_CurrentQtrM1
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM2Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM3Begins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_CurrentQtrM2
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM3Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_CurrentQtrM3
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_RemainingInQtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Plus1Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Plus2Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Plus3Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus5QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Plus4Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus5QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus6QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Plus5Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_AdditionalQtrs
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus6QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_AdditionalQtrs2
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_CustomRange
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= TO_TIMESTAMP(NULL) THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_AfterCutover
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_All
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_Future
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Ranges.Fnc_NextMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_CurrentMonth
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Ranges.Fnc_NextMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_FutureMonths
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_FutureQtrs
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_EntireCurrentQtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM2Begins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_CurrentQtrM1
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM2Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM3Begins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_CurrentQtrM2
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM3Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_CurrentQtrM3
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_RemainingInQtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_Plus1Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_Plus2Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_Plus3Qtr
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_AdditionalQtrs
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_CustomRange
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= TO_TIMESTAMP(NULL) THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_AfterCutover
        -- Start Soft Bookings Only section
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_All_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Future_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Ranges.Fnc_NextMonthBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_CurrentMonth_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Ranges.Fnc_NextMonthBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_FutureMonths_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_FutureQtrs_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_EntireCurrentQtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM2Begins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_CurrentQtrM1_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM2Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM3Begins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_CurrentQtrM2_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM3Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_CurrentQtrM3_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_RemainingInQtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Plus1Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Plus2Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Plus3Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_AdditionalQtrs_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_CustomRange_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= TO_TIMESTAMP(NULL)
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_AfterCutover_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_All_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Future_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Ranges.Fnc_NextMonthBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_CurrentMonth_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Ranges.Fnc_NextMonthBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_FutureMonths_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_FutureQtrs_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_EntireCurrentQtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM2Begins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_CurrentQtrM1_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM2Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM3Begins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_CurrentQtrM2_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM3Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_CurrentQtrM3_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_RemainingInQtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Plus1Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Plus2Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Plus3Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus5QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Plus4Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus5QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus6QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_Plus5Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_AdditionalQtrs_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus6QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_AdditionalQtrs2_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_CustomRange_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= TO_TIMESTAMP(NULL)
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Billable_AfterCutover_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_All_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_Future_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Ranges.Fnc_NextMonthBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_CurrentMonth_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Ranges.Fnc_NextMonthBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_FutureMonths_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_FutureQtrs_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_EntireCurrentQtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM2Begins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_CurrentQtrM1_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM2Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM3Begins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_CurrentQtrM2_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM3Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_CurrentQtrM3_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_RemainingInQtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_Plus1Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_Plus2Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_Plus3Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_AdditionalQtrs_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_CustomRange_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= TO_TIMESTAMP(NULL)
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_Gen_AfterCutover_Soft
        -- End Soft Bookings Only section
        -- Start non-billable Generic soft-bookings section
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_All_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_Future_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Ranges.Fnc_NextMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_CurrentMonth_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Ranges.Fnc_NextMonthBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_FutureMonths_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_FutureQtrs_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_EntireCurrentQtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM2Begins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_CurrentQtrM1_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM2Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_CurrentQtrM3Begins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_CurrentQtrM2_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrM3Begins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_CurrentQtrM3_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_RemainingInQtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_Plus1Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_Plus2Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_Plus3Qtr_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_AdditionalQtrs_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_CustomRange_Soft
        , SUM(IFNULL(CASE
                       WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = 1
                            AND TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                            AND TRPLNBOOKING.BOOKINGTYPE = 2
                            AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= TO_TIMESTAMP(NULL) THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS
                       ELSE 0.00
                     END, 0.00)) / 3600.00                               AS HrsFcst_NonBill_Gen_AfterCutover_Soft
        -- End non-billable Generic bookings section
        , MAX(Fnc_Fcst_CustomRangeBegin)                                 AS HrsFcst_CustomRangeBegin
        , MAX(Fnc_Fcst_CustomRangeEnd)                                   AS HrsFcst_CustomRangeEnd
    FROM eio_publish.tenrox_private.TRPLNBOOKING TRPLNBOOKING
    INNER JOIN eio_publish.tenrox_private.TRPLNBOOKINGDETAILS TRPLNBOOKINGDETAILS ON TRPLNBOOKINGDETAILS.BOOKINGID = TRPLNBOOKING.UNIQUEID
    INNER JOIN eio_publish.tenrox_private.TRPLNBOOKINGATTRIBUTES TRPLNBOOKINGATTRIBUTES ON TRPLNBOOKINGATTRIBUTES.BOOKINGID = TRPLNBOOKING.UNIQUEID
    INNER JOIN eio_publish.tenrox_private.TPROJECTTEAMRESOURCE TPROJECTTEAMRESOURCE ON TPROJECTTEAMRESOURCE.PROJECTID = TRPLNBOOKING.PROJECTID
          AND TPROJECTTEAMRESOURCE.RESOURCEID = CASE TRPLNBOOKING.BOOKINGOBJECTTYPE
                                                    WHEN 1 THEN TRPLNBOOKING.USERID
                                                    WHEN 700 THEN TRPLNBOOKING.ROLEID
                                                END
          AND TPROJECTTEAMRESOURCE.ISROLE = CASE TRPLNBOOKING.BOOKINGOBJECTTYPE
                                                WHEN 1 THEN 0
                                                WHEN 700 THEN 1
                                            END
    LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_month_q_ranges_v02 AS Ranges -- ON Ranges.FNC_CURRENTDATE = TRPLNBOOKINGDETAILS.BOOKEDDATE
    WHERE       TRPLNBOOKINGDETAILS.BOOKEDSECONDS > 0
    GROUP       BY
       TRPLNBOOKING.PROJECTID
)
 
SELECT
       TPROJECT.UNIQUEID                                              AS ProjectID
       , IFNULL(Actuals.HrsAct_Total_All, 0.00)                       AS HrsAct_Total_All
       , IFNULL(Actuals.HrsAct_Total_Past, 0.00)                      AS HrsAct_Total_Past
       , IFNULL(Actuals.HrsAct_Total_CurrentMonth, 0.00)              AS HrsAct_Total_CurrentMonth
       , IFNULL(Actuals.HrsAct_Total_PastQtrs, 0.00)                  AS HrsAct_Total_PastQtrs
       , IFNULL(Actuals.HrsAct_Total_EntireCurrentQtr, 0.00)          AS HrsAct_Total_EntireCurrentQtr
       , IFNULL(Actuals.HrsAct_Total_CurrentQtrM1, 0.00)              AS HrsAct_Total_CurrentQtrM1
       , IFNULL(Actuals.HrsAct_Total_CurrentQtrM2, 0.00)              AS HrsAct_Total_CurrentQtrM2
       , IFNULL(Actuals.HrsAct_Total_CurrentQtrM3, 0.00)              AS HrsAct_Total_CurrentQtrM3
       , IFNULL(Actuals.HrsAct_Total_CompletedInQtr, 0.00)            AS HrsAct_Total_CompletedInQtr
       , IFNULL(Actuals.HrsAct_Total_Minus1Qtr, 0.00)                 AS HrsAct_Total_Minus1Qtr
       , IFNULL(Actuals.HrsAct_Total_Minus2Qtr, 0.00)                 AS HrsAct_Total_Minus2Qtr
       , IFNULL(Actuals.HrsAct_Total_Minus3Qtr, 0.00)                 AS HrsAct_Total_Minus3Qtr
       , IFNULL(Actuals.HrsAct_Total_PriorQtrs, 0.00)                 AS HrsAct_Total_PriorQtrs
       , IFNULL(Actuals.HrsAct_Total_CustomRange, 0.00)               AS HrsAct_Total_CustomRange
       , IFNULL(Actuals.HrsAct_Total_BeforeCutover, 0.00)             AS HrsAct_Total_BeforeCutover
       , IFNULL(Actuals.HrsAct_All, 0.00)                             AS HrsAct_All
       , IFNULL(Actuals.HrsAct_Past, 0.00)                            AS HrsAct_Past
       , IFNULL(Actuals.HrsAct_CurrentMonth, 0.00)                    AS HrsAct_CurrentMonth
       , IFNULL(Actuals.HrsAct_PastQtrs, 0.00)                        AS HrsAct_PastQtrs
       , IFNULL(Actuals.HrsAct_EntireCurrentQtr, 0.00)                AS HrsAct_EntireCurrentQtr
       , IFNULL(Actuals.HrsAct_CurrentQtrM1, 0.00)                    AS HrsAct_CurrentQtrM1
       , IFNULL(Actuals.HrsAct_CurrentQtrM2, 0.00)                    AS HrsAct_CurrentQtrM2
       , IFNULL(Actuals.HrsAct_CurrentQtrM3, 0.00)                    AS HrsAct_CurrentQtrM3
       , IFNULL(Actuals.HrsAct_CompletedInQtr, 0.00)                  AS HrsAct_CompletedInQtr
       , IFNULL(Actuals.HrsAct_Minus1Qtr, 0.00)                       AS HrsAct_Minus1Qtr
       , IFNULL(Actuals.HrsAct_Minus2Qtr, 0.00)                       AS HrsAct_Minus2Qtr
       , IFNULL(Actuals.HrsAct_Minus3Qtr, 0.00)                       AS HrsAct_Minus3Qtr
       , IFNULL(Actuals.HrsAct_PriorQtrs, 0.00)                       AS HrsAct_PriorQtrs
       , IFNULL(Actuals.HrsAct_CustomRange, 0.00)                     AS HrsAct_CustomRange
       , IFNULL(Actuals.HrsAct_BeforeCutover, 0.00)                   AS HrsAct_BeforeCutover
       , IFNULL(Actuals.HrsAct_Unapp_All, 0.00)                       AS HrsAct_Unapp_All
       , IFNULL(Actuals.HrsAct_Unapp_Past, 0.00)                      AS HrsAct_Unapp_Past
       , IFNULL(Actuals.HrsAct_Unapp_CurrentMonth, 0.00)              AS HrsAct_Unapp_CurrentMonth
       , IFNULL(Actuals.HrsAct_Unapp_PastQtrs, 0.00)                  AS HrsAct_Unapp_PastQtrs
       , IFNULL(Actuals.HrsAct_Unapp_EntireCurrentQtr, 0.00)          AS HrsAct_Unapp_EntireCurrentQtr
       , IFNULL(Actuals.HrsAct_Unapp_CurrentQtrM1, 0.00)              AS HrsAct_Unapp_CurrentQtrM1
       , IFNULL(Actuals.HrsAct_Unapp_CurrentQtrM2, 0.00)              AS HrsAct_Unapp_CurrentQtrM2
       , IFNULL(Actuals.HrsAct_Unapp_CurrentQtrM3, 0.00)              AS HrsAct_Unapp_CurrentQtrM3
       , IFNULL(Actuals.HrsAct_Unapp_CompletedInQtr, 0.00)            AS HrsAct_Unapp_CompletedInQtr
       , IFNULL(Actuals.HrsAct_Unapp_Minus1Qtr, 0.00)                 AS HrsAct_Unapp_Minus1Qtr
       , IFNULL(Actuals.HrsAct_Unapp_Minus2Qtr, 0.00)                 AS HrsAct_Unapp_Minus2Qtr
       , IFNULL(Actuals.HrsAct_Unapp_Minus3Qtr, 0.00)                 AS HrsAct_Unapp_Minus3Qtr
       , IFNULL(Actuals.HrsAct_Unapp_PriorQtrs, 0.00)                 AS HrsAct_Unapp_PriorQtrs
       , IFNULL(Actuals.HrsAct_Unapp_CustomRange, 0.00)               AS HrsAct_Unapp_CustomRange
       , IFNULL(Actuals.HrsAct_Unapp_BeforeCutover, 0.00)             AS HrsAct_Unapp_BeforeCutover
       , IFNULL(Actuals.HrsAct_NonBill_All, 0.00)                     AS HrsAct_NonBill_All
       , IFNULL(Actuals.HrsAct_NonBill_Past, 0.00)                    AS HrsAct_NonBill_Past
       , IFNULL(Actuals.HrsAct_NonBill_CurrentMonth, 0.00)            AS HrsAct_NonBill_CurrentMonth
       , IFNULL(Actuals.HrsAct_NonBill_PastQtrs, 0.00)                AS HrsAct_NonBill_PastQtrs
       , IFNULL(Actuals.HrsAct_NonBill_EntireCurrentQtr, 0.00)        AS HrsAct_NonBill_EntireCurrentQtr
       , IFNULL(Actuals.HrsAct_NonBill_CurrentQtrM1, 0.00)            AS HrsAct_NonBill_CurrentQtrM1
       , IFNULL(Actuals.HrsAct_NonBill_CurrentQtrM2, 0.00)            AS HrsAct_NonBill_CurrentQtrM2
       , IFNULL(Actuals.HrsAct_NonBill_CurrentQtrM3, 0.00)            AS HrsAct_NonBill_CurrentQtrM3
       , IFNULL(Actuals.HrsAct_NonBill_CompletedInQtr, 0.00)          AS HrsAct_NonBill_CompletedInQtr
       , IFNULL(Actuals.HrsAct_NonBill_Minus1Qtr, 0.00)               AS HrsAct_NonBill_Minus1Qtr
       , IFNULL(Actuals.HrsAct_NonBill_Minus2Qtr, 0.00)               AS HrsAct_NonBill_Minus2Qtr
       , IFNULL(Actuals.HrsAct_NonBill_Minus3Qtr, 0.00)               AS HrsAct_NonBill_Minus3Qtr
       , IFNULL(Actuals.HrsAct_NonBill_PriorQtrs, 0.00)               AS HrsAct_NonBill_PriorQtrs
       , IFNULL(Actuals.HrsAct_NonBill_CustomRange, 0.00)             AS HrsAct_NonBill_CustomRange
       , IFNULL(Actuals.HrsAct_NonBill_BeforeCutover, 0.00)           AS HrsAct_NonBill_BeforeCutover
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_All, 0.00)               AS HrsAct_NonBill_Unapp_All
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_Past, 0.00)              AS HrsAct_NonBill_Unapp_Past
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_CurrentMonth, 0.00)      AS HrsAct_NonBill_Unapp_CurrentMonth
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_PastQtrs, 0.00)          AS HrsAct_NonBill_Unapp_PastQtrs
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_EntireCurrentQtr, 0.00)  AS HrsAct_NonBill_Unapp_EntireCurrentQtr
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_CurrentQtrM1, 0.00)      AS HrsAct_NonBill_Unapp_CurrentQtrM1
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_CurrentQtrM2, 0.00)      AS HrsAct_NonBill_Unapp_CurrentQtrM2
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_CurrentQtrM3, 0.00)      AS HrsAct_NonBill_Unapp_CurrentQtrM3
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_CompletedInQtr, 0.00)    AS HrsAct_NonBill_Unapp_CompletedInQtr
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_Minus1Qtr, 0.00)         AS HrsAct_NonBill_Unapp_Minus1Qtr
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_Minus2Qtr, 0.00)         AS HrsAct_NonBill_Unapp_Minus2Qtr
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_Minus3Qtr, 0.00)         AS HrsAct_NonBill_Unapp_Minus3Qtr
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_PriorQtrs, 0.00)         AS HrsAct_NonBill_Unapp_PriorQtrs
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_CustomRange, 0.00)       AS HrsAct_NonBill_Unapp_CustomRange
       , IFNULL(Actuals.HrsAct_NonBill_Unapp_BeforeCutover, 0.00)     AS HrsAct_NonBill_Unapp_BeforeCutover
       , IFNULL(Actuals.HrsAct_Utilized_All, 0.00)                    AS HrsAct_Utilized_All
       , IFNULL(Actuals.HrsAct_Utilized_Past, 0.00)                   AS HrsAct_Utilized_Past
       , IFNULL(Actuals.HrsAct_Utilized_CurrentMonth, 0.00)           AS HrsAct_Utilized_CurrentMonth
       , IFNULL(Actuals.HrsAct_Utilized_PastQtrs, 0.00)               AS HrsAct_Utilized_PastQtrs
       , IFNULL(Actuals.HrsAct_Utilized_EntireCurrentQtr, 0.00)       AS HrsAct_Utilized_EntireCurrentQtr
       , IFNULL(Actuals.HrsAct_Utilized_CurrentQtrM1, 0.00)           AS HrsAct_Utilized_CurrentQtrM1
       , IFNULL(Actuals.HrsAct_Utilized_CurrentQtrM2, 0.00)           AS HrsAct_Utilized_CurrentQtrM2
       , IFNULL(Actuals.HrsAct_Utilized_CurrentQtrM3, 0.00)           AS HrsAct_Utilized_CurrentQtrM3
       , IFNULL(Actuals.HrsAct_Utilized_CompletedInQtr, 0.00)         AS HrsAct_Utilized_CompletedInQtr
       , IFNULL(Actuals.HrsAct_Utilized_Minus1Qtr, 0.00)              AS HrsAct_Utilized_Minus1Qtr
       , IFNULL(Actuals.HrsAct_Utilized_Minus2Qtr, 0.00)              AS HrsAct_Utilized_Minus2Qtr
       , IFNULL(Actuals.HrsAct_Utilized_Minus3Qtr, 0.00)              AS HrsAct_Utilized_Minus3Qtr
       , IFNULL(Actuals.HrsAct_Utilized_PriorQtrs, 0.00)              AS HrsAct_Utilized_PriorQtrs
       , IFNULL(Actuals.HrsAct_Utilized_CustomRange, 0.00)            AS HrsAct_Utilized_CustomRange
       , IFNULL(Actuals.HrsAct_Utilized_BeforeCutover, 0.00)          AS HrsAct_Utilized_BeforeCutover
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_All, 0.00)              AS HrsAct_Utilized_Unapp_All
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_Past, 0.00)             AS HrsAct_Utilized_Unapp_Past
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_CurrentMonth, 0.00)     AS HrsAct_Utilized_Unapp_CurrentMonth
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_PastQtrs, 0.00)         AS HrsAct_Utilized_Unapp_PastQtrs
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_EntireCurrentQtr, 0.00) AS HrsAct_Utilized_Unapp_EntireCurrentQtr
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_CurrentQtrM1, 0.00)     AS HrsAct_Utilized_Unapp_CurrentQtrM1
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_CurrentQtrM2, 0.00)     AS HrsAct_Utilized_Unapp_CurrentQtrM2
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_CurrentQtrM3, 0.00)     AS HrsAct_Utilized_Unapp_CurrentQtrM3
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_CompletedInQtr, 0.00)   AS HrsAct_Utilized_Unapp_CompletedInQtr
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_Minus1Qtr, 0.00)        AS HrsAct_Utilized_Unapp_Minus1Qtr
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_Minus2Qtr, 0.00)        AS HrsAct_Utilized_Unapp_Minus2Qtr
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_Minus3Qtr, 0.00)        AS HrsAct_Utilized_Unapp_Minus3Qtr
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_PriorQtrs, 0.00)        AS HrsAct_Utilized_Unapp_PriorQtrs
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_CustomRange, 0.00)      AS HrsAct_Utilized_Unapp_CustomRange
       , IFNULL(Actuals.HrsAct_Utilized_Unapp_BeforeCutover, 0.00)    AS HrsAct_Utilized_Unapp_BeforeCutover
       , IFNULL(Actuals.HrsAct_Past, 0.00)
         + IFNULL(Actuals.HrsAct_Utilized_Past, 0.00)
         + IFNULL(Forecast.HrsFcst_Future, 0.00)                      AS Hrs_EAC_With_Utilized
       , IFNULL(Forecast.HrsFcst_All, 0.00)                           AS HrsFcst_All
       , IFNULL(Forecast.HrsFcst_Future, 0.00)                        AS HrsFcst_Future
       , IFNULL(Forecast.HrsFcst_CurrentMonth, 0.00)                  AS HrsFcst_CurrentMonth
       , IFNULL(Forecast.HrsFcst_FutureMonths, 0.00)                  AS HrsFcst_FutureMonths
       , IFNULL(Forecast.HrsFcst_FutureQtrs, 0.00)                    AS HrsFcst_FutureQtrs
       , IFNULL(Forecast.HrsFcst_EntireCurrentQtr, 0.00)              AS HrsFcst_EntireCurrentQtr
       , IFNULL(Forecast.HrsFcst_CurrentQtrM1, 0.00)                  AS HrsFcst_CurrentQtrM1
       , IFNULL(Forecast.HrsFcst_CurrentQtrM2, 0.00)                  AS HrsFcst_CurrentQtrM2
       , IFNULL(Forecast.HrsFcst_CurrentQtrM3, 0.00)                  AS HrsFcst_CurrentQtrM3
       , IFNULL(Forecast.HrsFcst_RemainingInQtr, 0.00)                AS HrsFcst_RemainingInQtr
       , IFNULL(Forecast.HrsFcst_Plus1Qtr, 0.00)                      AS HrsFcst_Plus1Qtr
       , IFNULL(Forecast.HrsFcst_Plus2Qtr, 0.00)                      AS HrsFcst_Plus2Qtr
       , IFNULL(Forecast.HrsFcst_Plus3Qtr, 0.00)                      AS HrsFcst_Plus3Qtr
       , IFNULL(Forecast.HrsFcst_Plus4Qtr, 0.00)                      AS HrsFcst_Plus4Qtr
       , IFNULL(Forecast.HrsFcst_Plus5Qtr, 0.00)                      AS HrsFcst_Plus5Qtr
       , IFNULL(Forecast.HrsFcst_AdditionalQtrs, 0.00)                AS HrsFcst_AdditionalQtrs
       , IFNULL(Forecast.HrsFcst_Additional2Qtrs, 0.00)               AS HrsFcst_Additional2Qtrs
       , IFNULL(Forecast.HrsFcst_CustomRange, 0.00)                   AS HrsFcst_CustomRange
       , IFNULL(Forecast.HrsFcst_AfterCutover, 0.00)                  AS HrsFcst_AfterCutover
       , IFNULL(Actuals.HrsAct_Past, 0.00)
         + IFNULL(Forecast.HrsFcst_Future, 0.00)                      AS Hrs_EAC
       , IFNULL(Forecast.HrsFcst_Billable_All, 0.00)                  AS HrsFcst_Billable_All
       , IFNULL(Forecast.HrsFcst_Billable_Future, 0.00)               AS HrsFcst_Billable_Future
       , IFNULL(Forecast.HrsFcst_Billable_CurrentMonth, 0.00)         AS HrsFcst_Billable_CurrentMonth
       , IFNULL(Forecast.HrsFcst_Billable_FutureMonths, 0.00)         AS HrsFcst_Billable_FutureMonths
       , IFNULL(Forecast.HrsFcst_Billable_FutureQtrs, 0.00)           AS HrsFcst_Billable_FutureQtrs
       , IFNULL(Forecast.HrsFcst_Billable_EntireCurrentQtr, 0.00)     AS HrsFcst_Billable_EntireCurrentQtr
       , IFNULL(Forecast.HrsFcst_Billable_CurrentQtrM1, 0.00)         AS HrsFcst_Billable_CurrentQtrM1
       , IFNULL(Forecast.HrsFcst_Billable_CurrentQtrM2, 0.00)         AS HrsFcst_Billable_CurrentQtrM2
       , IFNULL(Forecast.HrsFcst_Billable_CurrentQtrM3, 0.00)         AS HrsFcst_Billable_CurrentQtrM3
       , IFNULL(Forecast.HrsFcst_Billable_RemainingInQtr, 0.00)       AS HrsFcst_Billable_RemainingInQtr
       , IFNULL(Forecast.HrsFcst_Billable_Plus1Qtr, 0.00)             AS HrsFcst_Billable_Plus1Qtr
       , IFNULL(Forecast.HrsFcst_Billable_Plus2Qtr, 0.00)             AS HrsFcst_Billable_Plus2Qtr
       , IFNULL(Forecast.HrsFcst_Billable_Plus3Qtr, 0.00)             AS HrsFcst_Billable_Plus3Qtr
       , IFNULL(Forecast.HrsFcst_Billable_Plus4Qtr, 0.00)             AS HrsFcst_Billable_Plus4Qtr
       , IFNULL(Forecast.HrsFcst_Billable_Plus5Qtr, 0.00)             AS HrsFcst_Billable_Plus5Qtr
       , IFNULL(Forecast.HrsFcst_Billable_AdditionalQtrs, 0.00)       AS HrsFcst_Billable_AdditionalQtrs
       , IFNULL(Forecast.HrsFcst_Billable_AdditionalQtrs2, 0.00)      AS HrsFcst_Billable_AdditionalQtrs2
       , IFNULL(Forecast.HrsFcst_Billable_CustomRange, 0.00)          AS HrsFcst_Billable_CustomRange
       , IFNULL(Forecast.HrsFcst_Billable_AfterCutover, 0.00)         AS HrsFcst_Billable_AfterCutover
       , IFNULL(Actuals.HrsAct_Past, 0.00)
         + IFNULL(Forecast.HrsFcst_Billable_Future, 0.00)             AS Hrs_Billable_EAC
       , IFNULL(Forecast.HrsFcst_Gen_All, 0.00)                       AS HrsFcst_Gen_All
       , IFNULL(Forecast.HrsFcst_Gen_Future, 0.00)                    AS HrsFcst_Gen_Future
       , IFNULL(Forecast.HrsFcst_Gen_CurrentMonth, 0.00)              AS HrsFcst_Gen_CurrentMonth
       , IFNULL(Forecast.HrsFcst_Gen_FutureMonths, 0.00)              AS HrsFcst_Gen_FutureMonths
       , IFNULL(Forecast.HrsFcst_Gen_FutureQtrs, 0.00)                AS HrsFcst_Gen_FutureQtrs
       , IFNULL(Forecast.HrsFcst_Gen_EntireCurrentQtr, 0.00)          AS HrsFcst_Gen_EntireCurrentQtr
       , IFNULL(Forecast.HrsFcst_Gen_CurrentQtrM1, 0.00)              AS HrsFcst_Gen_CurrentQtrM1
       , IFNULL(Forecast.HrsFcst_Gen_CurrentQtrM2, 0.00)              AS HrsFcst_Gen_CurrentQtrM2
       , IFNULL(Forecast.HrsFcst_Gen_CurrentQtrM3, 0.00)              AS HrsFcst_Gen_CurrentQtrM3
       , IFNULL(Forecast.HrsFcst_Gen_RemainingInQtr, 0.00)            AS HrsFcst_Gen_RemainingInQtr
       , IFNULL(Forecast.HrsFcst_Gen_Plus1Qtr, 0.00)                  AS HrsFcst_Gen_Plus1Qtr
       , IFNULL(Forecast.HrsFcst_Gen_Plus2Qtr, 0.00)                  AS HrsFcst_Gen_Plus2Qtr
       , IFNULL(Forecast.HrsFcst_Gen_Plus3Qtr, 0.00)                  AS HrsFcst_Gen_Plus3Qtr
       , IFNULL(Forecast.HrsFcst_Gen_AdditionalQtrs, 0.00)            AS HrsFcst_Gen_AdditionalQtrs
       , IFNULL(Forecast.HrsFcst_Gen_CustomRange, 0.00)               AS HrsFcst_Gen_CustomRange
       , IFNULL(Forecast.HrsFcst_Gen_AfterCutover, 0.00)              AS HrsFcst_Gen_AfterCutover
       , IFNULL(HrsFcst_All_Soft, 0.00)                               AS HrsFcst_All_Soft
       , IFNULL(HrsFcst_Future_Soft, 0.00)                            AS HrsFcst_Future_Soft
       , IFNULL(HrsFcst_CurrentMonth_Soft, 0.00)                      AS HrsFcst_CurrentMonth_Soft
       , IFNULL(HrsFcst_FutureMonths_Soft, 0.00)                      AS HrsFcst_FutureMonths_Soft
       , IFNULL(HrsFcst_FutureQtrs_Soft, 0.00)                        AS HrsFcst_FutureQtrs_Soft
       , IFNULL(HrsFcst_EntireCurrentQtr_Soft, 0.00)                  AS HrsFcst_EntireCurrentQtr_Soft
       , IFNULL(HrsFcst_CurrentQtrM1_Soft, 0.00)                      AS HrsFcst_CurrentQtrM1_Soft
       , IFNULL(HrsFcst_CurrentQtrM2_Soft, 0.00)                      AS HrsFcst_CurrentQtrM2_Soft
       , IFNULL(HrsFcst_CurrentQtrM3_Soft, 0.00)                      AS HrsFcst_CurrentQtrM3_Soft
       , IFNULL(HrsFcst_RemainingInQtr_Soft, 0.00)                    AS HrsFcst_RemainingInQtr_Soft
       , IFNULL(HrsFcst_Plus1Qtr_Soft, 0.00)                          AS HrsFcst_Plus1Qtr_Soft
       , IFNULL(HrsFcst_Plus2Qtr_Soft, 0.00)                          AS HrsFcst_Plus2Qtr_Soft
       , IFNULL(HrsFcst_Plus3Qtr_Soft, 0.00)                          AS HrsFcst_Plus3Qtr_Soft
       , IFNULL(HrsFcst_AdditionalQtrs_Soft, 0.00)                    AS HrsFcst_AdditionalQtrs_Soft
       , IFNULL(HrsFcst_CustomRange_Soft, 0.00)                       AS HrsFcst_CustomRange_Soft
       , IFNULL(HrsFcst_AfterCutover_Soft, 0.00)                      AS HrsFcst_AfterCutover_Soft
       , IFNULL(HrsFcst_Billable_All_Soft, 0.00)                      AS HrsFcst_Billable_All_Soft
       , IFNULL(HrsFcst_Billable_Future_Soft, 0.00)                   AS HrsFcst_Billable_Future_Soft
       , IFNULL(HrsFcst_Billable_CurrentMonth_Soft, 0.00)             AS HrsFcst_Billable_CurrentMonth_Soft
       , IFNULL(HrsFcst_Billable_FutureMonths_Soft, 0.00)             AS HrsFcst_Billable_FutureMonths_Soft
       , IFNULL(HrsFcst_Billable_FutureQtrs_Soft, 0.00)               AS HrsFcst_Billable_FutureQtrs_Soft
       , IFNULL(HrsFcst_Billable_EntireCurrentQtr_Soft, 0.00)         AS HrsFcst_Billable_EntireCurrentQtr_Soft
       , IFNULL(HrsFcst_Billable_CurrentQtrM1_Soft, 0.00)             AS HrsFcst_Billable_CurrentQtrM1_Soft
       , IFNULL(HrsFcst_Billable_CurrentQtrM2_Soft, 0.00)             AS HrsFcst_Billable_CurrentQtrM2_Soft
       , IFNULL(HrsFcst_Billable_CurrentQtrM3_Soft, 0.00)             AS HrsFcst_Billable_CurrentQtrM3_Soft
       , IFNULL(HrsFcst_Billable_RemainingInQtr_Soft, 0.00)           AS HrsFcst_Billable_RemainingInQtr_Soft
       , IFNULL(HrsFcst_Billable_Plus1Qtr_Soft, 0.00)                 AS HrsFcst_Billable_Plus1Qtr_Soft
       , IFNULL(HrsFcst_Billable_Plus2Qtr_Soft, 0.00)                 AS HrsFcst_Billable_Plus2Qtr_Soft
       , IFNULL(HrsFcst_Billable_Plus3Qtr_Soft, 0.00)                 AS HrsFcst_Billable_Plus3Qtr_Soft
        , IFNULL(HrsFcst_Billable_Plus4Qtr_Soft, 0.00)                 AS HrsFcst_Billable_Plus4Qtr_Soft
        , IFNULL(HrsFcst_Billable_Plus5Qtr_Soft, 0.00)                 AS HrsFcst_Billable_Plus5Qtr_Soft
      , IFNULL(HrsFcst_Billable_AdditionalQtrs_Soft, 0.00)           AS HrsFcst_Billable_AdditionalQtrs_Soft
        , IFNULL(HrsFcst_Billable_AdditionalQtrs2_Soft, 0.00)          AS HrsFcst_Billable_AdditionalQtrs2_Soft
       , IFNULL(HrsFcst_Billable_CustomRange_Soft, 0.00)              AS HrsFcst_Billable_CustomRange_Soft
       , IFNULL(HrsFcst_Billable_AfterCutover_Soft, 0.00)             AS HrsFcst_Billable_AfterCutover_Soft
       , IFNULL(HrsFcst_Gen_All_Soft, 0.00)                           AS HrsFcst_Gen_All_Soft
       , IFNULL(HrsFcst_Gen_Future_Soft, 0.00)                        AS HrsFcst_Gen_Future_Soft
       , IFNULL(HrsFcst_Gen_CurrentMonth_Soft, 0.00)                  AS HrsFcst_Gen_CurrentMonth_Soft
       , IFNULL(HrsFcst_Gen_FutureMonths_Soft, 0.00)                  AS HrsFcst_Gen_FutureMonths_Soft
       , IFNULL(HrsFcst_Gen_FutureQtrs_Soft, 0.00)                    AS HrsFcst_Gen_FutureQtrs_Soft
       , IFNULL(HrsFcst_Gen_EntireCurrentQtr_Soft, 0.00)              AS HrsFcst_Gen_EntireCurrentQtr_Soft
       , IFNULL(HrsFcst_Gen_CurrentQtrM1_Soft, 0.00)                  AS HrsFcst_Gen_CurrentQtrM1_Soft
       , IFNULL(HrsFcst_Gen_CurrentQtrM2_Soft, 0.00)                  AS HrsFcst_Gen_CurrentQtrM2_Soft
       , IFNULL(HrsFcst_Gen_CurrentQtrM3_Soft, 0.00)                  AS HrsFcst_Gen_CurrentQtrM3_Soft
       , IFNULL(HrsFcst_Gen_RemainingInQtr_Soft, 0.00)                AS HrsFcst_Gen_RemainingInQtr_Soft
       , IFNULL(HrsFcst_Gen_Plus1Qtr_Soft, 0.00)                      AS HrsFcst_Gen_Plus1Qtr_Soft
       , IFNULL(HrsFcst_Gen_Plus2Qtr_Soft, 0.00)                      AS HrsFcst_Gen_Plus2Qtr_Soft
       , IFNULL(HrsFcst_Gen_Plus3Qtr_Soft, 0.00)                      AS HrsFcst_Gen_Plus3Qtr_Soft
       , IFNULL(HrsFcst_Gen_AdditionalQtrs_Soft, 0.00)                AS HrsFcst_Gen_AdditionalQtrs_Soft
       , IFNULL(HrsFcst_Gen_CustomRange_Soft, 0.00)                   AS HrsFcst_Gen_CustomRange_Soft
       , IFNULL(HrsFcst_Gen_AfterCutover_Soft, 0.00)                  AS HrsFcst_Gen_AfterCutover_Soft
       , IFNULL(HrsFcst_NonBill_Gen_All_Soft, 0.00)                   AS HrsFcst_NonBill_Gen_All_Soft
       , IFNULL(HrsFcst_NonBill_Gen_Future_Soft, 0.00)                AS HrsFcst_NonBill_Gen_Future_Soft
       , IFNULL(HrsFcst_NonBill_Gen_CurrentMonth_Soft, 0.00)          AS HrsFcst_NonBill_Gen_CurrentMonth_Soft
       , IFNULL(HrsFcst_NonBill_Gen_FutureMonths_Soft, 0.00)          AS HrsFcst_NonBill_Gen_FutureMonths_Soft
       , IFNULL(HrsFcst_NonBill_Gen_FutureQtrs_Soft, 0.00)            AS HrsFcst_NonBill_Gen_FutureQtrs_Soft
       , IFNULL(HrsFcst_NonBill_Gen_EntireCurrentQtr_Soft, 0.00)      AS HrsFcst_NonBill_Gen_EntireCurrentQtr_Soft
       , IFNULL(HrsFcst_NonBill_Gen_CurrentQtrM1_Soft, 0.00)          AS HrsFcst_NonBill_Gen_CurrentQtrM1_Soft
       , IFNULL(HrsFcst_NonBill_Gen_CurrentQtrM2_Soft, 0.00)          AS HrsFcst_NonBill_Gen_CurrentQtrM2_Soft
       , IFNULL(HrsFcst_NonBill_Gen_CurrentQtrM3_Soft, 0.00)          AS HrsFcst_NonBill_Gen_CurrentQtrM3_Soft
       , IFNULL(HrsFcst_NonBill_Gen_RemainingInQtr_Soft, 0.00)        AS HrsFcst_NonBill_Gen_RemainingInQtr_Soft
       , IFNULL(HrsFcst_NonBill_Gen_Plus1Qtr_Soft, 0.00)              AS HrsFcst_NonBill_Gen_Plus1Qtr_Soft
       , IFNULL(HrsFcst_NonBill_Gen_Plus2Qtr_Soft, 0.00)              AS HrsFcst_NonBill_Gen_Plus2Qtr_Soft
       , IFNULL(HrsFcst_NonBill_Gen_Plus3Qtr_Soft, 0.00)              AS HrsFcst_NonBill_Gen_Plus3Qtr_Soft
       , IFNULL(HrsFcst_NonBill_Gen_AdditionalQtrs_Soft, 0.00)        AS HrsFcst_NonBill_Gen_AdditionalQtrs_Soft
       , IFNULL(HrsFcst_NonBill_Gen_CustomRange_Soft, 0.00)           AS HrsFcst_NonBill_Gen_CustomRange_Soft
       , IFNULL(HrsFcst_NonBill_Gen_AfterCutover_Soft, 0.00)          AS HrsFcst_NonBill_Gen_AfterCutover_Soft
       , HrsAct_CustomRangeBegin                                      AS HrsAct_CustomRangeBegin
       , HrsAct_CustomRangeEnd                                        AS HrsAct_CustomRangeEnd
       , HrsFcst_CustomRangeBegin                                     AS HrsFcst_CustomRangeBegin
       , HrsFcst_CustomRangeEnd                                       AS HrsFcst_CustomRangeEnd
       , 22                                                           AS SQLVersion_LABOR_HRS
    FROM eio_publish.tenrox_private.TPROJECT TPROJECT 
    LEFT JOIN (SELECT
                        DISTINCT
                        PROJECTID AS ProjectID
                      FROM eio_publish.tenrox_private.TTIMEENTRY TTIMEENTRY
                      JOIN eio_publish.tenrox_private.TTASK TTASK
                        ON TTIMEENTRY.TASKID = TTASK.UNIQUEID
                      UNION
                      SELECT
                        DISTINCT
                        TRPLNBOOKING.PROJECTID AS ProjectID
                      FROM eio_publish.tenrox_private.TRPLNBOOKING TRPLNBOOKING 
                      JOIN eio_publish.tenrox_private.TRPLNBOOKINGDETAILS TRPLNBOOKINGDETAILS 
                        ON TRPLNBOOKINGDETAILS.BOOKINGID = TRPLNBOOKING.UNIQUEID) ProjectLinks
                  ON ProjectLinks.ProjectID = TPROJECT.UNIQUEID
    LEFT JOIN Actuals ON Actuals.ProjectID = ProjectLinks.ProjectID
    LEFT JOIN Forecast ON Forecast.ProjectID = ProjectLinks.ProjectID