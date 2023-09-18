{{ config(
    alias='viewprojectlist'
) }}

/* viewprojectlist UDFs used in

*/

WITH ttask AS (
    SELECT * FROM {{ source('tenrox_private', 'ttask') }}
    ),
     ttimeentry AS (
         SELECT * FROM {{ source('tenrox_private', 'ttimeentry') }}
         ),
     tmilest AS (
         SELECT * FROM {{ source('tenrox_private', 'tmilest') }}
         ),
     tprojectteamresource AS (
         SELECT * FROM {{ source('tenrox_private', 'tprojectteamresource') }}
         ),
     tproject AS (
         SELECT * FROM {{ source('tenrox_private', 'tproject') }}
         ),
     tsysdefs AS (
         SELECT * FROM {{ source('tenrox_private', 'tsysdefs') }}
         ),
     tcurrency AS (
         SELECT * FROM {{ source('tenrox_private', 'tcurrency') }}
         ),
     tworkflowmap AS (
         SELECT * FROM {{ source('tenrox_private', 'tworkflowmap') }}
         ),
     tclient AS (
         SELECT * FROM {{ source('tenrox_private', 'tclient') }}
         ),
     tclientinvoice AS (
         SELECT * FROM {{ source('tenrox_private', 'tclientinvoice') }}
         ),
     tcurrassoc AS (
         SELECT * FROM {{ source('tenrox_private', 'tcurrassoc') }}
         ),
     tcurrrate AS (
         SELECT * FROM {{ source('tenrox_private', 'tcurrrate') }}
         ),
     tbudgetdetail AS (
         SELECT * FROM {{ source('tenrox_private', 'tbudgetdetail') }}
         ),
     tcurrency AS (
         SELECT * FROM {{ source('tenrox_private', 'tcurrency') }}
         ),
     tportfolio AS (
         SELECT * FROM {{ source('tenrox_private', 'tportfolio') }}
         ),
     tuser AS (
         SELECT * FROM {{ source('tenrox_private', 'tuser') }}
         ),
     tinvoiceproj AS (
         SELECT * FROM {{ source('tenrox_private', 'tinvoiceproj') }}
         ),
     tinvoicetask AS (
         SELECT * FROM {{ source('tenrox_private', 'tinvoicetask') }}
         ),
     tinvoicetime AS (
         SELECT * FROM {{ source('tenrox_private', 'tinvoicetime') }}
         ),
     tinvoiceexp AS (
         SELECT * FROM {{ source('tenrox_private', 'tinvoiceexp') }}
         ),
     tinvoicechrg AS (
         SELECT * FROM {{ source('tenrox_private', 'tinvoicechrg') }}
         ),
     texpentry AS (
         SELECT * FROM {{ source('tenrox_private', 'texpentry') }}
         ),
     tchargeentry AS (
         SELECT * FROM {{ source('tenrox_private', 'tchargeentry') }}
         ),
     tcharge AS (
         SELECT * FROM {{ source('tenrox_private', 'tcharge') }}
         ),
     ttimeentryrate AS (
         SELECT * FROM {{ source('tenrox_private', 'ttimeentryrate') }}
         ),
     tbudgetdetailentry AS (
         SELECT * FROM {{ source('tenrox_private', 'tbudgetdetailentry') }}
         ),
     tbudgetdetaillist AS (
         SELECT * FROM {{ source('tenrox_private', 'tbudgetdetaillist') }}
         ),
     tnote AS (
         SELECT * FROM {{ source('tenrox_private', 'tnote') }}
         ),
     tobjfldlink AS (
         SELECT * FROM {{ source('tenrox_private', 'tobjfldlink') }}
         ),
     tfolderitem AS (
         SELECT * FROM {{ source('tenrox_private', 'tfolderitem') }}
         ),
     viewbudgetdetaillist  AS (
         SELECT tbudgetdetail.objectid
              , tbudgetdetail.objecttype
              , tbudgetdetail.costcurrencyid
              , tbudgetdetail.billcurrencyid
              , tbudgetdetaillist.uniqueid          AS budgetlistuid
              , tbudgetdetaillist.name              AS budgetlistname
              , tbudgetdetaillist.startdate         AS budgetliststartdate
              , tbudgetdetaillist.enddate           AS budgetlistenddate
              , tbudgetdetaillist.description       AS budgetlistdesc
              , tbudgetdetaillist.ratecosttobasecur AS ratecosttobasecur
              , tbudgetdetaillist.ratebilltobasecur AS ratetocbillcur
              , tbudgetdetaillist.ratetocostcur     AS ratetocostcur
              , tbudgetdetaillist.ratetobillcur     AS ratetobillcur
              , COUNT(*)                        AS number
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrenttime
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinetime
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 3
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentbillabletime
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 3
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinebillabletime
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 4
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentnonbillabletime
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 1 AND tbudgetdetailentry.entrysubtype = 4
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinenonbillabletime
--cost root
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentcostprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinecostprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetcurrentcostbasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetbaselinecostbasecurrency


--cost time
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentcostprojtimecostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinecostprojtimecostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetcurrenttimecostbasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetbaselinetimecostbasecurrency
--cost expense
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentexpensecostprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselineexpensecostprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetcurrentexpensecostbasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetbaselineexpensecostbasecurrency

--cost charge
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentchargecostprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinechargecostprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetcurrentchargecostbasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetbaselinechargecostbasecurrency
--cost product
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentproductcostprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselineproductcostprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetcurrentproductcostbasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 2 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetbaselineproductcostbasecurrency

--billable root
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentbillableclientcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinebillableclientcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratebilltobasecur
                               ELSE 0 END, 0))      AS budgetcurrentbillablebasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratebilltobasecur
                               ELSE 0 END, 0))      AS budgetbaselinebillablebasecurrency

