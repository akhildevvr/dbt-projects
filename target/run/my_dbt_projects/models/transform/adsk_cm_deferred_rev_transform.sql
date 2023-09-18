
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_cm_deferred_rev
  
   as (
    
/* ADSK_FN_CM_DEFERRED_REV
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/
SELECT 
    projectid                                   AS projectid
     , IFNULL(MAX(totaldeferredrevenue), 0.00)  AS totaldeferredrevenue
     , 1                                        AS sqlversion_deferred_rev
FROM EIO_INGEST.TENROX_TRANSFORM.adsk_cm_monthly_deferred_rev
GROUP BY 
    projectid
  );

