
  create or replace   view eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_const_curr
  
   as (
    
/* ADSK_FN_CM_CONST_CURR 
  @FiscalYear      INT = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
*/

SELECT
    cld.VALUE                                                       AS RateID
    , LEFT(cld.VALUE, ABS(CHARINDEX('-', cld.VALUE) - 1))           AS FiscalYear
    , RIGHT(cld.VALUE, ABS(CHARINDEX('-', REVERSE(cld.VALUE)) - 1)) AS CurrencyCode
    , cl.ID                                                         AS Rate
    , 1                                                             AS SQLVersion_CONST_CURR
FROM eio_publish.tenrox_private.TCUSTFLD  as cf
INNER JOIN eio_publish.tenrox_private.TCUSTLST  as cl
    ON cf.UNIQUEID = cl.CUSTFLDID
INNER JOIN eio_publish.tenrox_private.TCUSTLSTDESC  as cld 
    ON cld.CUSTLSTID = cl.UNIQUEID
WHERE cf.ID = 'ADSK_LU_Constant_Currency_Rates'
    AND cl.LANGUAGE = 0
    AND cld.LANGUAGE = 0
    AND LEFT(cld.VALUE, ABS(CHARINDEX('-', cld.VALUE) - 1)) = 'FY' || NVL(TO_VARCHAR(DATE_PART('YEAR', CURRENT_DATE()) + CASE WHEN DATE_PART('MONTH', CURRENT_DATE()) = 1 THEN 0 ELSE 1 END), '')
    /*  If current_date() produces 0 result. it appears that TCUSTLSTDESC.VALUE -1 max is FY18
    -- Original
                AND LEFT(TCUSTLSTDESC.VALUE, ABS(CHARINDEX('-', TCUSTLSTDESC.VALUE) - 1)) =
                'FY' + RIGHT(CONVERT(NVARCHAR(4), ISNULL(@FiscalYear, DATEPART(YEAR, GETDATE()) + CASE WHEN DATEPART(MONTH, GETDATE()) = 1
                THEN 0 ELSE 1
                END
                    )), 2)
    */
    -- When ADS_FN_CM_CONST_CURR.sql is queried directly from SSMS, result is = 0 recs
  );

