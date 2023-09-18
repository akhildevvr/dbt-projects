
  create or replace   view EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.project_forecast_test
  
   as (
     


WITH tproject AS (
	SELECT
	*
	FROM
	eio_publish.tenrox_private.tproject
),

tworkflowmap AS 
(
    SELECT
    *
    FROM
    eio_publish.tenrox_private.tworkflowmap

),

adsk_fn_cm_project_details AS 
(
    SELECT
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_project_details 
),

tprojectcustfld_view AS
(
    SELECT
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.tprojectcustfld_view
),

adsk_fn_cm_project_budget AS
(
    SELECT
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_project_budget_local_cur
),

adsk_fn_cm_labor_rev_v02 AS
(
    SELECT
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_labor_rev_local_cur_v02 
),

adsk_fn_cm_forecast_chrg_rev_v02 AS 
(
    SELECT 
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_forecast_chrg_rev_local_cur_v02
),

adsk_fn_cm_act_charge_costs_v02 AS
(
    SELECT
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_act_charge_costs_local_cur_v02
),

adsk_fn_cm_forecast_chrg_cost AS 
(
    SELECT
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_forecast_chrg_cost_local_cur
),

adsk_fn_cm_labor_hrs_v02 AS
(
    SELECT
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_labor_hrs_v02
),

adsk_fn_cm_rec_chrg_rev_v02 AS 
(
    SELECT
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_rec_chrg_rev_local_cur_v02
),

adsk_fn_cm_monthly_chrg_rev AS
(
    SELECT
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_monthly_chrg_rev_local_cur
),

adsk_fn_cm_rec_rev_v02 AS
(
    SELECT 
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_cm_rec_rev_v02
),

adsk_fn_month_q_ranges_v02 AS

(
    SELECT
    *
    FROM
    EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.adsk_month_q_ranges_v02
),

fcurrqexchrate AS (
	SELECT
	*
	FROM
	EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.fcurrqexchrate
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
    CURRENT_TIMESTAMP() as dt
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
    ,ROUND(currentbillablecharge) AS current_billable_charge
    ,ROUND(currentbillabletime) AS current_billable_time
    ,ROUND(currentbillablechargeratablebilling) AS current_billable_charge_ratable_billing
    ,ROUND(currentbillablecharge + currentbillabletime + currentbillablechargeratablebilling) AS bud_revenue
    ,ROUND(revlabor_pastqtrs) AS revlabor_pastqtrs
    ,ROUND(revlabor_currentqtr) AS revlabor_currentqtr
    ,ROUND(rev_deferred) AS rev_deferred
    ,ROUND(revlabor_remaininginqtr) AS revlabor_remaining_in_qtr
    ,ROUND(revlabor_remaininginqtr_hard) AS revlabor_remaining_in_qtr_hard
    ,ROUND(recrev_completedinqtr) as recrev_completedinqtr
    ,ROUND(recrev_pastqtrs) AS recrev_pastqtrs
    ,ROUND(revlabor_plus1qtr) AS revlabor_plus1qtr
    ,ROUND(revlabor_plus2qtr) AS revlabor_plus2qtr
    ,ROUND(revlabor_plus3qtr) AS revlabor_plus3qtr
    ,ROUND(revlabor_plus4qtr) AS revlabor_plus4qtr
    ,ROUND(revlabor_plus5qtr) AS revlabor_plus6qtr
    ,ROUND(revlabor_additionalqtrs) AS revlabor_additionalqtrs
    ,ROUND(revlabor_additionalqtrs2) AS revlabor_additionalqtrs2
    ,ROUND(fcstchrgrev_allbillable_futureqtrs) AS fcstchrgrev_allbillable_futureqtrs
    ,ROUND(fcstchrgrev_allbillable_remaininginqtr) AS fcstchrgrev_allbillable_remaining_in_qtr
    ,ROUND(fcstchrgrev_allbillable_plus1qtr) AS fcstchrgrev_allbillable_plus1qtr
    ,ROUND(fcstchrgrev_allbillable_plus2qtr) AS fcstchrgrev_allbillable_plus2qtr
    ,ROUND(fcstchrgrev_allbillable_plus3qtr) AS fcstchrgrev_allbillable_plus3qtr
    ,ROUND(fcstchrgrev_allbillable_plus4qtr) AS fcstchrgrev_allbillable_plus4qtr
    ,ROUND(fcstchrgrev_allbillable_plus5qtr) AS fcstchrgrev_allbillable_plus5qtr
    ,ROUND(fcstchrgrev_allbillable_additionalqtrs) AS fcstchrgrev_allbillable_additionalqtrs
    ,ROUND(fcstchrgrev_allbillable_additionalqtrs2) AS fcstchrgrev_allbillable_additionalqtrs2		
    ,CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            (hrsfcst_billable_currentqtrm1_wk - hrsfcst_billable_currentqtrm1_soft_wk)  + (hrsfcst_billable_currentqtrm2 - hrsfcst_billable_currentqtrm2_soft )  + (hrsfcst_billable_currentqtrm3 - hrsfcst_billable_currentqtrm3_soft )
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            (hrsfcst_billable_currentqtrm2_wk - hrsfcst_billable_currentqtrm2_soft_wk) + (hrsfcst_billable_currentqtrm3 - hrsfcst_billable_currentqtrm3_soft )
        ELSE
            (hrsfcst_billable_currentqtrm3_wk - hrsfcst_billable_currentqtrm3_soft_wk )
        END AS hard_booked_hrs_currentqtr
    ,CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsfcst_billable_currentqtrm1_soft_wk + hrsfcst_billable_currentqtrm2_soft + hrsfcst_billable_currentqtrm3_soft 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsfcst_billable_currentqtrm2_soft_wk + hrsfcst_billable_currentqtrm3_soft 
        ELSE
            hrsfcst_billable_currentqtrm3_soft_wk 
        END AS soft_booked_hrs_currentqtr
    ,hrsfcst_billable_plus1qtr - hrsfcst_billable_plus1qtr_soft as hard_booked_hrs_plus1qtr
    ,hrsfcst_billable_plus1qtr_soft as soft_booked_hrs_plus1qtr
    ,hrsfcst_billable_plus2qtr - hrsfcst_billable_plus2qtr_soft as hard_booked_hrs_plus2qtr
    ,hrsfcst_billable_plus2qtr_soft as soft_booked_hrs_plus2qtr
    ,hrsfcst_billable_plus3qtr - hrsfcst_billable_plus3qtr_soft as hard_booked_hrs_plus3qtr
    ,hrsfcst_billable_plus3qtr_soft as soft_booked_hrs_plus3qtr
    ,hrsfcst_billable_plus4qtr - hrsfcst_billable_plus4qtr_soft as hard_booked_hrs_plus4qtr
    ,hrsfcst_billable_plus4qtr_soft as soft_booked_hrs_plus4qtr
    ,hrsfcst_billable_plus5qtr - hrsfcst_billable_plus5qtr_soft as hard_booked_hrs_plus5qtr
    ,hrsfcst_billable_plus5qtr_soft as soft_booked_hrs_plus5qtr
    ,hrsfcst_billable_additionalqtrs - hrsfcst_billable_additionalqtrs_soft as hard_booked_hrs_additionalqtrs
    ,hrsfcst_billable_additionalqtrs_soft as soft_booked_hrs_additionalqtrs
    ,hrsfcst_billable_additionalqtrs2 - hrsfcst_billable_additionalqtrs2_soft as hard_booked_hrs_additionalqtrs2
    ,hrsfcst_billable_additionalqtrs2_soft as soft_booked_hrs_additionalqtrs2		  
    ,ROUND(
        COALESCE((recchrgrev_3rdbillableexp_pastqtrs + recchrgrev_internalbillableexp_pastqtrs), 0) * 1 
    )
    AS actual_expenses_pastqtr
    ,ROUND(
    ( 
        CASE
            WHEN
                MONTH(CURRENT_DATE()) IN 
                (
                    2,
                    5,
                    8,
                    11
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
    ) * 1 
    )
    AS estimated_expenses_currentqtr 
    ,ROUND(
        COALESCE(fcstchrgrev_nonratablebillable_plus1qtr, 0) * 1 
    )
    AS estimated_expenses_plus1qtr 
    ,ROUND(
        COALESCE(fcstchrgrev_nonratablebillable_plus2qtr, 0) * 1 
    )
    AS estimated_expenses_plus2qtr 
    ,ROUND(
        COALESCE(fcstchrgrev_nonratablebillable_plus3qtr, 0) * 1 
    )
    AS estimated_expenses_plus3qtr 
    ,ROUND(
        COALESCE(fcstchrgrev_nonratablebillable_plus4qtr, 0) * 1 
    )
    AS estimated_expenses_plus4qtr 
    ,ROUND(
        COALESCE(fcstchrgrev_nonratablebillable_plus5qtr, 0) * 1 
    )
    AS estimated_expenses_plus5qtr 
    ,ROUND(
        COALESCE(fcstchrgrev_nonratablebillable_additionalqtrs, 0) * 1 
    )
    AS estimated_expenses_additionalqtrs 
    ,ROUND(
        COALESCE(fcstchrgrev_nonratablebillable_additionalqtrs2, 0) * 1 
    )
    AS estimated_expenses_additional2qtrs 
    ,ROUND(
    ( COALESCE((recchrgrev_3rdbillableexp_pastqtrs + recchrgrev_internalbillableexp_pastqtrs), 0) + ( 
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
    ) + COALESCE(fcstchrgrev_nonratablebillable_plus1qtr, 0) + COALESCE(fcstchrgrev_nonratablebillable_plus2qtr, 0) + COALESCE(fcstchrgrev_nonratablebillable_plus3qtr, 0) + COALESCE(fcstchrgrev_nonratablebillable_additionalqtrs, 0) ) * 1 
    )
    AS total_expenses
    ,hrsact_past
    ,hrsact_pastqtrs
    ,hrsact_minus1qtr
    ,hrsact_minus2qtr
    ,hrsact_minus3qtr
    ,hrsact_currentqtrm1
    ,hrsact_currentqtrm2
    ,hrsact_currentqtrm3
    ,hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3 as hrsact_currentqtr
    ,hrsact_completedinqtr
    ,hrsfcst_billable_currentqtrm1
    ,hrsfcst_billable_currentqtrm2
    ,hrsfcst_billable_currentqtrm3
    ,hrsfcst_billable_remaininginqtr
    ,hrsfcst_billable_remaininginqtr_soft
    ,hrsfcst_billable_plus1qtr
    ,hrsfcst_billable_plus2qtr
    ,hrsfcst_billable_plus3qtr
    ,hrsfcst_billable_plus4qtr
    ,hrsfcst_billable_plus5qtr
    ,hrsfcst_billable_additionalqtrs
    ,hrsfcst_billable_additionalqtrs2
    ,hrsfcst_billable_future
    ,hrs_billable_eac
    ,hrsact_past_org
    ,hrsact_pastqtrs_org
    ,hrsact_currentqtrm1_org
    ,hrsact_currentqtrm2_org
    ,hrsact_currentqtrm3_org
    ,hrsfcst_billable_currentqtrm1_org
    ,hrsfcst_billable_currentqtrm2_org
    ,hrsfcst_billable_currentqtrm3_org
    ,hrsfcst_billable_plus1qtr_org
    ,hrsfcst_billable_plus2qtr_org
    ,hrsfcst_billable_plus3qtr_org
    ,hrsfcst_billable_plus4qtr_org
    ,hrsfcst_billable_plus5qtr_org
    ,hrsfcst_billable_additionalqtrs_org
    ,hrsfcst_billable_additionalqtrs2_org
    ,hrs_billable_eac_org
    ,( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) ) as billable_hours_currentqtr
   ,( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr ) AS billable_hours_plus1qtr
    ,( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr ) AS billable_hours_plus2qtr
  ,( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr + hrsfcst_billable_plus3qtr ) AS billable_hours_plus3qtr
  ,( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr + hrsfcst_billable_plus3qtr + hrsfcst_billable_plus4qtr ) AS billable_hours_plus4qtr
  ,( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr + hrsfcst_billable_plus3qtr + hrsfcst_billable_plus4qtr + hrsfcst_billable_plus5qtr ) AS billable_hours_plus5qtr
    ,( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr + hrsfcst_billable_plus3qtr + hrsfcst_billable_additionalqtrs ) AS billable_hours_additionalqtr
    ,( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr + hrsfcst_billable_plus3qtr + hrsfcst_billable_plus4qtr + hrsfcst_billable_plus5qtr + hrsfcst_billable_additionalqtrs2 ) AS billable_hours_additional2qtr
    , COALESCE ( ( hrsact_pastqtrs / NULLIF(hrs_billable_eac, 0) ), 0 )  AS percent_complete_prevqtr 
    , COALESCE ( ( ( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) ) / NULLIF(hrs_billable_eac, 0) ), 0 )  AS percent_complete_currentqtr 
    , COALESCE ( ( ( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr ) / NULLIF(hrs_billable_eac, 0) ), 0 )  AS percent_complete_plus1qtr 
    , COALESCE ( ( ( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr ) / NULLIF(hrs_billable_eac, 0) ), 0 ) AS percent_complete_plus2qtr 
    , COALESCE ( ( ( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr + hrsfcst_billable_plus3qtr ) / NULLIF(hrs_billable_eac, 0) ), 0 )  AS percent_complete_plus3qtr 
    , COALESCE ( ( ( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr + hrsfcst_billable_plus3qtr + hrsfcst_billable_plus4qtr ) / NULLIF(hrs_billable_eac, 0) ), 0 )  AS percent_complete_plus4qtr 
    , COALESCE ( ( ( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr + hrsfcst_billable_plus3qtr + hrsfcst_billable_plus4qtr + hrsfcst_billable_plus5qtr ) / NULLIF(hrs_billable_eac, 0) ), 0 )  AS percent_complete_plus5qtr 
    , COALESCE ( ( ( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr + hrsfcst_billable_plus3qtr + hrsfcst_billable_additionalqtrs ) / NULLIF(hrs_billable_eac, 0) ), 0 ) AS percent_complete_additionalqtr 
    , COALESCE ( ( ( hrsact_pastqtrs + ( 
        CASE
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                2, 5, 8, 11
            )
        THEN
            hrsact_currentqtrm1_wk + hrsfcst_billable_currentqtrm1_wk + hrsfcst_billable_currentqtrm2 + hrsfcst_billable_currentqtrm3 
        WHEN
            MONTH(CURRENT_DATE()) IN 
            (
                3, 6, 9, 12
            )
        THEN
            hrsact_currentqtrm1 + hrsact_currentqtrm2_wk + hrsfcst_billable_currentqtrm2_wk + hrsfcst_billable_currentqtrm3 
        ELSE
            hrsact_currentqtrm1 + hrsact_currentqtrm2 + hrsact_currentqtrm3_wk + hrsfcst_billable_currentqtrm3_wk 
    END
    ) + hrsfcst_billable_plus1qtr + hrsfcst_billable_plus2qtr + hrsfcst_billable_plus3qtr + hrsfcst_billable_plus4qtr + hrsfcst_billable_plus5qtr + hrsfcst_billable_additionalqtrs2 ) / NULLIF(hrs_billable_eac, 0) ), 0 ) AS percent_complete_additional2qtr 
    ,revlabor_minus1qtr AS total_revenue_minus1qtr
    ,revlabor_minus2qtr AS total_revenue_minus2qtr
    ,revlabor_minus3qtr AS total_revenue_minus3qtr
    ,revlabor_pastqtrs AS total_revenue_prevqtr
    ,(ROUND(revlabor_remaininginqtr)) + (ROUND(recrev_completedinqtr)) + (ROUND(rev_deferred))  + NVL(ROUND(fcstchrgrev_allbillable_remaininginqtr),0) AS total_revenue_currentqtr
    ,(ROUND(revlabor_remaininginqtr_hard)) + (ROUND(recrev_completedinqtr)) + (ROUND(rev_deferred)) + NVL(ROUND(fcstchrgrev_allbillable_remaininginqtr),0) AS hard_booked_rev_currentqtr
    ,total_revenue_currentqtr - hard_booked_rev_currentqtr AS soft_booked_rev_currentqtr
    ,ROUND(revlabor_plus1qtr) + NVL(ROUND(fcstchrgrev_allbillable_plus1qtr),0) AS total_revenue_plus1qtr
    ,ROUND(revlabor_plus1qtr_hard) + NVL(ROUND(fcstchrgrev_allbillable_plus1qtr),0) AS hard_booked_rev_plus1qtr
    ,total_revenue_plus1qtr - hard_booked_rev_plus1qtr AS soft_booked_rev_plus1qtr
    ,ROUND(revlabor_plus2qtr) + NVL(ROUND(fcstchrgrev_allbillable_plus2qtr),0) AS total_revenue_plus2qtr
    ,ROUND(revlabor_plus2qtr_hard) + NVL(ROUND(fcstchrgrev_allbillable_plus2qtr),0) AS hard_booked_rev_plus2qtr
    ,total_revenue_plus2qtr - hard_booked_rev_plus2qtr AS soft_booked_rev_plus2qtr
    ,ROUND(revlabor_plus3qtr) + NVL(ROUND(fcstchrgrev_allbillable_plus3qtr),0) AS total_revenue_plus3qtr
    ,ROUND(revlabor_plus3qtr_hard) + NVL(ROUND(fcstchrgrev_allbillable_plus3qtr),0) AS hard_booked_rev_plus3qtr
    ,total_revenue_plus3qtr - hard_booked_rev_plus3qtr AS soft_booked_rev_plus3qtr
    ,ROUND(revlabor_plus4qtr) + NVL(ROUND(fcstchrgrev_allbillable_plus4qtr),0) AS total_revenue_plus4qtr
    ,ROUND(revlabor_plus4qtr_hard) + NVL(ROUND(fcstchrgrev_allbillable_plus4qtr),0) AS hard_booked_rev_plus4qtr
    ,total_revenue_plus4qtr - hard_booked_rev_plus4qtr AS soft_booked_rev_plus4qtr
    ,ROUND(revlabor_plus5qtr) + NVL(ROUND(fcstchrgrev_allbillable_plus5qtr),0) AS total_revenue_plus5qtr
    ,ROUND(revlabor_plus5qtr_hard) + NVL(ROUND(fcstchrgrev_allbillable_plus5qtr),0) AS hard_booked_rev_plus5qtr
    ,total_revenue_plus5qtr - hard_booked_rev_plus5qtr AS soft_booked_rev_plus5qtr
    ,ROUND(revlabor_additionalqtrs) + NVL(ROUND(fcstchrgrev_allbillable_additionalqtrs),0) AS total_revenue_additionalqtr
    ,ROUND(revlabor_additionalqtrs_hard) + NVL(ROUND(fcstchrgrev_allbillable_additionalqtrs),0) AS hard_booked_rev_additionalqtrs
    ,total_revenue_additionalqtr - hard_booked_rev_additionalqtrs AS soft_booked_rev_additionalqtrs
    ,ROUND(revlabor_additionalqtrs2) + NVL(ROUND(fcstchrgrev_allbillable_additionalqtrs2),0) AS total_revenue_additional2qtr
    ,ROUND(revlabor_additionalqtrs2_hard) + NVL(ROUND(fcstchrgrev_allbillable_additionalqtrs2),0) AS hard_booked_rev_additionalqtrs2
    ,total_revenue_additional2qtr - hard_booked_rev_additionalqtrs2 AS soft_booked_rev_additionalqtrs2
    ,ROUND(revlabor_futureqtrs) + ROUND(fcstchrgrev_allbillable_futureqtrs) AS  total_revenue_futureqtrs
    ,CASE
        WHEN lower(tprojectcustfld_view.adsk_masteragreement_projecttype 	) IN ('is parent','as parent','pac parent') THEN cast(project_details.projectid as string)
        WHEN lower(tprojectcustfld_view.adsk_masteragreement_projecttype) like '%child%' THEN CAST(viewprojectlist.parent_id AS STRING)
            ELSE CAST(project_details.projectid AS STRING)
            END                                    AS parent_child_key 
    ,SUBSTR(DBT_JOB_ID, 1, 8) AS dbt_snapshot_dt
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
    LEFT OUTER JOIN
        adsk_fn_cm_project_budget AS project_budget 
        ON project_budget.projectid = project_details.projectid 
    LEFT OUTER JOIN
        adsk_fn_cm_labor_rev_v02 AS labor_rev 
        ON labor_rev.projectid = project_details.projectid 
    LEFT OUTER JOIN
        adsk_fn_cm_rec_rev_v02 AS rec_rev 
        ON rec_rev.project_id = project_details.projectid 		
    LEFT OUTER JOIN
        adsk_fn_cm_forecast_chrg_rev_v02 AS forecast_chrg_rev 
        ON forecast_chrg_rev.projectid = project_details.projectid 
    LEFT OUTER JOIN
        adsk_fn_cm_act_charge_costs_v02 AS act_charge_costs 
        ON act_charge_costs.projectid = project_details.projectid 
    LEFT OUTER JOIN
        adsk_fn_cm_forecast_chrg_cost AS forecast_chrg_cost 
        ON forecast_chrg_cost.projectid = project_details.projectid 
    LEFT OUTER JOIN
        adsk_fn_cm_labor_hrs_v02 AS labor_hrs 
        ON labor_hrs.projectid = project_details.projectid 
    LEFT OUTER JOIN
        adsk_fn_cm_rec_chrg_rev_v02 AS rev_chrg_cost 
        ON rev_chrg_cost.projectid = project_details.projectid 
    LEFT OUTER JOIN
        (
            SELECT
                projectid
                ,SUM ( 
                CASE
                    WHEN
                        monthofchrgrev = fnc_currentqtrbegins 
                    THEN
                        monthschrgrev_internalbillableexp + monthschrgrev_3rdbillableexp 
                END
                ) AS actual_charge_rev_month1
                , SUM ( 
                CASE
                    WHEN
                        monthofchrgrev = fnc_currentqtrm2begins 
                    THEN
                        monthschrgrev_internalbillableexp + monthschrgrev_3rdbillableexp 
                END
                ) AS actual_charge_rev_month2
                , SUM ( 
                CASE
                    WHEN
                        monthofchrgrev = fnc_currentqtrm3begins 
                    THEN
                        monthschrgrev_internalbillableexp + monthschrgrev_3rdbillableexp 
                END
                ) AS actual_charge_rev_month3 
            FROM
                adsk_fn_cm_monthly_chrg_rev 
                LEFT OUTER JOIN
                    adsk_fn_month_q_ranges_v02 ranges 
            WHERE
                monthofchrgrev BETWEEN fnc_currentqtrbegins AND fnc_plus1qtrbegins 
            GROUP BY
                projectid 
        )
        act_charge_rev 
        ON act_charge_rev.projectid = project_details.projectid 		
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

