{{ config(
    alias='adsk_cm_monthly_rec_rev'
) }}
/* ADSK_FN_CM_MONTHLY_REC_REV.sql
  @OverrideCurID   INT = NULL
  , @Placeholder01 DATETIME = NULL
  , @Placeholder02 DATETIME = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
*/

SELECT
    -- TOP 100 PERCENT   /* attempt to create an ordered view */
    tproject.uniqueid                                                          AS projectid
     , trunc(trecognizedrevenue.periodstartdate, 'month')                      AS monthrecognized
     , SUM(IFNULL(trecognizedrevenue.totalbasecurrency, 0.00)) * fxlookup.rate AS recognizedrevenue
     , IFNULL(lubasecurrencyid, 1)                                             AS sourcecurrencyid
     , IFNULL(overridecurid, 1)                                                AS destinationcurrencyid /*@OverrideCurID is just null all the way to adsk_cm_labor_rev_v02. Final CUST_ADSK_MARGINVARIANCE does not mention @OverrideCurID*/
     , 4                                                                       AS sqlversion_monthly_rec_rev
FROM {{ source('tenrox_private', 'tproject') }} tproject
LEFT OUTER JOIN {{ source('tenrox_private', 'trecognizedrevenue') }} trecognizedrevenue
    ON trecognizedrevenue.projectid = tproject.uniqueid 
LEFT OUTER JOIN {{ source('tenrox_private', 'tclient') }} tclient 
    ON tclient.uniqueid = tproject.clientid 
LEFT OUTER JOIN {{ source('tenrox_private', 'tclientinvoice') }} tclientinvoice 
    ON tclient.uniqueid = tclientinvoice.clientid
LEFT OUTER JOIN     (SELECT
                        IFNULL(uniqueid, 1) AS lubasecurrencyid
                      FROM   {{ source('tenrox_private', 'tcurrency') }}
                      WHERE  currencycode = 'USD') basecur
-- start: copy setup from CUST_ADSK_MARGINVARIANCE @OverrideCurID / @USDCurID
LEFT OUTER JOIN     (SELECT
                        IFNULL(uniqueid, 1) AS overridecurid
                      FROM   {{ source('tenrox_private', 'tcurrency') }}
                      WHERE  currencycode = 'USD') usdcurid
-- end: copy setup from CUST_ADSK_MARGINVARIACNE @OverrideCurID / @USDCurID
LEFT OUTER JOIN {{ ref('fcurrqexchrate_transform') }} AS fxlookup
        ON fxlookup.basecurrencyid = lubasecurrencyid
        -- traced back to CUST_ADSK_MARGINVARIANCE WHERE @OverrideCurID  = @USDCurID = 1 
        AND fxlookup.quotecurrencyid = COALESCE(overridecurid, tclientinvoice.currencyid, lubasecurrencyid)
        AND trecognizedrevenue.periodstartdate BETWEEN fxlookup.startdate AND fxlookup.enddate
GROUP BY
    tproject.uniqueid
    , trunc(trecognizedrevenue.periodstartdate, 'month')
    , IFNULL(lubasecurrencyid, 1)
    , IFNULL(overridecurid, 1)
    , fxlookup.rate
ORDER BY
    tproject.uniqueid
    , TRUNC(trecognizedrevenue.periodstartdate, 'month') 