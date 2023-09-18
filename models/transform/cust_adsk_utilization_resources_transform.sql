{{ config(
    alias='cust_adsk_utilization_resources'
) }}

/* CUST_ADSK_UTILIZATION_RESOURCES.sql
  @BatchSize           INT = 10000
  , @BatchNumber       INT = 0
  , @TerminationCutoff DATETIME = '2014-02-01'
  @SQLScriptVersion = 5
  CUST_ADSK_UTILIZATION_RESOURCES.sql Uses LEFT JOIN for non foregn currency exchange rate and month ranges joins
  The rest of the output tables in eio_publish.tenrox_private are left AS they are, that is; using LEFT OUTER JOIN
*/

WITH tmp_cust_adsk_utilization_resources AS (
    SELECT
          ROW_NUMBER()
                OVER (
                    ORDER BY tuser.uniqueid) AS rownumber
          , tuser.uniqueid                               AS userid
         -- catch employee id = '00001' and employee id = ''
          , CASE WHEN tuser.id = '00001' THEN '1'
                 WHEN tuser.id = '' THEN NULL
                 ELSE tuser.id END                       AS employeeid
          , tuser.lastname                               AS userlastname
          , tuser.firstname                              AS userfirstname
          , tuser.emailaddress                           AS email
          , site_master.name                             AS mastersite
          , site_active.name                             AS activesite
          , ttitle.name                                  AS title
          , group_app.name                               AS approvalgroup
          , NVL(group_appman.lastname, '') || ', '
                || NVL(group_appman.firstname, '')       AS approvalgroupmanager
          , group_funct.name                             AS functionalgroup
          , NVL(group_functman.lastname, '') || ', '
                || NVL(group_functman.firstname, '')     AS functionalgroupmanager
          , tholidayset.name                             AS holidayset
          , mapdata_secgroup.fielddesc                   AS securityrole
          , mapdata_usertype.fielddesc                   AS usertype
          , TO_DATE(tuser.datehired)                     AS hiredate
          , TO_DATE(tuser.servicedate)                   AS servicedate
          , CASE WHEN tuser.terminationdate = TO_DATE('2737-11-27') THEN NULL
                 ELSE TO_DATE(tuser.terminationdate) END AS terminationdate
         --, CONVERT(money, tuser.forecastcost, 1)       AS forecastedcostrate
         --, CONVERT(money, tuser.forecastbill, 1)       AS forecastedbillingrate
          , to_decimal(tuser.forecastcost)               AS forecastedcostrate
          , to_decimal(tuser.forecastbill)               AS forecastedbillingrate
          , CASE tuser.useraccessstatus WHEN 1 THEN 1
                                        ELSE 0 END       AS userisactive
          , tusercustfld.adsk_usertimetimefactor         AS usertimefactor
          , tusercustfld.adsk_utilizationtarget          AS userutilizationtarget
          , costrulerate.currentratecurrencycode         AS currentratecurrencycode
          , costrulerate.currentrate                     AS currentrate
          , TO_DATE(costrulerate.rateeffectivedate)      AS rateeffectivedate
          --, @sqlscriptversion AS sqlscriptversion
          , 5                                            AS sqlscriptversion
      FROM {{ source('tenrox_private', 'tuser') }} tuser
      LEFT JOIN {{ source('tenrox_private', 'tsite') }} site_active
          ON site_active.uniqueid = tuser.activesiteid
      LEFT JOIN {{ source('tenrox_private', 'tsite') }} site_master 
          ON site_master.uniqueid = tuser.siteid 
      LEFT JOIN {{ source('tenrox_private', 'ttitle') }} ttitle 
          ON ttitle.uniqueid = tuser.titleid 
      LEFT JOIN {{ source('tenrox_private', 'tgroup') }} group_app 
          ON group_app.uniqueid = tuser.groupid 
      LEFT JOIN {{ source('tenrox_private', 'tuser') }} group_appman 
          ON group_appman.uniqueid = group_app.manageruniqueid 
      LEFT JOIN {{ source('tenrox_private', 'tgroup') }} group_funct 
          ON group_funct.uniqueid = tuser.functionalgroupid 
      LEFT JOIN {{ source('tenrox_private', 'tuser') }} group_functman 
          ON group_functman.uniqueid = group_funct.manageruniqueid
      LEFT JOIN {{ source('tenrox_private', 'tholidayset') }} tholidayset 
          ON tholidayset.uniqueid = tuser.holidayset 
      LEFT JOIN {{ source('tenrox_private', 'tmapdata') }} mapdata_secgroup 
          ON mapdata_secgroup.fieldkey = tuser.security 
      -- AND MAPDATA_SECGROUP.LANGUAGE = 0
      -- AND MAPDATA_SECGROUP.TABLENAME = 'SECURITY'
      LEFT JOIN {{ source('tenrox_private', 'tmapdata') }} mapdata_usertype 
          ON mapdata_usertype.fieldkey = tuser.usertype 
      -- AND MAPDATA_USERTYPE.LANGUAGE = 0
      -- AND MAPDATA_USERTYPE.TABLENAME = 'USERTYPE'
      LEFT JOIN {{ source('tenrox_private', 'tusercustfld') }} tusercustfld 
          ON tusercustfld.userid = tuser.uniqueid
      LEFT JOIN (SELECT 
                    trateassociated.ownuserid       AS resourceid
                     , tcurrency.currencycode       AS currentratecurrencycode
                     , trateruleentry.rate1         AS currentrate
                     , CASE 
                         WHEN trateruleentry.datefrom < trateassociated.datefrom THEN trateassociated.datefrom
                         ELSE trateruleentry.datefrom 
                       END                          AS rateeffectivedate
                FROM {{ source('tenrox_private', 'traterule') }} traterule
                INNER JOIN {{ source('tenrox_private', 'trateassociated') }} trateassociated
                    ON trateassociated.rateruleid = traterule.uniqueid
                INNER JOIN {{ source('tenrox_private', 'trateruleentry') }} trateruleentry 
                    ON trateruleentry.rateruleid = traterule.uniqueid 
                INNER JOIN {{ source('tenrox_private', 'tcurrency') }} tcurrency 
                    ON tcurrency.uniqueid = traterule.currencyid
                INNER JOIN ( SELECT trateassociated.ownuserid, max(trateassociated.uniqueid) 
                    AS maxuid FROM {{ source('tenrox_private', 'trateassociated') }} trateassociated 
                GROUP BY trateassociated.ownuserid ) AS mostrecent 
                        ON mostrecent.ownuserid = trateassociated.ownuserid 
                        AND mostrecent.maxuid = trateassociated.uniqueid
                   ) AS costrulerate
                   ON costrulerate.resourceid = tuser.uniqueid
      WHERE IFNULL(tuser.id, '') IS NOT NULL
                  /* Original: AND ISNULL(TUSER.TERMINATIONDATE, '2737-11-27') >= @TerminationCutoff
                     Snowflake: AND IFNULL(TO_DATE(TUSER.TERMINATIONDATE), DATE'2737-11-27') >= DATE'2014-02-01'
                  Note: Having this conditional clause excludes some employee_id values from BSD_PUBLISH version of UTILIZATION_RESOURCE table
                  */
                  AND tuser.usertype = 'EMPLOYEE' 
                  AND tuser.useraccessstatus <> 100 
                  AND tuser.isadministrator <> 1
                  AND tuser.isdefaultuser <> 1 
                  AND tuser.lastname <> 'Administrator' 
                  AND tuser.lastname NOT LIKE '0-Sys Conv%'
                  AND tuser.lastname NOT LIKE '%3rd Party%' 
                  AND tuser.lastname NOT LIKE '1-%' 
                  AND mapdata_secgroup.language = 0
                  AND mapdata_secgroup.tablename = 'SECURITY' 
                  AND mapdata_usertype.language = 0
                  AND mapdata_usertype.tablename = 'USERTYPE'
        ORDER BY
          tuser.uniqueid
)
SELECT 
     rownumber
     , userid
     , employeeid
     , userlastname
     , userfirstname
     , email
     , mastersite
     , activesite
     , title
     , approvalgroup
     , approvalgroupmanager
     , functionalgroup
     , functionalgroupmanager
     , holidayset
     , securityrole
     , usertype
     , hiredate
     , servicedate
     , terminationdate
     , forecastedcostrate
     , forecastedbillingrate
     , userisactive
     , usertimefactor
     , userutilizationtarget
     , currentratecurrencycode
     , currentrate
     , rateeffectivedate
     , 1::BOOLEAN AS wasnewtable
     , sqlscriptversion
FROM tmp_cust_adsk_utilization_resources
     -- WHERE  RowNumber >= (0 * 10000) + 1
     -- AND RowNumber < (0 * 10000) + 10000 + 1
WHERE employeeid IS NOT NULL -- no NULL values for column 'employee_id' in BSD_PUBLISH.tenrox_private.TENROX_UTILIZATION_RESOURCES  
ORDER BY rownumber