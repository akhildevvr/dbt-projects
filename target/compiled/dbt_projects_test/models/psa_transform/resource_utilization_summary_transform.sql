/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with USERPLANNINGROLE as 
(
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TUSERPLANNINGROLE
),
RPLNUSERAVAILABILITY AS 
(
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TRPLNUSERAVAILABILITY
),
RPLNCALENDARDATES AS 
(
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TRPLNCALENDARDATES
),
RPLNBOOKINGDETAILS AS 
(
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TRPLNBOOKINGDETAILS
),
RPLNBOOKING AS
(
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TRPLNBOOKING
),
RPLNBOOKINGATTRIBUTES AS
(
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TRPLNBOOKINGATTRIBUTES
),
PROJECT AS
(
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TPROJECT
),
TASK AS 
(
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TTASK
),
TIMEENTRY AS 
(
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TTIMEENTRY
),
TIMEENTRYRATE AS 
(
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TTIMEENTRYRATE
)

 SELECT        TRPLNUSERAVAILABILITY.UNIQUEID AS Resource_Uilization_Unique_ID,
       TUSERPLANNINGROLE.USERID AS USER_ID,
       TUSERPLANNINGROLE.PLANNINGROLEID AS Role_Unique_ID,
                         CASE WHEN TRPLNUSERAVAILABILITY.AVAILABLEHOURS <= 0 THEN 0 ELSE TRPLNUSERAVAILABILITY.AVAILABLEHOURS / 3600.00 END AS Utilization_Available_Hours,
                         TRPLNUSERAVAILABILITY.CALENDARDATE AS Utilization_Date,
       TRPLNUSERAVAILABILITY.WORKINGHOURS / 3600.00 AS Utilization_Working_Hours,
                         TRPLNUSERAVAILABILITY.OVERLOADHOURS / 3600.00 AS Utilization_Overload_Hours,
       TRPLNUSERAVAILABILITY.OVERHEADHOURS / 3600.00 AS Utilization_Overhead_Hours,
                         TRPLNUSERAVAILABILITY.OVERALLOCATEDHOURS / 3600.00 AS Utilization_Overallocated_Hours,
       TRPLNUSERAVAILABILITY.TOTALWORKINGHOURS / 3600.00 AS Utilization_Total_Working_Hours,
                         TRPLNUSERAVAILABILITY.EXCEPTIONNOTES AS Utilization_Exception_Notes,
       CASE WHEN (TRPLNCALENDARDATES.TOTALWORKINGHOURS - TRPLNUSERAVAILABILITY.TOTALWORKINGHOURS)
                         <= 0 THEN 0 ELSE (TRPLNCALENDARDATES.TOTALWORKINGHOURS - TRPLNUSERAVAILABILITY.TOTALWORKINGHOURS) / 3600.00 END AS Utilization_Non_Working_Hours,
       COALESCE(BOOKINGTOTALS.Total_Booking / 3600.00, 0) AS Utilization_Total_Booking_Hours,
       COALESCE(BOOKINGTOTALS.Billable_Booking_Hours / 3600.00, 0) AS Utilization_Billable_Booking_Hours,
       COALESCE(BOOKINGTOTALS.Billable_Hard_Booking_Hours / 3600.00, 0)
                         AS Utilization_Billable_Hard_Booking_Hours,
       COALESCE(BOOKINGTOTALS.Billable_Soft_Booking_Hours / 3600.00, 0) AS Utilization_Billable_Soft_Booking_Hours,
       COALESCE(BOOKINGTOTALS.Hard_Booking_Hours / 3600.00, 0)
                         AS Utilization_Hard_Booking_Hours,
       COALESCE(BOOKINGTOTALS.Soft_Booking_Hours / 3600.00, 0) AS Utilization_Soft_Booking_Hours,
       COALESCE(BOOKINGTOTALS.Non_Billable_Booking_Hours / 3600.00, 0)
                         AS Utilization_Non_Billable_Booking_Hours,
       COALESCE(BOOKINGTOTALS.Non_Billable_Hard_Booking_Hours / 3600.00, 0) AS Utilization_Non_Billable_Hard_Booking_Hours,
                         COALESCE(BOOKINGTOTALS.Non_Billable_Soft_Booking_Hours / 3600.00, 0) AS Utilization_Non_Billable_Soft_Booking_Hours,
       COALESCE(ACTUALHRS.ACTUAL_BILLABLE_HOURS, 0) AS Utilization_Actual_Billable_Hours,
                         COALESCE(ACTUALHRS.ACTUAL_NON_BILLABLE_HOURS, 0) AS Utilization_Actual_Non_Billable_Hours,
       COALESCE(ACTUALHRS.ACTUAL_BILLING_BASE_CURRENCY, 0) AS Utilization_Actual_Billing_Base_Currency,
                         COALESCE(ACTUALHRS.ACTUAL_COST_BASE_CURRENCY, 0) AS Utilization_Actual_Cost_Base_Currency

