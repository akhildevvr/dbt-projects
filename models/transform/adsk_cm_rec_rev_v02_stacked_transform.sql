{{ config(alias = 'adsk_cm_rec_rev_v02_stacked') }} 


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
DISTINCT pd.uniqueid AS PROJECTID
, ds.dt
FROM 
{{ source('tenrox_private','tproject')}}   pd
LEFT OUTER JOIN date_sequence ds
  ),
tproject AS (
    SELECT
	*
	FROM
	{{ source('tenrox_private','tproject')}}
),
trecognizedrevenue AS (
	SELECT
					*
	FROM
	{{ source('tenrox_private','trecognizedrevenue')}}
),
tclient AS (
	SELECT
					*
	FROM
	{{ source('tenrox_private','tclient')}}
),
tclientinvoice AS (
	SELECT
					*
	FROM
	{{ source('tenrox_private','tclientinvoice')}}
),
tcurrency AS (
	SELECT
					*
	FROM
	{{ source('tenrox_private','tcurrency')}}
),
adsk_fn_month_q_ranges_v02 AS (
	SELECT
					*
	FROM
	{{ ref('adsk_month_q_ranges_v02_transform')}}
),
fcurrqexchrate AS (
	SELECT
					*
	FROM
	{{ ref('fcurrqexchrate_transform')}}
)
SELECT
    tproject.uniqueid AS projectid,
    SUM(nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0)) AS recrev
    ,CASE
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   p.dt)||'-02-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-05-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-08-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-11-01')
              ELSE TO_DATE(EXTRACT(YEAR FROM p.dt) - 1 ||'-11-01')
            END                                                                                                             AS dt
    ,SUM(nvl(
    CASE
        WHEN
            periodstartdate >= fnc_currentqtrbegins 
            AND periodstartdate < fnc_currentmonthbegins 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_completedinqtr

FROM
projects p
  LEFT JOIN   tproject AS tproject ON p.projectid = tproject.uniqueid
    LEFT JOIN
        trecognizedrevenue AS trecognizedrevenue 
        ON trecognizedrevenue.projectid = tproject.uniqueid AND trecognizedrevenue.periodstartdate = p.dt
    LEFT JOIN
        tclient AS tclient 
        ON tclient.uniqueid = tproject.clientid 
    LEFT JOIN
        tclientinvoice AS tclientinvoice 
        ON tclient.uniqueid = tclientinvoice.clientid 
    LEFT OUTER JOIN
        adsk_fn_month_q_ranges_v02
    LEFT OUTER JOIN
        (
            SELECT
                nvl(uniqueid, 1) AS lubasecurrencyid 
            FROM
                tcurrency
            WHERE
                currencycode = 'USD'
        )
        basecur 
    LEFT OUTER JOIN
        fcurrqexchrate AS fxlookup 
        ON fxlookup.basecurrencyid = lubasecurrencyid 
        AND fxlookup.quotecurrencyid = 
        (
            COALESCE(NULL, tclientinvoice.currencyid, lubasecurrencyid)
        )
        AND trecognizedrevenue.periodstartdate BETWEEN fxlookup.startdate AND fxlookup.enddate 

where p.projectid = 15078
GROUP BY
    tproject.uniqueid
    ,CASE
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 2 AND 4 THEN TO_DATE(EXTRACT(YEAR FROM   p.dt)||'-02-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 5 AND 7 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-05-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 8 AND 10 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-08-01')
              WHEN EXTRACT(MONTH FROM p.dt) BETWEEN 11 AND 12 THEN TO_DATE(EXTRACT(YEAR FROM p.dt)||'-11-01')
              ELSE TO_DATE(EXTRACT(YEAR FROM p.dt) - 1 ||'-11-01')
            END
  ,totalbasecurrency
  ,fxlookup.rate