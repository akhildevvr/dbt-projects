{{ config(
    alias='adsk_cm_deferred_rev'
) }}
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
FROM {{ ref('adsk_cm_monthly_deferred_rev_transform') }}
GROUP BY 
    projectid