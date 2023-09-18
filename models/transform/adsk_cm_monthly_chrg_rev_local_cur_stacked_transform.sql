

{{ config(
    alias='adsk_cm_monthly_chrg_rev_local_cur_stacked'
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
projects AS (  
SELECT
distinct pd.PROJECTID
, TRUNC(ds.dt,'MONTH') as dt
FROM 
{{ ref('adsk_cm_project_details_transform')}}   pd
LEFT OUTER JOIN date_sequence ds

),

task AS
(
    SELECT
    *
    FROM
    {{ source('tenrox_private','ttask')}}
),
chargeentry AS
(
    SELECT
    *
    FROM
    {{ source('tenrox_private','tchargeentry')}}
),
charge AS
(
    SELECT
    *
    FROM
    {{ source('tenrox_private','tcharge')}}
),
project AS
(
    SELECT
    *
    FROM
    {{ source('tenrox_private','tproject')}}
),
projectcustfld AS
(
    SELECT
    *
    FROM
    {{ source('tenrox_private','tprojectcustfld')}}
),
custlst AS
(
    SELECT
    *
    FROM
    {{ source('tenrox_private','tcustlst')}}
),
custlstdesc AS
(
    SELECT
    *
    FROM
    {{ source('tenrox_private','tcustlstdesc')}}
),
adsk_month_q_ranges_v02 AS
(
    SELECT
    *
    FROM
    {{ ref('adsk_month_q_ranges_v02_transform')}}
),
currency AS
(
    SELECT
    *
    FROM
    {{ source('tenrox_private','tcurrency')}}
),
fcurrqexchrate AS
(
    SELECT
    *
    FROM
    {{ ref('fcurrqexchrate_transform')}}
),

monthly_chrg_rev AS (

    SELECT
        CASE
           WHEN lower(parent_child.adsk_master_projecttype) in ( 'is parent' ) THEN
               ttask.projectid  
           WHEN lower(parent_child.adsk_master_projecttype) IN ( 'is master', 'is child' ) THEN
               parent_child.parentid 
           ELSE
               ttask.projectid
        END                                                                                                                              AS projectid
         , TRUNC(tchargeentry.currentdate, 'month')                                                                                      AS monthofchrgrev
         , SUM(IFNULL(CASE
                          WHEN tchargeentry.billable = 1 THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                             AS monthschrgrev_allbillable
        -- 3rd Party-Billable Expenses     RecChrgRev_3rdBillableExp
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                             AS monthschrgrev_3rdbillableexp
        -- 3rd Party-Non-Billable T&E      RecChrgRev_3rdNonBillTE
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = '3rd Party-Non-Billable T&E' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                             AS monthschrgrev_3rdnonbillte
        -- Internal-Billable Expenses      RecChrgRev_InternalBillableExp
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                             AS monthschrgrev_internalbillableexp
        -- Internal-Non-Billable T&E       RecChrgRev_InternalNonBillTE
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Internal-Non-Billable T&E' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                             AS monthschrgrev_internalnonbillte
        -- Ratable Billing                 RecChrgRev_RatableBilling
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Ratable Billing' 
                          AND tchargeentry.billable = 1 THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                             AS monthschrgrev_ratablebilling
        -- Sys Conv-Labor Non-Billable     RecChrgRev_SysConvNonBill
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                             AS monthschrgrev_sysconvnonbill
        -- Sys Conv-Labor Revenue          RecChrgRev_SysConvLaborRev
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Sys Conv-Labor Revenue' 
                          AND tchargeentry.billable = 1 THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                             AS monthschrgrev_sysconvlaborrev
        -- Autodesk IP Product-Sales       MonthsChrgRev_IPProdSales
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Autodesk IP Product-Sales' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                             AS monthschrgrev_ipprodsales
        -- Third Party Product-Sales       RecChrgRev_3rdProdSales
         , SUM(IFNULL(CASE
                          WHEN tcharge.name = 'Third Party Product-Sales' AND tchargeentry.billable = 1
                              THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                          ELSE 0.00 END,
                      0.00))                                                                                                             AS monthschrgrev_3rdprodsales
          ,
                CASE
                    WHEN
                        monthofchrgrev = fnc_currentqtrbegins 
                    THEN
                        monthschrgrev_internalbillableexp + monthschrgrev_3rdbillableexp 
                END
                                                                                                                                         AS  actual_charge_rev_month1
         ,
                CASE
                    WHEN
                        monthofchrgrev = fnc_currentqtrm2begins 
                    THEN
                        monthschrgrev_internalbillableexp + monthschrgrev_3rdbillableexp 
                END
                                                                                                                                        AS  actual_charge_rev_month2
         ,
                CASE
                    WHEN
                        monthofchrgrev = fnc_currentqtrm3begins 
                    THEN
                        monthschrgrev_internalbillableexp + monthschrgrev_3rdbillableexp 
                END
                                                                                                                                        AS  actual_charge_rev_month3     
     
        -- SQL Script Version Information
         , 6                                                                                                                            AS sqlversion_monthly_chrg_rev
     FROM   task AS ttask
     LEFT JOIN chargeentry AS tchargeentry
                  ON tchargeentry.taskid = ttask.uniqueid
                 AND tchargeentry.approved = 1
     INNER JOIN charge AS tcharge
                  ON tcharge.uniqueid = tchargeentry.chargeid
     LEFT JOIN (
        SELECT  
            tproject.uniqueid AS projectid
            ,tproject.parentid as parentid
            ,LSTDESC_16.VALUE as adsk_master_projecttype
        
        FROM 
            project AS  tproject
        LEFT JOIN projectcustfld  a On a.PROJECTID = tproject.uniqueid
        LEFT JOIN custlst AS LST_16  ON a.ADSK_MasterAgreement_ProjectType = LST_16.UNIQUEID 
        LEFT JOIN custlstdesc AS LSTDESC_16  ON LST_16.UNIQUEID = LSTDESC_16.CUSTLSTID AND LSTDESC_16.LANGUAGE = 0
                ) parent_child ON parent_child.projectid = ttask.projectid
     LEFT OUTER JOIN adsk_month_q_ranges_v02 AS ranges
     LEFT OUTER JOIN (
                    SELECT
                        IFNULL(uniqueid, 1) AS lubasecurrencyid
                    FROM   currency AS tcurrency
                    WHERE  currencycode = 'USD') basecur
     -- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN (
                    SELECT
                        IFNULL(uniqueid, 1) AS overridecurid
                    FROM   currency AS tcurrency
                    WHERE  currencycode = 'USD') usdcurid
     -- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID 
     LEFT OUTER JOIN fcurrqexchrate as fxrate
                ON fxrate.basecurrencyid = COALESCE(tchargeentry.currencyid, lubasecurrencyid)
                AND fxrate.quotecurrencyid = COALESCE(NULL, tchargeentry.clientcurrencyid, lubasecurrencyid)
                AND tchargeentry.currentdate BETWEEN fxrate.startdate AND fxrate.enddate
     WHERE      tcharge.chargetype = 'M'

     GROUP BY
      CASE
           WHEN lower(parent_child.adsk_master_projecttype) in ( 'is parent' ) THEN
               ttask.projectid  
           WHEN lower(parent_child.adsk_master_projecttype) IN ( 'is master', 'is child' ) THEN
               parent_child.parentid 
           ELSE
               ttask.projectid
       END
      , TRUNC(tchargeentry.currentdate, 'month')
      
      ,fnc_currentqtrbegins
      ,fnc_currentqtrm2begins
      ,fnc_currentqtrm3begins
      
),

monthly_chrg_rev_final AS 
(
  SELECT 
  p.projectid
  ,p.dt
  ,m.monthschrgrev_allbillable
  ,m.monthschrgrev_3rdbillableexp
  ,m.monthschrgrev_3rdnonbillte
  ,m.monthschrgrev_internalbillableexp
  ,m.monthschrgrev_internalnonbillte
  ,m.monthschrgrev_ratablebilling
  ,m.monthschrgrev_sysconvnonbill
  ,m.monthschrgrev_sysconvlaborrev
  ,m.monthschrgrev_ipprodsales
  ,m.monthschrgrev_3rdprodsales
  ,m.actual_charge_rev_month1
  ,m.actual_charge_rev_month2
  ,m.actual_charge_rev_month3
  FROM projects p
  LEFT JOIN monthly_chrg_rev m ON m.projectid = p.projectid AND p.dt = m.monthofchrgrev

)






SELECT 
projectid AS projectid
,CASE
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   dt)||'-02-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-05-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-08-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-11-01')
              ELSE TO_DATE(EXTRACT(YEAR FROM dt) - 1 ||'-11-01')
            END          AS dt
, SUM(monthschrgrev_allbillable) AS monthschrgrev_allbillable
, SUM(monthschrgrev_3rdbillableexp) AS monthschrgrev_3rdbillableexp
, SUM(monthschrgrev_3rdnonbillte) AS monthschrgrev_3rdnonbillte
, SUM(monthschrgrev_internalbillableexp) AS monthschrgrev_internalbillableexp
, SUM(monthschrgrev_internalnonbillte) AS monthschrgrev_internalnonbillte
, SUM(monthschrgrev_ratablebilling) AS monthschrgrev_ratablebilling
, SUM(monthschrgrev_sysconvnonbill) AS monthschrgrev_sysconvnonbill
, SUM(monthschrgrev_sysconvlaborrev) AS monthschrgrev_sysconvlaborrev
, SUM(monthschrgrev_ipprodsales) AS monthschrgrev_ipprodsales
, SUM(monthschrgrev_3rdprodsales) AS monthschrgrev_3rdprodsales
, SUM(actual_charge_rev_month1) AS actual_charge_rev_month1
, SUM(actual_charge_rev_month2) AS actual_charge_rev_month2
, SUM(actual_charge_rev_month3) AS actual_charge_rev_month3
FROM
monthly_chrg_rev_final

GROUP BY
projectid 
,CASE
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   dt)||'-02-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-05-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-08-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-11-01')
              ELSE TO_DATE(EXTRACT(YEAR FROM dt) - 1 ||'-11-01')
END