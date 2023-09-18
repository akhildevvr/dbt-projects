
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_month_q_ranges_v02
  
   as (
    
/* adsk_month_q_ranges_v02
  @RangeBegin      DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL      -> only @CutoverDate is specified (not null)

Unused vars in adsk_month_q_ranges_v02
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL

 DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) is only getting the 1st day of the month and can be replaced with TRUNC(CURRENT_DATE(), 'MONTH')
  
*/           
WITH month_q_ranges AS (
   SELECT 
      CURRENT_DATE()                                                       AS fnc_currentdate
      , DATE_TRUNC('W', CURRENT_DATE())-1                                  AS fnc_currentweekbegins
      , TRUNC(CURRENT_DATE(), 'month')                                     AS fnc_currentmonthbegins
      , DATEADD(month, 1, TRUNC(CURRENT_DATE(), 'MONTH'))                  AS fnc_nextmonthbegins
                   /* Define Current Quarter Begins to be used in other calculations */
                    , TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1
                                                  THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                              ELSE YEAR(CURRENT_DATE()) END) || '-'
                                      || CASE WHEN MONTH(CURRENT_DATE()) IN (2, 3, 4) THEN '02-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (5, 6, 7) THEN '05-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (8, 9, 10) THEN '08-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (11, 12, 1) THEN '11-01'
                     ELSE NULL END)                                         AS fnc_currentqtrbegins
      , DATEADD(month, -3, fnc_currentqtrbegins)                             AS fnc_minus1qtrbegins
      , DATEADD(month, -6, fnc_currentqtrbegins)                             AS fnc_minus2qtrbegins
      , DATEADD(month, -9, fnc_currentqtrbegins)                             AS fnc_minus3qtrbegins
      , DATEADD(month, -12, fnc_currentqtrbegins)                            AS fnc_minus4qtrbegins
      , DATEADD(month, 1, fnc_currentqtrbegins)                              AS fnc_currentqtrm2begins
      , DATEADD(month, 2, fnc_currentqtrbegins)                              AS fnc_currentqtrm3begins
      , DATEADD(month, 3, fnc_currentqtrbegins)                              AS fnc_plus1qtrbegins
      , DATEADD(month, 6, fnc_currentqtrbegins)                              AS fnc_plus2qtrbegins
      , DATEADD(month, 9, fnc_currentqtrbegins)                              AS fnc_plus3qtrbegins
      , DATEADD(month, 12, fnc_currentqtrbegins)                             AS fnc_plus4qtrbegins
      , DATEADD(month, 15, fnc_currentqtrbegins)                             AS fnc_plus5qtrbegins
      , DATEADD(month, 18, fnc_currentqtrbegins)                             AS fnc_plus6qtrbegins
      , 'FY' || CASE WHEN MONTH(fnc_currentqtrbegins) = 1
                                       THEN RIGHT(TO_VARCHAR(YEAR(fnc_currentqtrbegins)), 2)
                                   ELSE RIGHT(TO_VARCHAR(YEAR(DATEADD(year, 1, fnc_currentqtrbegins))), 2) END
                  || ' ' || CASE WHEN MONTH(fnc_currentqtrbegins) IN (2, 3, 4) THEN 'Q1'
                                 WHEN MONTH(fnc_currentqtrbegins) IN (5, 6, 7) THEN 'Q2'
                                 WHEN MONTH(fnc_currentqtrbegins) IN (8, 9, 10) THEN 'Q3'
                                 WHEN MONTH(fnc_currentqtrbegins) IN (11, 12, 1) THEN 'Q4'
                     ELSE '' 
           END                                                              AS fnc_currentqtrtitle
      , 'FY' || CASE WHEN MONTH(fnc_minus1qtrbegins) = 1
                                       THEN RIGHT(TO_VARCHAR(YEAR(fnc_minus1qtrbegins)), 2)
                                   ELSE RIGHT(TO_VARCHAR(YEAR(DATEADD(year, 1, fnc_minus1qtrbegins))), 2) END
                  || ' ' || CASE WHEN MONTH(fnc_minus1qtrbegins) IN (2, 3, 4) THEN 'Q1'
                                 WHEN MONTH(fnc_minus1qtrbegins) IN (5, 6, 7) THEN 'Q2'
                                 WHEN MONTH(fnc_minus1qtrbegins) IN (8, 9, 10) THEN 'Q3'
                                 WHEN MONTH(fnc_minus1qtrbegins) IN (11, 12, 1) THEN 'Q4'
                                 ELSE '' 
          END                                                              AS fnc_minus1qtrtitle
      , 'FY' || CASE WHEN MONTH(fnc_minus2qtrbegins) = 1
                                       THEN RIGHT(TO_VARCHAR(YEAR(fnc_minus2qtrbegins)), 2)
                                   ELSE RIGHT(TO_VARCHAR(YEAR(DATEADD(year, 1, fnc_minus2qtrbegins))), 2) END
                            || ' ' || CASE WHEN MONTH(fnc_minus2qtrbegins) IN (2, 3, 4) THEN 'Q1'
                                           WHEN MONTH(fnc_minus2qtrbegins) IN (5, 6, 7) THEN 'Q2'
                                           WHEN MONTH(fnc_minus2qtrbegins) IN (8, 9, 10) THEN 'Q3'
                                           WHEN MONTH(fnc_minus2qtrbegins) IN (11, 12, 1) THEN 'Q4'
                                           ELSE '' 
           END                                                              AS fnc_minus2qtrtitle
      , 'FY' || CASE WHEN MONTH(fnc_minus3qtrbegins) = 1
                                       THEN RIGHT(TO_VARCHAR(YEAR(fnc_minus3qtrbegins)), 2)
                                   ELSE RIGHT(TO_VARCHAR(YEAR(DATEADD(year, 1, fnc_minus3qtrbegins))), 2) END
                            || ' ' || CASE WHEN MONTH(fnc_minus3qtrbegins) IN (2, 3, 4) THEN 'Q1'
                                           WHEN MONTH(fnc_minus3qtrbegins) IN (5, 6, 7) THEN 'Q2'
                                           WHEN MONTH(fnc_minus3qtrbegins) IN (8, 9, 10) THEN 'Q3'
                                           WHEN MONTH(fnc_minus3qtrbegins) IN (11, 12, 1) THEN 'Q4'
                                           ELSE '' 
           END                                                              AS fnc_minus3qtrtitle
      , 'FY' || CASE WHEN MONTH(fnc_minus4qtrbegins) = 1
                                       THEN RIGHT(TO_VARCHAR(YEAR(fnc_minus4qtrbegins)), 2)
                                   ELSE RIGHT(TO_VARCHAR(YEAR(DATEADD(year, 1, fnc_minus4qtrbegins))), 2) END
                            || ' ' || CASE WHEN MONTH(fnc_minus4qtrbegins) IN (2, 3, 4) THEN 'Q1'
                                           WHEN MONTH(fnc_minus4qtrbegins) IN (5, 6, 7) THEN 'Q2'
                                           WHEN MONTH(fnc_minus4qtrbegins) IN (8, 9, 10) THEN 'Q3'
                                           WHEN MONTH(fnc_minus4qtrbegins) IN (11, 12, 1) THEN 'Q4'
                                           ELSE '' 
           END                                                              AS fnc_minus4qtrtitle
      , 'FY' || CASE WHEN MONTH(fnc_plus1qtrbegins) = 1
                                       THEN RIGHT(TO_VARCHAR(YEAR(fnc_plus1qtrbegins)), 2)
                                   ELSE RIGHT(TO_VARCHAR(YEAR(DATEADD(year, 1, fnc_plus1qtrbegins))), 2) END
                            || ' ' || CASE WHEN MONTH(fnc_plus1qtrbegins) IN (2, 3, 4) THEN 'Q1'
                                           WHEN MONTH(fnc_plus1qtrbegins) IN (5, 6, 7) THEN 'Q2'
                                           WHEN MONTH(fnc_plus1qtrbegins) IN (8, 9, 10) THEN 'Q3'
                                           WHEN MONTH(fnc_plus1qtrbegins) IN (11, 12, 1) THEN 'Q4'
                                           ELSE '' 
           END                                                              AS fnc_plus1qtrtitle
      , 'FY' || CASE WHEN MONTH(fnc_plus2qtrbegins) = 1
                                       THEN RIGHT(TO_VARCHAR(YEAR(fnc_plus2qtrbegins)), 2)
                                   ELSE RIGHT(TO_VARCHAR(YEAR(DATEADD(year, 1, fnc_plus2qtrbegins))), 2) END
                       || ' ' || CASE WHEN MONTH(fnc_plus2qtrbegins) IN (2, 3, 4) THEN 'Q1'
                                      WHEN MONTH(fnc_plus2qtrbegins) IN (5, 6, 7) THEN 'Q2'
                                      WHEN MONTH(fnc_plus2qtrbegins) IN (8, 9, 10) THEN 'Q3'
                                      WHEN MONTH(fnc_plus2qtrbegins) IN (11, 12, 1) THEN 'Q4'
                                      ELSE '' 
           END                                                              AS fnc_plus2qtrtitle
      , 'FY' || CASE WHEN MONTH(fnc_plus3qtrbegins) = 1
                                       THEN RIGHT(TO_VARCHAR(YEAR(fnc_plus3qtrbegins)), 2)
                                   ELSE RIGHT(TO_VARCHAR(YEAR(DATEADD(year, 1, fnc_plus3qtrbegins))), 2) END
                       || ' ' || CASE WHEN MONTH(fnc_plus3qtrbegins) IN (2, 3, 4) THEN 'Q1'
                                      WHEN MONTH(fnc_plus3qtrbegins) IN (5, 6, 7) THEN 'Q2'
                                      WHEN MONTH(fnc_plus3qtrbegins) IN (8, 9, 10) THEN 'Q3'
                                      WHEN MONTH(fnc_plus3qtrbegins) IN (11, 12, 1) THEN 'Q4'
                                      ELSE '' 
           END                                                              AS fnc_plus3qtrtitle
      , 'FY' || CASE WHEN MONTH(fnc_plus4qtrbegins) = 1
                                       THEN RIGHT(TO_VARCHAR(YEAR(fnc_plus4qtrbegins)), 2)
                                   ELSE RIGHT(TO_VARCHAR(YEAR(DATEADD(year, 1, fnc_plus4qtrbegins))), 2) END
                       || ' ' || CASE WHEN MONTH(fnc_plus4qtrbegins) IN (2, 3, 4) THEN 'Q1'
                                      WHEN MONTH(fnc_plus4qtrbegins) IN (5, 6, 7) THEN 'Q2'
                                      WHEN MONTH(fnc_plus4qtrbegins) IN (8, 9, 10) THEN 'Q3'
                                      WHEN MONTH(fnc_plus4qtrbegins) IN (11, 12, 1) THEN 'Q4'
                                      ELSE '' 
           END                                                               AS fnc_plus4qtrtitle
      , MONTHNAME(CURRENT_DATE()) || ' ' || YEAR(CURRENT_DATE())             AS fnc_currentmonthtitle
      , MONTHNAME(fnc_currentqtrbegins) || ' ' || YEAR(fnc_currentqtrbegins) AS fnc_currentqtrm1title
      , MONTHNAME(DATEADD(month, 1, fnc_currentqtrbegins)) || ' '
           || YEAR(DATEADD(month, 1, fnc_currentqtrbegins))                  AS fnc_currentqtrm2title
      , MONTHNAME(DATEADD(month, 2, fnc_currentqtrbegins)) || ' ' 
           || YEAR(DATEADD(month, 2, fnc_currentqtrbegins))                  AS fnc_currentqtrm3title
      , 6                                                                    AS sqlversion_month_q_ranges
)

