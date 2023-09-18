
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
       TPROJECT.UNIQUEID                AS ProjectID
       /* Exclude Ratable Billing */
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing' THEN IFNULL(CASE
                                                                               WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                               WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                               ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                             END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_All
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_Future
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME <> 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_NonRatable_CustomRange
       /* Ratable Costs Only */
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing' THEN IFNULL(CASE
                                                                              WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                              WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                              ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                            END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_All
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_Future
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Ratable Billing'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Ratable_CustomRange
       /* All Charge Costs */
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost' THEN IFNULL(CASE
                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_All
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Future
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus5QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Plus4Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus5QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus6QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Plus5Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus6QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_Additional2Qtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_CustomRange
       /* Third Party Product-Costs */
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs' THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_All
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_Future
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = 'Third Party Product-Costs'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_IPProdSales_CustomRange
       /* 3rd Party-Non-Billable T&E */
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E' THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_All
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_Future
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Non-Billable T&E'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdNonBillTE_CustomRange
       /* 3rd Party-Billable Expenses */
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses' THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_All
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_Future
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_NextMonthBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_CurrentMonth
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_FutureQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentQtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_EntireCurrentQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_CurrentMonthBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus1QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_RemainingInQtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus1QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus2QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_Plus1Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus2QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus3QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_Plus2Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus3QtrBegins
                           AND TFCALPERIOD.STARTDATE < Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                        WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                        WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                        ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                      END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_Plus3Qtr
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Plus4QtrBegins THEN IFNULL(CASE
                                                                                         WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                         WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                         ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                       END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_AdditionalQtrs
       , SUM(IFNULL(CASE
                      WHEN TRVFCBLSECLABEL.LABEL = 'Cost'
                           AND TCHARGE.NAME = '3rd Party-Billable Expenses'
                           AND TFCALPERIOD.STARTDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TFCALPERIOD.STARTDATE < Fnc_Fcst_CustomRangeEnd THEN IFNULL(CASE
                                                                                             WHEN OverrideCurID IS NULL THEN TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY
                                                                                             WHEN LUBaseCurrencyID = OverrideCurID THEN TRVFCBLITEMDATA.AMOUNTBASECURRENCY
                                                                                             ELSE TRVFCBLITEMDATA.AMOUNTCLIENTCURRENCY * FXRate.Rate
                                                                                           END, 0.00)
                      ELSE 0.00
                    END, 0.00))         AS FcstChrgCost_3rdBillableExp_CustomRange
       , MAX(Fnc_Fcst_CustomRangeBegin) AS FcstChrgCost_CustomRangeBegin
       , MAX(Fnc_Fcst_CustomRangeEnd)   AS FcstChrgCost_CustomRangeEnd
       , 7                              AS SQLVersion_FORECAST_CHRG_COST
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
            AND TRVFCBLSECLABEL.LABEL = 'Cost'
     INNER JOIN eio_publish.tenrox_private.TRVFCBLCAT TRVFCBLCAT
             ON TRVFCBLCAT.BLSECID = TRVFCBLSEC.UNIQUEID
     INNER JOIN eio_publish.tenrox_private.TRVFCBLCATLABEL TRVFCBLCATLABEL
             ON TRVFCBLCATLABEL.BLCATID = TRVFCBLCAT.UNIQUEID
            AND TRVFCBLCATLABEL.LANGUAGE = 0
            AND TRVFCBLCATLABEL.LABEL = 'Charges'
     INNER JOIN eio_publish.tenrox_private.TRVFCBLITEM TRVFCBLITEM
             ON TRVFCBLITEM.BLCATID = TRVFCBLCAT.UNIQUEID
            AND TRVFCBLITEM.OBJECTTYPE = 129
     INNER JOIN eio_publish.tenrox_private.TRVFCBLITEMDATA TRVFCBLITEMDATA
             ON TRVFCBLITEMDATA.BLITEMID = TRVFCBLITEM.UNIQUEID
            AND TRVFCBLITEMDATA.ELEMENTTYPE = 1
     INNER JOIN eio_publish.tenrox_private.TFCALPERIOD TFCALPERIOD
             ON TFCALPERIOD.UNIQUEID = TRVFCBLITEMDATA.CALPERIODID
            AND TFCALPERIOD.PERIODTYPE = 'M'
            AND TFCALPERIOD.CALID = 4
     INNER JOIN eio_publish.tenrox_private.TCHARGE TCHARGE
             ON TCHARGE.UNIQUEID = TRVFCBLITEM.OBJECTID
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
     /* only used in CUST_ADSK_MARGINVARIANCE where OverrideCurID = @USDCurID and is forced to 1, LUBaseCurrencyID is also always 1
                    SELECT  
                         @USDCurID = ISNULL(UNIQUEID, 1)  
                         FROM   TCURRENCY  
                         WHERE  CURRENCYCODE = 'USD'
                    @USDCurID = LUBaseCurrencyID = @OverrideCurID = 1
     */
     LEFT OUTER JOIN (
                    SELECT
                         IFNULL(UNIQUEID, 1)      AS OverrideCurID
                    FROM eio_publish.tenrox_private.TCURRENCY
                    WHERE CURRENCYCODE = 'USD'
                    ) USDCurID
     -- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.fcurrqexchrate AS FXRate
                  ON  FXRate.BASECURRENCYID = COALESCE(TCLIENTINVOICE.CURRENCYID, LUBaseCurrencyID)
                 AND  FXRate.QUOTECURRENCYID = COALESCE(NULL, TCLIENTINVOICE.CURRENCYID, LUBaseCurrencyID)
                 AND  CURRENT_DATE() BETWEEN FXRate.STARTDATE AND FXRate.ENDDATE
     WHERE            TRVFCBASELINE.ISCURRENT = 1
     GROUP            BY
          TPROJECT.UNIQUEID