--billable time
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrenttimebillableclientcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinetimebillableclientcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratebilltobasecur
                               ELSE 0 END, 0))      AS budgetcurrenttimebillablebasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratebilltobasecur
                               ELSE 0 END, 0))      AS budgetbaselinetimebillablebasecurrency
--billable expense
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentexpensebillableclientcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselineexpensebillableclientcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratebilltobasecur
                               ELSE 0 END, 0))      AS budgetcurrentexpensebillablebasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratebilltobasecur
                               ELSE 0 END, 0))      AS budgetbaselineexpensebillablebasecurrency
--billable charge
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentchargebillableclientcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinechargebillableclientcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratebilltobasecur
                               ELSE 0 END, 0))      AS budgetcurrentchargebillablebasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratebilltobasecur
                               ELSE 0 END, 0))      AS budgetbaselinechargebillablebasecurrency
--billable product
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentproductbillableclientcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselineproductbillableclientcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratebilltobasecur
                               ELSE 0 END, 0))      AS budgetcurrentproductbillablebasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 3 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratebilltobasecur
                               ELSE 0 END, 0))      AS budgetbaselineproductbillablebasecurrency

--nonbillable root
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentnonbillableprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinenonbillableprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetcurrentnonbillablebasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetbaselinenonbillablebasecurrency
--nonbillable time
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrenttimenonbillableprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinetimenonbillableprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetcurrenttimenonbillablebasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 4 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetbaselinetimenonbillablebasecurrency

--nonbillable expense
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentexpensenonbillableprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselineexpensenonbillableprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetcurrentexpensenonbillablebasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 1 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetbaselineexpensenonbillablebasecurrency
--nonbillable charge
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentchargenonbillableprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselinechargenonbillableprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetcurrentchargenonbillablebasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 2 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetbaselinechargenonbillablebasecurrency

