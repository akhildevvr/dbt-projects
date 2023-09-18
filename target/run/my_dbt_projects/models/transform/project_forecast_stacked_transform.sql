
  create or replace   view EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.project_forecast_stacked_transform
  
   as (
    WITH tproject AS (
	SELECT
	*
	FROM
	EIO_PUBLISH.TENROX_PRIVATE.TPROJECT
),

tworkflowmap AS 
(
    SELECT
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TWORKFLOWMAP

),

adsk_fn_cm_project_details AS 
(
    SELECT
    *
    FROM
    eio_ingest.tenrox_transform.adsk_cm_project_details 
),

tprojectcustfld_view AS
(
    SELECT
    *
    FROM
    eio_ingest.tenrox_transform.tprojectcustfld_view
),

adsk_fn_cm_project_budget AS
(
    SELECT
    *
    FROM
    eio_ingest.tenrox_transform.adsk_cm_project_budget_local_cur
),

quarter_dates AS
(
  WITH date_series AS (
    SELECT
        DATEADD(QUARTER, ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2013-02-01') AS dt
    FROM
        TABLE(GENERATOR(ROWCOUNT => 55))-- Adjust the number of quarters as needed
)

-- Select quarter start dates
SELECT
    CAST(dt AS DATE) AS dt
FROM
    date_series
),


adsk_fn_cm_labor_hrs_v02 AS
(
    SELECT
    *
    FROM
    eio_ingest.tenrox_transform.adsk_cm_labor_hrs_v02_stacked
),

adsk_fn_cm_deffered_rev AS
(
SELECT
 *
 FROM
 eio_ingest.tenrox_transform.adsk_cm_monthly_deferred_local_cur_rev_stacked

),

deffered_rev_max AS

(
 SELECT
 d.*
 FROM
 adsk_fn_cm_deffered_rev d
WHERE
dt = TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1
                                                  THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                              ELSE YEAR(CURRENT_DATE()) END) || '-'
                                      || CASE WHEN MONTH(CURRENT_DATE()) IN (2, 3, 4) THEN '02-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (5, 6, 7) THEN '05-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (8, 9, 10) THEN '08-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (11, 12, 1) THEN '11-01'
                     ELSE NULL END)
),

adsk_fn_cm_labor_rev_v02 AS
(
  SELECT
 *
 FROM
 eio_ingest.tenrox_transform.adsk_cm_labor_rev_local_cur_v02_stacked
),

adsk_fn_cm_forecast_chrg_rev_v02 AS 
(
 SELECT
  *
 FROM
 eio_ingest.tenrox_transform.adsk_cm_forecast_chrg_rev_local_cur_v02_stacked
),

adsk_fn_cm_rec_chrg_rev_v02 AS 
(
 SELECT
  *
 FROM
 eio_ingest.tenrox_transform.adsk_cm_rec_chrg_rev_local_cur_v02_stacked
              
),

adsk_fn_cm_monthly_chrg_rev AS
(

 SELECT
  *
 FROM
 eio_ingest.tenrox_transform.adsk_cm_monthly_chrg_rev_local_cur_stacked
 
),

adsk_fn_cm_rec_rev_v02 AS 
(
 SELECT
  *
 FROM
 eio_ingest.tenrox_transform.adsk_cm_rec_rev_v02_stacked
),

adsk_fn_month_q_ranges_v02 AS

(
    SELECT
    *
    FROM
    eio_ingest.tenrox_transform.adsk_month_q_ranges_v02
),

fcurrqexchrate AS (
	SELECT
	*
	FROM
	eio_ingest.tenrox_transform.fcurrqexchrate
),
  
parent_child_geo AS
  (   
SELECT 
     project_details.projectid
     ,tprojectcustfld_view.adsk_geo_name
  
    FROM
    adsk_fn_cm_project_details AS project_details 
    INNER JOIN
        tprojectcustfld_view AS tprojectcustfld_view 
        ON tprojectcustfld_view.projectid = project_details.projectid 
                
    LEFT OUTER JOIN
        (
            SELECT
                tproject.uniqueid AS uniqueid
                ,tworkflowmap.name AS workflow 
                ,tproject.parentid as parent_id
            FROM
                tproject AS tproject 
                JOIN
                    tworkflowmap AS tworkflowmap 
                    ON tproject.projectworkflowmapid = tworkflowmap.uniqueid
        ) AS viewprojectlist 
        ON tprojectcustfld_view.projectid = viewprojectlist.uniqueid 
        where tprojectcustfld_view.adsk_geo_name <> ''
        group by
      
            tprojectcustfld_view.adsk_geo_name
            ,project_details.projectid
  ),
  
