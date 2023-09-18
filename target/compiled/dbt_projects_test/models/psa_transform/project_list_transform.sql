/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



WITH PROJECT AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TPROJECT
),

MAPDATA AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TMAPDATA
),

WORKFLOWMAP AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TWORKFLOWMAP
),
PPMPROJWFFLAGS AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TPPMPROJWFFLAGS
),

WFWORKFLOWVERSION AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TWFWORKFLOWVERSION
),
WFWORKFLOWACTIVITY AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TWFWORKFLOWACTIVITY
),
WFWORKFLOWACTIVITYFLAG AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TWFWORKFLOWACTIVITYFLAG
),
WFWORKFLOWACTIVITYDESC AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TWFWORKFLOWACTIVITYDESC
),

PROCESS_STATUS AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TPROCESS_STATUS
),
WFINSTANCEOBJECT AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TWFINSTANCEOBJECT
),
WFINSTANCEACTIVITY AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TWFINSTANCEACTIVITY
),
ACCCONSET AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TACCCONSET
),
TASK AS (
  SELECT
  *
  FROM
   EIO_PUBLISH.TENROX_PRIVATE.TTASK
),
TIMEENTRY AS (
  SELECT
  *
  FROM
   EIO_PUBLISH.TENROX_PRIVATE.TTIMEENTRY
),

TIMEENTRYRATE AS (
  SELECT
  *
  FROM
   EIO_PUBLISH.TENROX_PRIVATE.TTIMEENTRYRATE
),
PROJECTCUSTFLD AS (
  SELECT
  *
  FROM
   EIO_PUBLISH.TENROX_PRIVATE.TPROJECTCUSTFLD
),
CUSTLST AS (
  SELECT
  *
  FROM
   EIO_PUBLISH.TENROX_PRIVATE.TCUSTLST
),
CUSTLSTDESC AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TCUSTLSTDESC
),
TSITE AS (
  SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TSITE
),
COMPONENT AS (
   SELECT
  *
  FROM
  EIO_PUBLISH.TENROX_PRIVATE.TCOMPONENT
)

