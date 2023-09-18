
/* ADSK_FN_CM_MONTHLY_REC_REV.sql
  @OverrideCurID   INT = NULL
  , @Placeholder01 DATETIME = NULL
  , @Placeholder02 DATETIME = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
*/

SELECT
    -- TOP 100 PERCENT   /* attempt to create an ordered view */
    TPROJECT.UNIQUEID                                                             AS ProjectID
    , TRUNC(TRECOGNIZEDREVENUE.PERIODSTARTDATE, 'month')                          AS MonthRecognized
    , SUM(IFNULL(TRECOGNIZEDREVENUE.TOTALBASECURRENCY, 0.00)) * FXLookup.RATE     AS RecognizedRevenue
    , IFNULL(LUBaseCurrencyID, 1)                                                 AS SourceCurrencyID
    , IFNULL(OverrideCurID, 1)                                                    AS DestinationCurrencyID     /*@OverrideCurID is just null all the way to ADSK_FN_CM_LABOR_REV_V02. Final CUST_ADSK_MARGINVARIANCE does not mention @OverrideCurID*/
    , 4                                                                           AS SQLVersion_MONTHLY_REC_REV
FROM            eio_publish.tenrox_private.TPROJECT TPROJECT
LEFT OUTER JOIN eio_publish.tenrox_private.TRECOGNIZEDREVENUE TRECOGNIZEDREVENUE
                  ON TRECOGNIZEDREVENUE.PROJECTID = TPROJECT.UNIQUEID
LEFT OUTER JOIN eio_publish.tenrox_private.TCLIENT TCLIENT
                  ON TCLIENT.UNIQUEID = TPROJECT.CLIENTID
LEFT OUTER JOIN eio_publish.tenrox_private.TCLIENTINVOICE TCLIENTINVOICE
                  ON TCLIENT.UNIQUEID = TCLIENTINVOICE.CLIENTID
LEFT OUTER JOIN     (SELECT
                        IFNULL(UNIQUEID, 1) AS LUBaseCurrencyID
                      FROM   eio_publish.tenrox_private.TCURRENCY
                      WHERE  CURRENCYCODE = 'USD') BaseCUR
-- start: copy setup from CUST_ADSK_MARGINVARIANCE @OverrideCurID / @USDCurID
LEFT OUTER JOIN     (SELECT
                        IFNULL(UNIQUEID, 1) AS OverrideCurID
                      FROM   eio_publish.tenrox_private.TCURRENCY
                      WHERE  CURRENCYCODE = 'USD') USDCurID
-- end: copy setup from CUST_ADSK_MARGINVARIACNE @OverrideCurID / @USDCurID
LEFT OUTER JOIN eio_ingest.tenrox_sandbox_transform.fcurrqexchrate as FXLookup
        ON FXLookup.BASECURRENCYID = LUBaseCurrencyID
        -- traced back to CUST_ADSK_MARGINVARIANCE where @OverrideCurID  = @USDCurID = 1 
        AND FXLookup.QUOTECURRENCYID = COALESCE(NULL, TCLIENTINVOICE.CURRENCYID, LUBaseCurrencyID)
        AND TRECOGNIZEDREVENUE.PERIODSTARTDATE BETWEEN FXLookup.STARTDATE AND FXLookup.ENDDATE
GROUP BY
    TPROJECT.UNIQUEID
    , TRUNC(TRECOGNIZEDREVENUE.PERIODSTARTDATE, 'month') 
    , IFNULL(LUBaseCurrencyID, 1)
    , IFNULL(OverrideCurID, 1)
    , FXLookup.RATE
ORDER           BY
    TPROJECT.UNIQUEID
    , TRUNC(TRECOGNIZEDREVENUE.PERIODSTARTDATE, 'month')