forecast as (

SELECT
    current_date() as dt
    ,qd.dt as quarter_dt
    ,project_details.projectid AS project_id
    ,viewprojectlist.parent_id as parent_id
    ,p.adsk_geo_name
    --,tprojectcustfld_view.adsk_geo_name AS adsk_geo_name
    ,portfolioname AS portfolio_name
    ,projectcode AS project_code
    ,projectname AS project_name
    ,projectmanagername AS project_manager_name
    ,projectstate AS project_state
    ,project_details.projectenddate 	 AS project_end_date                                        
    ,tprojectcustfld_view.adsk_sap_project_id 	AS     adsk_sap_project_id                                   
    ,clientname AS client_name
    ,tprojectcustfld_view.adsk_masteragreement_projecttype 							  
    ,adsk_revrectreatment AS adsk_revrec_treatment
    ,adsk_accountingcontracttype 	 AS adsk_accounting_contract_type	
    ,clientcurrency AS client_currency
    ,exclient2disp.rate as client_rate
    ,exbase2disp.rate as base_rate
    ,hourly_rate_contractcurrency
    ,hourly_rate_usd
    ,total_planned_rev_usd_adsk
    ,ROUND(currentbillablecharge + currentbillabletime + currentbillablechargeratablebilling) AS bud_revenue

    , hrsact_past_currentqtr + hrsfcst_future AS billable_hours
    , hrs_billable_eac AS hrs_billable_eac
    , CASE 
        WHEN qd.dt = TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1
                                                  THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                              ELSE YEAR(CURRENT_DATE()) END) || '-'
                                      || CASE WHEN MONTH(CURRENT_DATE()) IN (2, 3, 4) THEN '02-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (5, 6, 7) THEN '05-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (8, 9, 10) THEN '08-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (11, 12, 1) THEN '11-01'
                     ELSE NULL END) 
            THEN revlabor_remaininginqtr + rev_deferred + recrev_completedinqtr
        ELSE revlabor_actual + revlabor_forecast 
        END AS total_revenue
   , CASE 
        WHEN qd.dt = TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1
                                                  THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                              ELSE YEAR(CURRENT_DATE()) END) || '-'
                                      || CASE WHEN MONTH(CURRENT_DATE()) IN (2, 3, 4) THEN '02-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (5, 6, 7) THEN '05-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (8, 9, 10) THEN '08-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (11, 12, 1) THEN '11-01'
                     ELSE NULL END) 
            THEN revlabor_remaininginqtr_hard + rev_deferred + recrev_completedinqtr
        ELSE revlabor_actual + revlabor_forecast_hard 
        END AS hard_booked_revenue
   ,  total_revenue - hard_booked_revenue AS soft_booked_revenue
   ,  HRS_FCST_BILLABLE - HRS_FCST_BILLABLE_SOFT AS hard_booked_hours
   ,  HRS_FCST_BILLABLE_SOFT AS soft_booked_hours
   ,  CASE WHEN qd.dt < TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1
                                                  THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                              ELSE YEAR(CURRENT_DATE()) END) || '-'
                                      || CASE WHEN MONTH(CURRENT_DATE()) IN (2, 3, 4) THEN '02-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (5, 6, 7) THEN '05-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (8, 9, 10) THEN '08-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (11, 12, 1) THEN '11-01'
                     ELSE NULL END) THEN COALESCE((recchrgrev_3rdbillableexp_pastqtrs + recchrgrev_internalbillableexp_pastqtrs), 0) 
  
           WHEN qd.dt > TO_DATE(TO_VARCHAR(CASE WHEN MONTH(CURRENT_DATE()) = 1
                                                  THEN YEAR(DATEADD(year, -1, CURRENT_DATE()))
                                              ELSE YEAR(CURRENT_DATE()) END) || '-'
                                      || CASE WHEN MONTH(CURRENT_DATE()) IN (2, 3, 4) THEN '02-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (5, 6, 7) THEN '05-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (8, 9, 10) THEN '08-01'
                                              WHEN MONTH(CURRENT_DATE()) IN (11, 12, 1) THEN '11-01'
                     ELSE NULL END)  THEN fcstchrgrev_nonratablebillable
                                  
           ELSE
                CASE
                    WHEN
                        MONTH(CURRENT_DATE()) IN 
                        (
                            2, 5, 8, 11
                        )
                    THEN
                        COALESCE(fcstchrgrev_nonratablebillable_remaininginqtr, 0) 
                    WHEN
                        MONTH(CURRENT_DATE()) IN 
                        (
                            3, 6, 9, 12
                        )
                    THEN
                        COALESCE(act_charge_rev.actual_charge_rev_month1, 0) + COALESCE(fcstchrgrev_nonratablebillable_remaininginqtr, 0) 
                    ELSE
                        COALESCE(act_charge_rev.actual_charge_rev_month1, 0) + COALESCE(act_charge_rev.actual_charge_rev_month2, 0) + COALESCE(fcstchrgrev_nonratablebillable_remaininginqtr, 0) 
                END
          END AS expenses  
    , def_rev.deferredrevenue  AS deferred_revenue
    , def_rev.totaldeferredrevenue  AS total_deferred_revenue
                                        
    ,CASE
        WHEN lower(tprojectcustfld_view.adsk_masteragreement_projecttype 	) IN ('is parent','as parent','pac parent') THEN cast(project_details.projectid as string)
        WHEN lower(tprojectcustfld_view.adsk_masteragreement_projecttype) like '%child%' THEN CAST(viewprojectlist.parent_id AS STRING)
            ELSE CAST(project_details.projectid AS STRING)
            END                                    AS parent_child_key 
