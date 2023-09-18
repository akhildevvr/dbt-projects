
  create or replace   view eio_ingest.tenrox_sandbox_transform.adsk_fn_cm_forecast_labor_cost_rates
  
   as (
    
/* ADSK_FN_CM_FORECAST_LABOR_COST_RATES 
  @EffectiveDate   DATETIME = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/
    SELECT
       ptr.PROJECTID AS ProjectID
       , CASE ptr.ISROLE
           WHEN 0 THEN RESOURCEID
         END AS UserID
       , CASE ptr.ISROLE
           WHEN 1 THEN RESOURCEID
         END AS RoleID
       , ptr.ISROLE AS IsRole
       , IFNULL(CASE ptr.ISROLE
                  WHEN 0 THEN COALESCE(NULLIF(ProjAndUser.ForecastCostRate, 0), NULLIF(UserOnly.ForecastCostRate, 0), CASE ptr.ISCUSTOMFORECASTEDCOSTRATE
                                                                                                                        WHEN 1 THEN NULLIF(ptr.FORECASTEDCOSTRATE, 0)
                                                                                                                      END, NULLIF(u.FORECASTCOST, 0))
                  ELSE COALESCE(NULLIF(ProjAndRole.ForecastCostRate, 0), NULLIF(RoleOnly.ForecastCostRate, 0), CASE ptr.ISCUSTOMFORECASTEDCOSTRATE
                                                                                                                 WHEN 1 THEN NULLIF(ptr.FORECASTEDCOSTRATE, 0)
                                                                                                               END, NULLIF(plr.HOURLYCOSTRATE, 0))
                END, 0) AS ForecastCostRate
       , COALESCE(ProjAndUser.CurrencyID, UserOnly.CurrencyID, ProjAndRole.CurrencyID, RoleOnly.CurrencyID, 1) AS CurrencyID
       , 1 AS SQLVersion_FORECAST_LABOR_COST_RATES
     FROM eio_publish.tenrox_private.TPROJECTTEAMRESOURCE AS ptr
     LEFT JOIN eio_publish.tenrox_private.TUSER AS u
                  ON u.UNIQUEID = ptr.RESOURCEID
                 AND ptr.ISROLE = 0
     LEFT JOIN eio_publish.tenrox_private.TPLANNINGROLE AS plr
                  ON plr.UNIQUEID = ptr.RESOURCEID
                 AND ptr.ISROLE = 1
     LEFT JOIN (SELECT /* Project-to-User has priority */
                        rao.OBJECTID AS ProjectID
                        , rao.APPLYTOOBJECTID AS UserID
                        , 0 AS IsRole
                        , CASE
                            WHEN rao.STARTDATE < re.DATEFROM THEN re.DATEFROM
                            ELSE rao.STARTDATE
                          END AS STARTDATE
                        , CASE
                            WHEN rao.ENDDATE > re.DATETO THEN re.DATETO
                            ELSE rao.ENDDATE
                          END AS ENDDATE
                        , rr.CURRENCYID AS CurrencyID
                        , re.RATE1 AS ForecastCostRate
                      FROM eio_publish.tenrox_private.TRATEASSOCOBJECTLINK AS rao
                      JOIN eio_publish.tenrox_private.TRATERULE AS rr
                        ON (rao.RATERULEID = rr.UNIQUEID)
                      JOIN eio_publish.tenrox_private.TRATERULEENTRY AS re
                        ON (re.RATERULEID = rr.UNIQUEID)
                      WHERE  rr.TYPE = 0 -- COST
                         AND rr.PROCESSING = 0
                         AND rr.RATEENTRYTYPE = 1
                         AND rao.OBJECTTYPE = 2 --PROJECT
                         AND rao.APPLYTOOBJECTTYPE = 1 --USER
                         AND
                         (
                           CURRENT_DATE() BETWEEN rao.STARTDATE AND rao.ENDDATE
                         )
                     ) ProjAndUser
                  ON ProjAndUser.ProjectID = ptr.PROJECTID
                 AND ProjAndUser.UserID = ptr.RESOURCEID
                 AND ProjAndUser.IsRole = ptr.ISROLE
     LEFT JOIN (SELECT /* If no specified project rate for this user then use User rate with RATEMODE 1016 */
                        rao.OBJECTID AS UserID
                        , 0 AS IsRole
                        , CASE
                            WHEN rao.STARTDATE < re.DATEFROM THEN re.DATEFROM
                            ELSE rao.STARTDATE
                          END AS STARTDATE
                        , CASE
                            WHEN rao.ENDDATE > re.DATETO THEN re.DATETO
                            ELSE rao.ENDDATE
                          END AS ENDDATE
                        , rr.CURRENCYID AS CurrencyID
                        , re.RATE1 AS ForecastCostRate
                      FROM eio_publish.tenrox_private.TRATEASSOCOBJECTLINK AS rao
                      JOIN eio_publish.tenrox_private.TRATERULE AS rr
                        ON (rao.RATERULEID = rr.UNIQUEID)
                      JOIN eio_publish.tenrox_private.TRATERULEENTRY AS re
                        ON (re.RATERULEID = rr.UNIQUEID)
                      WHERE  rr.TYPE = 0 -- COST
                         AND rr.PROCESSING = 0
                         AND rr.RATEENTRYTYPE = 1
                         AND rao.OBJECTTYPE = 1 --USER
                         AND rao.APPLYTOOBJECTTYPE = 1 --USER
                         AND
                         (
                           CURRENT_DATE() BETWEEN rao.STARTDATE AND rao.ENDDATE
                         )
                     ) UserOnly
                  ON UserOnly.UserID = ptr.RESOURCEID
                 AND UserOnly.IsRole = ptr.ISROLE
     LEFT JOIN (SELECT /* If role, look for project specific role cost rates */
                        rao.OBJECTID AS ProjectID
                        , rao.APPLYTOOBJECTID AS RoleID
                        , 1 AS IsRole
                        , CASE
                            WHEN rao.STARTDATE < re.DATEFROM THEN re.DATEFROM
                            ELSE rao.STARTDATE
                          END AS STARTDATE
                        , CASE
                            WHEN rao.ENDDATE > re.DATETO THEN re.DATETO
                            ELSE rao.ENDDATE
                          END AS ENDDATE
                        , rr.CURRENCYID AS CurrencyID
                        , re.RATE1 AS ForecastCostRate
                      FROM eio_publish.tenrox_private.TRATEASSOCOBJECTLINK AS rao
                      JOIN eio_publish.tenrox_private.TRATERULE AS rr
                        ON (rao.RATERULEID = rr.UNIQUEID)
                      JOIN eio_publish.tenrox_private.TRATERULEENTRY  AS re
                        ON (re.RATERULEID = rr.UNIQUEID)
                      WHERE  rr.TYPE = 0 -- COST
                         AND rr.PROCESSING = 0
                         AND rr.RATEENTRYTYPE = 1
                         AND rao.OBJECTTYPE = 2 --PROJECT
                         AND rao.APPLYTOOBJECTTYPE = 700 --ROLE
                         AND
                         (
                           CURRENT_DATE() BETWEEN rao.STARTDATE AND rao.ENDDATE
                         )
                     ) ProjAndRole
                  ON ProjAndRole.ProjectID = ptr.PROJECTID
                 AND ProjAndRole.RoleID = ptr.RESOURCEID
                 AND ProjAndRole.IsRole = ptr.ISROLE
     LEFT JOIN (SELECT /* If no project-to-role rate is specified use the planning role rate */
                        rao.OBJECTID AS RoleID
                        , 1 AS IsRole
                        , CASE
                            WHEN rao.STARTDATE < re.DATEFROM THEN re.DATEFROM
                            ELSE rao.STARTDATE
                          END AS STARTDATE
                        , CASE
                            WHEN rao.ENDDATE > re.DATETO THEN re.DATETO
                            ELSE rao.ENDDATE
                          END AS ENDDATE
                        , rr.CURRENCYID AS CurrencyID
                        , re.RATE1 AS ForecastCostRate
                      FROM eio_publish.tenrox_private.TRATEASSOCOBJECTLINK AS rao
                      JOIN eio_publish.tenrox_private.TRATERULE AS rr
                        ON (rao.RATERULEID = rr.UNIQUEID)
                      JOIN eio_publish.tenrox_private.TRATERULEENTRY AS re
                        ON (re.RATERULEID = rr.UNIQUEID)
                      WHERE  rr.TYPE = 0 -- COST
                         AND rr.PROCESSING = 0
                         AND rr.RATEENTRYTYPE = 1
                         AND rao.OBJECTTYPE = 700 --ROLE
                         AND rao.APPLYTOOBJECTTYPE = 700 --ROLE
                         AND
                         (
                           CURRENT_DATE() BETWEEN rao.STARTDATE AND rao.ENDDATE
                         )
                     ) RoleOnly
                  ON RoleOnly.RoleID = ptr.RESOURCEID
                 AND RoleOnly.IsRole = ptr.ISROLE
  );

