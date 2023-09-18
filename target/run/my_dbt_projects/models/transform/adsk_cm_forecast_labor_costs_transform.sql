
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_cm_forecast_labor_costs
  
   as (
    
/* ADSK_FN_CM_FORECAST_LABOR_COSTS.sql
  @OverrideCurID   INT = NULL
  , @RangeBegin    DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL
  , @Placeholder05 INT = NULL
Use as pattern for FCURRQEXCHRATE join
*/
        SELECT 
            trplnbooking.projectid AS projectid
            , IFNULL(
                SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_future
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                AND trplnbookingdetails.bookeddate < fnc_nextmonthbegins THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_currentmonth
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_futureqtrs
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_entirecurrentqtr
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_remaininginqtr
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_plus1qtr
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_plus2qtr
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_plus3qtr
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_additionalqtrs
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
                AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_customrange
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_future
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                        AND trplnbookingdetails.bookeddate < fnc_nextmonthbegins
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_currentmonth
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_futureqtrs
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                        AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_entirecurrentqtr
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                        AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_remaininginqtr
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                        AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_plus1qtr
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
                        AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_plus2qtr
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
                        AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_plus3qtr
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_additionalqtrs
             , IFNULL(SUM(CASE WHEN trplnbooking.bookingobjecttype = 700
                AND trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
                AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_customrange
            -- All above include both hard-booked and soft-booked. Below includes only soft-booked hours.
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_future_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                AND trplnbookingdetails.bookeddate < fnc_nextmonthbegins AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_currentmonth_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_futureqtrs_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_entirecurrentqtr_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_remaininginqtr_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_plus1qtr_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_plus2qtr_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_plus3qtr_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_additionalqtrs_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
                AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_customrange_soft
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                        AND trplnbooking.bookingtype = 2 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                        * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_future_soft
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                        AND trplnbookingdetails.bookeddate < fnc_nextmonthbegins AND trplnbooking.bookingtype = 2
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_currentmonth_soft
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                        AND trplnbooking.bookingtype = 2 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                        * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_futureqtrs_soft
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                        AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_entirecurrentqtr_soft
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                        AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_remaininginqtr_soft
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                        AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins AND trplnbooking.bookingtype = 2
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_plus1qtr_soft
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
                        AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins AND trplnbooking.bookingtype = 2
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_plus2qtr_soft
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
                        AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins AND trplnbooking.bookingtype = 2
                             THEN (trplnbookingdetails.bookedseconds / 3600.00) * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_plus3qtr_soft
             , IFNULL(
                SUM(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins
                        AND trplnbooking.bookingtype = 2 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                        * forecast_labor_cost_rates.forecastcostrate
                         ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_additionalqtrs_soft
             , IFNULL(SUM(CASE WHEN trplnbooking.bookingobjecttype = 700
                AND trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
                AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend AND trplnbooking.bookingtype = 2
                                   THEN (trplnbookingdetails.bookedseconds / 3600.00)
                    * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_gen_customrange_soft
            /* Soft-booked Billable costs */
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins AND trplnbooking.bookingtype = 2
                AND trplnbookingattributes.billable = 1 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_billable_future_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                AND trplnbookingdetails.bookeddate < fnc_nextmonthbegins AND trplnbooking.bookingtype = 2
                AND trplnbookingattributes.billable = 1 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_billable_currentmonth_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                AND trplnbookingattributes.billable = 1 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_billable_futureqtrs_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentqtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                AND trplnbookingattributes.billable = 1 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_billable_entirecurrentqtr_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_currentmonthbegins
                AND trplnbookingdetails.bookeddate < fnc_plus1qtrbegins AND trplnbooking.bookingtype = 2
                AND trplnbookingattributes.billable = 1 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_billable_remaininginqtr_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus1qtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus2qtrbegins AND trplnbooking.bookingtype = 2
                AND trplnbookingattributes.billable = 1 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_billable_plus1qtr_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus2qtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus3qtrbegins AND trplnbooking.bookingtype = 2
                AND trplnbookingattributes.billable = 1 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_billable_plus2qtr_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus3qtrbegins
                AND trplnbookingdetails.bookeddate < fnc_plus4qtrbegins AND trplnbooking.bookingtype = 2
                AND trplnbookingattributes.billable = 1 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_billable_plus3qtr_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_plus4qtrbegins AND trplnbooking.bookingtype = 2
                AND trplnbookingattributes.billable = 1 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_billable_additionalqtrs_soft
             , IFNULL(SUM(CASE WHEN trplnbookingdetails.bookeddate >= fnc_fcst_customrangebegin
                AND trplnbookingdetails.bookeddate < fnc_fcst_customrangeend AND trplnbooking.bookingtype = 2
                AND trplnbookingattributes.billable = 1 THEN (trplnbookingdetails.bookedseconds / 3600.00)
                * forecast_labor_cost_rates.forecastcostrate
                               ELSE 0.00 END * fxrate.rate), 0.00) AS fcstcostlabor_billable_customrange_soft
             , 12 AS sqlversion_forecast_labor_costs
        FROM eio_publish.tenrox_private.tproject tproject
        INNER JOIN eio_publish.tenrox_private.tclientinvoice tclientinvoice
            ON tclientinvoice.clientid = tproject.clientid 
        INNER JOIN eio_publish.tenrox_private.trplnbooking trplnbooking 
            ON tproject.uniqueid = trplnbooking.projectid
        INNER JOIN eio_publish.tenrox_private.trplnbookingdetails trplnbookingdetails 
            ON trplnbookingdetails.bookingid = trplnbooking.uniqueid 
        INNER JOIN eio_publish.tenrox_private.trplnbookingattributes trplnbookingattributes 
            ON trplnbookingattributes.bookingid = trplnbooking.uniqueid
        INNER JOIN eio_publish.tenrox_private.tprojectteamresource tprojectteamresource 
            ON tprojectteamresource.projectid = trplnbooking.projectid 
            AND tprojectteamresource.resourceid = CASE trplnbooking.bookingobjecttype WHEN 1 THEN trplnbooking.userid 
                                                                                        WHEN 700 THEN trplnbooking.roleid END
            AND tprojectteamresource.isrole = CASE trplnbooking.bookingobjecttype WHEN 700 THEN 1 ELSE 0 END
        LEFT JOIN
            eio_publish.tenrox_private.tuser tuser
            ON tuser.uniqueid = CASE tprojectteamresource.isrole WHEN 0 THEN tprojectteamresource.resourceid END
        LEFT JOIN eio_publish.tenrox_private.tplanningrole tplanningrole
            ON tplanningrole.uniqueid = CASE tprojectteamresource.isrole
                                            WHEN 1 THEN tprojectteamresource.resourceid END
        LEFT JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_cm_forecast_labor_cost_rates
            AS forecast_labor_cost_rates
            ON forecast_labor_cost_rates.projectid = tproject.uniqueid
            AND forecast_labor_cost_rates.isrole = tprojectteamresource.isrole
            AND CASE forecast_labor_cost_rates.isrole
                WHEN 1
                THEN forecast_labor_cost_rates.roleid
                ELSE forecast_labor_cost_rates.userid END = tprojectteamresource.resourceid
        LEFT OUTER JOIN
            (
                SELECT IFNULL(uniqueid, 1) AS lubasecurrencyid
                FROM eio_publish.tenrox_private.tcurrency tcurrency
                WHERE currencycode = 'USD'
            ) basecur
        LEFT OUTER JOIN
            (
                -- Copying setup of @USDCurID value FROM CUST_ADSK_MARGINVARIANCE
                -- passed into adsk_cm_forecast_labor_costs AS parameter
                -- @OverrideCurID, OR always 1
                SELECT IFNULL(tcurrency.uniqueid, 1) AS overridecurid
                FROM eio_publish.tenrox_private.tcurrency tcurrency
                WHERE currencycode = 'USD'
            ) overridecurid
        LEFT OUTER JOIN
            EIO_INGEST.TENROX_TRANSFORM.fcurrqexchrate AS fxrate
            ON fxrate.basecurrencyid = lubasecurrencyid
            AND fxrate.quotecurrencyid
            = COALESCE(overridecurid, tclientinvoice.currencyid, lubasecurrencyid)  -- OVERRIDECURID was not included before, adding now
            AND trplnbookingdetails.bookeddate
            BETWEEN fxrate.startdate AND fxrate.enddate
        LEFT OUTER JOIN EIO_INGEST.TENROX_TRANSFORM.adsk_month_q_ranges_v02 AS ranges
        -- ON TRPLNBOOKINGDETAILS.BOOKEDDATE = Ranges.Fnc_CurrentDate
        WHERE trplnbookingdetails.bookedseconds > 0
        GROUP BY trplnbooking.projectid
  );

