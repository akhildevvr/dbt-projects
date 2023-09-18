
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_cm_forecast_labor_cost_rates
  
   as (
    
/* ADSK_FN_CM_FORECAST_LABOR_COST_RATES 
  @EffectiveDate   DATETIME = NULL
  , @Placeholder02 INT = NULL
  , @Placeholder03 INT = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/
SELECT 
    ptr.projectid AS projectid
     , CASE ptr.isrole WHEN 0 THEN resourceid END AS userid
     , CASE ptr.isrole WHEN 1 THEN resourceid END AS roleid
     , ptr.isrole AS isrole
     , IFNULL(CASE ptr.isrole WHEN 0 THEN COALESCE(NULLIF(projanduser.forecastcostrate, 0),
                                                                         NULLIF(useronly.forecastcostrate, 0),
                                                                         CASE ptr.iscustomforecastedcostrate WHEN 1
                                                                                                                 THEN NULLIF(ptr.forecastedcostrate, 0) END,
                                                                         NULLIF(u.forecastcost, 0))
                                                    ELSE COALESCE(NULLIF(projandrole.forecastcostrate, 0),
                                                                  NULLIF(roleonly.forecastcostrate, 0),
                                                                  CASE ptr.iscustomforecastedcostrate WHEN 1
                                                                                                          THEN NULLIF(ptr.forecastedcostrate, 0) END,
                                                                  NULLIF(plr.hourlycostrate, 0)) END,
                                    0) AS forecastcostrate
     , COALESCE(projanduser.currencyid, useronly.currencyid, projandrole.currencyid, roleonly.currencyid,
                1) AS currencyid
     , 1 AS sqlversion_forecast_labor_cost_rates
    FROM eio_publish.tenrox_private.tprojectteamresource AS ptr
    LEFT JOIN
        eio_publish.tenrox_private.tuser AS u
        ON u.uniqueid = ptr.resourceid AND ptr.isrole = 0 
    LEFT JOIN eio_publish.tenrox_private.tplanningrole AS plr 
        ON plr.uniqueid = ptr.resourceid AND ptr.isrole = 1

     LEFT JOIN (SELECT /* Project-to-User has priority */
                            rao.objectid AS projectid
                            , rao.applytoobjectid AS userid
                            , 0 AS isrole
                            , CASE WHEN rao.startdate < re.datefrom THEN re.datefrom
                                ELSE rao.startdate END AS startdate
                            , CASE WHEN rao.enddate > re.dateto THEN re.dateto
                                ELSE rao.enddate END AS enddate
                            , rr.currencyid AS currencyid
                            , re.rate1 AS forecastcostrate
                        FROM eio_publish.tenrox_private.trateassocobjectlink AS rao
                        JOIN eio_publish.tenrox_private.traterule AS rr
                            ON (rao.rateruleid = rr.uniqueid) 
                        JOIN eio_publish.tenrox_private.trateruleentry AS re 
                            ON (re.rateruleid = rr.uniqueid)
                        WHERE rr.type = 0 -- COST
                            AND rr.processing = 0 
                            AND rr.rateentrytype = 1 
                            AND rao.objecttype = 2 -- PROJECT
                            AND rao.applytoobjecttype = 1 -- USER
                            AND (CURRENT_DATE() BETWEEN rao.startdate AND rao.enddate)
                        ) projanduser
                        ON projanduser.projectid = ptr.projectid 
                            AND projanduser.userid = ptr.resourceid 
                            AND projanduser.isrole = ptr.isrole
     LEFT JOIN (SELECT /* If no specified project rate for this user then use User rate with RATEMODE 1016 */
                            rao.objectid AS userid
                            , 0 AS isrole
                            , CASE WHEN rao.startdate < re.datefrom THEN re.datefrom
                                ELSE rao.startdate END AS startdate
                            , CASE WHEN rao.enddate > re.dateto THEN re.dateto
                                ELSE rao.enddate END AS enddate
                            , rr.currencyid AS currencyid
                            , re.rate1 AS forecastcostrate
                        FROM eio_publish.tenrox_private.trateassocobjectlink AS rao
                        JOIN
                            eio_publish.tenrox_private.traterule AS rr
                            ON (rao.rateruleid = rr.uniqueid)
                        JOIN
                            eio_publish.tenrox_private.trateruleentry AS re
                            ON (re.rateruleid = rr.uniqueid)
                        WHERE
                            rr.type = 0  -- COST
                            AND rr.processing = 0
                            AND rr.rateentrytype = 1
                            AND rao.objecttype = 1  -- USER
                            AND rao.applytoobjecttype = 1  -- USER
                            AND (CURRENT_DATE() BETWEEN rao.startdate AND rao.enddate)
                    ) useronly
                    ON useronly.userid = ptr.resourceid
                    AND useronly.isrole = ptr.isrole
     LEFT JOIN (SELECT /* If role, look for project specific role cost rates */
                            rao.objectid AS projectid
                            , rao.applytoobjectid AS roleid
                            , 1 AS isrole
                            , CASE WHEN rao.startdate < re.datefrom THEN re.datefrom
                                ELSE rao.startdate END AS startdate
                            , CASE WHEN rao.enddate > re.dateto THEN re.dateto
                                ELSE rao.enddate END AS enddate
                            , rr.currencyid AS currencyid
                            , re.rate1 AS forecastcostrate
                        FROM eio_publish.tenrox_private.trateassocobjectlink AS rao
                        JOIN eio_publish.tenrox_private.traterule AS rr
                            ON (rao.rateruleid = rr.uniqueid) 
                        JOIN eio_publish.tenrox_private.trateruleentry AS re 
                            ON (re.rateruleid = rr.uniqueid)
                        WHERE rr.type = 0 -- COST
                          AND rr.processing = 0
                          AND rr.rateentrytype = 1
                          AND rao.objecttype = 2 -- PROJECT
                          AND rao.applytoobjecttype = 700 -- ROLE
                          AND (CURRENT_DATE() BETWEEN rao.startdate AND rao.enddate) 
                      ) projandrole
                      ON projandrole.projectid = ptr.projectid 
                          AND projandrole.roleid = ptr.resourceid 
                          AND projandrole.isrole = ptr.isrole
     LEFT JOIN (SELECT /* If no project-to-role rate is specified use the planning role rate */
                            rao.objectid AS roleid
                            , 1 AS isrole
                            , CASE WHEN rao.startdate < re.datefrom THEN re.datefrom
                                ELSE rao.startdate END AS startdate
                             , CASE WHEN rao.enddate > re.dateto THEN re.dateto
                                    ELSE rao.enddate END AS enddate
                             , rr.currencyid AS currencyid
                             , re.rate1 AS forecastcostrate
                        FROM eio_publish.tenrox_private.trateassocobjectlink AS rao
                            JOIN eio_publish.tenrox_private.traterule AS rr
                              ON (rao.rateruleid = rr.uniqueid)
                        JOIN eio_publish.tenrox_private.trateruleentry AS re
                              ON (re.rateruleid = rr.uniqueid)
                        WHERE rr.type = 0 -- COST
                          AND rr.processing = 0 
                          AND rr.rateentrytype = 1 
                          AND rao.objecttype = 700 -- ROLE
                          AND rao.applytoobjecttype = 700 -- ROLE
                          AND (CURRENT_DATE() BETWEEN rao.startdate AND rao.enddate)
                      ) roleonly
                        ON roleonly.roleid = ptr.resourceid 
                        AND roleonly.isrole = ptr.isrole
  );