FROM           USERPLANNINGROLE as TUSERPLANNINGROLE  inner join
                        RPLNUSERAVAILABILITY as TRPLNUSERAVAILABILITY ON TRPLNUSERAVAILABILITY.USERID = TUSERPLANNINGROLE.USERID AND TUSERPLANNINGROLE.ISPRIMARYROLE = 1 INNER JOIN
                        RPLNCALENDARDATES as TRPLNCALENDARDATES  ON TRPLNCALENDARDATES.UNIQUEID = TRPLNUSERAVAILABILITY.RPLNCALENDARDATEID LEFT OUTER JOIN
                             (SELECT        BOOKINGDATA.USERID, TRPLNBOOKINGDETAILS.BOOKEDDATE, SUM(TRPLNBOOKINGDETAILS.BOOKEDSECONDS) AS Total_Booking,
                                                         SUM(CASE WHEN BOOKINGDATA.IsBillable = 0 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS ELSE 0 END) AS Non_Billable_Booking_Hours,
                                                         SUM(CASE WHEN BOOKINGDATA.IsBillable = 1 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS ELSE 0 END) AS Billable_Booking_Hours,
                                                         SUM(CASE WHEN BOOKINGDATA.BOOKINGTYPE = 1 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS ELSE 0 END) AS Hard_Booking_Hours,
                                                         SUM(CASE WHEN BOOKINGDATA.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS ELSE 0 END) AS Soft_Booking_Hours, SUM(CASE WHEN BOOKINGDATA.IsBillable = 1 AND
                                                         BOOKINGDATA.BOOKINGTYPE = 1 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS ELSE 0 END) AS Billable_Hard_Booking_Hours, SUM(CASE WHEN BOOKINGDATA.IsBillable = 0 AND
                                                         BOOKINGDATA.BOOKINGTYPE = 1 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS ELSE 0 END) AS Non_Billable_Hard_Booking_Hours, SUM(CASE WHEN BOOKINGDATA.IsBillable = 1 AND
                                                         BOOKINGDATA.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS ELSE 0 END) AS Billable_Soft_Booking_Hours, SUM(CASE WHEN BOOKINGDATA.IsBillable = 0 AND
                                                         BOOKINGDATA.BOOKINGTYPE = 2 THEN TRPLNBOOKINGDETAILS.BOOKEDSECONDS ELSE 0 END) AS Non_Billable_Soft_Booking_Hours
                               FROM           RPLNBOOKINGDETAILS as TRPLNBOOKINGDETAILS  INNER JOIN
                                                        RPLNBOOKING as TRPLNBOOKING  ON TRPLNBOOKING.UNIQUEID = TRPLNBOOKINGDETAILS.BOOKINGID INNER JOIN
                                                             (SELECT        TRPLNBOOKING.UNIQUEID AS BOOKINGID, TRPLNBOOKING.USERID, TRPLNBOOKING.BOOKINGTYPE,
                                                                                         CASE WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE <> - 1 THEN TRPLNBOOKINGATTRIBUTES.BILLABLE WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = - 1 AND
                                                                                         TRPLNBOOKINGATTRIBUTES.TASKID >= 1 THEN TTASK.BILLABLE WHEN TRPLNBOOKINGATTRIBUTES.BILLABLE = - 1 AND TRPLNBOOKINGATTRIBUTES.TASKID <= 0 AND
                                                                                         TPROJECT.OVERRIDEBILLABLE = 1 THEN TPROJECT.BILLABLE ELSE 0 END AS IsBillable
                                                               FROM           RPLNBOOKING as TRPLNBOOKING  INNER JOIN
                                                                                        RPLNBOOKINGATTRIBUTES as TRPLNBOOKINGATTRIBUTES  ON TRPLNBOOKINGATTRIBUTES.BOOKINGID = TRPLNBOOKING.UNIQUEID INNER JOIN
                                                                                        PROJECT as TPROJECT  ON TPROJECT.UNIQUEID = TRPLNBOOKING.PROJECTID LEFT OUTER JOIN
                                                                                        TASK as TTASK  ON TTASK.UNIQUEID = TRPLNBOOKINGATTRIBUTES.TASKID) AS BOOKINGDATA ON
                                                         BOOKINGDATA.BOOKINGID = TRPLNBOOKINGDETAILS.BOOKINGID AND TRPLNBOOKING.USERID = BOOKINGDATA.USERID
                               GROUP BY BOOKINGDATA.USERID, TRPLNBOOKINGDETAILS.BOOKEDDATE) AS BOOKINGTOTALS ON BOOKINGTOTALS.USERID = TRPLNUSERAVAILABILITY.USERID AND
                         BOOKINGTOTALS.BOOKEDDATE = TRPLNUSERAVAILABILITY.CALENDARDATE LEFT OUTER JOIN
                             (SELECT        USERID, CURRENTDATE, SUM(ACTUAL_BILLABLE_HOURS) AS ACTUAL_BILLABLE_HOURS, SUM(ACTUAL_NON_BILLABLE_HOURS) AS ACTUAL_NON_BILLABLE_HOURS, SUM(ACTUAL_COST_BASE_CURRENCY)
                                                          AS ACTUAL_COST_BASE_CURRENCY, SUM(ACTUAL_BILLING_BASE_CURRENCY) AS ACTUAL_BILLING_BASE_CURRENCY
                               FROM            (SELECT        TIMEENTRY.USERID, TIMEENTRY.CURRENTDATE, TIMEENTRY.ACTUAL_BILLABLE_HOURS, TIMEENTRY.ACTUAL_NON_BILLABLE_HOURS,
                                                                                   CASE WHEN TIMEENTRY.TEAPPROVED = 1 THEN TIMEENTRYRATE.ACTUAL_COST_BASE_CURRENCY ELSE 0 END AS ACTUAL_COST_BASE_CURRENCY,
                                                                                   CASE WHEN TIMEENTRY.TEAPPROVED = 1 THEN TIMEENTRYRATE.ACTUAL_BILLING_BASE_CURRENCY ELSE 0 END AS ACTUAL_BILLING_BASE_CURRENCY
                                                         FROM            (SELECT        UNIQUEID, USERID, CURRENTDATE, SUM(COALESCE(BILLEDTIMESPAN1, 0) + COALESCE(BILLEDTIMESPAN2, 0) + COALESCE(BILLEDTIMESPAN3, 0)) / 3600.00 AS ACTUAL_BILLABLE_HOURS,
                                                                                                             SUM(COALESCE(TIMESPAN, 0) - (COALESCE(BILLEDTIMESPAN1, 0) + COALESCE(BILLEDTIMESPAN2, 0) + COALESCE(BILLEDTIMESPAN3, 0))) / 3600.00 AS ACTUAL_NON_BILLABLE_HOURS,
                                                                                                             TEAPPROVED
                                                                                   FROM           TIMEENTRY as TTIMEENTRY
                                                                                   GROUP BY UNIQUEID, USERID, CURRENTDATE, TEAPPROVED) AS TIMEENTRY LEFT OUTER JOIN
                                                                                       (SELECT        TIMEENTRYUID, SUM(COALESCE(COSTAMOUNTTOTAL, 0) * COALESCE(COSTEXCHANGERATE, 0)) AS ACTUAL_COST_BASE_CURRENCY, SUM(COALESCE(BILLABLEAMNTTOTAL, 0)
                                                                                                                   * COALESCE(BILLEXCHANGERATE, 0)) AS ACTUAL_BILLING_BASE_CURRENCY
                                                                                         FROM           TIMEENTRYRATE as TTIMEENTRYRATE
                                                                                         GROUP BY TIMEENTRYUID) AS TIMEENTRYRATE ON TIMEENTRY.UNIQUEID = TIMEENTRYRATE.TIMEENTRYUID) AS TIMEENTRY_A
                               GROUP BY USERID, CURRENTDATE) AS ACTUALHRS ON ACTUALHRS.USERID = TRPLNUSERAVAILABILITY.USERID AND ACTUALHRS.CURRENTDATE = TRPLNUSERAVAILABILITY.CALENDARDATE