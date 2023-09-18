
  
    

        create or replace  table EIO_INGEST.ASSIGNMENT_MONTHLY_TEST.assignment_monthly  as
        (


WITH DI as (
    select *
    from adp_publish.customer_success_optimized.date_info
),
     EDP AS (SELECT *
             FROM adp_publish.entitlement_optimized.entitlement_edp_optimized
             WHERE entitlement_registration_status= 'Registered'
               AND entitlement_model = 'Subscription Single User'
               AND entitlement_status = 'Active'
               AND usage_type = 'Commercial'
               AND feature_type <> 'Benefit'
               AND end_customer_acct_csn is not null),
     ECCR AS (SELECT *
              FROM adp_publish.product_public.product_line_code_eccr
     ),
     subs as (select * from adp_publish.entitlement_public.subscription_aum),
     EPM AS (SELECT *
             FROM adp_publish.entitlement_public.entitlement_pool_aum
             WHERE seats_rule = 'quantity'
               AND pool_id not in ('1_PPUCOL'
                 , '1_PREMSUB'
                 , '1_TFXCOL'
                 , '1_COLLRP')),
     EM AS (SELECT *
     FROM adp_publish.entitlement_public.entitlement_aum
         ),
     USER_AUM AS (SELECT *
                  FROM adp_publish.entitlement_public.user_aum
                  WHERE user_role = 'primaryadmin'
         ),
     TRANSACTIONAL_CSN_MAPPING AS ( SELECT *
     FROM adp_publish.account_optimized.transactional_csn_mapping_optimized
         ),
     ACCOUNT_EDP AS (SELECT *
     FROM adp_publish.account_optimized.account_edp_optimized
         ),
     EDP_Base AS (
         SELECT DISTINCT EDP.Entitlement_Model
                         , EDP.Entitlement_id                                         as Serial_number
                         , EDP.Subscription_end_date
                         , EDP.Owner_id
                         , EDP.Usage_type
                         , coalesce(edp.subscription_id, edp.entitlement_id)          as ent_subs_id
                         , EDP.Subscription_id
                         , EDP.entitlement_status
                         , EDP.Contract_id
                         , EDP.Contract_status
                         , EDP.Contract_start_date
                         , EDP.Contract_end_date
                         , EDP.purchased_seat_quantity
                         , EDP.usable_seat_quantity
                         , EDP.Offering_type
                         , EDP.Offering_name
                         , EDP.Offering_product_line_code
                         , EDP.Feature_type
                         , EDP.Feature_name
                         , EDP.product_line_code
                         , case
                             when ECCR.product_line_code is null
                                 then 0
                             else 1
                             end as eccr_flag
                         , cast(SUBS.Tenant_id as varchar)                            as Tenant_id
                         , SUBS.Pool_id
                         , EDP.Oxygen_id                                              as oxygen_id_cm
                         , EDP.end_customer_acct_csn
                         , EDP.dt
         FROM EDP
                  LEFT JOIN ECCR
                            ON EDP.Offering_product_line_code = ECCR.product_line_code
              INNER JOIN SUBS
                        ON  cast(EDP.Subscription_id as varchar) = cast(SUBS.Subscription_id as varchar)
     ),
     EDP_SUBS_AUM
         AS
         (
             SELECT EDP.*
                  , SUBS.subscription_id                    as AUM_Subs_ID
                  , cast(SUBS.tenant_id as varchar)         as AUM_Tenant_id
                  , SUBS.pool_id                            as AUM_Pool_id
             FROM EDP_Base as EDP
                      LEFT JOIN SUBS
                                ON cast(EDP.Subscription_id as varchar) = cast(SUBS.Subscription_id as varchar)
         ),
     EDP_Subs_to_EPM
         AS
         (SELECT EDP.*
               , EPM.pool_code
               , EPM.offering_external_key
               , EPM.offering_plcs
               , EPM.offering_plc_name
               , EPM.seats_purchased
               , EPM.seats_assigned
               , (EPM.seats_purchased - EPM.seats_assigned) AS seats_unassigned
               , EM.entitlement_id                          as Assigned_PLC
               , EM.assignable
          FROM EDP_SUBS_AUM EDP
                   INNER JOIN EPM
                             ON cast(EDP.Tenant_id as varchar) = cast(EPM.tenant_id as varchar)
                                 AND EDP.pool_id = EPM.pool_id
                   LEFT JOIN EM
                             ON cast(EDP.Tenant_id as varchar) = cast(EM.tenant_id as varchar)
                                 AND EDP.pool_id = EM.pool_id
                                 AND EDP.product_line_code = EM.entitlement_id
         ),
     AUM_PA as
         (SELECT DISTINCT a.Entitlement_Model
                        , a.Serial_number
                        , a.Subscription_end_date
                        , a.Owner_id
                        , a.Usage_type
                        , a.ent_subs_id
                        , a.Subscription_id
                        , a.Contract_id
                        , a.Contract_status
                        , a.Contract_start_date
                        , a.Contract_end_date
                        , a.purchased_seat_quantity
                        , a.usable_seat_quantity
                        , a.Offering_type
                        , a.Offering_name
                        , a.Offering_product_line_code
                        , a.Feature_type
                        , a.Feature_name
                        , a.product_line_code
                        , a.eccr_flag
                        , a.oxygen_id_cm
                        , a.end_customer_acct_csn
                        , d.corporate_parent_csn_static AS corporate_parent_csn
                        , a.dt
                        , a.AUM_Tenant_id as tenant_id
                        , a.AUM_Pool_id as pool_id
                        , a.offering_external_key
                        , a.seats_purchased
                        , a.seats_assigned
                        , a.seats_unassigned
                        , a.Assigned_PLC
                        , COALESCE(CAST(a.assignable AS VARCHAR), 'na') AS assignable
                        , CASE
                            WHEN b.user_role = 'primaryadmin'
                                THEN user_id
                            ELSE 'missing_pa'
                            END AS oxygen_id_pa
                        , DI.by_month as by_month
          from EDP_Subs_to_EPM as a
                   LEFT JOIN USER_AUM AS b
                             ON cast(a.Tenant_id as varchar) = cast(b.Tenant_id as varchar)
                                 and a.dt = b.dt
                   LEFT JOIN DI
                             ON a.dt = DI.dt
                   LEFT JOIN TRANSACTIONAL_CSN_MAPPING c
                            ON a.end_customer_acct_csn = c.account_csn
                   LEFT JOIN ACCOUNT_EDP d
                            ON d.site_uuid_csn = c.site_uuid_csn
         ),
     EDP_Subs_to_EPM_final as (
         SELECT DISTINCT ENTITLEMENT_MODEL
                       , SERIAL_NUMBER
                       , SUBSCRIPTION_END_DATE
                       , OWNER_ID
                       , USAGE_TYPE
                       , ENT_SUBS_ID
                       , SUBSCRIPTION_ID
                       , CONTRACT_ID
                       , CONTRACT_STATUS
                       , CONTRACT_START_DATE
                       , CONTRACT_END_DATE
                       , PURCHASED_SEAT_QUANTITY
                       , USABLE_SEAT_QUANTITY
                       , OFFERING_TYPE
                       , OFFERING_NAME
                       , OFFERING_PRODUCT_LINE_CODE
                       , FEATURE_TYPE
                       , FEATURE_NAME
                       , PRODUCT_LINE_CODE
                       , ECCR_FLAG
                       , TENANT_ID
                       , POOL_ID
                       , OXYGEN_ID_CM
                       , END_CUSTOMER_ACCT_CSN
                       , CORPORATE_PARENT_CSN
                       , OFFERING_EXTERNAL_KEY
                       , SEATS_PURCHASED
                       , SEATS_ASSIGNED
                       , SEATS_UNASSIGNED
                       , ASSIGNED_PLC
                       , ASSIGNABLE
                       , oxygen_id_pa
                       , DT
                       , BY_MONTH
                       , current_date() as INSERT_DT
                       , current_date() as UPDATE_DT
         from AUM_PA
     )
select *
from EDP_Subs_to_EPM_final


        );
      
  