SELECT        sp.*,
       COALESCE(LSTDESC_1.VALUE, '') AS Industry,
       COALESCE(LST_1.ID, '') AS Industry_ID,
       COALESCE(LSTDESC_2.VALUE, '') AS Region,
       COALESCE(LST_2.ID, '') AS Region_ID,
                         a.ADSK_SFDCOppNo AS SFDC_Opportunity_No,
       COALESCE(TSITE3.NAME, SPACE(0)) AS GEO,

       a.ADSK_SAP_Project_ID AS SAP_Project_ID,
                         COALESCE(TCOMPONENT10.NAME, SPACE(0)) AS Master_Agreement_Name,

                         COALESCE(LSTDESC_16.VALUE, '') AS Master_Agreement___Project_Type,

       CASE WHEN a.ADSK_Master_ContractDate = '1900-01-01' THEN NULL
                         ELSE a.ADSK_Master_ContractDate END AS PA_Agreement_Term_Start_Date,
       a.ADSK_PA_Master_CreditsPurchased AS PA_Master___Total_Credits_Purchased,
                         CASE WHEN a.ADSK_PA_ExpirationDate1 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate1 END AS PA_Agreement_Expiration_Date_1,
       CASE WHEN a.ADSK_PA_ExpirationDate10 = '1900-01-01' THEN NULL
                         ELSE a.ADSK_PA_ExpirationDate10 END AS PA_Agreement_Expiration_Date_10,
       a.ADSK_PA_ExpirationDate10_Credits AS PA_Agreement_Expiring_Credits_10,
                         CASE WHEN a.ADSK_PA_ExpirationDate11 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate11 END AS PA_Agreement_Expiration_Date_11,
                         a.ADSK_PA_ExpirationDate11_Credits AS PA_Agreement_Expiring_Credits_11, CASE WHEN a.ADSK_PA_ExpirationDate12 = '1900-01-01' THEN NULL
                         ELSE a.ADSK_PA_ExpirationDate12 END AS PA_Agreement_Expiration_Date_12, a.ADSK_PA_ExpirationDate12_Credits AS PA_Agreement_Expiring_Credits_12,
                         a.ADSK_PA_ExpirationDate1_Credits AS PA_Agreement_Expiring_Credits_1, CASE WHEN a.ADSK_PA_ExpirationDate2 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate2 END AS PA_Agreement_Expiration_Date_2,
                         a.ADSK_PA_ExpirationDate2_Credits AS PA_Agreement_Expiring_Credits_2, CASE WHEN a.ADSK_PA_ExpirationDate3 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate3 END AS PA_Agreement_Expiration_Date_3,
                         a.ADSK_PA_ExpirationDate3_Credits AS PA_Agreement_Expiring_Credits_3, CASE WHEN a.ADSK_PA_ExpirationDate4 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate4 END AS PA_Agreement_Expiration_Date_4,
                         a.ADSK_PA_ExpirationDate4_Credits AS PA_Agreement_Expiring_Credits_4, CASE WHEN a.ADSK_PA_ExpirationDate5 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate5 END AS PA_Agreement_Expiration_Date_5,
                         a.ADSK_PA_ExpirationDate5_Credits AS PA_Agreement_Expiring_Credits_5, CASE WHEN a.ADSK_PA_ExpirationDate6 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate6 END AS PA_Agreement_Expiration_Date_6,
                         a.ADSK_PA_ExpirationDate6_Credits AS PA_Agreement_Expiring_Credits_6, CASE WHEN a.ADSK_PA_ExpirationDate7 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate7 END AS PA_Agreement_Expiration_Date_7,
                         a.ADSK_PA_ExpirationDate7_Credits AS PA_Agreement_Expiring_Credits_7, CASE WHEN a.ADSK_PA_ExpirationDate8 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate8 END AS PA_Agreement_Expiration_Date_8,
                         a.ADSK_PA_ExpirationDate8_Credits AS PA_Agreement_Expiring_Credits_8, CASE WHEN a.ADSK_PA_ExpirationDate9 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate9 END AS PA_Agreement_Expiration_Date_9,
                         a.ADSK_PA_ExpirationDate9_Credits AS PA_Agreement_Expiring_Credits_9, CASE WHEN a.ADSK_PA_ExpirationDate13 = '1900-01-01' THEN NULL
                         ELSE a.ADSK_PA_ExpirationDate13 END AS PA_Agreement_Expiration_Date_13, a.ADSK_PA_ExpirationDate13_Credits AS PA_Agreement_Expiring_Credits_13,
                         CASE WHEN a.ADSK_PA_ExpirationDate14 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate14 END AS PA_Agreement_Expiration_Date_14,
                         a.ADSK_PA_ExpirationDate14_Credits AS PA_Agreement_Expiring_Credits_14, CASE WHEN a.ADSK_PA_ExpirationDate15 = '1900-01-01' THEN NULL
                         ELSE a.ADSK_PA_ExpirationDate15 END AS PA_Agreement_Expiration_Date_15, a.ADSK_PA_ExpirationDate15_Credits AS PA_Agreement_Expiring_Credits_15,
                         CASE WHEN a.ADSK_PA_ExpirationDate16 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate16 END AS PA_Agreement_Expiration_Date_16,
                         a.ADSK_PA_ExpirationDate16_Credits AS PA_Agreement_Expiring_Credits_16, CASE WHEN a.ADSK_PA_ExpirationDate17 = '1900-01-01' THEN NULL
                         ELSE a.ADSK_PA_ExpirationDate17 END AS PA_Agreement_Expiration_Date_17, a.ADSK_PA_ExpirationDate17_Credits AS PA_Agreement_Expiring_Credits_17,
                         CASE WHEN a.ADSK_PA_ExpirationDate18 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate18 END AS PA_Agreement_Expiration_Date_18,
                         a.ADSK_PA_ExpirationDate18_Credits AS PA_Agreement_Expiring_Credits_18, CASE WHEN a.ADSK_PA_ExpirationDate19 = '1900-01-01' THEN NULL
                         ELSE a.ADSK_PA_ExpirationDate19 END AS PA_Agreement_Expiration_Date_19, a.ADSK_PA_ExpirationDate19_Credits AS PA_Agreement_Expiring_Credits_19,
                         CASE WHEN a.ADSK_PA_ExpirationDate20 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ExpirationDate20 END AS PA_Agreement_Expiration_Date_20,
                         a.ADSK_PA_ExpirationDate20_Credits AS PA_Agreement_Expiring_Credits_20, CASE WHEN a.ADSK_PA_SCO_Contract_Date = '1900-01-01' THEN NULL
                         ELSE a.ADSK_PA_SCO_Contract_Date END AS PA_SCO_Customer_Signature_Date, a.ADSK_PA_SCO_Expense_Credits AS PA_SCO_Expense_Credits, a.ADSK_PA_SCO_Labor_Credits AS PA_SCO_Labor_Credits,
                         a.ADSK_PA_ChangeOrderCredits_1 AS PA_Change_Order_Credits_1, a.ADSK_PA_ChangeOrderCredits_2 AS PA_Change_Order_Credits_2, a.ADSK_PA_ChangeOrderCredits_3 AS PA_Change_Order_Credits_3,
                         CASE WHEN a.ADSK_PA_ChangeOrderDate_1 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ChangeOrderDate_1 END AS PA_Change_Order_Date_1, CASE WHEN a.ADSK_PA_ChangeOrderDate_2 = '1900-01-01' THEN NULL
                         ELSE a.ADSK_PA_ChangeOrderDate_2 END AS PA_Change_Order_Date_2, CASE WHEN a.ADSK_PA_ChangeOrderDate_3 = '1900-01-01' THEN NULL ELSE a.ADSK_PA_ChangeOrderDate_3 END AS PA_Change_Order_Date_3,

       COALESCE(LSTDESC_24.VALUE, '') AS Time_Category,
       COALESCE(LST_24.ID, '') AS Time_Category_ID,

       COALESCE(LSTDESC_28.VALUE, '') AS CS_Service_Line,
       COALESCE(LST_28.ID, '') AS CS_Service_Line_ID,
       CASE WHEN a.ADSK_Planned_End_Date = '1900-01-01' THEN NULL
                         ELSE a.ADSK_Planned_End_Date END AS Planned_End_Date,

       COALESCE(LSTDESC_31.VALUE, '') AS Delivery_Manager,
       COALESCE(LST_31.ID, '') AS Delivery_Manager_ID,

       CASE WHEN a.ADSK_ContractEndDate = '1900-01-01' THEN NULL ELSE a.ADSK_ContractEndDate END AS Contract_End_Date,
                         CASE WHEN a.ADSK_ContractStartDate = '1900-01-01' THEN NULL ELSE a.ADSK_ContractStartDate END AS Contract_Start_Date,
       COALESCE(LSTDESC_33.VALUE, '') AS Delivery_Geo,
       COALESCE(LST_33.ID, '') AS Delivery_Geo_ID,
                         COALESCE(LSTDESC_34.VALUE, '') AS CSM_Lead,
       COALESCE(LST_34.ID, '') AS CSM_Lead_ID,
       COALESCE(LSTDESC_35.VALUE, '') AS AC_Contract_Type,
       COALESCE(LST_35.ID, '') AS AC_Contract_Type_ID,



       COALESCE(LSTDESC_37.VALUE, '')
                         AS Rev_Forecast_Contract_Type,
       COALESCE(LST_37.ID, '') AS Rev_Forecast_Contract_Type_ID,
       COALESCE(LSTDESC_38.VALUE, '') AS CS_Project_Type,

        a.ADSK_GOVESC_Reason AS Escalation_Reason, a.ADSK_GOVESC_Status AS Escalation_Status___Actions,
                         a.ADSK_ConfluenceOppId AS Confluence_Opportunity_Id
