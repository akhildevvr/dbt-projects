
/* ADSK_FN_CM_CONST_CURR 
  @FiscalYear      INT = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
*/

SELECT
    cld.value                                                       AS rateid
    , LEFT(cld.value, ABS(CHARINDEX('-', cld.value) - 1))           AS fiscalyear
    , RIGHT(cld.value, ABS(CHARINDEX('-', REVERSE(cld.value)) - 1)) AS currencycode
    , cl.id                                                         AS rate
    , 1                                                             AS sqlversion_const_curr
FROM eio_publish.tenrox_private.tcustfld  AS cf
INNER JOIN eio_publish.tenrox_private.tcustlst  AS cl
    ON cf.uniqueid = cl.custfldid
INNER JOIN eio_publish.tenrox_private.tcustlstdesc  AS cld 
    ON cld.custlstid = cl.uniqueid
WHERE cf.id = 'ADSK_LU_Constant_Currency_Rates'
    AND cl.language = 0
    AND cld.language = 0
    AND LEFT(cld.value, ABS(CHARINDEX('-', cld.value) - 1)) = 'FY' || NVL(TO_VARCHAR(DATE_PART('YEAR', CURRENT_DATE()) + CASE WHEN DATE_PART('MONTH', CURRENT_DATE()) = 1 THEN 0 ELSE 1 END), '')
    /*  If current_date() produces 0 result. it appears that TCUSTLSTDESC.VALUE -1 max is FY18
    -- Original
                AND LEFT(TCUSTLSTDESC.VALUE, ABS(CHARINDEX('-', TCUSTLSTDESC.VALUE) - 1)) =
                'FY' + RIGHT(CONVERT(NVARCHAR(4), ISNULL(@FiscalYear, DATEPART(YEAR, GETDATE()) + CASE WHEN DATEPART(MONTH, GETDATE()) = 1
                THEN 0 ELSE 1
                END
                    )), 2)
    */
    -- When ADS_FN_CM_CONST_CURR.sql is queried directly from SSMS, result is = 0 recs