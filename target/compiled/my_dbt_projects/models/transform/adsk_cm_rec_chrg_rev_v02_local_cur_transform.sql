
/* ADSK_FN_CM_REC_CHRG_REV_V02
  @OverrideCurID   INT
  , @RangeBegin    DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL
  , @Placeholder05 INT = NULL
*/
SELECT
     tproject.uniqueid AS projectid
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                    ELSE 0.00
                    END, 0.00)) AS recchrgrev_allbillable_all
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_allbillable_past
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 AND tchargeentry.currentdate >= fnc_currentmonthbegins
                              AND tchargeentry.currentdate < fnc_nextmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_allbillable_currentmonth
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_allbillable_pastqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_plus1qtrbegins THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_allbillable_entirecurrentqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_allbillable_completedinqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 AND tchargeentry.currentdate >= fnc_minus1qtrbegins
                              AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_allbillable_minus1qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 AND tchargeentry.currentdate >= fnc_minus2qtrbegins
                              AND tchargeentry.currentdate < fnc_minus1qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_allbillable_minus2qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 AND tchargeentry.currentdate >= fnc_minus3qtrbegins
                              AND tchargeentry.currentdate < fnc_minus2qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_allbillable_minus3qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 AND tchargeentry.currentdate < fnc_minus3qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_allbillable_priorqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 AND tchargeentry.currentdate >= fnc_hist_customrangebegin
                              AND tchargeentry.currentdate < fnc_hist_customrangeend
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_allbillable_customrange
    -- 3rd Party-Billable Expenses     RecChrgRev_3rdBillableExp
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_all
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_past
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate >= fnc_currentmonthbegins
                              AND tchargeentry.currentdate < fnc_nextmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_currentmonth
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_pastqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_plus1qtrbegins THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_entirecurrentqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_completedinqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate >= fnc_minus1qtrbegins
                              AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_minus1qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate >= fnc_minus2qtrbegins
                              AND tchargeentry.currentdate < fnc_minus1qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_minus2qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate >= fnc_minus3qtrbegins
                              AND tchargeentry.currentdate < fnc_minus2qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_minus3qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate < fnc_minus3qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_priorqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate >= fnc_hist_customrangebegin
                              AND tchargeentry.currentdate < fnc_hist_customrangeend
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_customrange
    -- 3rd Party-Non-Billable T&E      RecChrgRev_3rdNonBillTE
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_all
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_past
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_currentmonthbegins
                              AND tchargeentry.currentdate < fnc_nextmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_currentmonth
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_pastqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_plus1qtrbegins THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_entirecurrentqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_completedinqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_minus1qtrbegins
                              AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_minus1qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_minus2qtrbegins
                              AND tchargeentry.currentdate < fnc_minus1qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_minus2qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_minus3qtrbegins
                              AND tchargeentry.currentdate < fnc_minus2qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_minus3qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.currentdate < fnc_minus3qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_priorqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_hist_customrangebegin
                              AND tchargeentry.currentdate < fnc_hist_customrangeend
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte_customrange
    -- Internal-Billable Expenses      RecChrgRev_InternalBillableExp
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_all
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_past
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate >= fnc_currentmonthbegins
                              AND tchargeentry.currentdate < fnc_nextmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_currentmonth
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_pastqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_plus1qtrbegins THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_entirecurrentqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_completedinqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate >= fnc_minus1qtrbegins
                              AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_minus1qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate >= fnc_minus2qtrbegins
                              AND tchargeentry.currentdate < fnc_minus1qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_minus2qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate >= fnc_minus3qtrbegins
                              AND tchargeentry.currentdate < fnc_minus2qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_minus3qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate < fnc_minus3qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_priorqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate >= fnc_hist_customrangebegin
                              AND tchargeentry.currentdate < fnc_hist_customrangeend
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_customrange
    -- Internal-Non-Billable T&E       RecChrgRev_InternalNonBillTE
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_all
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_past
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_currentmonthbegins
                              AND tchargeentry.currentdate < fnc_nextmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_currentmonth
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_pastqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_plus1qtrbegins THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_entirecurrentqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_completedinqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_minus1qtrbegins
                              AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_minus1qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_minus2qtrbegins
                              AND tchargeentry.currentdate < fnc_minus1qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_minus2qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_minus3qtrbegins
                              AND tchargeentry.currentdate < fnc_minus2qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_minus3qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.currentdate < fnc_minus3qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_priorqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.currentdate >= fnc_hist_customrangebegin
                              AND tchargeentry.currentdate < fnc_hist_customrangeend
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte_customrange
    -- Ratable Billing                 RecChrgRev_RatableBilling
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_all
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_past
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' AND tchargeentry.currentdate >= fnc_currentmonthbegins
                              AND tchargeentry.currentdate < fnc_nextmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_currentmonth
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_pastqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_plus1qtrbegins THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_entirecurrentqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_completedinqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' AND tchargeentry.currentdate >= fnc_minus1qtrbegins
                              AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_minus1qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' AND tchargeentry.currentdate >= fnc_minus2qtrbegins
                              AND tchargeentry.currentdate < fnc_minus1qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_minus2qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' AND tchargeentry.currentdate >= fnc_minus3qtrbegins
                              AND tchargeentry.currentdate < fnc_minus2qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_minus3qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' AND tchargeentry.currentdate < fnc_minus3qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_priorqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' AND tchargeentry.currentdate >= fnc_hist_customrangebegin
                              AND tchargeentry.currentdate < fnc_hist_customrangeend
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling_customrange
    -- Sys Conv-Labor Non-Billable     RecChrgRev_SysConvNonBill
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_all
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_past
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.currentdate >= fnc_currentmonthbegins
                              AND tchargeentry.currentdate < fnc_nextmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_currentmonth
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_pastqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_plus1qtrbegins THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_entirecurrentqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_completedinqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.currentdate >= fnc_minus1qtrbegins
                              AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_minus1qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.currentdate >= fnc_minus2qtrbegins
                              AND tchargeentry.currentdate < fnc_minus1qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_minus2qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.currentdate >= fnc_minus3qtrbegins
                              AND tchargeentry.currentdate < fnc_minus2qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_minus3qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.currentdate < fnc_minus3qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_priorqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.currentdate >= fnc_hist_customrangebegin
                              AND tchargeentry.currentdate < fnc_hist_customrangeend
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill_customrange
    -- Sys Conv-Labor Revenue          RecChrgRev_SysConvLaborRev
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_all
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_past
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' AND tchargeentry.currentdate >= fnc_currentmonthbegins
                              AND tchargeentry.currentdate < fnc_nextmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_currentmonth
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_pastqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_plus1qtrbegins THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_entirecurrentqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_completedinqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' AND tchargeentry.currentdate >= fnc_minus1qtrbegins
                              AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_minus1qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' AND tchargeentry.currentdate >= fnc_minus2qtrbegins
                              AND tchargeentry.currentdate < fnc_minus1qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_minus2qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' AND tchargeentry.currentdate >= fnc_minus3qtrbegins
                              AND tchargeentry.currentdate < fnc_minus2qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_minus3qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' AND tchargeentry.currentdate < fnc_minus3qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_priorqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' AND tchargeentry.currentdate >= fnc_hist_customrangebegin
                              AND tchargeentry.currentdate < fnc_hist_customrangeend
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev_customrange
    -- Autodesk IP Product-Sales       RecChrgRev_IPProdSales
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_all
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_past
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.currentdate >= fnc_currentmonthbegins
                              AND tchargeentry.currentdate < fnc_nextmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_currentmonth
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_pastqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_plus1qtrbegins THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_entirecurrentqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_completedinqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.currentdate >= fnc_minus1qtrbegins
                              AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_minus1qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.currentdate >= fnc_minus2qtrbegins
                              AND tchargeentry.currentdate < fnc_minus1qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_minus2qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.currentdate >= fnc_minus3qtrbegins
                              AND tchargeentry.currentdate < fnc_minus2qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_minus3qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.currentdate < fnc_minus3qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_priorqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.currentdate >= fnc_hist_customrangebegin
                              AND tchargeentry.currentdate < fnc_hist_customrangeend
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales_customrange
    -- Third Party Product-Sales       RecChrgRev_3rdProdSales
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_all
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_past
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.currentdate >= fnc_currentmonthbegins
                              AND tchargeentry.currentdate < fnc_nextmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_currentmonth
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_pastqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_plus1qtrbegins THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_entirecurrentqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.currentdate >= fnc_currentqtrbegins
                              AND tchargeentry.currentdate < fnc_currentmonthbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_completedinqtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.currentdate >= fnc_minus1qtrbegins
                              AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_minus1qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.currentdate >= fnc_minus2qtrbegins
                              AND tchargeentry.currentdate < fnc_minus1qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_minus2qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.currentdate >= fnc_minus3qtrbegins
                              AND tchargeentry.currentdate < fnc_minus2qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_minus3qtr
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.currentdate < fnc_minus3qtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_priorqtrs
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.currentdate >= fnc_hist_customrangebegin
                              AND tchargeentry.currentdate < fnc_hist_customrangeend
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales_customrange
     , MAX(fnc_hist_customrangebegin) AS recchrgrev_customrangebegin, MAX(fnc_hist_customrangeend) AS recchrgrev_customrangeend
     , 8 AS sqlversion_rec_chrg_rev
