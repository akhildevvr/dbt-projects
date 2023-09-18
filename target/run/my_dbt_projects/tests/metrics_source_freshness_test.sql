select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      


-- this macro contains code to check the source freshness of all source tables
    

    
    

    

    
        

        
        
        
        
        SELECT
            TOP 1
            'source_freshness' AS test_type,
            LOWER('nps') AS kpi_name,
            'eio_publish.engagement_shared.nps_eba_non_eba_survey' AS source,
            TO_TIMESTAMP('2023-07-29') AS max_loaded_date,
            CURRENT_DATE() AS dt
        FROM eio_publish.engagement_shared.nps_eba_non_eba_survey
            WHERE DATEDIFF('day', TO_TIMESTAMP('2023-07-29'), CURRENT_TIMESTAMP()) > 1
        
        
            UNION ALL
        

    
        

        
        
        
        
        SELECT
            TOP 1
            'source_freshness' AS test_type,
            LOWER('aov') AS kpi_name,
            'adp_workspaces.customer_success_finance_private.curated_finmart' AS source,
            TO_TIMESTAMP('2023--0-7-') AS max_loaded_date,
            CURRENT_DATE() AS dt
        FROM adp_workspaces.customer_success_finance_private.curated_finmart
            WHERE DATEDIFF('day', TO_TIMESTAMP('2023--0-7-'), CURRENT_TIMESTAMP()) > 1
        
        
            UNION ALL
        

    
        

        
        
        
        
        SELECT
            TOP 1
            'source_freshness' AS test_type,
            LOWER('billings') AS kpi_name,
            'adp_workspaces.customer_success_finance_private.subs_billed_seats_finmart' AS source,
            TO_TIMESTAMP('2023--0-7-') AS max_loaded_date,
            CURRENT_DATE() AS dt
        FROM adp_workspaces.customer_success_finance_private.subs_billed_seats_finmart
            WHERE DATEDIFF('day', TO_TIMESTAMP('2023--0-7-'), CURRENT_TIMESTAMP()) > 1
        
        
            UNION ALL
        

    
        

        
        
        
        
        SELECT
            TOP 1
            'source_freshness' AS test_type,
            LOWER('acv') AS kpi_name,
            'bsd_publish.finmart_private.cvc_finmart' AS source,
            TO_TIMESTAMP('2023-07-31 11:12:02+00:00') AS max_loaded_date,
            CURRENT_DATE() AS dt
        FROM bsd_publish.finmart_private.cvc_finmart
            WHERE DATEDIFF('day', TO_TIMESTAMP('2023-07-31 11:12:02+00:00'), CURRENT_TIMESTAMP()) > 1
        
        
            UNION ALL
        

    
        

        
        
        
        
        SELECT
            TOP 1
            'source_freshness' AS test_type,
            LOWER('multi year billings rate') AS kpi_name,
            'bsd_publish.finmart_private.cvc_finmart' AS source,
            TO_TIMESTAMP('2023-07-31 11:12:02+00:00') AS max_loaded_date,
            CURRENT_DATE() AS dt
        FROM bsd_publish.finmart_private.cvc_finmart
            WHERE DATEDIFF('day', TO_TIMESTAMP('2023-07-31 11:12:02+00:00'), CURRENT_TIMESTAMP()) > 1
        
        

    


      
    ) dbt_internal_test