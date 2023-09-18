
/* ADSK_FN_CM_RESOURCE_DETAILS.sql
  @OverrideCurID   INT = 1
  , @Placeholder02 DATETIME = NULL
  , @Placeholder03 DATETIME = NULL
  , @Placeholder04 INT = NULL
  , @Placeholder05 INT = NULL
*/

with FXRate as (
  select * from eio_ingest.tenrox_sandbox_transform.fcurrqexchrate
  where QUOTECURRENCYID = 1
    -- traced back to final table CUST_ADSK_UTILIZATION_HOURS where @OverrideCurID = DEFAULT of this ADSK_FN_CM_RESOURCE_DETAILS 
    -- @OverrideCurID in ADSK_FN_CM_RESOURCE_DETAILS default value = 1
    and BASECURRENCYID = 1
    and CURRENT_DATE() BETWEEN STARTDATE AND ENDDATE
)

    SELECT
       TUSER.UNIQUEID                            AS ResourceID
       , 0                                       AS IsRole
       , TUSER.FIRSTNAME                         AS ResourceFirstName
       , TUSER.LASTNAME                          AS ResourceLastName
       , NVL(TUSER.FIRSTNAME, '') 
              ||  ' ' || 
              NVL(TUSER.LASTNAME, '')            AS ResourceFullName
       , NVL(TUSER.LASTNAME, '')
              ||  ', ' ||
              NVL(TUSER.FIRSTNAME, '')           AS ResourceFullName_Rev
       , TUSER.EMAILADDRESS                      AS ResourceEmailAddress
       , TUSER.EMPLOYEETYPE                      AS ResourceEmployeeType
       , TUSER.FORECASTCOST * FXRate.Rate        AS ResourceDefaultForecastCostRate
       , TUSER.FORECASTBILL * FXRate.Rate        AS ResourceDefaultBillRate
       , TUSER.GROUPID                           AS ResourceApprovalGroupID
       , GROUP_APP.NAME                          AS ResourceApprovalGroupName
       , TUSER.FUNCTIONALGROUPID                 AS ResourceFunctionalGroupID
       , GROUP_FUNCT.NAME                        AS ResourceFunctionalGroupName
       , TUSER.RESGROUPID                        AS ResourceGroupID
       , GROUP_USER.NAME                         AS ResourceGroupName
       , TUSER.LOGINNAME                         AS ResourceLoginName
       , TUSER.TITLEID                           AS ResourceTitleID
       , TTITLE.NAME                             AS ResourceTitleName
       , MAPDATA_SECGROUP.FIELDDESC              AS ResourceSecurityGroup
       , MAPDATA_USERTYPE.FIELDDESC              AS ResourceUserType
       , TRESOURCETYPE.UNIQUEID                  AS ResourceResTypeID
       , TRESOURCETYPE.NAME                      AS ResourceResTypeName
       , 3                                       AS SQLVersion_RESOURCE_DETAILS
     FROM            eio_publish.tenrox_private.TUSER TUSER
     LEFT OUTER JOIN eio_publish.tenrox_private.TTITLE TTITLE
                  ON TTITLE.UNIQUEID = TUSER.TITLEID
     LEFT OUTER JOIN eio_publish.tenrox_private.TMAPDATA MAPDATA_SECGROUP
                  ON MAPDATA_SECGROUP.FIELDKEY = TUSER.SECURITY
                 AND MAPDATA_SECGROUP.LANGUAGE = 0
                 AND MAPDATA_SECGROUP.TABLENAME = 'SECURITY'
     LEFT OUTER JOIN eio_publish.tenrox_private.TMAPDATA MAPDATA_USERTYPE
                  ON MAPDATA_USERTYPE.FIELDKEY = TUSER.USERTYPE
                 AND MAPDATA_USERTYPE.LANGUAGE = 0
                 AND MAPDATA_USERTYPE.TABLENAME = 'USERTYPE'
     LEFT OUTER JOIN eio_publish.tenrox_private.TGROUP GROUP_APP
                  ON GROUP_APP.UNIQUEID = TUSER.GROUPID
     LEFT OUTER JOIN eio_publish.tenrox_private.TGROUP GROUP_FUNCT
                  ON GROUP_FUNCT.UNIQUEID = TUSER.FUNCTIONALGROUPID
     LEFT OUTER JOIN eio_publish.tenrox_private.TGROUP GROUP_USER
                  ON GROUP_USER.UNIQUEID = TUSER.RESGROUPID
     LEFT OUTER JOIN eio_publish.tenrox_private.TRESOURCETYPEHIST TRESOURCETYPEHIST
                  ON TRESOURCETYPEHIST.RESOURCEID = TUSER.UNIQUEID
                 AND TRESOURCETYPEHIST.STARTDATE < CURRENT_DATE()
                 AND TRESOURCETYPEHIST.ENDDATE >= CURRENT_DATE()
     LEFT OUTER JOIN eio_publish.tenrox_private.TRESOURCETYPE TRESOURCETYPE
                  ON TRESOURCETYPE.UNIQUEID = TRESOURCETYPEHIST.RESOURCETYPEID
     LEFT OUTER JOIN FXRate

     UNION

     SELECT
       UNIQUEID            AS ResourceID
       , 1                 AS IsRole
       , ''                AS ResourceFirstName
       , NAME              AS ResourceLastName
       , NAME              AS ResourceFullName
       , NAME              AS ResourceFullName_Rev
       , ''                AS ResourceEmailAddress
       , 'Role'            AS ResourceEmployeeType
       , HOURLYCOSTRATE    AS ResourceDefaultForecastCostRate
       , HOURLYBILLINGRATE AS ResourceDefaultBillRate
       , NULL              AS ResourceApprovalGroupID
       , NULL              AS ResourceApprovalGroupName
       , NULL              AS ResourceFunctionalGroupID
       , NULL              AS ResourceFunctionalGroupName
       , NULL              AS ResourceGroupID
       , NULL              AS ResourceGroupName
       , ROLETYPE          AS ResourceLoginName
       , NULL              AS ResourceTitleID
       , DESCRIPTION       AS ResourceTitleName
       , NULL              AS ResourceSecurityGroup
       , NULL              AS ResourceUserType
       , NULL              AS ResourceResTypeID
       , 'Role'            AS ResourceResTypeName
       , 3                 AS SQLVersion_RESOURCE_DETAILS
     FROM  eio_publish.tenrox_private.TPLANNINGROLE TPLANNINGROLE