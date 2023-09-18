/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/




with project_details as (
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.CUST_ADSK_SERVICESIMPACT_PROJECTDETAILS
),

margin_variance as (
    SELECT
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.CUST_ADSK_MARGINVARIANCE
)

  SELECT
    -- Client Details
    pd.client_csn                                  AS client_csn
    , pd.client_nm                                 AS client_name
    -- Agreement Details
    , pd.master_agreement_id                      AS master_agreement_id
    , pd.master_agreement_nm                      AS master_agreement_name
    -- Project Details
    , cast(pd.project_id as string)               AS project_id
    , mv.projectcode                               AS project_code
    , mv.projectname                               AS project_name
    , mv.tenroxtrackingno                          AS tenrox_tracking_no
    , mv.projectstate                              AS project_state
    , mv.projecttype                               AS project_type
    -- Dates
    , date(pd.pa_master_contract_dt)               AS pa_contract_date
    , date(pd.pa_sco_contract_dt)                  AS pa_cso_contract_date
    , date(pd.contract_end_dt)                     AS contract_end_date
    , date(pd.contract_start_dt)                   AS contract_start_date
    , date(mv.projectstartdate)                    AS project_start_date
    , date(mv.projectenddate)                      AS project_end_date
    , date(mv.planned_end_date)                    AS planned_end_date
    , date(mv.initialworkdate)                     AS initial_work_date
    , date(mv.finalworkdate)                       AS final_work_date
    -- Geo Details
    , mv.geo                                       AS geo
    , mv.geo2                                      AS geo_2
    , mv.geodelivery                               AS geo_delivery
    -- Revenue, Hours, Cost
    , mv.planrevenue                               AS plan_revenue
    , mv.plancost                                  AS plan_cost
    , mv.planhours                                 AS plan_hours
    , mv.hrs_etc                                   AS hours_etc
    , mv.hrs_eac                                   AS hours_eac
    , mv.hrs_booked                                AS hours_booked
    , mv.eac_revenue                               AS eac_revenue
    , mv.eac_cost                                  AS eac_cost
    , mv.priorfycost                               AS prior_fy_cost
    -- Credits
    , pd.pa_master_credits_purchased               AS pa_master_credits_purchased
    , pd.pa_sco_expense_credits                    AS pa_sco_expense_credits
    , pd.pa_sco_labor_credits                      AS pa_sco_labor_credits
    --
    , pd.cs_discipline                             AS cs_discipline
    , pd.cs_project_type                           AS cs_project_type
    , mv.ac_projgovernance                         AS ac_projgovernance
    , mv.accontracttype                            AS ac_contract_type
    , mv.timecategory                              AS time_category
    , mv.accountingcontracttype                    AS accounting_contract_type
    , mv.revrectreatment                           AS revenue_recognition_treatment
    , mv.packaged_offerings                        AS packaged_offerings
    , mv.projectcurrency                           AS project_currency
    , mv.displayedcurrency                         AS displayed_currency
    -- Product and Industry
    , mv.gs_serviceline                            AS gs_service_line
    , mv.gs_serviceline_projecttype                AS gs_service_line_project_type
    , mv.gs_serviceline_primaryproduct             AS gs_service_line_primary_product
    , mv.gs_serviceline_sub_industry               AS gs_service_line_sub_industry
    -- Escalation
    , REGEXP_REPLACE(mv.escalation_statusandaction,'\n\r', '')                AS escalation_status_and_action
    , REGEXP_REPLACE(mv.escalation_reason   , '\n\r', '')                     AS escalation_reason
    -- Margin
    , mv.marginvariancedescription                 AS margin_variance_description
    , mv.marginvariancecategory                    AS margin_variance_category
    -- Portfolio and Team
    , mv.portfolioname                             AS portfolio_name
    , mv.portfoliomanager                          AS portfolio_manager
    , mv.projectmanagereeid                        AS project_manager_eeid
    , mv.projectmanagername                        AS project_manager_name
    , mv.projectmanagergeo                         AS project_manager_geo
    , mv.govpmdoc_delivery_manager                 AS govpmdoc_delivery_manager
    , mv.ac_se_name1                               AS ac_se_name1
    , mv.ac_se_name2                               AS ac_se_name2
    , mv.csmlead                                   AS csm_lead
    -- Project Heath
    , mv.projhealth_customer                       AS project_health_customer
    , mv.projhealth_overall                        AS project_health_overall
    , mv.projhealth_quality                        AS project_health_quality
    , mv.projhealth_resource                       AS project_health_resource
    , mv.projhealth_schedule                       AS project_health_schedule
    -- Survey
    , date(mv.cs_date_engagement_survey_sent)      AS cs_date_engagement_survey_sent
    -- Joining Key
    , CASE
        WHEN lower(mv.projecttype) in ('is parent-child', 'as parent-child') THEN cast(pd.project_id as string)
        WHEN lower(mv.projecttype) = 'is child' THEN CONCAT(pd.master_agreement_nm, '-IS')
        WHEN lower(mv.projecttype) = 'as child' THEN CONCAT(pd.master_agreement_nm, '-AS')
            ELSE pd.master_agreement_nm
            END                                    AS parent_child_key   
FROM project_details pd
    JOIN margin_variance mv
        ON (cast(pd.project_id as int) = cast(mv.projectid as int))
WHERE
    lower(mv.projecttype) in ('is child', 'as child', 'is parent-child',
                                    'as parent-child')
    AND pd.project_state in ('Active', 'At Risk', 'Chg Order Review', 'Closed',
                            'Completed','End Time Capture',
                            'PA Review - Completion', 'PA Review-Active',
                            'PA Review-WAR to Active')
    AND mv.accountingcontracttype in ('Advisory Services: ARR',
                                      'Implementation Services: Non-ARR')
ORDER BY client_name