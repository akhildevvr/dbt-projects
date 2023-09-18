
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_cm_labor_hrs_v02_stacked
  
   as (
    




 WITH 
timesheetentries AS
(
  SELECT
  *
  FROM
  eio_publish.tenrox_private.ttimesheetentries
),
task AS
(
  SELECT
  *
  FROM
  eio_publish.tenrox_private.ttask
),
adsk_month_q_ranges_v02 AS
(
  SELECT
  *
  FROM
  EIO_INGEST.TENROX_TRANSFORM.adsk_month_q_ranges_v02
),

rplnbooking AS
(
  SELECT
  *
  FROM
  eio_publish.tenrox_private.trplnbooking

),
rplnbookingdetails AS
(
  SELECT
  *
  FROM
  eio_publish.tenrox_private.trplnbookingdetails

),

rplnbookingattributes AS
(
  SELECT
  *
  FROM
  eio_publish.tenrox_private.trplnbookingattributes

),

projectteamresource AS
(
  SELECT
  *
  FROM
  eio_publish.tenrox_private.tprojectteamresource

),
project AS
(
  SELECT
  *
  FROM
  eio_publish.tenrox_private.tproject

),
projectcustfld AS
(
  SELECT
  *
  FROM
  eio_publish.tenrox_private.tprojectcustfld

),
custlst AS
(
  SELECT
  *
  FROM
  eio_publish.tenrox_private.tcustlst

),
custlstdesc AS
(
  SELECT
  *
  FROM
  eio_publish.tenrox_private.tcustlstdesc

),

adsk_cm_labor_hrs_v02 AS
(
  SELECT
  *
  FROM
  EIO_INGEST.TENROX_TRANSFORM.adsk_cm_labor_hrs_v02
),

combined as (
    SELECT
            ttask.projectid AS projectid
            ,ttimesheetentries.entrydate                as dt
           -- ,trunc(to_date(ttimesheetentries.entrydate),'MONTH') AS entrydate

            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1 THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.billable = 1 THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_unapp
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 0 
                                    AND ttimesheetentries.funded = 0 THEN totaltime
                                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_nonbill
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 1 AND ttimesheetentries.funded = 1 THEN totaltime
                ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized
            , SUM(IFNULL(CASE WHEN ttimesheetentries.approved = 0 AND ttimesheetentries.funded = 1 THEN totaltime
                    ELSE NULL END, 0.00)) / 3600.00 AS hrsact_utilized_unapp
            , 0.00 AS hrsfcst_all
            , 0.00 AS hrsfcst_billable
            , 0.00 AS hrsfcst_gen
            , 0.00 AS hrsfcst_soft
            , 0.00 AS hrsfcst_billable_soft
            , 0.00 AS hrsfcst_gen_soft
            , 0.00 AS hrsfcst_nonbill_gen_soft
       
            , MAX(fnc_hist_customrangebegin) AS customrangebegin
            , MAX(fnc_hist_customrangeend) AS customrangeend
        FROM timesheetentries AS ttimesheetentries 
        INNER JOIN task AS  ttask
            ON ttimesheetentries.TASKUID = ttask.uniqueid 
        --LEFT OUTER JOIN quarter_dates qd
        LEFT OUTER JOIN adsk_month_q_ranges_v02 AS ranges
        
        --where ttimesheetentries.approved = 1 AND ttimesheetentries.billable = 1
        GROUP BY 
        ttask.projectid
        , ttimesheetentries.entrydate
    UNION ALL
    
    SELECT
       trplnbooking.projectid                                            AS projectid
       ,trplnbookingdetails.bookeddate                                   AS dt
       --,trunc(trplnbookingdetails.bookeddate, 'MONTH')                   AS bookeddate
        , 0.00 AS  hrsact
        , 0.00 AS hrsact_unapp
        , 0.00 AS hrsact_nonbill
        , 0.00 AS hrsact_utilized
        , 0.00 AS hrsact_utilized_unapp
        , SUM(IFNULL(trplnbookingdetails.bookedseconds, 0.00)) / 3600.00 AS hrsfcst_all
     
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable
       
        , SUM(IFNULL(CASE WHEN trplnbooking.bookingobjecttype = 700 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_gen
       
       -- Start Soft Bookings Only section
        , SUM(IFNULL(CASE WHEN trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_soft
  
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_billable_soft
    

        , SUM(IFNULL(CASE WHEN trplnbooking.bookingobjecttype = 700 AND trplnbooking.bookingtype = 2
                              THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_gen_soft
    
        , SUM(IFNULL(CASE WHEN trplnbookingattributes.billable = 1 AND trplnbooking.bookingobjecttype = 700
           AND trplnbooking.bookingtype = 2 THEN trplnbookingdetails.bookedseconds
                          ELSE 0.00 END, 0.00)) / 3600.00                AS hrsfcst_nonbill_gen_soft
      
       -- End non-billable Generic bookings section
        , MAX(fnc_fcst_customrangebegin)                                 AS customrangebegin
        , MAX(fnc_fcst_customrangeend)                                   AS customrangeend
    FROM rplnbooking AS trplnbooking
    INNER JOIN rplnbookingdetails AS  trplnbookingdetails ON trplnbookingdetails.bookingid = trplnbooking.uniqueid 
    INNER JOIN rplnbookingattributes AS trplnbookingattributes ON trplnbookingattributes.bookingid = trplnbooking.uniqueid 
    INNER JOIN projectteamresource AS tprojectteamresource ON tprojectteamresource.projectid = trplnbooking.projectid 
            AND tprojectteamresource.resourceid = CASE trplnbooking.bookingobjecttype 
                                                    WHEN 1 THEN trplnbooking.userid 
                                                    WHEN 700 THEN trplnbooking.roleid 
                                                END 
            AND tprojectteamresource.isrole = CASE trplnbooking.bookingobjecttype 
                                                    WHEN 1 THEN 0
                                                    WHEN 700 THEN 1
                                                END
    LEFT OUTER JOIN adsk_month_q_ranges_v02 AS ranges -- ON Ranges.FNC_CURRENTDATE = TRPLNBOOKINGDETAILS.BOOKEDDATE
    WHERE trplnbookingdetails.bookedseconds > 0
    GROUP BY 
        trplnbooking.projectid,trplnbookingdetails.bookeddate
      ),
    parent_child_key as (
    
    SELECT
    CASE
           WHEN lower(LSTDESC_16.VALUE) in ( 'is parent' ) THEN
               cast(tproject.uniqueid as string)
           WHEN lower(LSTDESC_16.VALUE) IN ( 'is master', 'is child' ) THEN
               CONCAT(CAST(tproject.parentid AS STRING))
           ELSE
               CAST(tproject.uniqueid AS STRING)
       END                                         AS parent_child_key
    ,dt
    , SUM(hrsact) as hrsact
    , SUM(hrsact_unapp) as hrsact_unapp
    , SUM(hrsact_nonbill) as hrsact_nonbill
    , SUM(hrsact_utilized) as hrsact_utilized
    , SUM(hrsact_utilized_unapp) as hrsact_utilized_unapp
    , SUM(hrsfcst_all) as hrsfcst_all
    , SUM(hrsfcst_billable) as hrsfcst_billable
    , SUM(hrsfcst_gen) as hrsfcst_gen
    , SUM(hrsfcst_soft) as hrsfcst_soft
    , SUM(hrsfcst_billable_soft) as hrsfcst_billable_soft
    , SUM(hrsfcst_gen_soft) as hrsfcst_gen_soft
    , SUM(hrsfcst_nonbill_gen_soft) as hrsfcst_nonbill_gen_soft
    FROM 
    combined c
        LEFT JOIN project AS  tproject on c.projectid = tproject.uniqueid
        LEFT JOIN projectcustfld  a On a.PROJECTID = tproject.uniqueid
        LEFT JOIN custlst AS LST_16  ON a.ADSK_MasterAgreement_ProjectType = LST_16.UNIQUEID 
        LEFT JOIN custlstdesc AS LSTDESC_16  ON LST_16.UNIQUEID = LSTDESC_16.CUSTLSTID AND LSTDESC_16.LANGUAGE = 0
where LSTDESC_16.VALUE in ('IS Parent','IS Child')
   GROUP BY
    parent_child_key
    ,dt
   ),
    
adsk_cm_labor_hrs_v02_stacked as (   
    
SELECT 
   CAST(c.projectid AS STRING) AS projectid
    ,  dt
    ,  hrsact
    ,  hrsact_unapp
    ,  hrsact_nonbill
    ,  hrsact_utilized
    ,  hrsact_utilized_unapp
    ,  hrsfcst_all
    ,  hrsfcst_billable
    ,  hrsfcst_gen
    ,  hrsfcst_soft
    ,  hrsfcst_billable_soft
    ,  hrsfcst_gen_soft
    ,  hrsfcst_nonbill_gen_soft
    FROM combined c
    LEFT JOIN project  tproject on c.projectid = tproject.uniqueid
    LEFT JOIN projectcustfld  a On a.PROJECTID = tproject.uniqueid
    LEFT JOIN custlst AS LST_16  ON a.ADSK_MasterAgreement_ProjectType = LST_16.UNIQUEID 
    LEFT JOIN custlstdesc AS LSTDESC_16  ON LST_16.UNIQUEID = LSTDESC_16.CUSTLSTID AND LSTDESC_16.LANGUAGE = 0
    where LSTDESC_16.VALUE not in ('IS Parent')
 union all
    
  SELECT
    parent_child_key as projectid
    ,  dt
    ,  hrsact
    ,  hrsact_unapp
    ,  hrsact_nonbill
    ,  hrsact_utilized
    ,  hrsact_utilized_unapp
    ,  hrsfcst_all
    ,  hrsfcst_billable
    ,  hrsfcst_gen
    ,  hrsfcst_soft
    ,  hrsfcst_billable_soft
    ,  hrsfcst_gen_soft
    ,  hrsfcst_nonbill_gen_soft
   FROM
   parent_child_key),
   


date_range AS (
  SELECT YEAR(DATEADD(YEAR, -10, CURRENT_DATE())) || '-02-01' AS start_date,
         DATEADD(YEAR, 2, CURRENT_DATE()) AS end_date,
        DATEDIFF(DAY, start_date, end_date) + 1   AS rng
),
date_sequence AS (
SELECT DATEADD(DAY, seq4(), start_date) AS dt
FROM date_range,
     TABLE(GENERATOR(ROWCOUNT => 5000)) 
ORDER BY dt
  ),
projects AS (  
SELECT
DISTINCT pd.PROJECTID
, ds.dt
FROM 
EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_details   pd
LEFT OUTER JOIN date_sequence ds
  ),
adsk_cm_labor_hrs_v02_stacked_final AS (
SELECT 
      p.projectid
    ,CASE
                  WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   p.dt)||'-02-01')
                  WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-05-01')
                  WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-08-01')
                  WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-11-01')
                  ELSE TO_DATE(EXTRACT(YEAR FROM p.dt) - 1 ||'-11-01')
                END AS dt
    ,Sum(IFNULL(hrsact,0.00)) as hrsact_all
    ,sum(IFNULL(hrsfcst_billable,0.00)) as hrsfcst_billable_all
    ,sum(IFNULL(hrsfcst_billable_soft,0.00)) as hrsfcst_billable_soft_all
    ,SUM(IFNULL(CASE WHEN p.dt <= (DATE_TRUNC('W', CURRENT_DATE())-1) THEN hrsact
    ELSE hrsfcst_billable
    END,0.00)) AS HRS
    ,SUM( IFNULL(CASE WHEN p.dt < (DATE_TRUNC('W', CURRENT_DATE())-1) 
                                        THEN hrsact
    ELSE 0.00
    END,0.00)) AS HRS_ACTUAL
    ,SUM( IFNULL(CASE WHEN p.dt >= (DATE_TRUNC('W', CURRENT_DATE())-1) 
                                        THEN hrsfcst_billable
    ELSE 0.00
    END,0.00)) AS HRS_FCST_BILLABLE
    ,SUM( IFNULL(CASE WHEN p.dt >= (DATE_TRUNC('W', CURRENT_DATE())-1) 
                                        THEN hrsfcst_billable_soft
    ELSE 0.00
    END,0.00)) AS HRS_FCST_BILLABLE_SOFT
    ,SUM( IFNULL(CASE WHEN p.dt >= (DATE_TRUNC('W', CURRENT_DATE())-1)  AND p.dt < fnc_plus1qtrbegins
                                        THEN hrsfcst_billable
    ELSE 0.00
    END,0.00)) AS HRS_FCST_BILLABLE_REMAININGINQTR
      ,SUM( IFNULL(CASE WHEN p.dt >= (DATE_TRUNC('W', CURRENT_DATE())-1)  AND p.dt < fnc_plus1qtrbegins
                                        THEN hrsfcst_billable_soft
    ELSE 0.00
    END,0.00)) AS HRS_FCST_BILLABLE_REMAININGINQTR_SOFT
    
 FROM projects p
 LEFT JOIN adsk_cm_labor_hrs_v02_stacked l ON p.projectid = l.projectid and p.dt = l.dt
 LEFT OUTER JOIN adsk_month_q_ranges_v02 AS ranges
 GROUP BY
 p.projectid
 ,CASE
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   p.dt)||'-02-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-05-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-08-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-11-01')
              ELSE TO_DATE(EXTRACT(YEAR FROM p.dt) - 1 ||'-11-01')
            END)

SELECT
lh.*
, SUM(CASE WHEN dt <= TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1
                                                  THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                              ELSE YEAR(CURRENT_DATE()) END) || '-'
                                      || CASE WHEN MONTH(CURRENT_DATE()) IN (2, 3, 4) THEN '02-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (5, 6, 7) THEN '05-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (8, 9, 10) THEN '08-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (11, 12, 1) THEN '11-01'
                     ELSE NULL END)  THEN HRS_ACTUAL
      ELSE 0.00 END) OVER (PARTITION BY lh.projectid order by dt) AS hrsact_past_currentqtr
, SUM(CASE WHEN dt >= TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1
                                                  THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                              ELSE YEAR(CURRENT_DATE()) END) || '-'
                                      || CASE WHEN MONTH(CURRENT_DATE()) IN (2, 3, 4) THEN '02-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (5, 6, 7) THEN '05-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (8, 9, 10) THEN '08-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (11, 12, 1) THEN '11-01'
                     ELSE NULL END)  THEN HRS_FCST_BILLABLE
      ELSE 0.00 END) OVER (PARTITION BY lh.projectid order by dt) AS hrsfcst_future
,NULLIF(laborhrs.hrs_billable_eac,0.00) as hrs_billable_eac
FROM 
adsk_cm_labor_hrs_v02_stacked_final lh
LEFT JOIN adsk_cm_labor_hrs_v02 as laborhrs
ON laborhrs.projectid = lh.projectid
  );

