/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with TRPLNBOOKING as (
       SELECT 
       *
       FROM
       EIO_PUBLISH.TENROX_PRIVATE.TRPLNBOOKING
),
TRPLNBOOKINGATTRIBUTES AS (
   SELECT 
       *
       FROM
      EIO_PUBLISH.TENROX_PRIVATE.TRPLNBOOKINGATTRIBUTES
),

TRPLNBOOKINGDETAILS AS (
       SELECT 
       *
       FROM
      EIO_PUBLISH.TENROX_PRIVATE.TRPLNBOOKINGDETAILS
),
TPROJECT AS (
       SELECT 
       *
       FROM
      EIO_PUBLISH.TENROX_PRIVATE.TPROJECT
),
TTASK AS (
       SELECT 
       *
       FROM
      EIO_PUBLISH.TENROX_PRIVATE.TTASK
)

 SELECT  ROW_NUMBER() OVER (ORDER BY BOOKINGDDATA.Date) AS Resource_Allocation_Unique_Id,
       BOOKINGDDATA.BOOKINGUNIQUEID AS Booking_Unique_Id,
       BOOKINGDDATA.Date AS Resource_Allocation_Date,
CASE WHEN BOOKINGDDATA.BOOKINGTYPE = 1 THEN 1 ELSE 0 END AS Resource_Allocation_Is_Hard_Booking,
CASE WHEN BOOKINGDDATA.BOOKINGTYPE = 1 THEN BOOKEDSEC ELSE 0 END AS Resource_Allocation_Hard_Booking_Hours,
CASE WHEN BOOKINGDDATA.BOOKINGTYPE = 2 THEN BOOKEDSEC ELSE 0 END AS Resource_Allocation_Soft_Booking_Hours,
       BOOKEDSEC AS Resource_Allocation_Total_Booking_Hours,
       BOOKINGDDATA.ROLEID AS Role_Unique_ID,
COALESCE(BOOKINGDDATA.USERID, 0) AS User_Unique_ID,
       BOOKINGDDATA.PROJECTUID AS Project_Unique_ID,
       COALESCE(BOOKINGDDATA.TASKUID, 0) AS Task_Unique_ID,
       BOOKINGDDATA.ISBILLABLE AS Resource_Allocation_Is_Billable,
BOOKINGDDATA.ISUSERBOOKING AS Resource_Allocation_Is_User_Booking

FROM
     (SELECT   SUM(bd.BOOKEDSECONDS) / 3600.00 AS BOOKEDSEC, bd.BOOKEDDATE AS "Date", b.UNIQUEID AS BOOKINGUNIQUEID, b.ROLEID,
                                                    b.USERID, b.BOOKINGTYPE, CASE WHEN b.BOOKINGOBJECTTYPE = 1 THEN 1 ELSE 0 END AS ISUSERBOOKING, b.PROJECTID AS PROJECTUID,
                                                    ba.TASKID AS TASKUID,
                                                    CASE WHEN ba.BILLABLE <> - 1 THEN ba.BILLABLE WHEN ba.BILLABLE = - 1 AND
                                                    ba.TASKID >= 1 THEN t.BILLABLE WHEN ba.BILLABLE = - 1 AND ba.TASKID <= 0 AND
                                                    p.OVERRIDEBILLABLE = 1 THEN p.BILLABLE ELSE 0 END AS ISBILLABLE, CASE WHEN ba.CUSTOMDATE1 <= '1900-01-01' THEN NULL
                                                    ELSE ba.CUSTOMDATE1 END AS CUSTOMDATE1
                          FROM           TRPLNBOOKING b JOIN
                                                   TRPLNBOOKINGATTRIBUTES ba ON ba.BOOKINGID = b.UNIQUEID JOIN
                                                   TRPLNBOOKINGDETAILS bd ON bd.BOOKINGID = b.UNIQUEID JOIN
                                                   TPROJECT p ON p.UNIQUEID = b.PROJECTID LEFT JOIN
                                                   TTASK t ON t.UNIQUEID = ba.TASKID
                          GROUP BY bd.BOOKEDDATE,
                                   b.UNIQUEID,
                                   b.ROLEID,
                                   b.USERID,
                                   b.BOOKINGOBJECTTYPE,
                                   b.BOOKINGTYPE,
                                   b.PROJECTID,
                                   p.BILLABLE,
                                   t.BILLABLE,
                                   p.OVERRIDEBILLABLE,
                                   ba.TASKID,
                                   ba.BILLABLE,
                                   ba.CUSTOMCHECKBOX1,
                                   ba.CUSTOMCHECKBOX2,
                                   ba.CUSTOMCHECKBOX3,
                                   ba.CUSTOMCHECKBOX4,
                                   ba.CUSTOMCHECKBOX5,
                                   ba.CUSTOMCHECKBOX6,
                                   ba.CUSTOMSELECTION1,
                                   ba.CUSTOMSELECTION2,
                                   ba.CUSTOMSELECTION3,
                                   ba.CUSTOMSELECTION4,
                                   ba.CUSTOMSELECTION5,
                                   ba.CUSTOMSELECTION6,
                                   ba.CUSTOMSELECTION7,
                                   CASE WHEN ba.CUSTOMDATE1 <= '1900-01-01' THEN NULL ELSE ba.CUSTOMDATE1 END)
                         AS BOOKINGDDATA