
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.adsk_cm_resource_details
  
   as (
    
/* ADSK_FN_CM_RESOURCE_DETAILS.sql
  @OverrideCurID   INT = 1
  , @Placeholder02 DATETIME = NULL
  , @Placeholder03 DATETIME = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/

WITH fxrate AS (
    SELECT * FROM EIO_INGEST.TENROX_TRANSFORM.fcurrqexchrate
    WHERE quotecurrencyid = 1
    -- traced back to final table CUST_ADSK_UTILIZATION_HOURS WHERE @OverrideCurID = DEFAULT of this adsk_cm_resource_details 
    -- @OverrideCurID in adsk_cm_resource_details default value = 1
    AND basecurrencyid = 1 AND CURRENT_DATE() BETWEEN startdate AND enddate
)

    SELECT
          tuser.uniqueid                                                AS resourceid
          , 0                                                           AS isrole
          , tuser.firstname                                             AS resourcefirstname
          , tuser.lastname                                              AS resourcelastname
          , NVL(tuser.firstname, '') || ' ' || NVL(tuser.lastname, '')  AS resourcefullname
          , NVL(tuser.lastname, '') || ', ' || NVL(tuser.firstname, '') AS resourcefullname_rev
          , tuser.emailaddress                                          AS resourceemailaddress
          , tuser.employeetype                                          AS resourceemployeetype
          , tuser.forecastcost * fxrate.rate                            AS resourcedefaultforecastcostrate
          , tuser.forecastbill * fxrate.rate                            AS resourcedefaultbillrate
          , tuser.groupid                                               AS resourceapprovalgroupid
          , group_app.name                                              AS resourceapprovalgroupname
          , tuser.functionalgroupid                                     AS resourcefunctionalgroupid
          , group_funct.name                                            AS resourcefunctionalgroupname
          , tuser.resgroupid                                            AS resourcegroupid
          , group_user.name                                             AS resourcegroupname
          , tuser.loginname                                             AS resourceloginname
          , tuser.titleid                                               AS resourcetitleid
          , ttitle.name                                                 AS resourcetitlename
          , mapdata_secgroup.fielddesc                                  AS resourcesecuritygroup
          , mapdata_usertype.fielddesc                                  AS resourceusertype
          , tresourcetype.uniqueid                                      AS resourcerestypeid
          , tresourcetype.name                                          AS resourcerestypename
          , 3                                                           AS sqlversion_resource_details
    FROM eio_publish.tenrox_private.tuser tuser
    LEFT OUTER JOIN eio_publish.tenrox_private.ttitle ttitle 
        ON ttitle.uniqueid = tuser.titleid
    LEFT OUTER JOIN eio_publish.tenrox_private.tmapdata mapdata_secgroup
        ON mapdata_secgroup.fieldkey = tuser.security
        AND mapdata_secgroup.language = 0
        AND mapdata_secgroup.tablename = 'SECURITY'
    LEFT OUTER JOIN eio_publish.tenrox_private.tmapdata mapdata_usertype
        ON mapdata_usertype.fieldkey = tuser.usertype
        AND mapdata_usertype.language = 0
        AND mapdata_usertype.tablename = 'USERTYPE'
    LEFT OUTER JOIN eio_publish.tenrox_private.tgroup group_app 
        ON group_app.uniqueid = tuser.groupid
    LEFT OUTER JOIN eio_publish.tenrox_private.tgroup group_funct 
        ON group_funct.uniqueid = tuser.functionalgroupid
    LEFT OUTER JOIN eio_publish.tenrox_private.tgroup group_user 
        ON group_user.uniqueid = tuser.resgroupid
    LEFT OUTER JOIN eio_publish.tenrox_private.tresourcetypehist tresourcetypehist
        ON tresourcetypehist.resourceid = tuser.uniqueid
        AND tresourcetypehist.startdate < CURRENT_DATE()
        AND tresourcetypehist.enddate >= CURRENT_DATE()
    LEFT OUTER JOIN eio_publish.tenrox_private.tresourcetype tresourcetype 
        ON tresourcetype.uniqueid = tresourcetypehist.resourcetypeid
    LEFT OUTER JOIN fxrate

    UNION

    SELECT 
          uniqueid               AS resourceid
          , 1                    AS isrole
          , ''                   AS resourcefirstname
          , name                 AS resourcelastname
          , name                 AS resourcefullname
          , name                 AS resourcefullname_rev
          , ''                   AS resourceemailaddress
          , 'Role'               AS resourceemployeetype
          , hourlycostrate       AS resourcedefaultforecastcostrate
          , hourlybillingrate    AS resourcedefaultbillrate
          , NULL                 AS resourceapprovalgroupid
          , NULL                 AS resourceapprovalgroupname
          , NULL                 AS resourcefunctionalgroupid
          , NULL                 AS resourcefunctionalgroupname
          , NULL                 AS resourcegroupid
          , NULL                 AS resourcegroupname
          , roletype             AS resourceloginname
          , NULL                 AS resourcetitleid
          , description          AS resourcetitlename
          , NULL                 AS resourcesecuritygroup
          , NULL                 AS resourceusertype
          , NULL                 AS resourcerestypeid
          , 'Role'               AS resourcerestypename
          , 3 AS sqlversion_resource_details
    FROM eio_publish.tenrox_private.tplanningrole tplanningrole
  );

