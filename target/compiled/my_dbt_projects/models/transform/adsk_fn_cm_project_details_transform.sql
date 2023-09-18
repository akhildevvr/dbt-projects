
/* ADSK_FN_CM_PROJECT_DETAILS*/

    SELECT  
       TPROJECT.UNIQUEID                                                AS ProjectID  
       , TPROJECT.RELEASEALIAS                                          AS ProjectCode  
       , TPROJECT.NAME                                                  AS ProjectName  
       , TO_DATE(TPROJECT.STARTDATE)                                    AS ProjectStartDate  
       , TO_DATE(TPROJECT.ENDDATE)                                      AS ProjectEndDate  
       , PM.UNIQUEID                                                    AS ProjectManagerID  
       , IFNULL(NVL(PM.FIRSTNAME, '') 
                || ' ' || NVL(PM.LASTNAME, ''), '')                     AS ProjectManagerName  
       , IFNULL(NVL(PM.LASTNAME, '')
                || ', ' || NVL(PM.FIRSTNAME, ''), '')                   AS ProjectManagerName_Rev  
       , IFNULL(PM.ID, '')                                              AS ProjectManagerEmployeeID  
       , IFNULL(PM.EMAILADDRESS, '')                                    AS ProjectManagerEmailAddress  
       , IFNULL(NVL(PMAlt.FIRSTNAME, '') 
                || ' ' || NVL(PMAlt.LASTNAME, ''), '')                  AS AltProjectManagerName  
       , IFNULL(NVL(PMAlt.LASTNAME, '')
                || ', ' || NVL(PMAlt.FIRSTNAME, ''), '')                AS AltProjectManagerName_Rev  
       , IFNULL(PMAlt.ID, '')                                           AS AltProjectManagerEmployeeID  
       , IFNULL(PMAlt.EMAILADDRESS, '')                                 AS AltProjectManagerEmailAddress  
       , IFNULL(TBL_State.ProjectState, 'Closed')                       AS ProjectState  
       , TCLIENTINVOICE.CURRENCYID                                      AS ProjectCurrencyID  
       , IFNULL(TCURRENCY.CURRENCYCODE, '')                             AS ProjectCurrency  
       , IFNULL(TCURRENCY.CURRENCYSYMBOL, '$')                          AS ProjectCurrencySymbol  
       , TPORTFOLIO.UNIQUEID                                            AS PortfolioID  
       , TPORTFOLIO.NAME                                                AS PortfolioName  
       , TPORTFOLIO.MANAGERID                                           AS PortfolioManagerID  
       , IFNULL(NVL(PortMan.FIRSTNAME, '')
                || ' ' || NVL(PortMan.LASTNAME, ''), '')                AS PortfolioManagerName  
       , IFNULL(NVL(PortMan.LASTNAME, '')
                || ', ' || NVL(PortMan.FIRSTNAME, ''), '')              AS PortfolioManagerName_Rev  
       , IFNULL(PortMan.ID, '')                                         AS PortfolioManagerEmployeeID  
       , IFNULL(PortMan.EMAILADDRESS, '')                               AS PortfolioManagerEmailAddress  
       , TCLIENT.UNIQUEID                                               AS ClientID  
       , TCLIENT.NAME                                                   AS ClientName  
       , TCLIENT.ID                                                     AS AccountCSN  
       , IFNULL(TCURRENCY.CURRENCYCODE, '')                             AS ClientCurrency
       , TPROJECT.TRACKINGNO                                            AS TenroxTrackingNo
       , 9                                                              AS SQLVersion_PROJECT_DETAILS  
     FROM eio_publish.tenrox_private.TPROJECT TPROJECT  
     LEFT JOIN (SELECT  
                        TWFINSTANCEOBJECT.OBJECTID   AS ProjectID  
                        , WFACTIVITYDESC.DISPLAYNAME AS ProjectState  
                      FROM eio_publish.tenrox_private.TWFINSTANCEOBJECT TWFINSTANCEOBJECT  
                      INNER JOIN eio_publish.tenrox_private.TWFWORKFLOWVERSION TWFWORKFLOWVERSION  
                              ON TWFWORKFLOWVERSION.UNIQUEID = TWFINSTANCEOBJECT.WORKFLOWVERSIONID  
                      INNER JOIN eio_publish.tenrox_private.TWFWORKFLOW TWFWORKFLOW  
                              ON TWFWORKFLOW.UNIQUEID = TWFWORKFLOWVERSION.WORKFLOWID  
                      INNER JOIN eio_publish.tenrox_private.TWFINSTANCEACTIVITY AS WFINSTACT  
                              ON WFINSTACT.INSTANCEGUID = TWFINSTANCEOBJECT.INSTANCEGUID  
                      INNER JOIN eio_publish.tenrox_private.TWFWORKFLOWACTIVITYDESC AS WFACTIVITYDESC
                              ON WFACTIVITYDESC.WORKFLOWACTIVITYID = WFINSTACT.WORKFLOWACTIVITYID  
                      WHERE TWFWORKFLOW.OBJECTTYPE = 501
                        AND WFACTIVITYDESC.LANGUAGE = 0
                ) TBL_State ON TBL_State.ProjectID = TPROJECT.UNIQUEID  
    LEFT JOIN eio_publish.tenrox_private.TPORTFOLIO TPORTFOLIO  
                 ON TPORTFOLIO.UNIQUEID = TPROJECT.PORTFOLIOID  
    LEFT JOIN eio_publish.tenrox_private.TUSER PM  
                 ON TPROJECT.MANAGERID = PM.UNIQUEID  
    LEFT JOIN eio_publish.tenrox_private.TUSER PMAlt  
                 ON TPROJECT.ALTERNATEMGRID = PMAlt.UNIQUEID  
    LEFT JOIN eio_publish.tenrox_private.TUSER PortMan  
                 ON TPORTFOLIO.MANAGERID = PortMan.UNIQUEID  
    LEFT JOIN eio_publish.tenrox_private.TCLIENT TCLIENT  
                 ON TCLIENT.UNIQUEID = TPROJECT.CLIENTID  
    LEFT JOIN eio_publish.tenrox_private.TCLIENTINVOICE TCLIENTINVOICE  
                 ON TCLIENTINVOICE.CLIENTID = TPROJECT.CLIENTID  
    LEFT JOIN eio_publish.tenrox_private.TCURRENCY TCURRENCY  
                 ON TCURRENCY.UNIQUEID = TCLIENTINVOICE.CURRENCYID