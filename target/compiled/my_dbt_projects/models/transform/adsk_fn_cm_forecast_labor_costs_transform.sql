
/* ADSK_FN_CM_FORECAST_LABOR_COSTS.sql
  @OverrideCurID   INT = NULL
  , @RangeBegin    DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL
  , @Placeholder05 INT = NULL
Use as pattern for FCURRQEXCHRATE join
*/
    SELECT
       TRPLNBOOKING.PROJECTID                 AS ProjectID
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Future
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_NextMonthBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_CurrentMonth
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_FutureQtrs
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_EntireCurrentQtr
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_RemainingInQtr
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Plus1Qtr
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Plus2Qtr
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Plus3Qtr
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_AdditionalQtrs
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_CustomRange
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_Future
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_NextMonthBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_CurrentMonth
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_FutureQtrs
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_EntireCurrentQtr
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_RemainingInQtr
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_Plus1Qtr
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_Plus2Qtr
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_Plus3Qtr
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_AdditionalQtrs
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_CustomRange
       -- All above include both hard-booked and soft-booked. Below includes only soft-booked hours.
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Future_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_NextMonthBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_CurrentMonth_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_FutureQtrs_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_EntireCurrentQtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_RemainingInQtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Plus1Qtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Plus2Qtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Plus3Qtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_AdditionalQtrs_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_CustomRange_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_Future_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_NextMonthBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_CurrentMonth_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_FutureQtrs_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_EntireCurrentQtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_RemainingInQtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_Plus1Qtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_Plus2Qtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_Plus3Qtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_AdditionalQtrs_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKING.BOOKINGOBJECTTYPE = 700
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd
                           AND TRPLNBOOKING.BOOKINGTYPE = 2 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Gen_CustomRange_Soft
       /* Soft-booked Billable costs */
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2
                           AND TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Billable_Future_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_NextMonthBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2
                           AND TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Billable_CurrentMonth_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2
                           AND TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Billable_FutureQtrs_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentQtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2
                           AND TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Billable_EntireCurrentQtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_CurrentMonthBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus1QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2
                           AND TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Billable_RemainingInQtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus1QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus2QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2
                           AND TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Billable_Plus1Qtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus2QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus3QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2
                           AND TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Billable_Plus2Qtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus3QtrBegins
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Plus4QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2
                           AND TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Billable_Plus3Qtr_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Plus4QtrBegins
                           AND TRPLNBOOKING.BOOKINGTYPE = 2
                           AND TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Billable_AdditionalQtrs_Soft
       , IFNULL(SUM(CASE
                      WHEN TRPLNBOOKINGDETAILS.BOOKEDDATE >= Fnc_Fcst_CustomRangeBegin
                           AND TRPLNBOOKINGDETAILS.BOOKEDDATE < Fnc_Fcst_CustomRangeEnd
                           AND TRPLNBOOKING.BOOKINGTYPE = 2
                           AND TRPLNBOOKINGATTRIBUTES.BILLABLE = 1 THEN (TRPLNBOOKINGDETAILS.BOOKEDSECONDS / 3600.00) * FORECAST_LABOR_COST_RATES.ForecastCostRate
                      ELSE 0.00
                    END * FXRate.RATE), 0.00) AS FcstCostLabor_Billable_CustomRange_Soft
       , 12                                   AS SQLVersion_FORECAST_LABOR_COSTS
     FROM eio_publish.tenrox_private.TPROJECT TPROJECT
     INNER JOIN eio_publish.tenrox_private.TCLIENTINVOICE TCLIENTINVOICE
             ON TCLIENTINVOICE.CLIENTID = TPROJECT.CLIENTID
     INNER JOIN eio_publish.tenrox_private.TRPLNBOOKING TRPLNBOOKING
             ON TPROJECT.UNIQUEID = TRPLNBOOKING.PROJECTID
     INNER JOIN eio_publish.tenrox_private.TRPLNBOOKINGDETAILS TRPLNBOOKINGDETAILS
             ON TRPLNBOOKINGDETAILS.BOOKINGID = TRPLNBOOKING.UNIQUEID
     INNER JOIN eio_publish.tenrox_private.TRPLNBOOKINGATTRIBUTES TRPLNBOOKINGATTRIBUTES
             ON TRPLNBOOKINGATTRIBUTES.BOOKINGID = TRPLNBOOKING.UNIQUEID
     INNER JOIN eio_publish.tenrox_private.TPROJECTTEAMRESOURCE TPROJECTTEAMRESOURCE
             ON TPROJECTTEAMRESOURCE.PROJECTID = TRPLNBOOKING.PROJECTID
            AND TPROJECTTEAMRESOURCE.RESOURCEID = CASE TRPLNBOOKING.BOOKINGOBJECTTYPE
                                                    WHEN 1 THEN TRPLNBOOKING.USERID
                                                    WHEN 700 THEN TRPLNBOOKING.ROLEID
                                                  END
            AND TPROJECTTEAMRESOURCE.ISROLE = CASE TRPLNBOOKING.BOOKINGOBJECTTYPE
                                                WHEN 700 THEN 1
                                                ELSE 0
                                              END
     LEFT JOIN eio_publish.tenrox_private.TUSER TUSER
                  ON TUSER.UNIQUEID = CASE TPROJECTTEAMRESOURCE.ISROLE
                                        WHEN 0 THEN TPROJECTTEAMRESOURCE.RESOURCEID
                                      END
     LEFT JOIN eio_publish.tenrox_private.TPLANNINGROLE TPLANNINGROLE
                  ON TPLANNINGROLE.UNIQUEID = CASE TPROJECTTEAMRESOURCE.ISROLE
                                                WHEN 1 THEN TPROJECTTEAMRESOURCE.RESOURCEID
                                              END
     LEFT JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_forecast_labor_cost_rates AS FORECAST_LABOR_COST_RATES
                  ON FORECAST_LABOR_COST_RATES.ProjectID = TPROJECT.UNIQUEID
                 AND FORECAST_LABOR_COST_RATES.IsRole = TPROJECTTEAMRESOURCE.ISROLE
                 AND CASE FORECAST_LABOR_COST_RATES.IsRole
                       WHEN 1 THEN FORECAST_LABOR_COST_RATES.RoleID
                       ELSE FORECAST_LABOR_COST_RATES.UserID
                     END = TPROJECTTEAMRESOURCE.RESOURCEID
     LEFT OUTER JOIN (SELECT
                        IFNULL(UNIQUEID, 1) AS LUBaseCurrencyID
                      FROM   eio_publish.tenrox_private.TCURRENCY TCURRENCY
                      WHERE  CURRENCYCODE = 'USD') BaseCUR
     LEFT OUTER JOIN (
               -- Copying setup of @USDCurID value FROM CUST_ADSK_MARGINVARIANCE passed into ADSK_FN_CM_FORECAST_LABOR_COSTS as parameter @OverrideCurID, OR always 1
               SELECT  
                    IFNULL(TCURRENCY.UNIQUEID, 1) AS OVERRIDECURID
               FROM   eio_publish.tenrox_private.TCURRENCY TCURRENCY  
               WHERE  CURRENCYCODE = 'USD'
               ) OVERRIDECURID
     LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.fcurrqexchrate as FXRate
                  ON FXRate.BASECURRENCYID = LUBaseCurrencyID
                 AND FXRate.QUOTECURRENCYID = COALESCE(OVERRIDECURID, TCLIENTINVOICE.CURRENCYID, LUBaseCurrencyID)      -- OVERRIDECURID was not included before, adding now
                 AND TRPLNBOOKINGDETAILS.BOOKEDDATE BETWEEN FXRate.STARTDATE AND FXRate.ENDDATE
     LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.adsk_fn_month_q_ranges_v02 AS Ranges
                  -- ON TRPLNBOOKINGDETAILS.BOOKEDDATE = Ranges.Fnc_CurrentDate
     WHERE           TRPLNBOOKINGDETAILS.BOOKEDSECONDS > 0 
     GROUP           BY
      TRPLNBOOKING.PROJECTID