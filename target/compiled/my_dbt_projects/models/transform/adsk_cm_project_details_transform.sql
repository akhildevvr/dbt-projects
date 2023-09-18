
/* ADSK_FN_CM_PROJECT_DETAILS*/

SELECT 
    tproject.uniqueid                                                       AS projectid
    , tproject.releasealias                                                 AS projectcode
    , tproject.name                                                         AS projectname
    , TO_DATE(tproject.startdate)                                           AS projectstartdate
    , TO_DATE(tproject.enddate)                                             AS projectenddate
    , pm.uniqueid                                                           AS projectmanagerid
    , IFNULL(NVL(pm.firstname, '') || ' ' || NVL(pm.lastname, ''), '')      AS projectmanagername
    , IFNULL(NVL(pm.lastname, '') || ', ' || NVL(pm.firstname, ''), '')     AS projectmanagername_rev
    , IFNULL(pm.id, '')                                                     AS projectmanageremployeeid
    , IFNULL(pm.emailaddress, '')                                           AS projectmanageremailaddress
    , IFNULL(
       NVL(pmalt.firstname, '') || ' ' || NVL(pmalt.lastname, ''), '')      AS altprojectmanagername
    , IFNULL(
       NVL(pmalt.lastname, '') || ', ' || NVL(pmalt.firstname, ''), '')     AS altprojectmanagername_rev
    , IFNULL(pmalt.id, '')                                                  AS altprojectmanageremployeeid
    , IFNULL(pmalt.emailaddress, '')                                        AS altprojectmanageremailaddress
    , IFNULL(tbl_state.projectstate, 'Closed')                              AS projectstate
    , tclientinvoice.currencyid                                             AS projectcurrencyid
    , IFNULL(tcurrency.currencycode, '')                                    AS projectcurrency
    , IFNULL(tcurrency.currencysymbol, '$')                                 AS projectcurrencysymbol
    , tportfolio.uniqueid                                                   AS portfolioid
    , tportfolio.name                                                       AS portfolioname
    , tportfolio.managerid                                                  AS portfoliomanagerid
    , IFNULL(
       NVL(portman.firstname, '') || ' ' || NVL(portman.lastname, ''), '')  AS portfoliomanagername
    , IFNULL(
       NVL(portman.lastname, '') || ', ' || NVL(portman.firstname, ''), '') AS portfoliomanagername_rev
    , IFNULL(portman.id, '')                                                AS portfoliomanageremployeeid
    , IFNULL(portman.emailaddress, '')                                      AS portfoliomanageremailaddress
    , tclient.uniqueid                                                      AS clientid
    , tclient.name AS clientname
    , tclient.id                                                            AS accountcsn
    , IFNULL(tcurrency.currencycode, '')                                    AS clientcurrency
    , tproject.trackingno                                                   AS tenroxtrackingno
    , 9                                                                     AS sqlversion_project_details  
FROM eio_publish.tenrox_private.tproject tproject
LEFT JOIN
    (
        SELECT 
            twfinstanceobject.objectid AS projectid, wfactivitydesc.displayname AS projectstate
        FROM eio_publish.tenrox_private.twfinstanceobject twfinstanceobject
        INNER JOIN
            eio_publish.tenrox_private.twfworkflowversion twfworkflowversion
            ON twfworkflowversion.uniqueid = twfinstanceobject.workflowversionid
        INNER JOIN
            eio_publish.tenrox_private.twfworkflow twfworkflow
            ON twfworkflow.uniqueid = twfworkflowversion.workflowid
        INNER JOIN
            eio_publish.tenrox_private.twfinstanceactivity AS wfinstact
            ON wfinstact.instanceguid = twfinstanceobject.instanceguid
        INNER JOIN
            eio_publish.tenrox_private.twfworkflowactivitydesc AS wfactivitydesc
            ON wfactivitydesc.workflowactivityid = wfinstact.workflowactivityid
        WHERE twfworkflow.objecttype = 501 AND wfactivitydesc.language = 0
    ) tbl_state
    ON tbl_state.projectid = tproject.uniqueid
LEFT JOIN eio_publish.tenrox_private.tportfolio tportfolio
    ON tportfolio.uniqueid = tproject.portfolioid
LEFT JOIN eio_publish.tenrox_private.tuser pm 
    ON tproject.managerid = pm.uniqueid
LEFT JOIN eio_publish.tenrox_private.tuser pmalt 
    ON tproject.alternatemgrid = pmalt.uniqueid
LEFT JOIN eio_publish.tenrox_private.tuser portman 
    ON tportfolio.managerid = portman.uniqueid
LEFT JOIN eio_publish.tenrox_private.tclient tclient 
    ON tclient.uniqueid = tproject.clientid
LEFT JOIN eio_publish.tenrox_private.tclientinvoice tclientinvoice 
    ON tclientinvoice.clientid = tproject.clientid
LEFT JOIN eio_publish.tenrox_private.tcurrency tcurrency 
    ON tcurrency.uniqueid = tclientinvoice.currencyid