FROM eio_publish.tenrox_private.tproject tproject
LEFT JOIN eio_publish.tenrox_private.ttask ttask
ON ttask.projectid = tproject.uniqueid
LEFT JOIN eio_publish.tenrox_private.tchargeentry tchargeentry
    ON tchargeentry.taskid = ttask.uniqueid
    AND tchargeentry.approved = 1
INNER JOIN eio_publish.tenrox_private.tcharge tcharge 
    ON tcharge.uniqueid = tchargeentry.chargeid 
    AND tcharge.chargetype = 'M'
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_month_q_ranges_v02 AS ranges
LEFT OUTER JOIN (SELECT
                   IFNULL(uniqueid, 1) AS lubasecurrencyid
                 FROM   eio_publish.tenrox_private.tcurrency tcurrency
                 WHERE  currencycode = 'USD') basecur
-- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN (
               SELECT
                   IFNULL(uniqueid, 1) AS overridecurid
               FROM   eio_publish.tenrox_private.tcurrency tcurrency
               WHERE  currencycode = 'USD') usdcurid
-- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.fcurrqexchrate AS fxrate
    ON fxrate.basecurrencyid = COALESCE(tchargeentry.currencyid, lubasecurrencyid)
    -- traced back to final table CUST_ADSK_MARGINVARIANCE where @OverrideCurID = @USDCurID = 1
    AND fxrate.quotecurrencyid = COALESCE(NULL, tchargeentry.clientcurrencyid, lubasecurrencyid) 
    AND tchargeentry.currentdate BETWEEN fxrate.startdate AND fxrate.enddate
GROUP BY
    tproject.uniqueid