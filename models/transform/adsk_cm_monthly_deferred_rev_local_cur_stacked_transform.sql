{{ config(
    alias='adsk_cm_monthly_deferred_local_cur_rev_stacked'
) }}


WITH date_range AS (
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

project AS
(
  SELECT
  *
  FROM
  {{ source('tenrox_private','tproject')}}
),
projects AS (  
SELECT
DISTINCT pd.uniqueid AS PROJECTID
, TRUNC(ds.dt,'MONTH') as dt
FROM 
project AS  pd
LEFT OUTER JOIN date_sequence ds
  ),

fcalperiod AS
(
  SELECT
  *
  FROM
  {{ source('tenrox_private','tfcalperiod')}}
),

adsk_cm_monthly_expect_labor_local_cur_rev AS
(
    SELECT
    *
    FROM
    {{ ref('adsk_cm_monthly_expect_labor_rev_local_cur_transform')}}
),

adsk_cm_monthly_chrg_rev_local_cur AS
(
  SELECT
    *
  FROM
  {{ ref('adsk_cm_monthly_chrg_rev_local_cur_transform')}}
),
adsk_cm_monthly_rec_local_cur_rev AS
(
  SELECT
    *
  FROM
  {{ ref('adsk_cm_monthly_rec_rev_local_cur_transform')}}
),

  
deffered_rev as

(
    SELECT 
       IFNULL(calitems.projectid, monthly_rec_rev.projectid)                                                                                      AS projectid
       , IFNULL(calitems.monthtoinclude, monthly_rec_rev.monthrecognized)                                                                          AS revenuemonth
       , IFNULL(monthly_chrg_rev.monthschrgrev_allbillable, 0.00)                                                                                  AS chrgrevenue
       , IFNULL(monthly_expect_labor_rev.expectedlaborrevenue, 0.00)                                                                               AS expectedlaborrevenue
       , IFNULL(monthly_chrg_rev.monthschrgrev_allbillable, 0.00)
          + IFNULL(monthly_expect_labor_rev.expectedlaborrevenue, 0.00)                                                                            AS totalexpectedrevenue
       , IFNULL(monthly_rec_rev.recognizedrevenue, 0.00)                                                                                           AS recognizedrevenue
       , IFNULL(monthly_rec_rev.recognizedrevenue, 0.00) - (IFNULL(monthly_chrg_rev.monthschrgrev_allbillable, 0.00)
          + IFNULL(monthly_expect_labor_rev.expectedlaborrevenue, 0.00))                                                                           AS deferredrevenue
       , SUM((IFNULL(monthly_chrg_rev.monthschrgrev_allbillable, 0.00) + IFNULL(monthly_expect_labor_rev.expectedlaborrevenue, 0.00))
                     - IFNULL(monthly_rec_rev.recognizedrevenue, 0.00))
             OVER ( PARTITION BY IFNULL(calitems.projectid, monthly_rec_rev.projectid))                                                            AS totaldeferredrevenue
       , 9                                                                                                                                         AS sqlversion_monthly_deferred_rev
    FROM            (SELECT
                      tproject.uniqueid AS projectid
                      , tfcalperiod.startdate AS monthtoinclude
                    FROM fcalperiod AS tfcalperiod
                        INNER JOIN project AS tproject
                                ON tfcalperiod.startdate >= trunc(tproject.startdate, 'MONTH') 
                                AND tfcalperiod.startdate <= CASE 
                                                                WHEN tproject.enddate > dateadd('MONTH', 1, TRUNC(CURRENT_DATE (), 'MONTH')) 
                                                                    THEN DATEADD('MONTH', 1, TRUNC(CURRENT_DATE (), 'MONTH')) 
                                                                ELSE tproject.enddate 
                                                            END 
                                AND tfcalperiod.periodtype = 'M' 
                                AND tfcalperiod.calid = 4) calitems
    FULL OUTER JOIN adsk_cm_monthly_expect_labor_local_cur_rev AS monthly_expect_labor_rev
        ON monthly_expect_labor_rev.projectid = calitems.projectid 
        AND monthly_expect_labor_rev.monthofexpectedlaborrev = calitems.monthtoinclude 
    FULL OUTER JOIN adsk_cm_monthly_chrg_rev_local_cur AS monthly_chrg_rev 
        ON monthly_chrg_rev.projectid = calitems.projectid 
        AND monthly_chrg_rev.monthofchrgrev < TRUNC(CURRENT_DATE (), 'MONTH') 
        AND monthly_chrg_rev.monthofchrgrev = calitems.monthtoinclude
    FULL OUTER JOIN (SELECT
                      projectid
                      , monthrecognized
                      , recognizedrevenue
                    FROM adsk_cm_monthly_rec_local_cur_rev
                    WHERE  monthrecognized IS NOT NULL) monthly_rec_rev
                ON monthly_rec_rev.projectid = calitems.projectid
               AND monthly_rec_rev.monthrecognized = calitems.monthtoinclude
    WHERE           COALESCE(monthly_expect_labor_rev.projectid, monthly_chrg_rev.projectid, monthly_rec_rev.projectid) IS NOT NULL
   and  IFNULL(calitems.projectid, monthly_rec_rev.projectid) 
),

deffered_rev_sum as (
SELECT 
p.projectid
,CASE
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   p.dt)||'-02-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-05-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-08-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-11-01')
              ELSE TO_DATE(EXTRACT(YEAR FROM p.dt) - 1 ||'-11-01')
            END                                                                                                             AS dt
,sum(IFNULL(chrgrevenue,0.00)) AS chrgrevenue
,sum(IFNULL(expectedlaborrevenue,0.00)) AS expectedlaborrevenue
,sum(IFNULL(totalexpectedrevenue,0.00)) AS totalexpectedrevenue
,sum(IFNULL(recognizedrevenue,0.00)) AS recognizedrevenue
,sum(IFNULL(deferredrevenue,0.00)) AS deferredrevenue
--,IFNULL(totaldeferredrevenue,0.00) AS totaldeferredrevenue

FROM projects p 
LEFT JOIN deffered_rev r ON p.projectid = r.projectid AND DATE(p.dt) = DATE(r.revenuemonth)


group by
p.projectid
,CASE
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   p.dt)||'-02-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-05-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-08-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-11-01')
              ELSE TO_DATE(EXTRACT(YEAR FROM p.dt) - 1 ||'-11-01')
            END
--,totaldeferredrevenue
  
  ),
  
 deffered_rev_final
 AS
 (
  
 SELECT *,
 SUM((IFNULL(chrgrevenue, 0.00) + IFNULL(expectedlaborrevenue, 0.00))
                     - IFNULL(recognizedrevenue, 0.00))
             OVER ( PARTITION BY projectid)                                                            AS totaldeferredrevenue
 FROM deffered_rev_sum
   
   )
  
SELECT 
*
FROM 
deffered_rev_final