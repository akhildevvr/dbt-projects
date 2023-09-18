{{ config(
    alias='cust_adsk_utilization_hours'
) }}

/* CUST_ADSK_UTILIZATION_HOURS.sql
  @BatchSize     INT = 10000
  , @BatchNumber INT = 0
  , @RangeBegin  DATETIME = '2014-02-01'
  , @SQLScriptVersion = 3
  
1) @RangeEnd = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), -DATEPART(DW, GETDATE()) + 1)
-- This is just getting the date of the start of the week (Sunday) for the current date
Ex. if date = '2022-12-02' (Friday of that week), value returned is '2022-11-27' (Sunday of that same week)
Snowflake is iso week starts Monday. Then -1 day to get the Sunday:
conversion: DATEADD(day, -1, DATE_TRUNC('week', current_date()))

2) DATEADD(MONTH, DATEDIFF(MONTH, 0, @RangeEnd), 0) -> gives the last day of month immediately before the @RangeEnd

3) DATEADD(MONTH, DATEDIFF(MONTH, 0, TSMain.EntryDate), 0)  -> gives the first day of the month

Uses temp table: TMP_CUST_ADSK_UTILIZATION_HOURS  

*/ 
WITH tmp_cust_adsk_utilization_hours AS (
    SELECT
        ROW_NUMBER() 
            OVER ( 
                ORDER BY resource_details.resourceid
                    , resource_details.resourcefullname_rev
                    , TRUNC(tsmain.entrydate, 'month')
                    , project_details.projectcode
                    , project_details.projectname
                    , tsmain.taskname
                    , tsmain.billable
                    , tsmain.utilized
                    , tsmain.entryisapproved
                    , tsmain.taskcode 
                )                                                       AS rownumber
        , resource_details.resourceid                                   AS userid
        , resource_details.resourcefullname_rev                         AS username
        , TRUNC(tsmain.entrydate, 'month')                              AS entrydate
        , DATEADD(day, -1,
                DATEADD(day, -1, DATE_TRUNC('week', CURRENT_DATE())))   AS limitdate
        , SUM(IFNULL(tsmain.totaltime, 0) / 3600.00)                    AS totaltime
        , project_details.projectcode                                   AS projectcode
        , project_details.projectname                                   AS projectname
        , tsmain.taskname                                               AS taskname
        , tsmain.billable                                               AS billable
        , tsmain.utilized                                               AS utilized
        , tsmain.customer_utilized                                      AS customer_utilized
        , tsmain.entryisapproved                                        AS entryisapproved
        , tsmain.taskcode                                               AS taskcode
        , 3                                                             AS sqlscriptversion
  FROM       (SELECT 
                     ttask.projectid                AS projectid
                     , ttimesheetentries.taskuid    AS taskid
                     , ttimesheetentries.useruid    AS userid
                     , ttimesheetentries.entrydate  AS entrydate
                     , ttimesheetentries.totaltime  AS totaltime
                     , ttimesheetentries.uniqueid   AS entryid
                     , ttask.billable               AS billable
                     , ttask.funded                 AS utilized
                     , ttask.custom1                AS customer_utilized
                     , ttimesheetentries.approved   AS entryisapproved
                     , ttask.name                   AS taskname
                     , tworktype.name               AS taskcode
              FROM {{ source('tenrox_private', 'ttask') }} ttask
              INNER JOIN {{ source('tenrox_private', 'ttimesheetentries') }} ttimesheetentries
                ON ttimesheetentries.taskuid = ttask.uniqueid 
              LEFT OUTER JOIN {{ source('tenrox_private', 'tworktype') }} tworktype 
                ON tworktype.uniqueid = ttask.worktypeid
            ) tsmain
  INNER JOIN {{ ref('adsk_cm_project_details_transform') }} AS project_details
    ON project_details.projectid = tsmain.projectid 
  INNER JOIN {{ ref('adsk_cm_resource_details_transform') }} AS resource_details 
    ON resource_details.resourceid = tsmain.userid 
    AND resource_details.isrole = 0
  WHERE tsmain.entrydate >= DATE '2012-09-01' 
    AND tsmain.entrydate < DATEADD(DAY, -1, DATE_TRUNC('week', CURRENT_DATE()))
  GROUP BY 
    resource_details.resourceid
    , resource_details.resourcefullname_rev
    , TRUNC(tsmain.entrydate, 'month')
    , project_details.projectcode
    , project_details.projectname
    , tsmain.taskname
    , tsmain.billable
    , tsmain.utilized
    , tsmain.customer_utilized
    , tsmain.entryisapproved
    , tsmain.taskcode
  ORDER BY
    resource_details.resourceid
    , resource_details.resourcefullname_rev
    , TRUNC(tsmain.entrydate, 'month')
    , project_details.projectcode
    , project_details.projectname
    , tsmain.taskname
    , tsmain.billable
    , tsmain.utilized
    , tsmain.customer_utilized
    , tsmain.entryisapproved
    , tsmain.taskcode
)

SELECT 
     rownumber
     , userid
     , username
     , entrydate
     , limitdate
     , totaltime
     , projectcode
     , projectname
     , taskname
     , billable
     , utilized
     , customer_utilized
     , entryisapproved
     , taskcode
     , 1::BOOLEAN AS wasnewtable
     , sqlscriptversion
FROM tmp_cust_adsk_utilization_hours
     -- WHERE  RowNumber BETWEEN 1 AND 10000
ORDER BY rownumber