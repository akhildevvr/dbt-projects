
/* FCURRQEXCHRATE.sql
	@PBASECURRID INTEGER,
	@PQUOTECURRID INTEGER,
	@PDATE DATETIME

TOP 1 not included from original since the FX rate record row is selected via the ff:
  WHERE dbo.TCURRASSOC.BASECURRENCYID=@PBASECURRID
	  AND dbo.TCURRASSOC.QUOTECURRENCYID=@PQUOTECURRID
	  AND @PDATE BETWEEN dbo.TCURRRATE.STARTDATE AND dbo.TCURRRATE.ENDDATE
*/

SELECT
    ta.basecurrencyid
    , ta.quotecurrencyid
    , tc.rate
    , tc.startdate
    , tc.enddate
FROM eio_publish.tenrox_private.tcurrassoc AS ta
JOIN eio_publish.tenrox_private.tcurrrate AS tc ON ta.uniqueid = tc.curassocid 
ORDER BY tc.startdate DESC