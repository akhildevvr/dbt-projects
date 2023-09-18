
  create or replace   view eio_ingest.tenrox_sandbox_transform.adsk_fn_month_q_ranges_v02
  
   as (
    
/* ADSK_FN_MONTH_Q_RANGES_V02
  @RangeBegin      DATETIME = NULL
  , @RangeEnd      DATETIME = NULL
  , @CutoverDate   DATETIME = NULL      -> only @CutoverDate is specified (not null)

Unused vars in ADSK_FN_MONTH_Q_RANGES_V02
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL

 DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) is only getting the 1st day of the month and can be replaced with TRUNC(CURRENT_DATE(), 'MONTH')
  
*/           
with month_q_ranges as (
select
     current_date()                                                         AS Fnc_CurrentDate
    , trunc(current_date(), 'month')                                        AS Fnc_CurrentMonthBegins
    , DATEADD(month, 1, 
                TRUNC(current_date(), 'MONTH'))                             AS Fnc_NextMonthBegins
    /* Define Current Quarter Begins to be used in other calculations */
    , to_date(to_varchar(case 
                                when month(current_date()) = 1 then year(dateadd(year, -1, current_date()))
                                else year(current_date()) end) ||
                '-' ||
                    case when month(current_date()) in (2, 3, 4) then '02-01'
                        when month(current_date()) in (5, 6, 7) then '05-01'
                        when month(current_date()) in (8, 9, 10) then '08-01'
                        when month(current_date()) in (11, 12, 1) then '11-01'
                    else NULL end)                                 AS Fnc_CurrentQtrBegins  
    , DATEADD(month, -3, Fnc_CurrentQtrBegins)                      AS Fnc_Minus1QtrBegins
    , DATEADD(month, -6, Fnc_CurrentQtrBegins)                      AS Fnc_Minus2QtrBegins
    , DATEADD(month, -9, Fnc_CurrentQtrBegins)                      AS Fnc_Minus3QtrBegins
    , DATEADD(month, -12, Fnc_CurrentQtrBegins)                     AS Fnc_Minus4QtrBegins 
    , DATEADD(month, 1, Fnc_CurrentQtrBegins)                       AS Fnc_CurrentQtrM2Begins
    , DATEADD(month, 2, Fnc_CurrentQtrBegins)                       AS Fnc_CurrentQtrM3Begins
    , DATEADD(month, 3, Fnc_CurrentQtrBegins)                       AS Fnc_Plus1QtrBegins
    , DATEADD(month, 6, Fnc_CurrentQtrBegins)                       AS Fnc_Plus2QtrBegins
    , DATEADD(month, 9, Fnc_CurrentQtrBegins)                       AS Fnc_Plus3QtrBegins
    , DATEADD(month, 12, Fnc_CurrentQtrBegins)                      AS Fnc_Plus4QtrBegins
    , DATEADD(month, 15, Fnc_CurrentQtrBegins)                      AS Fnc_Plus5QtrBegins
    , DATEADD(month, 18, Fnc_CurrentQtrBegins)                      AS Fnc_Plus6QtrBegins
    , 'FY' ||
           case
            when month(Fnc_CurrentQtrBegins) = 1 then right(to_varchar(year(Fnc_CurrentQtrBegins)), 2)
                else right(to_varchar(year(dateadd(year, 1, Fnc_CurrentQtrBegins))), 2)
            end ||
           ' ' ||
           case
            when month(Fnc_CurrentQtrBegins) in (2, 3, 4) then 'Q1'
            when month(Fnc_CurrentQtrBegins) in (5, 6, 7) then 'Q2'
            when month(Fnc_CurrentQtrBegins) in (8, 9, 10) then 'Q3'
            when month(Fnc_CurrentQtrBegins) in (11, 12, 1) then 'Q4'
            else ''
          end                                                       AS Fnc_CurrentQtrTitle
    , 'FY' ||
           case
            when month(Fnc_Minus1QtrBegins) = 1 then right(to_varchar(year(Fnc_Minus1QtrBegins)), 2)
                else right(to_varchar(year(dateadd(year, 1, Fnc_Minus1QtrBegins))), 2)
            end ||
           ' ' ||
           case
            when month(Fnc_Minus1QtrBegins) in (2, 3, 4) then 'Q1'
            when month(Fnc_Minus1QtrBegins) in (5, 6, 7) then 'Q2'
            when month(Fnc_Minus1QtrBegins) in (8, 9, 10) then 'Q3'
            when month(Fnc_Minus1QtrBegins) in (11, 12, 1) then 'Q4'
            else ''
          end                                                       AS Fnc_Minus1QtrTitle
    , 'FY' ||
           case
            when month(Fnc_Minus2QtrBegins) = 1 then right(to_varchar(year(Fnc_Minus2QtrBegins)), 2)
                else right(to_varchar(year(dateadd(year, 1, Fnc_Minus2QtrBegins))), 2)
            end ||
           ' ' ||
           case
            when month(Fnc_Minus2QtrBegins) in (2, 3, 4) then 'Q1'
            when month(Fnc_Minus2QtrBegins) in (5, 6, 7) then 'Q2'
            when month(Fnc_Minus2QtrBegins) in (8, 9, 10) then 'Q3'
            when month(Fnc_Minus2QtrBegins) in (11, 12, 1) then 'Q4'
            else ''
          end                                                       AS Fnc_Minus2QtrTitle
    , 'FY' ||
           case
            when month(Fnc_Minus3QtrBegins) = 1 then right(to_varchar(year(Fnc_Minus3QtrBegins)), 2)
                else right(to_varchar(year(dateadd(year, 1, Fnc_Minus3QtrBegins))), 2)
            end ||
           ' ' ||
           case
            when month(Fnc_Minus3QtrBegins) in (2, 3, 4) then 'Q1'
            when month(Fnc_Minus3QtrBegins) in (5, 6, 7) then 'Q2'
            when month(Fnc_Minus3QtrBegins) in (8, 9, 10) then 'Q3'
            when month(Fnc_Minus3QtrBegins) in (11, 12, 1) then 'Q4'
            else ''
          end                                                       AS Fnc_Minus3QtrTitle
    , 'FY' ||
           case
            when month(Fnc_Minus4QtrBegins) = 1 then right(to_varchar(year(Fnc_Minus4QtrBegins)), 2)
                else right(to_varchar(year(dateadd(year, 1, Fnc_Minus4QtrBegins))), 2)
            end ||
           ' ' ||
           case
            when month(Fnc_Minus4QtrBegins) in (2, 3, 4) then 'Q1'
            when month(Fnc_Minus4QtrBegins) in (5, 6, 7) then 'Q2'
            when month(Fnc_Minus4QtrBegins) in (8, 9, 10) then 'Q3'
            when month(Fnc_Minus4QtrBegins) in (11, 12, 1) then 'Q4'
            else ''
          end                                                       AS Fnc_Minus4QtrTitle
    , 'FY' ||
           case
            when month(Fnc_Plus1QtrBegins) = 1 then right(to_varchar(year(Fnc_Plus1QtrBegins)), 2)
                else right(to_varchar(year(dateadd(year, 1, Fnc_Plus1QtrBegins))), 2)
            end ||
           ' ' || 
           case
            when month(Fnc_Plus1QtrBegins) in (2, 3, 4) then 'Q1'
            when month(Fnc_Plus1QtrBegins) in (5, 6, 7) then 'Q2'
            when month(Fnc_Plus1QtrBegins) in (8, 9, 10) then 'Q3'
            when month(Fnc_Plus1QtrBegins) in (11, 12, 1) then 'Q4'
            else ''
          end                                                       AS Fnc_Plus1QtrTitle
    , 'FY' ||
           case
            when month(Fnc_Plus2QtrBegins) = 1 then right(to_varchar(year(Fnc_Plus2QtrBegins)), 2)
                else right(to_varchar(year(dateadd(year, 1, Fnc_Plus2QtrBegins))), 2)
            end ||
           ' ' ||
           case
            when month(Fnc_Plus2QtrBegins) in (2, 3, 4) then 'Q1'
            when month(Fnc_Plus2QtrBegins) in (5, 6, 7) then 'Q2'
            when month(Fnc_Plus2QtrBegins) in (8, 9, 10) then 'Q3'
            when month(Fnc_Plus2QtrBegins) in (11, 12, 1) then 'Q4'
            else ''
          end                                                       AS Fnc_Plus2QtrTitle
    , 'FY' ||
           case
            when month(Fnc_Plus3QtrBegins) = 1 then right(to_varchar(year(Fnc_Plus3QtrBegins)), 2)
                else right(to_varchar(year(dateadd(year, 1, Fnc_Plus3QtrBegins))), 2)
            end ||
           ' ' ||
           case
            when month(Fnc_Plus3QtrBegins) in (2, 3, 4) then 'Q1'
            when month(Fnc_Plus3QtrBegins) in (5, 6, 7) then 'Q2'
            when month(Fnc_Plus3QtrBegins) in (8, 9, 10) then 'Q3'
            when month(Fnc_Plus3QtrBegins) in (11, 12, 1) then 'Q4'
            else ''
          end                                                       AS Fnc_Plus3QtrTitle
    , 'FY' ||
           case
            when month(Fnc_Plus4QtrBegins) = 1 then right(to_varchar(year(Fnc_Plus4QtrBegins)), 2)
                else right(to_varchar(year(dateadd(year, 1, Fnc_Plus4QtrBegins))), 2)
            end ||
           ' ' ||
           case
            when month(Fnc_Plus4QtrBegins) in (2, 3, 4) then 'Q1'
            when month(Fnc_Plus4QtrBegins) in (5, 6, 7) then 'Q2'
            when month(Fnc_Plus4QtrBegins) in (8, 9, 10) then 'Q3'
            when month(Fnc_Plus4QtrBegins) in (11, 12, 1) then 'Q4'
            else ''
          end                                                       AS Fnc_Plus4QtrTitle
    , MONTHNAME(current_date()) || ' ' || YEAR(current_date())      AS Fnc_CurrentMonthTitle
    , MONTHNAME(Fnc_CurrentQtrBegins) || ' ' ||
                            YEAR(Fnc_CurrentQtrBegins)              AS Fnc_CurrentQtrM1Title
    , MONTHNAME(DATEADD(MONTH, 1, Fnc_CurrentQtrBegins)) || 
        ' ' ||
        YEAR(DATEADD(MONTH, 1, Fnc_CurrentQtrBegins))               AS Fnc_CurrentQtrM2Title
    , MONTHNAME(DATEADD(MONTH, 2, Fnc_CurrentQtrBegins)) || 
        ' ' ||
        YEAR(DATEADD(MONTH, 2, Fnc_CurrentQtrBegins))               AS Fnc_CurrentQtrM3Title
    , 6                                                             AS SQLVersion_MONTH_Q_RANGES
)

select
    Fnc_CurrentDate
    , Fnc_CurrentMonthBegins
    , Fnc_NextMonthBegins
    , Fnc_Minus1QtrBegins
    , Fnc_Minus2QtrBegins
    , Fnc_Minus3QtrBegins
    , Fnc_Minus4QtrBegins
    , Fnc_CurrentQtrBegins
    , Fnc_CurrentQtrM2Begins
    , Fnc_CurrentQtrM3Begins
    , Fnc_Plus1QtrBegins
    , Fnc_Plus2QtrBegins
    , Fnc_Plus3QtrBegins
    , Fnc_Plus4QtrBegins
    , Fnc_Plus5QtrBegins
    , Fnc_Plus6QtrBegins
    , '1900-01-01'                                                              AS Fnc_Hist_CustomRangeBegin
    , IFNULL(to_date(to_varchar(case when month(current_date()) = 1 
                                    then year(dateadd(year, -1, current_date())) 
                                    else year(current_date()) 
                                    end) || '-' || '02-01')
             , TRUNC(CURRENT_DATE(), 'MONTH'))                                  AS Fnc_Hist_CustomRangeEnd
    , IFNULL(to_date(to_varchar(case when month(current_date()) = 1 
                                   then year(dateadd(year, -1, current_date())) 
                                   else year(current_date()) 
                                   end) || '-' || '02-01')
             , TRUNC(CURRENT_DATE(), 'MONTH'))                                  AS Fnc_Fcst_CustomRangeBegin
    , '3333-12-31'                                                              AS Fnc_Fcst_CustomRangeEnd
    , Fnc_Minus1QtrTitle
    , Fnc_Minus2QtrTitle
    , Fnc_Minus3QtrTitle
    , Fnc_Minus4QtrTitle
    , Fnc_Plus1QtrTitle
    , Fnc_Plus2QtrTitle
    , Fnc_Plus3QtrTitle
    , Fnc_Plus4QtrTitle
    , Fnc_CurrentMonthTitle
    , Fnc_CurrentQtrM1Title
    , Fnc_CurrentQtrM2Title
    , Fnc_CurrentQtrM3Title
    , SQLVersion_MONTH_Q_RANGES
from month_q_ranges
  );

