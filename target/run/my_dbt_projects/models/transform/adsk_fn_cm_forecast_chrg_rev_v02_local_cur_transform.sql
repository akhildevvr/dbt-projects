
  create or replace   view eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_forecast_chrg_rev_local_cur_v02
  
   as (
    
/* ADSK_FN_CM_FORECAST_CHRG_COST
  @OverrideCurID  INT
  , @RangeBegin   DATETIME = NULL
  , @RangeEnd     DATETIME = NULL
  , @CutoverDate  DATETIME = NULL
  , @Placeholder5 INT = NULL

Used only in CUST_ADSK_MARGINVARIANCE where @OverrideCurID = @USDCurID is forced set to 1
and LUBaseCurrencyID is forced set to 1 as well

Therefore:
CASE
     WHEN @OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY   --> @OverrideCurID is always 1 and IS NEVER NULL
     WHEN LUBaseCurrencyID = @OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY  --> LUBaseCurrencyID = 1 and therefore @USDCurID = LUBaseCurrencyID
     ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
 END
*/

     SELECT
       TPROJECT.UNIQUEID AS ProjectID
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1 THEN IFNULL(CASE
                                                              WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                              WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                              ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                            END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_Future
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus5QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_Plus4Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus5QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus6QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_Plus5Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus6QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_AdditionalQtrs2
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_AllBillable_CustomRange
       -- All BUT Ratable
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing' THEN IFNULL(CASE
                                                                                           WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                           WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                           ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                         END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_Future
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_Plus3Qtr
        , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus5QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_Plus4Qtr
        , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus5QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus6QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_Plus5Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus6QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_AdditionalQtrs2
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.BILLABLE = 1
                           AND IFNULL(TCHARGE.NAME, '') <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_NonRatableBillable_CustomRange
       -- IPProdSales
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales' THEN IFNULL(CASE
                                                                                    WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                    WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                    ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                  END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_Future
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Autodesk IP Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_IPProdSales_CustomRange
       -- Ratable Billing
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing' THEN IFNULL(CASE
                                                                          WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                          WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                          ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                        END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_Future
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_RatableBilling_CustomRange
       -- IP3rdSales
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales' THEN IFNULL(CASE
                                                                                    WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                    WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                    ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                  END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_Future
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Third Party Product-Sales'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdProdSales_CustomRange
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses' THEN IFNULL(CASE
                                                                                      WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                      WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                      ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                    END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_Future
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdBillableExp_CustomRange
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses' THEN IFNULL(CASE
                                                                                     WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                     WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                     ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                   END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_Future
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalBillableExp_CustomRange
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN IFNULL(CASE
                                                                                     WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                     WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                     ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                   END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_Future
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_3rdNonBillTE_CustomRange
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E' THEN IFNULL(CASE
                                                                                    WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                    WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                    ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                  END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_Future
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Internal-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_InternalNonBillTE_CustomRange
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable' THEN IFNULL(CASE
                                                                                      WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                      WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                      ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                    END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_All
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_Future
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TCHARGE.NAME = 'Sys Conv-Labor Non-Billable'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00)) AS FcstChrgRev_SysConvNonBill_CustomRange
       , MAX(Fnc_Fcst_CustomRangeBegin) AS FcstChrgRev_CustomRangeBegin
       , MAX(Fnc_Fcst_CustomRangeEnd) AS FcstChrgRev_CustomRangeEnd
       , 15 AS SQLVersion_FORECAST_CHRG_REV
     FROM eio_publish.tenrox_private.TRVFCBASELINE TRVFCBASELINE
     LEFT OUTER JOIN eio_publish.tenrox_private.TRVFCBASELINEBUDGET TRVFCBASELINEBUDGET
                  ON TRVFCBASELINEBUDGET.BASELINEUID = TRVFCBASELINE.UNIQUEID
     INNER JOIN eio_publish.tenrox_private.TRVFCBLTMPL TRVFCBLTMPL
             ON TRVFCBLTMPL.BASELINEID = TRVFCBASELINE.UNIQUEID
     INNER JOIN eio_publish.tenrox_private.TRVFCBLSEC TRVFCBLSEC
             ON TRVFCBLSEC.BLTMPLID = TRVFCBLTMPL.UNIQUEID
     INNER JOIN eio_publish.tenrox_private.TRVFCBLSECLABEL TRVFCBLSECLABEL
             ON TRVFCBLSECLABEL.BLSECID = TRVFCBLSEC.UNIQUEID
            AND TRVFCBLSECLABEL.LANGUAGE = 0
     INNER JOIN eio_publish.tenrox_private.TRVFCBLCAT TRVFCBLCAT
             ON TRVFCBLCAT.BLSECID = TRVFCBLSEC.UNIQUEID
     INNER JOIN eio_publish.tenrox_private.TRVFCBLCATLABEL TRVFCBLCATLABEL
             ON TRVFCBLCATLABEL.BLCATID = TRVFCBLCAT.UNIQUEID
            AND TRVFCBLCATLABEL.LANGUAGE = 0
     INNER JOIN eio_publish.tenrox_private.TRVFCBLITEM TRVFCBLITEM
             ON TRVFCBLITEM.BLCATID = TRVFCBLCAT.UNIQUEID
     INNER JOIN eio_publish.tenrox_private.TRVFCBLITEMDATA TRVFCBLITEMDATA
             ON TRVFCBLITEMDATA.BLITEMID = TRVFCBLITEM.UNIQUEID
     INNER JOIN eio_publish.tenrox_private.TFCALPERIOD TFCALPERIOD
             ON TFCALPERIOD.UNIQUEID = TRVFCBLITEMDATA.CALPERIODID
            AND TFCALPERIOD.PERIODTYPE = 'M'
            AND TFCALPERIOD.CALID = 4
     LEFT JOIN eio_publish.tenrox_private.TCHARGE TCHARGE
                  ON CASE TRVFCBLITEM.OBJECTTYPE
                       WHEN 129 THEN TCHARGE.UNIQUEID
                     END = TRVFCBLITEM.OBJECTID
                     AND TCHARGE.CHARGETYPE = 'M'
     RIGHT OUTER JOIN eio_publish.tenrox_private.TPROJECT TPROJECT
                   ON TPROJECT.UNIQUEID = TRVFCBASELINE.PROJECTID
     LEFT JOIN eio_publish.tenrox_private.TCLIENTINVOICE TCLIENTINVOICE
                  ON TCLIENTINVOICE.CLIENTID = TPROJECT.CLIENTID
     LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_month_q_ranges_v02 AS Ranges
     LEFT OUTER JOIN  (SELECT
                         IFNULL(UNIQUEID, 1) AS LUBaseCurrencyID
                       FROM eio_publish.tenrox_private.TCURRENCY TCURRENCY
                       WHERE  CURRENCYCODE = 'USD') BaseCUR
     -- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID
     LEFT OUTER JOIN (
                    SELECT
                         NULL      AS OverrideCurID
                    FROM eio_publish.tenrox_private.TCURRENCY
                    WHERE CURRENCYCODE = 'USD'
                    ) USDCurID
     -- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID
     LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.fcurrqexchrate AS FXRate
                  ON  FXRate.BASECURRENCYID = COALESCE(TCLIENTINVOICE.CURRENCYID, LUBaseCurrencyID)
                      -- only used in CUST_ADSK_MARGINVARIANCE where @OverrideCurID = @USDCurID and is forced to 1, LUBaseCurrencyID is also always 1
                 AND  FXRate.QUOTECURRENCYID = COALESCE(NULL, TCLIENTINVOICE.CURRENCYID, LUBaseCurrencyID)
                 AND  CURRENT_DATE() BETWEEN FXRate.STARTDATE AND FXRate.ENDDATE
     WHERE            TRVFCBASELINE.ISCURRENT = 1
                  AND TRVFCBLITEMDATA.ELEMENTTYPE = 1
                  AND TRVFCBLSECLABEL.LABEL = 'Revenue'
                  AND TRVFCBLCATLABEL.LABEL = 'Charges'
                  AND TRVFCBLITEM.OBJECTTYPE = 129
                  AND TRVFCBLITEMDATA.ELEMENTTYPE = 1
     GROUP            BY
      TPROJECT.UNIQUEID
  );