SELECT 
     fnc_currentdate
     , fnc_currentweekbegins
     , fnc_currentmonthbegins
     , fnc_nextmonthbegins
     , fnc_minus1qtrbegins
     , fnc_minus2qtrbegins
     , fnc_minus3qtrbegins
     , fnc_minus4qtrbegins
     , fnc_currentqtrbegins
     , fnc_currentqtrm2begins
     , fnc_currentqtrm3begins
     , fnc_plus1qtrbegins
     , fnc_plus2qtrbegins
     , fnc_plus3qtrbegins
     , fnc_plus4qtrbegins
     , fnc_plus5qtrbegins
     , fnc_plus6qtrbegins
     , '1900-01-01'                                                                 AS fnc_hist_customrangebegin
     , IFNULL(TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1 THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                      ELSE YEAR(CURRENT_DATE()) END) || '-' || '02-01'),
              TRUNC(CURRENT_DATE(), 'MONTH'))                                       AS fnc_hist_customrangeend
     , IFNULL(TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1 THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                      ELSE YEAR(CURRENT_DATE()) END) || '-' || '02-01'),
              TRUNC(CURRENT_DATE(), 'MONTH'))                                       AS fnc_fcst_customrangebegin
     , '3333-12-31'                                                                 AS fnc_fcst_customrangeend
     , fnc_minus1qtrtitle
     , fnc_minus2qtrtitle
     , fnc_minus3qtrtitle
     , fnc_minus4qtrtitle
     , fnc_plus1qtrtitle
     , fnc_plus2qtrtitle
     , fnc_plus3qtrtitle
     , fnc_plus4qtrtitle
     , fnc_currentmonthtitle
     , fnc_currentqtrm1title
     , fnc_currentqtrm2title
     , fnc_currentqtrm3title
     , sqlversion_month_q_ranges
FROM month_q_ranges
  );

