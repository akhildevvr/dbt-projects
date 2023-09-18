
/* ADSK_FN_CM_DEFERRED_REV
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/
SELECT
    ProjectID                                 AS ProjectID
    , IFNULL(MAX(TotalDeferredRevenue), 0.00) AS TotalDeferredRevenue
    , 1                                       AS SQLVersion_DEFERRED_REV
FROM eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_monthly_deferred_rev
GROUP  BY
    ProjectID