--nonbillable product
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue
                               ELSE 0 END, 0))      AS budgetcurrentproductnonbillableprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue
                               ELSE 0 END, 0))      AS budgetbaselineproductnonbillableprojcostcurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.currentvalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetcurrentproductnonbillablebasecurrency
              , SUM(COALESCE(CASE
                               WHEN tbudgetdetailentry.entrytype = 4 AND tbudgetdetailentry.entrysubtype = 3 and
                                    tbudgetdetailentry.objectid IS NULL
                                   THEN tbudgetdetailentry.baselinevalue * tbudgetdetaillist.ratecosttobasecur
                               ELSE 0 END, 0))      AS budgetbaselineproductnonbillablebasecurrency

         FROM tbudgetdetailentry
                  JOIN tbudgetdetaillist ON tbudgetdetaillist.uniqueid = tbudgetdetailentry.budgetdetailedlistid
                  JOIN tbudgetdetail ON tbudgetdetail.uniqueid = tbudgetdetaillist.budgetdetailedid
         GROUP BY tbudgetdetail.objectid, tbudgetdetail.objecttype, tbudgetdetail.costcurrencyid
                , tbudgetdetaillist.uniqueid, tbudgetdetaillist.name, tbudgetdetaillist.startdate
                , tbudgetdetaillist.enddate, tbudgetdetaillist.description, tbudgetdetaillist.startdate
                , tbudgetdetaillist.enddate
                , tbudgetdetaillist.ratecosttobasecur, tbudgetdetaillist.ratetocostcur
                , tbudgetdetaillist.ratebilltobasecur
                , tbudgetdetail.billcurrencyid, tbudgetdetaillist.ratetobillcur
         ),
     viewbudgetdetailtotals_proj AS (
         SELECT 2                                                            objecttype
              , budgetinfo.objectid                                          objectid
              , SUM(budgetinfo.budgetcurrenttime)                         AS bdgtimecurrent
              , SUM(budgetinfo.budgetbaselinetime)                        AS bdgtimebaseline
              , SUM(budgetinfo.budgetcurrentbillabletime)                 AS bdgtimebillcurrent
              , SUM(budgetinfo.budgetbaselinebillabletime)                AS bdgtimebillbaseline
              , SUM(budgetinfo.budgetcurrentnonbillabletime)              AS bdgtimenonbillcurrent
              , SUM(budgetinfo.budgetbaselinenonbillabletime)             AS bdgtimenonbillbaseline
              , SUM(budgetinfo.budgetcurrentcostprojcostcurrency)         AS bdgcostcurrent
              , SUM(budgetinfo.budgetbaselinecostprojcostcurrency)        AS bdgcostbaseline
              , SUM(budgetinfo.budgetcurrentcostbasecurrency)             AS bdgcostcurrent_bc
              , SUM(budgetinfo.budgetbaselinecostbasecurrency)            AS bdgcostbaseline_bc
              , SUM(budgetinfo.budgetcurrentcostprojtimecostcurrency)     AS bdgcosttimecurrent
              , SUM(budgetinfo.budgetbaselinecostprojtimecostcurrency)    AS bdgcosttimebaseline
              , SUM(budgetinfo.budgetcurrenttimecostbasecurrency)         AS bdgcosttimecurrent_bc
              , SUM(budgetinfo.budgetbaselinetimecostbasecurrency)        AS bdgcosttimebaseline_bc
              , SUM(budgetinfo.budgetcurrentbillableclientcurrency)       AS bdgbillcurrent
              , SUM(budgetinfo.budgetbaselinebillableclientcurrency)      AS bdgbillbaseline
              , SUM(budgetinfo.budgetcurrentbillablebasecurrency)         AS bdgbillcurrent_bc
              , SUM(budgetinfo.budgetbaselinebillablebasecurrency)        AS bdgbillbaseline_bc
              , SUM(budgetinfo.budgetcurrenttimebillableclientcurrency)   AS bdgbilltimecurrent
              , SUM(budgetinfo.budgetbaselinetimebillableclientcurrency)  AS bdgbilltimebaseline
              , SUM(budgetinfo.budgetcurrenttimebillablebasecurrency)     AS bdgbilltimecurrent_bc
              , SUM(budgetinfo.budgetbaselinetimebillablebasecurrency)    AS bdgbilltimebaseline_bc
              --non billable root
              , SUM(budgetinfo.budgetcurrentnonbillableprojcostcurrency)  AS bdgnbilcurrent
              , SUM(budgetinfo.budgetbaselinenonbillableprojcostcurrency) AS bdgnbilbaseline
              , SUM(budgetinfo.budgetcurrentnonbillablebasecurrency)      AS bdgnbilcurrent_bc
              , SUM(budgetinfo.budgetbaselinenonbillablebasecurrency)     AS bdgnbilbaseline_bc
         FROM viewbudgetdetaillist budgetinfo
         WHERE objecttype =2
         GROUP BY budgetinfo.objectid
         ),
     viewexpense_proj AS (
         SELECT ttask.projectid
              , texpentry.currentdate
              , COUNT(*)                                                               AS number
              , SUM(COALESCE(CASE
                               WHEN texpentry.payable = 1
                                   THEN finalamount
                               ELSE 0 END, 0))                                             AS expensecost
              , SUM(COALESCE(CASE
                               WHEN texpentry.payable = 1
                                   THEN amountwithtips * COALESCE(texpentry.billcurrexchangerate, 0)
                               ELSE 0 END, 0))                                             AS expensecost_clc
              , SUM(COALESCE(CASE
                               WHEN texpentry.billable = 1
                                   THEN totamtwithmarkup
                               ELSE 0 END, 0))                                             AS expensebillable
              , SUM(COALESCE(CASE
                               WHEN texpentry.payable = 1 AND texpentry.billable = 0
                                   THEN totamtwithmarkup
                               ELSE 0 END, 0))                                             AS expensenonbillable
              , SUM(COALESCE(CASE
                               WHEN texpentry.payable = 1 AND texpentry.billable = 0
                                   THEN amountwithtips
                               ELSE 0 END, 0) * COALESCE(texpentry.billcurrexchangerate, 0)) AS expensenonbillable_clc
              , SUM(COALESCE(CASE
                               WHEN texpentry.reimbursable = 1
                                   THEN finalamount
                               ELSE 0 END, 0))                                             AS expensereimbursable
              , SUM(COALESCE(CASE
                               WHEN texpentry.reimbursable = 1
                                   THEN amountwithtips
                               ELSE 0 END, 0))                                             AS expensereimbursable_clc
              , SUM(COALESCE(totamtwithmarkup, 0))                                           AS expensetotal
              , SUM(COALESCE(texpentry.amountwithtips * (1. + texpentry.markuppercentage / 100.), 0) *
                    COALESCE(texpentry.billcurrexchangerate, 0))                             AS expensetotal_clc
              , SUM(COALESCE(CASE
                               WHEN texpentry.billable = 1
                                   THEN totamtwithmarkup *
                                   --tcurrrate.rate
                                        COALESCE(texpentry.billcurrexchangerate, 0)
                               ELSE 0 END, 0))                                             AS expensebillable_clc
         FROM texpentry
                  JOIN ttask ON texpentry.taskid = ttask.uniqueid
         GROUP BY ttask.projectid, texpentry.currentdate
         ),
     viewmoneycharge_proj AS (
         SELECT ttask.projectid
              , tchargeentry.currentdate
              , COUNT(*)                                          AS number
              , SUM(CASE
                        WHEN tchargeentry.costed = 1
                            THEN tchargeentry.amountbasecurrency
                        ELSE 0 END)                                   AS chargecost
              , SUM(CASE
                        WHEN tchargeentry.costed = 1
                            THEN COALESCE(tchargeentry.amount, 0)
                        ELSE 0 END * COALESCE(billcurrexchangerate, 0)) AS chargecost_clc
              , SUM(CASE
                        WHEN tchargeentry.billable = 1
                            THEN tchargeentry.amountbasecurrency
                        ELSE 0 END)                                   AS chargebillable
              , SUM(CASE
                        WHEN tchargeentry.costed = 1 AND tchargeentry.billable = 0
                            THEN tchargeentry.amountbasecurrency
                        ELSE 0 END)                                   AS chargenonbillable
              , SUM(tchargeentry.amountbasecurrency)                  AS chargetotal
              , SUM(CASE
                        WHEN tchargeentry.billable = 1
                            THEN tchargeentry.amountclientcurrency
                        ELSE 0 END)                                   AS chargebillable_clc --clientcurrency
         FROM tchargeentry
                  JOIN ttask ON tchargeentry.taskid = ttask.uniqueid
                  JOIN tcharge ON tchargeentry.chargeid = tcharge.uniqueid
         WHERE tcharge.chargetype = 'M' --for charges
         GROUP BY ttask.projectid, tchargeentry.currentdate
         ),
     viewproduct_proj AS (
         SELECT ttask.projectid
              , tchargeentry.currentdate
              , COUNT(*)                              AS number
              , SUM(COALESCE(CASE
                               WHEN tchargeentry.costed = 1
                                   THEN tchargeentry.costedamount
                               ELSE 0 END, 0))            AS productcost
              , SUM(COALESCE(CASE
                               WHEN tchargeentry.costed = 1
                                   THEN COALESCE(tchargeentry.costamountcostcurrency, 0) *
                                        COALESCE(tchargeentry.billcurrexchangerate, 0)
                               ELSE 0 END, 0))            AS productcost_clc
              , SUM(COALESCE(CASE
                               WHEN tchargeentry.billable = 1
                                   THEN tchargeentry.amountbasecurrency
                               ELSE 0 END, 0))            AS productbillable
              , SUM(COALESCE(CASE
                               WHEN tchargeentry.costed = 1 AND tchargeentry.billable = 0
                                   THEN tchargeentry.costedamount
                               ELSE 0 END, 0))            AS productnonbillable
              , SUM(COALESCE(CASE
                               WHEN tchargeentry.costed = 1 AND tchargeentry.billable = 0
                                   THEN COALESCE(tchargeentry.costamountcostcurrency, 0) *
                                        COALESCE(tchargeentry.billcurrexchangerate, 0)
                               ELSE 0 END, 0))            AS productnonbillable_clc
              , SUM(COALESCE(tchargeentry.costedamount, 0)) AS producttotal
              , SUM(COALESCE(CASE
                               WHEN tchargeentry.billable = 1
                                   THEN tchargeentry.amountclientcurrency
                               ELSE 0 END, 0))            AS productbillable_clc
         FROM tchargeentry
                  JOIN ttask ON tchargeentry.taskid = ttask.uniqueid
                  JOIN tcharge ON tchargeentry.chargeid = tcharge.uniqueid
         WHERE tcharge.chargetype = 'N' -- Product
         GROUP BY ttask.projectid, tchargeentry.currentdate
         ),
     viewtimesheetentries_proj AS (
         SELECT ttask.projectid
              , ttimeentry.currentdate                                                                                     AS entrydate
              , COUNT(*)                                                                                               AS number
              , SUM(COALESCE(ttimeentryrate.costamounttotal, 0) * (CASE COALESCE(ttimeentryrate.costexchangerate, 0)
                                                                     WHEN 0 THEN 1
                                                                     ELSE COALESCE(ttimeentryrate.costexchangerate, 0) END)) AS timecost
              , SUM(COALESCE(ttimeentryrate.costamounttotal, 0) * (CASE COALESCE(ttimeentryrate.costexchangerate, 0)
                                                                     WHEN 0 THEN 1
                                                                     ELSE COALESCE(ttimeentryrate.costexchangerate, 0) END) *
                    (CASE WHEN COALESCE(ttimeentryrate.posted, 0) > 0 THEN 1 ELSE 0 END))                                    AS totalpaidtime
              , SUM(COALESCE(ttimeentryrate.billableamnttotal, 0) * COALESCE(billexchangerate, 0) *
                    COALESCE(billed, 0))                                                                                     AS totalbilledtime
              , SUM(CASE
                        WHEN COALESCE(ttimeentryrate.israted, 0) = 1 AND COALESCE(ttimeentry.billable, 0) = 1 and
                             ttask.milestbilling = 0 THEN COALESCE(ttimeentryrate.billableamnttotal, 0) *
                                                          COALESCE(billexchangerate, 0)
                        ELSE 0 END)                                                                                        AS timebillable
              , SUM(CASE
                        WHEN COALESCE(ttimeentryrate.israted, 0) = 1 AND COALESCE(ttimeentry.billable, 0) = 1 and
                             ttask.milestbilling = 0 then
                                COALESCE(ttimeentryrate.billableamnttotal, 0) * COALESCE(billexchangerate, 0) *
                                COALESCE(billcurrexchangerate, 0)
                        ELSE 0 END)                                                                                        AS billabletimeamnt_clcurr
              , SUM(COALESCE(ttimeentryrate.billableamnttotal, 0) * COALESCE(billexchangerate, 0) * COALESCE(billed, 0)
             * (CASE COALESCE(ttimeentryrate.billexchangerate, 0)
                    WHEN 0 THEN 1
                    ELSE COALESCE(ttimeentryrate.billexchangerate, 0) END)
             * (CASE
                    WHEN COALESCE(ttimeentryrate.billed, 0) > 0 AND COALESCE(ttimeentryrate.invoiceid, 0) > 0 THEN 1
                    ELSE COALESCE(ttimeentryrate.billed, 0) END))                                                            AS billedamount


              , SUM(CASE
                        WHEN (COALESCE(ttimeentry.costedtimespan1, 0)
                            + COALESCE(ttimeentry.costedtimespan2, 0)
                            + COALESCE(ttimeentry.costedtimespan3, 0)) = 0 THEN 0
                        ELSE (CASE
                                  WHEN (COALESCE(ttimeentry.billedtimespan1, 0)
                                      + COALESCE(ttimeentry.billedtimespan2, 0)
                                      + COALESCE(ttimeentry.billedtimespan3, 0)) = 0 then
                                      (COALESCE(ttimeentry.costedtimespan1, 0)
                                          + COALESCE(ttimeentry.costedtimespan2, 0)
                                          + COALESCE(ttimeentry.costedtimespan3, 0))
                                  ELSE
                                      (COALESCE(ttimeentry.timespan, 0)
                                          - (COALESCE(ttimeentry.billedtimespan1, 0)
                                              + COALESCE(ttimeentry.billedtimespan2, 0)
                                              + COALESCE(ttimeentry.billedtimespan3, 0)))
                                  END
                                  * (COALESCE(ttimeentryrate.costamounttotal, 0)
                                * COALESCE(ttimeentryrate.costexchangerate, 0))
                            / (COALESCE(ttimeentry.costedtimespan1, 0)
                                + COALESCE(ttimeentry.costedtimespan2, 0)
                                + COALESCE(ttimeentry.costedtimespan3, 0)))
             END)                                                                                                          AS timenonbillable
              , SUM(COALESCE(ttimeentry.timespan, 0))                                                                        AS totaltime
              , SUM(COALESCE(ttimeentry.billedtimespan1, 0) + COALESCE(ttimeentry.billedtimespan2, 0) +
                    COALESCE(ttimeentry.billedtimespan3, 0))                                                                 AS totaltimebill
              , SUM(COALESCE(ttimeentry.timespan, 0) -
                    (COALESCE(ttimeentry.billedtimespan1, 0) + COALESCE(ttimeentry.billedtimespan2, 0) +
                     COALESCE(ttimeentry.billedtimespan3, 0)))                                                               AS totaltimenonbill
              , SUM((COALESCE(ttimeentry.costedtimespan1, 0) + COALESCE(ttimeentry.costedtimespan2, 0) +
                     COALESCE(ttimeentry.costedtimespan3, 0)))                                                                  totaltimepayable
              , SUM(CASE
                        WHEN COALESCE(ttimeentry.costed, 0) = 1 THEN COALESCE(ttimeentryrate.costamounttotal, 0) *
                                                                   COALESCE(costexchangerate, 0)
                        ELSE 0 END)                                                                                        AS payable_time
         FROM ttask
                  JOIN ttimeentry ON ttimeentry.taskid = ttask.uniqueid
                  JOIN ttimeentryrate ON ttimeentryrate.timeentryuid = ttimeentry.uniqueid
         WHERE ttimeentryrate.splitbilclientid = 0
         GROUP BY ttask.projectid, ttimeentry.currentdate
         ),
     viewprojectlist AS (
         SELECT tproject.uniqueid                                                                          AS uniqueid
              , tproject.name                                                                              AS name
              , tproject.accesstype                                                                        AS accesstype
              , COALESCE(tproject.description, '')                                                           AS description
              , COALESCE(tproject.id, '')                                                                    AS id
              , COALESCE(tproject.releasealias, '')                                                          AS code
              , COALESCE(tproject.trackingno, '')                                                            AS trackingnumber
              , COALESCE(tproject.managerid, 0)                                                              AS managerid
              , COALESCE(tuser.firstname, '')                                                                AS managerfirstname
              , COALESCE(tuser.lastname, '')                                                                 AS managerlastname
              , COALESCE(tuser.emailaddress, '')                                                             AS manageremail
              , ''                                                                                         AS state
              , tproject.clientid                                                                          AS clientid
              , tclient.name                                                                               AS client
              , tclientinvoice.currencyid                                                                  AS clientcurrencyid
              , ''                                                                                         AS clientcurrencydescription
              , ''                                                                                         AS clientcurrencysymbol
              , tportfolio.uniqueid                                                                        AS portfolioid
              , tportfolio.name                                                                            AS portfolio
              , tproject.projecttypeid                                                                     AS type   -- this field is not showed ON ui. tmapdata.tablename='%ppm_project_type%' or tprojecttype
              , COALESCE(tproject.phealth, 'green')                                                          AS health -- green/yellow/red tmapdata.tablename = 'projecthealth'
              , tproject.priority                                                                          AS priority
              , tproject.startdate                                                                         AS startdate
              , tproject.enddate                                                                           AS enddate
              , COALESCE((SELECT min(currentdate) AS mindate
                        FROM ttimeentry
                                 JOIN ttask ON ttimeentry.taskid = ttask.uniqueid
                        WHERE ttask.projectid = tproject.uniqueid),
                       '19000101')                                                                         AS actualstartdate
              , COALESCE((SELECT max(currentdate) AS maxdate
                        FROM ttimeentry
                                 JOIN ttask ON ttimeentry.taskid = ttask.uniqueid
                        WHERE ttask.projectid = tproject.uniqueid),
                       '19000101')                                                                         AS actualenddate

              -- budget
              , COALESCE(viewbudgetdetailtotals_proj.bdgtimecurrent / 3600.00, 0.00)                         AS currenttimebudget
              , COALESCE(viewbudgetdetailtotals_proj.bdgtimebaseline / 3600.00, 0.00)                        AS baselinetimebudget
              , COALESCE(viewbudgetdetailtotals_proj.bdgcostcurrent_bc, 0.00)                                AS currentcostbudget_bc
              , COALESCE(viewbudgetdetailtotals_proj.bdgcostcurrent, 0.00)                                   AS currentcostbudget_cc
              , COALESCE(viewbudgetdetailtotals_proj.bdgcostbaseline_bc, 0.00)                               AS baselinecostbudget_bc
              , COALESCE(viewbudgetdetailtotals_proj.bdgcostbaseline, 0.00)                                  AS baselinecostbudget_cc
              , COALESCE(viewbudgetdetailtotals_proj.bdgbillcurrent_bc, 0.00)                                AS currentbillablebudget_bc
              , COALESCE(viewbudgetdetailtotals_proj.bdgbillcurrent, 0.00)                                   AS currentbillablebudget_clc
              , COALESCE(viewbudgetdetailtotals_proj.bdgbillbaseline, 0.00)                                  AS baselinebillablebudget_clc
              , COALESCE(viewbudgetdetailtotals_proj.bdgbillbaseline_bc, 0.00)                               AS baselinebillablebudget_bc
              , COALESCE(viewbudgetdetailtotals_proj.bdgnbilcurrent_bc, 0.00)                                AS currentnonbillablebudget_bc
              , COALESCE(viewbudgetdetailtotals_proj.bdgnbilcurrent, 0.00)                                   AS currentnonbillablebudget_cc
              , COALESCE(viewbudgetdetailtotals_proj.bdgnbilbaseline_bc, 0.00)                               AS baselinenonbillablebudget_bc
              , COALESCE(viewbudgetdetailtotals_proj.bdgnbilbaseline, 0.00)                                  AS baselinenonbillablebudget_cc

              -- project
              , COALESCE(expenseproj.payableexpenses, 0.00) + COALESCE(moneychargeproj.payablecharges, 0.00) +
                COALESCE(productproj.payableproducts, 0.00) + COALESCE(timeproj.payabletimeamnt_bc, 0.00)      AS actualcost
              , COALESCE(expenseproj.billableexpenses_clc, 0.00) + COALESCE(moneychargeproj.billablecharges_clc, 0.00) +
                COALESCE(productproj.billableproducts_clc, 0.00) +
                COALESCE(timeproj.billabletimeamnt_bc * currrate_bctoclc.rate, 0.00)                         AS actualbilling_clc
              , COALESCE(expenseproj.billableexpenses_bc, 0.00) + COALESCE(moneychargeproj.billablecharges_bc, 0.00) +
                COALESCE(productproj.billableproducts_bc, 0.00) +
                COALESCE(timeproj.billabletimeamnt_bc, 0.00)                                                 AS actualbilling_bc

              --time
              , COALESCE(timeproj.totaltime, 0.00)                                                           AS totaltime
              , COALESCE(timeproj.billabletime, 0.00)                                                        AS billabletime
              , COALESCE(timeproj.payabletime, 0.00)                                                         AS payabletime
              , COALESCE(timeproj.nonbillabletime, 0.00)                                                     AS nonbillabletime
              , COALESCE(timeproj.payabletimeamnt_bc, 0.00)                                                  AS payabletimeamnt_bc
              , COALESCE(timeproj.billabletimeamnt_bc, 0.00)                                                 AS billabletimeamnt_bc
              , COALESCE(timeproj.billabletimeamnt_bc * currrate_bctoclc.rate, 0.00)                         AS billabletimeamnt_clc

              -- expense
              , COALESCE(expenseproj.payableexpenses, 0.00)                                                  AS payableexpense
              , COALESCE(expenseproj.billableexpenses_bc, 0.00)                                              AS billableexpense_bc
              , COALESCE(expenseproj.billableexpenses_clc, 0.00)                                             AS billableexpense_clc
              , COALESCE(expenseproj.reimbursableexpenses, 0.00)                                             AS reimbursableexpenses
              , COALESCE(expenseproj.totalexpenses, 0.00)                                                    AS totalexpenses


              -- charge, all charges
              , COALESCE(moneychargeproj.payablecharges, 0.00)                                               AS payablecharges
              , COALESCE(moneychargeproj.billablecharges_bc, 0.00)                                           AS billablecharges_bc
              , COALESCE(moneychargeproj.billablecharges_clc, 0.00)                                          AS billablecharges_clc
              , COALESCE(moneychargeproj.totalcharges, 0.00)                                                 AS totalcharges

              -- product
              , COALESCE(productproj.payableproducts, 0.00)                                                  AS payableproducts
              , COALESCE(productproj.billableproducts_bc, 0.00)                                              AS billableproducts_bc
              , COALESCE(productproj.billableproducts_clc, 0.00)                                             AS billableproducts_clc
              , COALESCE(productproj.totalproducts, 0.00)                                                    AS totalproducts


              -- cwp
              , 0.00                                                                                       AS committedhours
              , 0.00                                                                                       AS proposedhours
              , 0.00                                                                                       AS forecastedcost
              , 0.00                                                                                       AS forecastedbilling

              -- invoice
              , COALESCE(invoiceproj.totalinvoiced_clc, 0.00)                                                AS totalinvoiced_clc
              , COALESCE(invoiceproj.totalinvoiced_clc * currrate_clctobc.rate, 0.00)                        AS totalinvoiced_bc

              --
              , (SELECT COUNT(*) FROM ttask WHERE projectid = tproject.uniqueid)                           AS tasks
              , (SELECT COUNT(*) FROM tmilest WHERE projectid = tproject.uniqueid)                         AS milestones
              , (SELECT COUNT(*)
                 FROM tprojectteamresource
                 WHERE projectid = tproject.uniqueid)                                                      AS teammembers
              , COALESCE(invoiceproj.invoices, 0)                                                            AS invoices
              , ''                                                                                         AS customfields
              , ''                                                                                         AS actionitems
              , CASE WHEN parent.parentid = 0 THEN '' ELSE parent.name END                                    parent
              , tworkflowmap.name                                                                             workflow
              , COALESCE(notes.countnote, 0)                                                                    notes
              , COALESCE(documents.countdocument, 0)                                                            documents
              , tproject.alternatemgrid                                                                       alternatemanagerid
              , COALESCE( CONCAT(user_alternativemgr.lastname, ', ', user_alternativemgr.firstname), '')               alternatemanager
              , COALESCE(user_alternativemgr.emailaddress, '')                                                  alternatemanageremail
              , tproject.actualmgrid                                                                          actualmanagerid
              , COALESCE( CONCAT(user_activemgr.lastname, ', ', user_activemgr.firstname), '')                         actualmanager
              , COALESCE(user_activemgr.emailaddress, '')                                                       actualmanageremail
              , -1                                                                                         AS stateuid
              , tproject.projectworkflowmapid
              , COALESCE(costcurrency.uniqueid, basecurrency.uniqueid)                                       AS costcurrencyid
              , COALESCE(costcurrency.currencysymbol, basecurrency.currencysymbol)                           AS costcurrencysymbol
              , COALESCE(costcurrency.currencycode, basecurrency.currencycode)                               AS costcurrencydescription
         FROM tproject
                  CROSS JOIN tsysdefs
                  JOIN tcurrency basecurrency ON tsysdefs.currencyid = basecurrency.uniqueid
                  JOIN tworkflowmap ON tproject.projectworkflowmapid = tworkflowmap.uniqueid
                  JOIN tclient ON tproject.clientid = tclient.uniqueid
                  JOIN tclientinvoice ON tclient.uniqueid = tclientinvoice.clientid
                  JOIN tcurrassoc curassoc_bctoclc ON curassoc_bctoclc.basecurrencyid = tsysdefs.currencyid and
                                                      curassoc_bctoclc.quotecurrencyid = tclientinvoice.currencyid
                  JOIN tcurrrate currrate_bctoclc ON currrate_bctoclc.curassocid = curassoc_bctoclc.uniqueid and
                                                     getdate() between currrate_bctoclc.startdate AND currrate_bctoclc.enddate
                  JOIN tcurrassoc curassoc_clctobc ON curassoc_clctobc.basecurrencyid = tclientinvoice.currencyid and
                                                      curassoc_clctobc.quotecurrencyid = tsysdefs.currencyid
                  JOIN tcurrrate currrate_clctobc ON currrate_clctobc.curassocid = curassoc_clctobc.uniqueid and
                                                     getdate() between currrate_clctobc.startdate AND currrate_clctobc.enddate
                  LEFT JOIN viewbudgetdetailtotals_proj ON tproject.uniqueid = viewbudgetdetailtotals_proj.objectid and
                                                           viewbudgetdetailtotals_proj.objecttype = 2
                  LEFT JOIN tbudgetdetail ON tbudgetdetail.objecttype = 2 AND tbudgetdetail.objectid = tproject.uniqueid
                  LEFT JOIN tcurrency costcurrency ON costcurrency.uniqueid = tbudgetdetail.costcurrencyid
                  LEFT JOIN tportfolio ON tproject.portfolioid = tportfolio.uniqueid
                  LEFT JOIN tuser ON tproject.managerid = tuser.uniqueid
                  LEFT JOIN
              (
                  SELECT projectid
                       , SUM(expensecost)         AS payableexpenses
                       , SUM(expensebillable)     AS billableexpenses_bc
                       , SUM(expensereimbursable) AS reimbursableexpenses
                       , SUM(expensetotal)        AS totalexpenses
                       , SUM(expensebillable_clc) AS billableexpenses_clc
                  FROM viewexpense_proj
                  GROUP BY projectid
              ) AS expenseproj ON tproject.uniqueid = expenseproj.projectid

                  LEFT JOIN
              (
                  SELECT projectid
                       , SUM(chargecost)         AS payablecharges
                       , SUM(chargebillable)     AS billablecharges_bc
                       , SUM(chargetotal)        AS totalcharges
                       , SUM(chargebillable_clc) AS billablecharges_clc
                  FROM viewmoneycharge_proj
                  GROUP BY projectid
              ) AS moneychargeproj ON moneychargeproj.projectid = tproject.uniqueid
                  LEFT JOIN
              (
                  SELECT projectid
                       , SUM(productcost)         AS payableproducts
                       , SUM(productbillable)     AS billableproducts_bc
                       , SUM(producttotal)        AS totalproducts
                       , SUM(productbillable_clc) AS billableproducts_clc
                  FROM viewproduct_proj
                  GROUP BY projectid
              ) AS productproj ON productproj.projectid = tproject.uniqueid
                  LEFT JOIN
              (SELECT viewtimesheetentries_proj.projectid
                    , SUM(totaltime) / 3600.00        AS totaltime
                    , SUM(totaltimebill) / 3600.00    AS billabletime
                    , SUM(totaltimepayable) / 3600.00 AS payabletime
                    , SUM(totaltimenonbill) / 3600.00 AS nonbillabletime
                    , SUM(timebillable)               AS billabletimeamnt_bc
                    , SUM(timecost)                   AS payabletimeamnt_bc
               FROM viewtimesheetentries_proj
               GROUP BY viewtimesheetentries_proj.projectid
              ) AS timeproj ON tproject.uniqueid = timeproj.projectid
                  LEFT JOIN(SELECT tinvoiceproj.projectid                 AS projectid
                                 , SUM(taskinvamount.invamount)           AS totalinvoiced_clc
                                 , COUNT(distinct tinvoiceproj.invoiceid) AS invoices
                            FROM tinvoiceproj
                                     JOIN tinvoicetask ON tinvoiceproj.uniqueid = tinvoicetask.invoiceprojid
                                     LEFT JOIN
                                 (SELECT tinvoicetime.invoiceid
                                       , tinvoicetime.taskid
                                       , (tinvoicetime.amount) invamount
                                  FROM tinvoicetime
                                  WHERE tinvoicetime.include = 1
                                  UNION ALL
                                  SELECT tinvoiceexp.invoiceid
                                       , tinvoiceexp.taskid
                                       , tinvoiceexp.amount
                                  FROM tinvoiceexp
                                  WHERE tinvoiceexp.include = 1
                                  UNION ALL
                                  SELECT tinvoicechrg.invoiceid
                                       , tinvoicechrg.taskid
                                       , tinvoicechrg.amount
                                  FROM tinvoicechrg
                                  WHERE tinvoicechrg.include = 1
                                 ) taskinvamount ON tinvoicetask.taskid = taskinvamount.taskid and
                                                    taskinvamount.invoiceid = tinvoiceproj.invoiceid
                            WHERE tinvoiceproj.include = 1
                              AND tinvoicetask.include = 1
                            GROUP BY tinvoiceproj.projectid) invoiceproj ON invoiceproj.projectid = tproject.uniqueid
                  JOIN tproject parent ON tproject.parentid = parent.uniqueid
                  LEFT JOIN (SELECT tnote.objectid        projectid
                                  , COUNT(tnote.uniqueid) countnote
                             FROM tnote
                             WHERE tnote.objecttype = 2
                             GROUP BY tnote.objectid
         ) notes ON notes.projectid = tproject.uniqueid
                  LEFT JOIN (SELECT tobjfldlink.objectid projectid, COUNT(tfolderitem.uniqueid) countdocument
                             FROM tobjfldlink
                                      JOIN tfolderitem ON tobjfldlink.folderid = tfolderitem.folderid
                             WHERE tobjfldlink.objecttype = 2
                             GROUP BY tobjfldlink.objectid
         ) documents ON documents.projectid = tproject.uniqueid
                  LEFT JOIN tuser user_alternativemgr ON user_alternativemgr.uniqueid = tproject.alternatemgrid
                  LEFT JOIN tuser user_activemgr ON user_activemgr.uniqueid = tproject.actualmgrid
         WHERE tproject.virtual = 0
         )
SELECT * FROM viewprojectlist