FROM
    adsk_fn_cm_project_details AS project_details 
    LEFT OUTER JOIN quarter_dates qd
    INNER JOIN
        tprojectcustfld_view AS tprojectcustfld_view 
        ON tprojectcustfld_view.projectid = project_details.projectid 
    LEFT OUTER JOIN
        (
            SELECT
                tproject.uniqueid AS uniqueid
                ,tworkflowmap.name AS workflow 
                ,tproject.parentid as parent_id
            FROM
                tproject AS tproject 
                JOIN
                    tworkflowmap AS tworkflowmap 
                    ON tproject.projectworkflowmapid = tworkflowmap.uniqueid
        ) AS viewprojectlist 
        ON tprojectcustfld_view.projectid = viewprojectlist.uniqueid 
    LEFT OUTER JOIN
        adsk_fn_cm_project_budget AS project_budget 
        ON project_budget.projectid = project_details.projectid
    LEFT OUTER JOIN
        adsk_fn_cm_labor_rev_v02 AS labor_rev 
        ON labor_rev.projectid = project_details.projectid and labor_rev.dt = qd.dt
    LEFT OUTER JOIN
        adsk_fn_cm_labor_hrs_v02 AS labor_hrs 
        ON labor_hrs.projectid = project_details.projectid and labor_hrs.dt = qd.dt
    LEFT OUTER JOIN
        adsk_fn_cm_forecast_chrg_rev_v02 AS forecast_chrg_rev 
        ON forecast_chrg_rev.projectid = project_details.projectid and forecast_chrg_rev.dt = qd.dt
    LEFT OUTER JOIN
        adsk_fn_cm_rec_chrg_rev_v02 AS rev_chrg_cost 
        ON rev_chrg_cost.projectid = project_details.projectid  and rev_chrg_cost.dt = qd.dt
	LEFT OUTER JOIN adsk_fn_cm_monthly_chrg_rev act_charge_rev
        ON act_charge_rev.projectid = project_details.projectid 	 and act_charge_rev.dt = qd.dt
   LEFT OUTER JOIN
        adsk_fn_cm_rec_rev_v02 AS rec_rev 
        ON rec_rev.projectid = project_details.projectid 	and rec_rev.dt = qd.dt
   LEFT OUTER JOIN
        adsk_fn_cm_deffered_rev AS def_rev 
        ON def_rev.projectid = project_details.projectid 	and def_rev.dt = qd.dt
    LEFT OUTER JOIN
        fcurrqexchrate AS exclient2disp 
        ON exclient2disp.basecurrencyid = 
        (
            COALESCE(projectcurrencyid, 1)
        )
        AND exclient2disp.quotecurrencyid = 
        (
            COALESCE(NULL, projectcurrencyid, 1)
        )
        AND CURRENT_DATE() BETWEEN exclient2disp.startdate AND exclient2disp.enddate 
    LEFT OUTER JOIN
        fcurrqexchrate AS exbase2disp 
        ON exbase2disp.basecurrencyid = 1 
        AND exbase2disp.quotecurrencyid = 
        (
            COALESCE(NULL, projectcurrencyid, 1)
        )
        AND CURRENT_DATE() BETWEEN exbase2disp.startdate AND exbase2disp.enddate 
    LEFT JOIN parent_child_geo p
        ON CASE
            WHEN lower(tprojectcustfld_view.adsk_masteragreement_projecttype 	) IN ('is parent','as parent','pac parent') THEN cast(project_details.projectid as string)
            WHEN lower(tprojectcustfld_view.adsk_masteragreement_projecttype) like '%child%' THEN CAST(viewprojectlist.parent_id AS STRING)
            ELSE CAST(project_details.projectid AS STRING)
           END = p.projectid

WHERE
    1 = 1 
    AND project_details.projectstate <> 'Discarded' 	
    AND 
    (
        viewprojectlist.workflow NOT IN 
        (
            'V2-Ratable SCO'
            , 'APAC Conversion Setup' 
            , 'Completed Non-Migrated SCOs'
            , 'Conversion Setup'
            , 'Customer Facing' 
            , 'FY14-Booking Credit ONLY' 
            , 'Internal-Non-Utilized' 
            , 'Internal-Utilized' 
            , 'Program Bookings' 
        )
        OR 
        (
            viewprojectlist.workflow = 'V2-Ratable SCO' 
            AND tprojectcustfld_view.adsk_sap_project_id <> '' 
        )
    )
)
  
  
SELECT 
    * 
FROM 
    forecast
  );

