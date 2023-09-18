
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_cm_rec_chrg_rev_local_cur_v02_stacked
  
   as (
    


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
DISTINCT pd.PROJECTID
, ds.dt
FROM 
EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_details   pd
LEFT OUTER JOIN date_sequence ds
),
project AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.tproject
),

task AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.ttask
),

chargeentry AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.tchargeentry
),

charge AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.tcharge
),

adsk_month_q_ranges_v02 AS
(
    SELECT
    *
    FROM
    EIO_INGEST.TENROX_TRANSFORM.adsk_month_q_ranges_v02
),
currency AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.tcurrency
),
fcurrqexchrate AS
(
    SELECT
    *
    FROM
    EIO_INGEST.TENROX_TRANSFORM.fcurrqexchrate
),
rec_chrg_rev AS (
SELECT
     tproject.uniqueid AS projectid
     , tchargeentry.currentdate as dt
     , SUM(IFNULL(CASE
                      WHEN tcharge.billable = 1 THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                    ELSE 0.00
                    END, 0.00)) AS recchrgrev_allbillable

    -- 3rd Party-Billable Expenses     RecChrgRev_3rdBillableExp
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Billable Expenses' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdbillableexp_pastqtrs

    -- 3rd Party-Non-Billable T&E      RecChrgRev_3rdNonBillTE
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = '3rd Party-Non-Billable T&E' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdnonbillte

    -- Internal-Billable Expenses      RecChrgRev_InternalBillableExp
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Billable Expenses' AND tchargeentry.currentdate < fnc_currentqtrbegins
                          THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalbillableexp_pastqtrs

    -- Internal-Non-Billable T&E       RecChrgRev_InternalNonBillTE
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Internal-Non-Billable T&E' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_internalnonbillte

    -- Ratable Billing                 RecChrgRev_RatableBilling
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Ratable Billing' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ratablebilling

    -- Sys Conv-Labor Non-Billable     RecChrgRev_SysConvNonBill
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvnonbill

    -- Sys Conv-Labor Revenue          RecChrgRev_SysConvLaborRev
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Sys Conv-Labor Revenue' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_sysconvlaborrev

    -- Autodesk IP Product-Sales       RecChrgRev_IPProdSales
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Autodesk IP Product-Sales' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_ipprodsales

    -- Third Party Product-Sales       RecChrgRev_3rdProdSales
     , SUM(IFNULL(CASE
                      WHEN tcharge.name = 'Third Party Product-Sales' THEN IFNULL(tchargeentry.amount * fxrate.rate, 0.00)
                      ELSE 0.00
                  END, 0.00)) AS recchrgrev_3rdprodsales

     , MAX(fnc_hist_customrangebegin) AS recchrgrev_customrangebegin, MAX(fnc_hist_customrangeend) AS recchrgrev_customrangeend
     , 8 AS sqlversion_rec_chrg_rev
FROM project AS tproject
LEFT JOIN task AS ttask
ON ttask.projectid = tproject.uniqueid
LEFT JOIN chargeentry AS tchargeentry
    ON tchargeentry.taskid = ttask.uniqueid
    AND tchargeentry.approved = 1
INNER JOIN charge AS tcharge 
    ON tcharge.uniqueid = tchargeentry.chargeid 
    AND tcharge.chargetype = 'M'
LEFT OUTER JOIN adsk_month_q_ranges_v02 AS ranges
LEFT OUTER JOIN (SELECT
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
LEFT OUTER JOIN fcurrqexchrate AS fxrate
    ON fxrate.basecurrencyid = COALESCE(tchargeentry.currencyid, lubasecurrencyid)
    -- traced back to final table CUST_ADSK_MARGINVARIANCE where @OverrideCurID = @USDCurID = 1
    AND fxrate.quotecurrencyid = COALESCE(NULL, tchargeentry.clientcurrencyid, lubasecurrencyid) 
    AND tchargeentry.currentdate BETWEEN fxrate.startdate AND fxrate.enddate
GROUP BY
    tproject.uniqueid
  ,tchargeentry.currentdate
  ),
  
rec_chrg_rev_final AS 
(
  SELECT
  p.projectid
  ,p.dt
  ,r.recchrgrev_allbillable
  ,r.recchrgrev_3rdbillableexp
  ,r.recchrgrev_3rdbillableexp_pastqtrs
  ,r.recchrgrev_3rdnonbillte
  ,r.recchrgrev_internalbillableexp
  ,r.recchrgrev_internalbillableexp_pastqtrs
  ,r.recchrgrev_internalnonbillte
  ,r.recchrgrev_ratablebilling
  ,r.recchrgrev_sysconvnonbill
  ,r.recchrgrev_sysconvlaborrev
  ,r.recchrgrev_ipprodsales
  ,r.recchrgrev_3rdprodsales
  FROM 
  projects p
  LEFT JOIN  rec_chrg_rev r ON p.projectid = r.projectid and p.dt = r.dt
  
)
  
  SELECT
  projectid AS projectid
  ,CASE
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   dt)||'-02-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-05-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-08-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-11-01')
              ELSE TO_DATE(EXTRACT(YEAR FROM dt) - 1 ||'-11-01')
            END                                                                                           AS dt
  ,SUM(recchrgrev_allbillable) AS recchrgrev_allbillable
  ,SUM(recchrgrev_3rdbillableexp) AS recchrgrev_3rdbillableexp
  ,SUM(recchrgrev_3rdbillableexp_pastqtrs) AS recchrgrev_3rdbillableexp_pastqtrs
  ,SUM(recchrgrev_3rdnonbillte) AS recchrgrev_3rdnonbillte
  ,SUM(recchrgrev_internalbillableexp) AS recchrgrev_internalbillableexp
  ,SUM(recchrgrev_internalbillableexp_pastqtrs) AS recchrgrev_internalbillableexp_pastqtrs
  ,SUM(recchrgrev_internalnonbillte) AS recchrgrev_internalnonbillte
  ,SUM(recchrgrev_ratablebilling) AS recchrgrev_ratablebilling
  ,SUM(recchrgrev_sysconvnonbill) AS recchrgrev_sysconvnonbill
  ,SUM(recchrgrev_sysconvlaborrev) AS recchrgrev_sysconvlaborrev
  ,SUM(recchrgrev_ipprodsales) AS recchrgrev_ipprodsales
  ,SUM(recchrgrev_3rdprodsales) AS recchrgrev_3rdprodsales
  FROM
 rec_chrg_rev_final
  GROUP BY
  projectid 
  ,CASE
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   dt)||'-02-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-05-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-08-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-11-01')
              ELSE TO_DATE(EXTRACT(YEAR FROM dt) - 1 ||'-11-01')
            END
  );