FROM            (

SELECT        p.UNIQUEID AS Project_Unique_ID,
       p.NAME AS Project,
       CASE p.ACCESSTYPE WHEN 1 THEN 1 ELSE 0 END AS Project_Is_Active,

       COALESCE(p.DESCRIPTION, '') AS Project_Description, COALESCE(p.ID, '') AS Project_ID,
                         COALESCE(p.RELEASEALIAS, '') AS Project_Code,
       COALESCE(p.TRACKINGNO, '') AS Project_Tracking_No,
       p.MANAGERID AS Active_Manager_Unique_ID,
                         p.ACTUALMGRID AS Project_Manager_Unique_ID,
       p.ALTERNATEMGRID AS Alternate_Manager_Unique_ID,
       p.CLIENTID AS Client_Unique_ID,
                         p.PORTFOLIOID AS Portfolio_Unique_ID,

       TPROJECT_PRIORITY.FIELDDESC AS Project_Priority,
       p.STARTDATE AS Project_Start,
       p.ENDDATE AS Project_End,
       TIMEPROJ.ACTUALSTART AS Project_Actual_Start,
                         TIMEPROJ.ACTUALEND AS Project_Actual_End,
       CASE WHEN p.PARENTID = 0 THEN '' ELSE PARENT.NAME END AS Project_Parent,
       wm.NAME AS Project_Workflow,
                         COALESCE(TACCCONSET.COMPANYNAME, '') AS Project_Company,

       COALESCE(LASTSTATE.LASTSTATUS, '') AS  Project_State,

       p.CREATEDON AS Project_Created_On,
                         p.CANBEINVOICED AS Project_Can_Be_Invoiced,
       p.OVERRIDEBILLABLE AS Project_Is_Override_Billable,
       p.BILLABLE AS Project_Is_Billable,
                         p.OVERRIDECOSTED AS Project_Is_Override_Payable,
       p.COSTED AS Project_Is_Payable, p.OVERRIDECUSTOM AS Project_Is_Override_Capitalized,
                         p.CUSTOM AS Project_Is_Capitalized,
       p.OVERRIDEFUNDED AS Project_Is_Override_Funded,
       p.FUNDED AS Project_Is_Funded,
                         p.OVERRIDERANDD AS Project_Is_Override_RandD,
       p.RANDD AS Project_Is_RandD
FROM           PROJECT  p INNER JOIN
                        MAPDATA AS TPROJECT_PRIORITY  ON TPROJECT_PRIORITY.TABLENAME = 'PROJECTPRIORITY' AND p.PRIORITY = TPROJECT_PRIORITY.FIELDKEY AND
                         TPROJECT_PRIORITY.LANGUAGE = 0 INNER JOIN
                        WORKFLOWMAP  wm ON p.PROJECTWORKFLOWMAPID = wm.UNIQUEID INNER JOIN
                        PROJECT AS PARENT  ON p.PARENTID = PARENT.UNIQUEID LEFT OUTER JOIN
                         ( SELECT STAT.PROJECTID,  CASE WHEN STAT.ISFINAL = 1 THEN STAT.DISPLAYNAME ELSE COALESCE(WFTINST.DISPLAYNAME, '') END AS LASTSTATUS
                            FROM
                                 (SELECT UNIQUEID AS PROJECTID, DISPLAYNAME, ISFINAL FROM
                                    (SELECT  TPROJECT.UNIQUEID, TWFWORKFLOWACTIVITYDESC.DISPLAYNAME, TPPMPROJWFFLAGS.ISFINAL,
                                       ROW_NUMBER () OVER(PARTITION BY TPROJECT.UNIQUEID ORDER BY TPROCESS_STATUS.TIMESTAMP DESC) AS RN
                                       from PROJECT TPROJECT
                                       inner join PPMPROJWFFLAGS TPPMPROJWFFLAGS
                                     on TPROJECT.UNIQUEID = TPPMPROJWFFLAGS.PROJECTID
                                       left join WFWORKFLOWVERSION  TWFWORKFLOWVERSION
                                     on TWFWORKFLOWVERSION.UNIQUEID = TPPMPROJWFFLAGS.WORKFLOWVERSIONID
                                       JOIN WFWORKFLOWACTIVITY TWFWORKFLOWACTIVITY
                                     ON TWFWORKFLOWACTIVITY.WORKFLOWVERSIONID =TWFWORKFLOWVERSION.UNIQUEID
                                       JOIN WFWORKFLOWACTIVITYFLAG TWFWORKFLOWACTIVITYFLAG
                                     ON  TWFWORKFLOWACTIVITY.UNIQUEID=TWFWORKFLOWACTIVITYFLAG.WORKFLOWACTIVITYID AND TWFWORKFLOWACTIVITYFLAG.ISFINAL=1
                                       JOIN WFWORKFLOWACTIVITYDESC TWFWORKFLOWACTIVITYDESC
                                     ON  TWFWORKFLOWACTIVITYDESC.WORKFLOWACTIVITYID=TWFWORKFLOWACTIVITYFLAG.WORKFLOWACTIVITYID AND TWFWORKFLOWACTIVITYDESC.LANGUAGE=0
                                       LEFT JOIN PROCESS_STATUS TPROCESS_STATUS
                                     ON TPROCESS_STATUS.ACTIVITYNAME = TWFWORKFLOWACTIVITY.NAME AND TPROCESS_STATUS.OBJECTID=TPROJECT.UNIQUEID AND TPROCESS_STATUS.OBJECTTYPE=501
                                   )
                           WHERE RN = 1) STAT
                                      LEFT OUTER JOIN
                                               (SELECT OBJECTID,DISPLAYNAME FROM (
                                                            SELECT        TWFINSTANCEOBJECT.OBJECTID, WFACTIVITYDESC.DISPLAYNAME,WFINSTACT.INSERTDATE,  ROW_NUMBER () over(partition by TWFINSTANCEOBJECT.OBJECTID order by WFINSTACT.INSERTDATE desc) as rn
                                                 FROM           WFINSTANCEOBJECT TWFINSTANCEOBJECT INNER JOIN
                                                                        WFINSTANCEACTIVITY  WFINSTACT ON WFINSTACT.INSTANCEOBJECTID = TWFINSTANCEOBJECT.UNIQUEID INNER JOIN
                                                                          WFWORKFLOWACTIVITYDESC  WFACTIVITYDESC  ON WFACTIVITYDESC.WORKFLOWACTIVITYID = WFINSTACT.WORKFLOWACTIVITYID

                                                 WHERE        (TWFINSTANCEOBJECT.OBJECTTYPE = 501) AND (WFACTIVITYDESC.LANGUAGE = 0)
                                                 )
                                                    WHERE RN = 1) WFTINST ON WFTINST.OBJECTID = STAT.PROJECTID) AS LASTSTATE ON LASTSTATE.PROJECTID = p.UNIQUEID


                       LEFT OUTER JOIN ACCCONSET as TACCCONSET ON p.ACCCONSETID = TACCCONSET.UNIQUEID LEFT OUTER JOIN
                             (SELECT        PROJECTID, MIN(ENTRYDATE) AS ACTUALSTART, MAX(ENTRYDATE) AS ACTUALEND
                               FROM            (SELECT        tt.PROJECTID, tte.CURRENTDATE AS ENTRYDATE, COUNT(*) AS NUMBER, SUM(COALESCE(ttr.COSTAMOUNTTOTAL, 0) * (CASE COALESCE(ttr.COSTEXCHANGERATE, 0) WHEN 0 THEN 1 ELSE COALESCE(ttr.COSTEXCHANGERATE, 0) END)) AS TIMECOST, SUM(COALESCE(ttr.COSTAMOUNTTOTAL, 0) * (CASE COALESCE(ttr.COSTEXCHANGERATE, 0)
                         WHEN 0 THEN 1 ELSE COALESCE(ttr.COSTEXCHANGERATE, 0) END) * (CASE WHEN COALESCE(ttr.POSTED, 0) > 0 THEN 1 ELSE 0 END)) AS TOTALPAIDTIME,
                         SUM(COALESCE(ttr.BILLABLEAMNTTOTAL, 0) * COALESCE(ttr.BILLEXCHANGERATE, 0) * COALESCE(ttr.BILLED, 0)) AS TOTALBILLEDTIME,
                         SUM(CASE WHEN COALESCE(ttr.ISRATED, 0) = 1 AND COALESCE(tte.BILLABLE, 0) = 1 AND tt.MILESTBILLING = 0 THEN COALESCE(ttr.BILLABLEAMNTTOTAL, 0)
                         * COALESCE(BILLEXCHANGERATE, 0) ELSE 0 END) AS TIMEBILLABLE, SUM(CASE WHEN COALESCE(ttr.ISRATED, 0) = 1 AND COALESCE(tte.BILLABLE, 0) = 1 AND
                         tt.MILESTBILLING = 0 THEN COALESCE(ttr.BILLABLEAMNTTOTAL, 0) * COALESCE(BILLEXCHANGERATE, 0) * COALESCE(BILLCURREXCHANGERATE, 0) ELSE 0 END) AS BILLABLETIMEAMNT_CLCURR,
                         SUM(COALESCE(ttr.BILLABLEAMNTTOTAL, 0) * COALESCE(ttr.BILLEXCHANGERATE, 0) * COALESCE(ttr.BILLED, 0) * (CASE COALESCE(ttr.BILLEXCHANGERATE, 0) WHEN 0 THEN 1 ELSE COALESCE(ttr.BILLEXCHANGERATE, 0) END) * (CASE WHEN COALESCE(ttr.BILLED, 0) > 0 AND COALESCE(ttr.INVOICEID, 0)
                         > 0 THEN 1 ELSE COALESCE(ttr.BILLED, 0) END)) AS BILLEDAMOUNT, SUM(CASE WHEN (COALESCE(tte.COSTEDTIMESPAN1, 0) + COALESCE(tte.COSTEDTIMESPAN2, 0)
                         + COALESCE(tte.COSTEDTIMESPAN3, 0)) = 0 THEN 0 ELSE (CASE WHEN (COALESCE(tte.BILLEDTIMESPAN1, 0) + COALESCE(tte.BILLEDTIMESPAN2, 0) + COALESCE(tte.BILLEDTIMESPAN3, 0))
                         = 0 THEN (COALESCE(tte.COSTEDTIMESPAN1, 0) + COALESCE(tte.COSTEDTIMESPAN2, 0) + COALESCE(tte.COSTEDTIMESPAN3, 0)) ELSE (COALESCE(tte.TIMESPAN, 0)
                         - (COALESCE(tte.BILLEDTIMESPAN1, 0) + COALESCE(tte.BILLEDTIMESPAN2, 0) + COALESCE(tte.BILLEDTIMESPAN3, 0))) END * (COALESCE(ttr.COSTAMOUNTTOTAL, 0)
                         * COALESCE(ttr.COSTEXCHANGERATE, 0)) / (COALESCE(tte.COSTEDTIMESPAN1, 0) + COALESCE(tte.COSTEDTIMESPAN2, 0) + COALESCE(tte.COSTEDTIMESPAN3, 0))) END)
                         AS TIMENONBILLABLE, SUM(COALESCE(tte.TIMESPAN, 0)) AS TOTALTIME, SUM(COALESCE(tte.BILLEDTIMESPAN1, 0) + COALESCE(tte.BILLEDTIMESPAN2, 0)
                         + COALESCE(tte.BILLEDTIMESPAN3, 0)) AS TOTALTIMEBILL, SUM(COALESCE(tte.TIMESPAN, 0) - (COALESCE(tte.BILLEDTIMESPAN1, 0) + COALESCE(tte.BILLEDTIMESPAN2, 0)
                         + COALESCE(tte.BILLEDTIMESPAN3, 0))) AS TOTALTIMENONBILL, SUM(COALESCE(tte.COSTEDTIMESPAN1, 0) + COALESCE(tte.COSTEDTIMESPAN2, 0)
                         + COALESCE(tte.COSTEDTIMESPAN3, 0)) AS TOTALTIMEPAYABLE, SUM(CASE WHEN COALESCE(tte.COSTED, 0) = 1 THEN COALESCE(ttr.COSTAMOUNTTOTAL, 0) * COALESCE(COSTEXCHANGERATE, 0) ELSE 0 END) AS PAYABLE_TIME
FROM           TASK tt INNER JOIN
                        TIMEENTRY tte ON tte.TASKID = tt.UNIQUEID INNER JOIN
                        TIMEENTRYRATE ttr ON ttr.TIMEENTRYUID = tte.UNIQUEID
WHERE        (ttr.SPLITBILCLIENTID = 0)
GROUP BY tt.PROJECTID, tte.CURRENTDATE)
                               GROUP BY PROJECTID) AS TIMEPROJ ON p.UNIQUEID = TIMEPROJ.PROJECTID
WHERE        (p.VIRTUAL = 0)

) as sp JOIN
                        PROJECTCUSTFLD AS a  ON a.PROJECTID = sp.Project_Unique_ID LEFT JOIN
                        CUSTLST AS LST_1  ON a.ADSK_Industry = LST_1.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_1  ON LST_1.UNIQUEID = LSTDESC_1.CUSTLSTID AND LSTDESC_1.LANGUAGE = 0 LEFT JOIN
                        CUSTLST AS LST_2  ON a.ADSK_Region = LST_2.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_2  ON LST_2.UNIQUEID = LSTDESC_2.CUSTLSTID AND LSTDESC_2.LANGUAGE = 0 LEFT JOIN
                        TSITE AS TSITE3  ON a.ADSK_Geo = TSITE3.UNIQUEID LEFT JOIN
                        COMPONENT AS TCOMPONENT10  ON a.ADSK_PA_Name = TCOMPONENT10.UNIQUEID LEFT JOIN
                        CUSTLST AS LST_16  ON a.ADSK_MasterAgreement_ProjectType = LST_16.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_16  ON LST_16.UNIQUEID = LSTDESC_16.CUSTLSTID AND LSTDESC_16.LANGUAGE = 0 LEFT JOIN
                        CUSTLST AS LST_24  ON a.ADSK_TimeCategory = LST_24.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_24  ON LST_24.UNIQUEID = LSTDESC_24.CUSTLSTID AND LSTDESC_24.LANGUAGE = 0 LEFT JOIN
                        CUSTLST AS LST_28  ON a.ADSK_GS_ServiceLine = LST_28.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_28  ON LST_28.UNIQUEID = LSTDESC_28.CUSTLSTID AND LSTDESC_28.LANGUAGE = 0 LEFT JOIN
                        CUSTLST AS LST_31  ON a.ADSK_GOVPMDOC_Delivery_Manager = LST_31.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_31  ON LST_31.UNIQUEID = LSTDESC_31.CUSTLSTID AND LSTDESC_31.LANGUAGE = 0 LEFT JOIN
                        CUSTLST AS LST_33  ON a.ADSK_GeoDelivery = LST_33.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_33  ON LST_33.UNIQUEID = LSTDESC_33.CUSTLSTID AND LSTDESC_33.LANGUAGE = 0 LEFT JOIN
                        CUSTLST AS LST_34  ON a.ADSK_CSMLead = LST_34.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_34  ON LST_34.UNIQUEID = LSTDESC_34.CUSTLSTID AND LSTDESC_34.LANGUAGE = 0 LEFT JOIN
                        CUSTLST AS LST_35  ON a.ADSK_AC_ContractType = LST_35.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_35  ON LST_35.UNIQUEID = LSTDESC_35.CUSTLSTID AND LSTDESC_35.LANGUAGE = 0 LEFT JOIN
                        CUSTLST AS LST_37  ON a.ADSK_AccountingContractType = LST_37.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_37  ON LST_37.UNIQUEID = LSTDESC_37.CUSTLSTID AND LSTDESC_37.LANGUAGE = 0 LEFT JOIN
                        CUSTLST AS LST_38  ON a.ADSK_CS_Project_Type = LST_38.UNIQUEID LEFT JOIN
                        CUSTLSTDESC AS LSTDESC_38  ON LST_38.UNIQUEID = LSTDESC_38.CUSTLSTID AND LSTDESC_38.LANGUAGE = 0