
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.tprojectcustfld_view
  
   as (
    
/* TPROJECTCUSTFLD_VIEW UDFs used in
    adsk_cm_project_budget_V02
    CUST_ADSK_MARGINVARIANCE
    CUST_ADSK_SERVICESIMPACT_PROJECTDETAILS

*/


SELECT
     a.projectid
     , a.adsk_geo
     , a.hourly_rate_contractcurrency_adsk                                                                          AS hourly_rate_contractcurrency
     , a.hourly_rate_usd                                                                                      AS hourly_rate_usd
     , a.Total_Planned_Rev_USD_ADSK                                                                                 AS total_planned_rev_usd_adsk
     , IFNULL(tsite3.name, SPACE(0))                                                                                AS adsk_geo_name
     , IFNULL(tsite3.id, '')                                                                                        AS adsk_geo__id__
     , a.adsk_sap_project_id
     , IFNULL(lstdesc_11.value, '')                                                                                 AS adsk_projaccountant
     , IFNULL(lst_11.id, '')                                                                                        AS adsk_projaccountant__id__
--      , IFNULL(lstdesc_12.value, '')                                                                                 AS adsk_contractingentity
--      , IFNULL(lst_12.id, '')                                                                                        AS adsk_contractingentity__id__
     , IFNULL(lstdesc_16.value, '')                                                                                 AS adsk_masteragreement_projecttype
     , IFNULL(lst_16.id, '')                                                                                        AS adsk_masteragreement_projecttype__id__
     , IFNULL(lstdesc_20.value, '')                                                                                 AS adsk_revrectreatment
     , IFNULL(lst_20.id, '')                                                                                        AS adsk_revrectreatment__id__
--      , a.adsk_master_contractdate
     , a.adsk_contractenddate
     , a.adsk_contractstartdate
     , IFNULL(lstdesc_36.value, '')                                                                                 AS adsk_accountingcontracttype
     , IFNULL(lst_36.id, '')                                                                                        AS adsk_accountingcontracttype__id__
     , a.adsk_planned_end_date
FROM eio_publish.tenrox_private.tprojectcustfld AS a
LEFT JOIN eio_publish.tenrox_private.tsite AS tsite3
    ON a.adsk_geo = tsite3.uniqueid
LEFT JOIN eio_publish.tenrox_private.tcustlst AS lst_11 
    ON a.adsk_projaccountant = lst_11.uniqueid
LEFT JOIN eio_publish.tenrox_private.tcustlstdesc AS lstdesc_11 
    ON lst_11.uniqueid = lstdesc_11.custlstid AND lstdesc_11.language = 0
LEFT JOIN eio_publish.tenrox_private.tcustlst AS lst_16 
    ON a.adsk_masteragreement_projecttype = lst_16.uniqueid
LEFT JOIN eio_publish.tenrox_private.tcustlstdesc AS lstdesc_16 
    ON lst_16.uniqueid = lstdesc_16.custlstid AND lstdesc_16.language = 0
LEFT JOIN eio_publish.tenrox_private.tcustlst AS lst_20 
    ON a.adsk_revrectreatment = lst_20.uniqueid 
LEFT JOIN eio_publish.tenrox_private.tcustlstdesc AS lstdesc_20 
    ON lst_20.uniqueid = lstdesc_20.custlstid AND lstdesc_20.language = 0
LEFT JOIN eio_publish.tenrox_private.tcustlst AS lst_36 
    ON a.adsk_accountingcontracttype = lst_36.uniqueid 
LEFT JOIN eio_publish.tenrox_private.tcustlstdesc AS lstdesc_36 
    ON lst_36.uniqueid = lstdesc_36.custlstid AND lstdesc_36.language = 0
  );

