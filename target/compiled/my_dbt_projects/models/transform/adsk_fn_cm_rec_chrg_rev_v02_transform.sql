
/* ADSK_FN_CM_REC_CHRG_REV_V02
  @OverrideCurID   INT
  , @RangeBegin    DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL
  , @Placeholder05 INT = NULL
*/
    SELECT
       TPROJECT.UNIQUEID AS ProjectID
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1 THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_Past
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_PastQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_CompletedInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_Minus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_Minus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_Minus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_PriorQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_AllBillable_CustomRange
       -- 3rd Party-Billable Expenses     RecChrgRev_3rdBillableExp
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses' THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_Past
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_PastQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_CompletedInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_Minus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_Minus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_Minus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_PriorQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdBillableExp_CustomRange
       -- 3rd Party-Non-Billable T&E      RecChrgRev_3rdNonBillTE
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_Past
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_PastQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_CompletedInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_Minus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_Minus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_Minus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_PriorQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdNonBillTE_CustomRange
       -- Internal-Billable Expenses      RecChrgRev_InternalBillableExp
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses' THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_Past
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_PastQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_CompletedInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_Minus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_Minus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_Minus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_PriorQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalBillableExp_CustomRange
       -- Internal-Non-Billable T&E       RecChrgRev_InternalNonBillTE
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E' THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_Past
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_PastQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_CompletedInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_Minus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_Minus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_Minus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_PriorQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_InternalNonBillTE_CustomRange
       -- Ratable Billing                 RecChrgRev_RatableBilling
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing' THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_Past
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_PastQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_CompletedInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_Minus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_Minus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_Minus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_PriorQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_RatableBilling_CustomRange
       -- Sys Conv-Labor Non-Billable     RecChrgRev_SysConvNonBill
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable' THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_Past
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_PastQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_CompletedInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_Minus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_Minus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_Minus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_PriorQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvNonBill_CustomRange
       -- Sys Conv-Labor Revenue          RecChrgRev_SysConvLaborRev
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue' THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_Past
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_PastQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_CompletedInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_Minus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_Minus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_Minus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_PriorQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Revenue'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_SysConvLaborRev_CustomRange
       -- Autodesk IP Product-Sales       RecChrgRev_IPProdSales
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales' THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_Past
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_PastQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_CompletedInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_Minus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_Minus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_Minus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_PriorQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_IPProdSales_CustomRange
       -- Third Party Product-Sales       RecChrgRev_3rdProdSales
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales' THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_Past
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentMonthBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_NextMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_PastQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Plus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_CurrentQtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentMonthBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_CompletedInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus1QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_CurrentQtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_Minus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus2QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus1QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_Minus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Minus3QtrBegins
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus2QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_Minus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Minus3QtrBegins THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_PriorQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TCHARGEENTRY.CURRENTDATE >= Fnc_Hist_CustomRangeBegin
                           AND TCHARGEENTRY.CURRENTDATE < Fnc_Hist_CustomRangeEnd THEN IFNULL(TCHARGEENTRY.AMOUNT * FXRate.Rate, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS RecChrgRev_3rdProdSales_CustomRange
       , MAX(Fnc_Hist_CustomRangeBegin) AS RecChrgRev_CustomRangeBegin
       , MAX(Fnc_Hist_CustomRangeEnd) AS RecChrgRev_CustomRangeEnd
       , 8 AS SQLVersion_REC_CHRG_REV
     FROM eio_publish.tenrox_private.TPROJECT TPROJECT
     LEFT JOIN eio_publish.tenrox_private.TTASK TTASK
                  ON TTASK.PROJECTID = TPROJECT.UNIQUEID
     LEFT JOIN eio_publish.tenrox_private.TCHARGEENTRY TCHARGEENTRY
                  ON TCHARGEENTRY.TASKID = TTASK.UNIQUEID
                 AND TCHARGEENTRY.APPROVED = 1
     INNER JOIN eio_publish.tenrox_private.TCHARGE TCHARGE
             ON TCHARGE.UNIQUEID = TCHARGEENTRY.CHARGEID
            AND TCHARGE.CHARGETYPE = 'M'
     LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_month_q_ranges_v02 AS Ranges
     LEFT OUTER JOIN (SELECT
                        IFNULL(UNIQUEID, 1) AS LUBaseCurrencyID
                      FROM   eio_publish.tenrox_private.TCURRENCY TCURRENCY
                      WHERE  CURRENCYCODE = 'USD') BaseCUR
     -- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN (
                    SELECT
                        IFNULL(UNIQUEID, 1) AS OverrideCurID
                    FROM   eio_publish.tenrox_private.TCURRENCY TCURRENCY
                    WHERE  CURRENCYCODE = 'USD') USDCurID
     -- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.fcurrqexchrate as FXRate
                  ON FXRate.BASECURRENCYID = COALESCE(TCHARGEENTRY.CURRENCYID, LUBaseCurrencyID)
                  -- traced back to final table CUST_ADSK_MARGINVARIANCE where @OverrideCurID = @USDCurID = 1
                 AND FXRate.QUOTECURRENCYID = COALESCE(OverrideCurID, TCHARGEENTRY.CLIENTCURRENCYID, LUBaseCurrencyID)
                 AND TCHARGEENTRY.CURRENTDATE BETWEEN FXRate.STARTDATE AND FXRate.ENDDATE
     GROUP           BY
      TPROJECT.UNIQUEID