


WITH 
date_range AS (
  SELECT YEAR(DATEADD(YEAR, -10, CURRENT_DATE())) || '-02-01' AS start_date,
         DATEADD(YEAR, 2, CURRENT_DATE()) AS end_date,
        DATEDIFF(DAY, start_date, end_date) + 1   AS rng
),

rvfcbaseline AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.trvfcbaseline
),

rvfcbaselinebudget AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.trvfcbaselinebudget
),

rvfcbltmpl AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.trvfcbltmpl
),

rvfcblsec AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.trvfcblsec
),

rvfcblseclabel AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.trvfcblseclabel
),

rvfcblcat AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.trvfcblcat
),

rvfcblcatlabel AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.trvfcblcatlabel
),

rvfcblitem AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.trvfcblitem
),

rvfcblitemdata AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.trvfcblitemdata
),

fcalperiod AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.tfcalperiod
),

project AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.tproject
),

clientinvoice AS
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.tclientinvoice
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

adsk_cm_project_details AS
(
    SELECT
    *
    FROM
    EIO_INGEST.TENROX_TRANSFORM.adsk_cm_project_details
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
adsk_cm_project_details AS   pd
LEFT OUTER JOIN date_sequence ds
),

fcst_charge_rev AS (
SELECT 
     tproject.uniqueid                     AS projectid
     ,tfcalperiod.startdate as dt
     , SUM(IFNULL(
        CASE WHEN tcharge.billable = 1 THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_allbillable

    -- All BUT Ratable
     , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' THEN IFNULL(
        CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
             WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
             ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable
    , SUM(IFNULL(CASE WHEN tcharge.billable = 1 AND IFNULL(tcharge.name, '') <> 'Ratable Billing' AND tfcalperiod.startdate >= fnc_currentmonthbegins
        AND tfcalperiod.startdate < fnc_plus1qtrbegins THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                        WHEN lubasecurrencyid = overridecurid THEN trvfcblitemdata.amountbasecurrency
                                                                        ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_nonratablebillable_remaininginqtr

    -- IPProdSales
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Autodesk IP Product-Sales' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                              WHEN lubasecurrencyid = overridecurid
                                                                                  THEN trvfcblitemdata.amountbasecurrency
                                                                              ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_ipprodsales

    -- Ratable Billing
     , SUM(IFNULL(CASE WHEN tcharge.name = 'Ratable Billing' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                              WHEN lubasecurrencyid = overridecurid
                                                                                  THEN trvfcblitemdata.amountbasecurrency
                                                                              ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
                       ELSE 0.00 END, 0.00)) AS fcstchrgrev_ratablebilling

    -- IP3rdSales
     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Third Party Product-Sales' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                              WHEN lubasecurrencyid = overridecurid
                                                                                  THEN trvfcblitemdata.amountbasecurrency
                                                                              ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_3rdprodsales

     , SUM(IFNULL(
        CASE WHEN tcharge.name = '3rd Party-Billable Expenses' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_3rdbillableexp

     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Internal-Billable Expenses' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                               WHEN lubasecurrencyid = overridecurid
                                                                                   THEN trvfcblitemdata.amountbasecurrency
                                                                               ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_internalbillableexp

     , SUM(IFNULL(
        CASE WHEN tcharge.name = '3rd Party-Non-Billable T&E' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                               WHEN lubasecurrencyid = overridecurid
                                                                                   THEN trvfcblitemdata.amountbasecurrency
                                                                               ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_3rdnonbillte

     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Internal-Non-Billable T&E' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                              WHEN lubasecurrencyid = overridecurid
                                                                                  THEN trvfcblitemdata.amountbasecurrency
                                                                              ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_internalnonbillte

     , SUM(IFNULL(
        CASE WHEN tcharge.name = 'Sys Conv-Labor Non-Billable' THEN IFNULL(CASE WHEN overridecurid IS NULL THEN trvfcblitemdata.amountclientcurrency
                                                                                WHEN lubasecurrencyid = overridecurid
                                                                                    THEN trvfcblitemdata.amountbasecurrency
                                                                                ELSE trvfcblitemdata.amountclientcurrency * fxrate.rate END, 0.00)
             ELSE 0.00 END, 0.00))           AS fcstchrgrev_sysconvnonbill

     , MAX(fnc_fcst_customrangebegin)        AS fcstchrgrev_customrangebegin, MAX(fnc_fcst_customrangeend) AS fcstchrgrev_customrangeend
     , 15                                    AS sqlversion_forecast_chrg_rev
    FROM  rvfcbaseline AS trvfcbaseline
    LEFT OUTER JOIN rvfcbaselinebudget AS trvfcbaselinebudget
        ON trvfcbaselinebudget.baselineuid = trvfcbaseline.uniqueid 
    INNER JOIN rvfcbltmpl AS trvfcbltmpl 
        ON trvfcbltmpl.baselineid = trvfcbaseline.uniqueid 
    INNER JOIN rvfcblsec AS trvfcblsec 
        ON trvfcblsec.bltmplid = trvfcbltmpl.uniqueid 
    INNER JOIN rvfcblseclabel AS trvfcblseclabel 
        ON trvfcblseclabel.blsecid = trvfcblsec.uniqueid 
        AND trvfcblseclabel.language = 0 
    INNER JOIN rvfcblcat AS trvfcblcat 
        ON trvfcblcat.blsecid = trvfcblsec.uniqueid 
    INNER JOIN rvfcblcatlabel AS trvfcblcatlabel 
        ON trvfcblcatlabel.blcatid = trvfcblcat.uniqueid 
        AND trvfcblcatlabel.language = 0 
    INNER JOIN rvfcblitem AS trvfcblitem 
        ON trvfcblitem.blcatid = trvfcblcat.uniqueid 
    INNER JOIN rvfcblitemdata AS trvfcblitemdata 
        ON trvfcblitemdata.blitemid = trvfcblitem.uniqueid 
    INNER JOIN fcalperiod AS tfcalperiod 
        ON tfcalperiod.uniqueid = trvfcblitemdata.calperiodid 
        AND tfcalperiod.periodtype = 'M' 
        AND tfcalperiod.calid = 4
    LEFT JOIN eio_publish.tenrox_private.tcharge tcharge
                ON CASE trvfcblitem.objecttype 
                    WHEN 129 THEN tcharge.uniqueid 
                END = trvfcblitem.objectid 
                AND tcharge.chargetype = 'M'

    RIGHT OUTER JOIN project AS tproject
        ON tproject.uniqueid = trvfcbaseline.projectid 
    LEFT JOIN clientinvoice AS tclientinvoice 
        ON tclientinvoice.clientid = tproject.clientid 
    LEFT OUTER JOIN adsk_month_q_ranges_v02 AS ranges
    LEFT OUTER JOIN  (SELECT
                         IFNULL(uniqueid, 1) AS lubasecurrencyid
                       FROM currency AS tcurrency
                       WHERE  currencycode = 'USD') basecur
     -- start: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID
    LEFT OUTER JOIN (
                    SELECT
                         NULL      AS overridecurid
                    FROM currency
                    WHERE currencycode = 'USD'
                    ) usdcurid
     -- end: copy setup from CUST_ADSK_MARGINVARIANCE for @USDCurID = @OverrideCurID
    LEFT OUTER JOIN fcurrqexchrate AS fxrate
        ON fxrate.basecurrencyid = COALESCE(tclientinvoice.currencyid, lubasecurrencyid)
        -- only used in CUST_ADSK_MARGINVARIANCE where @OverrideCurID = @USDCurID and is forced to 1, LUBaseCurrencyID is also always 1
        AND fxrate.quotecurrencyid = COALESCE(NULL, tclientinvoice.currencyid, lubasecurrencyid) 
        AND CURRENT_DATE () BETWEEN fxrate.startdate AND fxrate.enddate
    WHERE trvfcbaseline.iscurrent = 1 
        AND trvfcblitemdata.elementtype = 1 
        AND trvfcblseclabel.label = 'Revenue' 
        AND trvfcblcatlabel.label = 'Charges'
        AND trvfcblitem.objecttype = 129 
        AND trvfcblitemdata.elementtype = 1
    GROUP BY 
        tproject.uniqueid
 ,tfcalperiod.startdate
  
  ),
  
--select * from final where projectid = 15078;
fcst_charge_rev_final AS (  
 SELECT 
 p.projectid
,p.dt
,f.fcstchrgrev_allbillable
,f.fcstchrgrev_nonratablebillable
,f.fcstchrgrev_nonratablebillable_remaininginqtr
,f.fcstchrgrev_ipprodsales
,f.fcstchrgrev_ratablebilling
,f.fcstchrgrev_3rdprodsales
,f.fcstchrgrev_3rdbillableexp
,f.fcstchrgrev_internalbillableexp
,f.fcstchrgrev_3rdnonbillte
,f.fcstchrgrev_internalnonbillte
,f.fcstchrgrev_sysconvnonbill

 FROM 
 projects p
 left join fcst_charge_rev f ON p.projectid = f.projectid AND p.dt = f.dt

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
  ,SUM(fcstchrgrev_allbillable) AS fcstchrgrev_allbillable
  ,SUM(fcstchrgrev_nonratablebillable) AS fcstchrgrev_nonratablebillable
  ,SUM(fcstchrgrev_nonratablebillable_remaininginqtr) AS fcstchrgrev_nonratablebillable_remaininginqtr
  ,SUM(fcstchrgrev_ipprodsales) AS fcstchrgrev_ipprodsales
  ,SUM(fcstchrgrev_ratablebilling) AS fcstchrgrev_ratablebilling
  ,SUM(fcstchrgrev_3rdprodsales) AS fcstchrgrev_3rdprodsales
  ,SUM(fcstchrgrev_3rdbillableexp) AS fcstchrgrev_3rdbillableexp
  ,SUM(fcstchrgrev_internalbillableexp) AS fcstchrgrev_internalbillableexp
  ,SUM(fcstchrgrev_3rdnonbillte) AS fcstchrgrev_3rdnonbillte
  ,SUM(fcstchrgrev_internalnonbillte) AS fcstchrgrev_internalnonbillte
  ,SUM(fcstchrgrev_sysconvnonbill) AS fcstchrgrev_sysconvnonbill
  FROM  
  fcst_charge_rev_final
  GROUP BY
  projectid 
  ,CASE
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   dt)||'-02-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-05-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-08-01')
              WHEN EXTRACT(MONTH FROM dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM dt)||'-11-01')
              ELSE TO_DATE(EXTRACT(YEAR FROM dt) - 1 ||'-11-01')
            END