 

WITH tproject AS (
    SELECT
	*
	FROM
	eio_publish.tenrox_private.TPROJECT
),
trecognizedrevenue AS (
	SELECT
					*
	FROM
					eio_publish.tenrox_private.TRECOGNIZEDREVENUE
),
tclient AS (
	SELECT
					*
	FROM
					eio_publish.tenrox_private.TCLIENT
),
tclientinvoice AS (
	SELECT
					*
	FROM
					eio_publish.tenrox_private.TCLIENTINVOICE
),
tcurrency AS (
	SELECT
					*
	FROM
					eio_publish.tenrox_private.TCURRENCY
),
adsk_fn_month_q_ranges_v02 AS (
	SELECT
					*
	FROM
					eio_ingest.tenrox_sandbox_transform.adsk_fn_month_q_ranges_v02
),
fcurrqexchrate AS (
	SELECT
					*
	FROM
					eio_ingest.tenrox_sandbox_transform.fcurrqexchrate
)
SELECT
    tproject.uniqueid AS project_id,
    SUM(nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0)) AS recrev_all,
    SUM(nvl(
    CASE
        WHEN
            periodstartdate < fnc_currentmonthbegins 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_past , SUM(nvl(
    CASE
        WHEN
            periodstartdate >= fnc_currentmonthbegins 
            AND periodstartdate < fnc_nextmonthbegins 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_currentmonth , SUM(nvl(
    CASE
        WHEN
            periodstartdate < fnc_currentqtrbegins 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_pastqtrs , SUM(nvl(
    CASE
        WHEN
            periodstartdate >= fnc_currentqtrbegins 
            AND periodstartdate < fnc_plus1qtrbegins 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_entirecurrentqtr , SUM(nvl(
    CASE
        WHEN
            periodstartdate >= fnc_currentqtrbegins 
            AND periodstartdate < fnc_currentmonthbegins 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_completedinqtr , SUM(nvl(
    CASE
        WHEN
            periodstartdate >= fnc_minus1qtrbegins 
            AND periodstartdate < fnc_currentqtrbegins 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_minus1qtr , SUM(nvl(
    CASE
        WHEN
            periodstartdate >= fnc_minus2qtrbegins 
            AND periodstartdate < fnc_minus1qtrbegins 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_minus2qtr , SUM(nvl(
    CASE
        WHEN
            periodstartdate >= fnc_minus3qtrbegins 
            AND periodstartdate < fnc_minus2qtrbegins 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_minus3qtr , SUM(nvl(
    CASE
        WHEN
            periodstartdate < fnc_minus3qtrbegins 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_priorqtrs , SUM(nvl(
    CASE
        WHEN
            periodstartdate >= fnc_hist_customrangebegin 
            AND periodstartdate < fnc_hist_customrangeend 
        THEN
            nvl(totalbasecurrency, 0.00) * nvl(fxlookup.rate, 1.0) 
        ELSE
            0.00 
    END
, 0.00)) AS recrev_customrange , MAX(fnc_hist_customrangebegin) AS recrev_customrangebegin , MAX(fnc_hist_customrangeend) AS recrev_customrangeend 
FROM
    tproject AS tproject 
    LEFT JOIN
        trecognizedrevenue AS trecognizedrevenue 
        ON trecognizedrevenue.projectid = tproject.uniqueid 
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
GROUP BY
    tproject.uniqueid