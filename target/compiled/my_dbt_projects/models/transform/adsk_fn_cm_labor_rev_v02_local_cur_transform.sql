
/* ADSK_FN_CM_LABOR_REV_V02
  @OverrideCurID   INT = NULL
  , @RangeBegin    DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL
  , @Placeholder05 INT = NULL
*/
SELECT
       TPROJECT.UNIQUEID                                                                                                                                                     AS ProjectID
       , IFNULL(ProjBudget.CurrentBillableTime, 0.00)                                                                                                                        AS LaborRevenue_Total
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsAct_Past, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                                         AS RevLabor_Past
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsAct_PastQtrs, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                                     AS RevLabor_PastQtrs
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsAct_PriorQtrs, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                                    AS RevLabor_PriorQtrs
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsAct_Minus3Qtr, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                                    AS RevLabor_Minus3Qtr
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsAct_Minus2Qtr, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                                    AS RevLabor_Minus2Qtr
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsAct_Minus1Qtr, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                                    AS RevLabor_Minus1Qtr
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsAct_CompletedInQtr, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                               AS RevLabor_CompletedInQtr
       , IFNULL(ProjBudget.CurrentBillableTime * ((IFNULL(HrsAct_CompletedInQtr, 0.00)
                                                   + IFNULL(HrsFcst_Billable_RemainingInQtr, 0.00)) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                 AS RevLabor_CurrentQtr
       , IFNULL(DEFERRED_REV.TotalDeferredRevenue, 0.00)                                                                                                                     AS Rev_Deferred
       , IFNULL(DEFERRED_REV.TotalDeferredRevenue, 0.00) + (ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_CurrentMonth, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00))) AS RevLabor_CurrentMonth
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_CurrentMonth, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                       AS RevLabor_CurrentMonthFcstOnly
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_RemainingInQtr, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                     AS RevLabor_RemainingInQtr
       , IFNULL(ProjBudget.CurrentBillableTime * ((IFNULL(HrsFcst_Billable_RemainingInQtr, 0.00) 
                                                    - IFNULL(HrsFcst_Billable_RemainingInQtr_Soft, 0.00)) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                           AS RevLabor_RemainingInQtr_Hard
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_Future, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                             AS RevLabor_Future
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_Plus1Qtr, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                           AS RevLabor_Plus1Qtr      
       , IFNULL(ProjBudget.CurrentBillableTime * ((IFNULL(HrsFcst_Billable_Plus1Qtr, 0.00)
                                                    - IFNULL(HrsFcst_Billable_Plus1Qtr_Soft, 0.00)) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                 AS RevLabor_Plus1Qtr_Hard
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_Plus2Qtr, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                           AS RevLabor_Plus2Qtr
       , IFNULL(ProjBudget.CurrentBillableTime * ((IFNULL(HrsFcst_Billable_Plus2Qtr, 0.00)
                                                    - IFNULL(HrsFcst_Billable_Plus2Qtr_Soft, 0.00) ) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                AS RevLabor_Plus2Qtr_Hard
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_Plus3Qtr, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                           AS RevLabor_Plus3Qtr
       , IFNULL(ProjBudget.CurrentBillableTime * ((IFNULL(HrsFcst_Billable_Plus3Qtr, 0.00)
                                                    - IFNULL(HrsFcst_Billable_Plus3Qtr_Soft , 0.00)) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                AS RevLabor_Plus3Qtr_Hard
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_Plus4Qtr, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                           AS RevLabor_Plus4Qtr
       , IFNULL(ProjBudget.CurrentBillableTime * ((IFNULL(HrsFcst_Billable_Plus4Qtr, 0.00) 
                                                    - IFNULL(HrsFcst_Billable_Plus4Qtr_Soft, 0.00))/ NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                  AS RevLabor_Plus4Qtr_Hard
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_Plus5Qtr, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                           AS RevLabor_Plus5Qtr
       , IFNULL(ProjBudget.CurrentBillableTime * ((IFNULL(HrsFcst_Billable_Plus5Qtr, 0.00) 
                                                    - IFNULL(HrsFcst_Billable_Plus5Qtr_Soft, 0.00))/ NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                  AS RevLabor_Plus5Qtr_Hard
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_FutureQtrs, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                         AS RevLabor_FutureQtrs
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_AdditionalQtrs, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                     AS RevLabor_AdditionalQtrs
       , IFNULL(ProjBudget.CurrentBillableTime * ((IFNULL(HrsFcst_Billable_AdditionalQtrs, 0.00) 
                                                    - IFNULL(HrsFcst_Billable_AdditionalQtrs_Soft, 0.00))/ NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                            AS RevLabor_AdditionalQtrs_Hard
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsFcst_Billable_AdditionalQtrs2, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                    AS RevLabor_AdditionalQtrs2
       , IFNULL(ProjBudget.CurrentBillableTime * ((IFNULL(HrsFcst_Billable_AdditionalQtrs2, 0.00) 
                                                    - IFNULL(HrsFcst_Billable_AdditionalQtrs2_Soft, 0.00))/ NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                           AS RevLabor_AdditionalQtrs2_Hard
       , IFNULL(ProjBudget.CurrentBillableTime * (IFNULL(HrsAct_CustomRange
                                                         + HrsFcst_Billable_CustomRange, 0.00) / NULLIF(Hrs_Billable_EAC, 0.00)), 0.00)                                      AS RevLabor_CustomRange
       , Fnc_Hist_CustomRangeBegin                                                                                                                                           AS RevLabor_CustomRangeBegin
       , Fnc_Fcst_CustomRangeEnd                                                                                                                                             AS RevLabor_CustomRangeEnd
       , 12                                                                                                                                                                  AS SQLVersion_LABOR_REV
     FROM eio_publish.tenrox_private.TPROJECT TPROJECT
     INNER JOIN eio_publish.tenrox_private.TCLIENTINVOICE TCLIENTINVOICE
             ON TCLIENTINVOICE.CLIENTID = TPROJECT.CLIENTID
     LEFT JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_project_budget_local_cur as ProjBudget
                  ON ProjBudget.ProjectID = TPROJECT.UNIQUEID
     LEFT JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_labor_hrs_v02 as LaborHrs
                  ON LaborHrs.ProjectID = TPROJECT.UNIQUEID
     LEFT JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_deferred_local_cur_rev as DEFERRED_REV
                  ON DEFERRED_REV.ProjectID = TPROJECT.UNIQUEID
     LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_month_q_ranges_v02 as Ranges