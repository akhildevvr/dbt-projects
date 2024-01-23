---
title: Calculate EBA Token mismatch on SDFC and SAP-CORE
author: Enterprise Data and Analytics, Global Revenue Operations
tags:
  - how-to
  - analysis
---

## :material-list-box-outline:{ .red-icon-heading } Introduction

<h3>Objective</h3>
This document explains how to calculate mismatch or validate the annual and multi year tokens from salesforce (SDFC) vs SAP-CORE for EBA (Enterprise Business Agreement) accounts.


<h3>Purpose</h3>

The purpose of this guide is to help the analysts community to perform a data quality check between two main source systems of tokens (i.e. SDFC and SAP-CORE) in the most appropriate and standardized way. Token mismatch calculation is required to ensure the maintenance of clean token data used across multiple teams. 

Currently the Premier team utilizes an RPA (Robotic Process Automation) to highlight those mismatches which are further described in [FAQ](#faqs)

Tokens data links customer transaction with Autodesk in terms of agreement and it is fundamental to nearly all analytics. The amount of multi-year/annual tokens can be changed throughout a contract term due to purchases or amendments. Due to it's fluid behaviour, it can be tricky to capture the exact purchased, consumed and remaining tokens when joining datasets across systems.
The token mismatch calculation ensures that all systems involved display the correct amounts after such a transaction.  


!!! note "Notes"
    It is fundamental to know that this validation of tokens between SDFC and CORE systems is only performed as an example for 'Token-Flex' exhibit types whose status is currently `Active`.   


## :material-format-list-checks:{ .green-icon-heading } Prerequisites

In order to perform the mismatch validation, you need to have access to the following tables:

| Schema/Database | View/Table | Basic Filters | Usage | 
| --------------- | ---------- | ------------- | ----- |
| BSD_PUBLISH.SDFC_SHARED | [ACCOUNT](https://autodesk.atlan.com/assets/b7434f7a-60b9-4fc0-8b47-d436e391fa17/overview) | | Used to capture Account description |
| BSD_PUBLISH.SDFC_SHARED | [END_CUSTOMER_CONTRACTS__C](https://autodesk.atlan.com/assets/3be063a9-e069-425e-bbf9-07f7d777f136/overview)| agreemen_type__c = 'Purchasing & Services Agreement' AND status__c = 'Active' | Used to capture Contract Exhibit details |
| BSD_PUBLISH.SDFC_SHARED | [CONTRACT_EXHIBIT__C](https://autodesk.atlan.com/assets/38bf15c9-731c-40b3-a60f-d3eac64cfba8/overview)| type__c = 'Token-Flex' AND reporting_platform__c = 'NLRS' AND active__c = TRUE AND name <> 'EX-050728' | The SDFC table for tokens capturing the data for all contract provisioned. | 
| ADP_PUBLISH.TOKEN_FLEX_CORE_PUBLIC | [T_ECCR_CONTRACT_PROVISION](https://autodesk.atlan.com/assets/56791e7d-aa35-483f-a9af-488a12f49241/overview) | exhibit_status_flg = TRUE | The CORE table for tokens capturing the data for all contract provisioned. |

- Request access via [ADP Access Management](https://access.adp.autodesk.com/data-access/snowflake).
- For more information, please refer to [ADP Access Management User Guide](https://wiki.autodesk.com/pages/viewpage.action?spaceKey=CPDDPS&title=ADP+Access+Management+User+Guide), or contact the team on their slack channel [#adp-access-support](https://autodesk.enterprise.slack.com/archives/C05JFCCB0FK).


## :fontawesome-solid-map-location:{ .purple-icon-heading } Methodology

Joining datasets of different source types is challenging as they might not reflect the tokens data due to the change in purchase tokens annually and amendments. This is not different when joining **CORE Token data**, sourced from CORE ECCR systems, with **SDFC Token data**, sourced from SalesForce. 


It is important to understand the nature of the different systems:

1. **CORE Token Data**: Agreement based, having term start date and end date along with token flex agreement numbers. 
2. **SDFC Token Data**: Salesforce data of the whole account with token agreement details and other contract details.


To calculate the mismatch between CORE and SDFC system, using `end_customer_contracts__c` table pulling dimension from `account`, the following steps will guide you: 

### 1. Join tokens tables from SFDC and CORE

This query gets the main columns from accounts table and joins with SDFC and CORE tables to get annual and multiyear tokens i.e. `sdfc_annual_tokens_year`, `core_annual_tokens_year`, `sdfc_multi_year_tokens` and `core_multi_year_tokens`.


??? abstract "Creating Annual_tokens yearly for SDFC and CORE tables and getting dimensions from `account` table"
    #### Step 1

   
    ``` sql linenums="1"
      -- this CTE has main raw column from sources 
      WITH sdfc_vs_sap_core AS
      (
        SELECT
            acc.name AS account_name
            , acc.account_csn__c AS account_csn
            , contracts.name AS agreement_name
            , exhibit.start_date__c AS exhibit_start_date
            , exhibit.end_date__c AS exhibit_end_date          
            , exhibit.annual_token_baseline_year_1__c AS sfdc_annual_tokens_year_1
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 1 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_1          
            , exhibit.annual_token_baseline_year_2__c AS sfdc_annual_tokens_year_2
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 2 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_2          
            , exhibit.annual_token_baseline_year_3__c AS sfdc_annual_tokens_year_3
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 3 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_3          
            , exhibit.annual_token_baseline_year_4__c AS sfdc_annual_tokens_year_4
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 4 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_4          
            , exhibit.annual_token_baseline_year_5__c AS sfdc_annual_tokens_year_5
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 5 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_5          
            , exhibit.multi_year_token__c AS sfdc_multi_year_tokens
            , SUM(CASE WHEN prov.token_type_nm = 'MULTI_YEAR' THEN prov.units_provisioned_qty END) AS core_multi_year_tokens
        FROM
            bsd_publish.sfdc_shared.account AS acc   
            JOIN bsd_publish.sfdc_shared.end_customer_contracts__c AS contracts ON (acc.id = contracts.account__c )
            JOIN bsd_publish.sfdc_shared.contract_exhibit__c AS exhibit ON (contracts.id = exhibit.end_customer_contracts__c)
            JOIN adp_publish.token_flex_core_public.t_eccr_contract_provision AS prov ON (contracts.id = prov.end_customer_agreement_id)
        WHERE
            contracts.agreemen_type__c = 'Purchasing & Services Agreement'
            AND exhibit.type__c = 'Token-Flex'
            AND exhibit.reporting_platform__c = 'NLRS'
            AND contracts.status__c = 'Active'
            AND exhibit.active__c = True
            AND prov.exhibit_status_flg = True
            AND exhibit.name <> 'EX-050728' -- Bechtel Exception
        GROUP BY
            acc.name
            , acc.account_csn__c
            , contracts.name
            , exhibit.start_date__c
            , exhibit.end_date__c
            , exhibit.annual_token_baseline_year_1__c
            , exhibit.annual_token_baseline_year_2__c
            , exhibit.annual_token_baseline_year_3__c
            , exhibit.annual_token_baseline_year_4__c
            , exhibit.annual_token_baseline_year_5__c
            , exhibit.multi_year_token__c
        ORDER BY
            acc.name
      ),
    ```

### 2. Add annual and multiyear difference

This step adds columns for `annual_year_1_difference` and likewise for all 5 years and `multi_year_difference`.

The difference is calculated between `sfdc_annual_tokens_year_1` and `core_annual_tokens_year_1` for year 1 and similarly for all 5 years.
For `multi_year_difference`, it is the difference between `sfdc_multi_year_tokens`, `core_multi_year_tokens`. If the difference is 0, then it is a 'MATCH', otherwise 'MISMATCH'

??? abstract "Sample: Describing the difference calculation column"
    
    ``` sql linenums="1"
    -- this is sample for the difference in SDFC and CORE tokens:

      CASE WHEN
          (SUM
              (CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 1 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty else 0 END)
            - (CASE WHEN exhibit.annual_token_baseline_year_1__c IS NOT NULL THEN exhibit.annual_token_baseline_year_1__c ELSE 0 END)) = 0
          THEN 'MATCH' 
          ELSE 'MISMATCH' 
      END AS annual_year_1_difference
    ```

??? abstract "Add annual and multiyear difference to the main CTE"
    #### Step 2

    ``` sql linenums="1"
    --  this CTE is extension of (step 1): ----------------------------------------------------------------
    With sdfc_vs_sap_core AS
    (
        SELECT
            acc.name AS account_name
            , acc.account_csn__c AS account_csn
            , contracts.name AS agreement_name
            , exhibit.start_date__c AS exhibit_start_date
            , exhibit.end_date__c AS exhibit_end_date
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 1 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_1__c IS NOT NULL THEN exhibit.annual_token_baseline_year_1__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_1_difference
            , exhibit.annual_token_baseline_year_1__c AS sfdc_annual_tokens_year_1
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 1 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_1
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 2 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_2__c IS NOT NULL THEN exhibit.annual_token_baseline_year_2__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_2_difference
            , exhibit.annual_token_baseline_year_2__c AS sfdc_annual_tokens_year_2
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 2 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_2
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 3 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_3__c IS NOT NULL THEN exhibit.annual_token_baseline_year_3__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_3_difference
            , exhibit.annual_token_baseline_year_3__c AS sfdc_annual_tokens_year_3
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 3 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_3
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 4 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_4__c IS NOT NULL THEN exhibit.annual_token_baseline_year_4__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_4_difference
            , exhibit.annual_token_baseline_year_4__c AS sfdc_annual_tokens_year_4
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 4 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_4
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 5 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_5__c IS NOT NULL THEN exhibit.annual_token_baseline_year_5__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_5_difference
            , exhibit.annual_token_baseline_year_5__c AS sfdc_annual_tokens_year_5
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 5 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_5
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'MULTI_YEAR' THEN prov.units_provisioned_qty END)
                    - (CASE WHEN exhibit.multi_year_token__c IS NOT NULL THEN exhibit.multi_year_token__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS multi_year_difference
            , exhibit.multi_year_token__c AS sfdc_multi_year_tokens
            , SUM(CASE WHEN prov.token_type_nm = 'MULTI_YEAR' THEN prov.units_provisioned_qty END) AS core_multi_year_tokens
        FROM
            bsd_publish.sfdc_shared.account AS acc   
            JOIN bsd_publish.sfdc_shared.end_customer_contracts__c AS contracts ON (acc.id = contracts.account__c )
            JOIN bsd_publish.sfdc_shared.contract_exhibit__c AS exhibit ON (contracts.id = exhibit.end_customer_contracts__c)
            JOIN adp_publish.token_flex_core_public.t_eccr_contract_provision AS prov ON (contracts.id = prov.end_customer_agreement_id)
        WHERE
            contracts.agreemen_type__c = 'Purchasing & Services Agreement'
            AND exhibit.type__c = 'Token-Flex'
            AND exhibit.reporting_platform__c = 'NLRS'
            AND contracts.status__c = 'Active'
            AND exhibit.active__c = True
            AND prov.exhibit_status_flg = True
            AND exhibit.name <> 'EX-050728' -- Bechtel Exception
        GROUP BY
            acc.name
            , acc.account_csn__c
            , contracts.name
            , exhibit.start_date__c
            , exhibit.end_date__c
            , exhibit.annual_token_baseline_year_1__c
            , exhibit.annual_token_baseline_year_2__c
            , exhibit.annual_token_baseline_year_3__c
            , exhibit.annual_token_baseline_year_4__c
            , exhibit.annual_token_baseline_year_5__c
            , exhibit.multi_year_token__c
        ORDER BY
            acc.name
    ),
        
    ```

### 3. Calculate the overall mismatch filter

This query is selecting each Annual Year Difference and Multi year difference and calculating a final mismatch Filter.
The value 'MATCH' of this field will determine that there is no mismatches or error between SDFC and CORE tokens

??? abstract "Calculating `Mismatch_Filter`"
    #### Step 3

    ``` sql linenums="1"  
    -- This CTE is calculating overall mismatch filter
    -- This steps needs to use CTE from step 2:

    -- step 2 -----------------------------------------------------------------------------------------------
    With sdfc_vs_sap_core AS
    (
        SELECT
            acc.name AS account_name
            , acc.account_csn__c AS account_csn
            , contracts.name AS agreement_name
            , exhibit.start_date__c AS exhibit_start_date
            , exhibit.end_date__c AS exhibit_end_date
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 1 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_1__c IS NOT NULL THEN exhibit.annual_token_baseline_year_1__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_1_difference
            , exhibit.annual_token_baseline_year_1__c AS sfdc_annual_tokens_year_1
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 1 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_1
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 2 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_2__c IS NOT NULL THEN exhibit.annual_token_baseline_year_2__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_2_difference
            , exhibit.annual_token_baseline_year_2__c AS sfdc_annual_tokens_year_2
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 2 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_2
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 3 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_3__c IS NOT NULL THEN exhibit.annual_token_baseline_year_3__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_3_difference
            , exhibit.annual_token_baseline_year_3__c AS sfdc_annual_tokens_year_3
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 3 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_3
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 4 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_4__c IS NOT NULL THEN exhibit.annual_token_baseline_year_4__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_4_difference
            , exhibit.annual_token_baseline_year_4__c AS sfdc_annual_tokens_year_4
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 4 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_4
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 5 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_5__c IS NOT NULL THEN exhibit.annual_token_baseline_year_5__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_5_difference
            , exhibit.annual_token_baseline_year_5__c AS sfdc_annual_tokens_year_5
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 5 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_5
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'MULTI_YEAR' THEN prov.units_provisioned_qty END)
                    - (CASE WHEN exhibit.multi_year_token__c IS NOT NULL THEN exhibit.multi_year_token__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS multi_year_difference
            , exhibit.multi_year_token__c AS sfdc_multi_year_tokens
            , SUM(CASE WHEN prov.token_type_nm = 'MULTI_YEAR' THEN prov.units_provisioned_qty END) AS core_multi_year_tokens
        FROM
            bsd_publish.sfdc_shared.account AS acc   
            JOIN bsd_publish.sfdc_shared.end_customer_contracts__c AS contracts ON (acc.id = contracts.account__c )
            JOIN bsd_publish.sfdc_shared.contract_exhibit__c AS exhibit ON (contracts.id = exhibit.end_customer_contracts__c)
            JOIN adp_publish.token_flex_core_public.t_eccr_contract_provision AS prov ON (contracts.id = prov.end_customer_agreement_id)
        WHERE
            contracts.agreemen_type__c = 'Purchasing & Services Agreement'
            AND exhibit.type__c = 'Token-Flex'
            AND exhibit.reporting_platform__c = 'NLRS'
            AND contracts.status__c = 'Active'  
            AND exhibit.active__c = True
            AND prov.exhibit_status_flg = True
            AND exhibit.name <> 'EX-050728' -- Bechtel Exception
        GROUP BY
            acc.name
            , acc.account_csn__c
            , contracts.name
            , exhibit.start_date__c
            , exhibit.end_date__c
            , exhibit.annual_token_baseline_year_1__c
            , exhibit.annual_token_baseline_year_2__c
            , exhibit.annual_token_baseline_year_3__c
            , exhibit.annual_token_baseline_year_4__c
            , exhibit.annual_token_baseline_year_5__c
            , exhibit.multi_year_token__c
        ORDER BY
            acc.name
    ),

    -- Calculate the overall mismatch filter (step 3) --------------------------------------------------------
    sdfc_vs_sap_core_with_mismatch AS
    (
      SELECT 
        * ,
        CASE
          WHEN
            annual_year_1_difference = 'MISMATCH' OR
            annual_year_2_difference = 'MISMATCH' OR
            annual_year_3_difference = 'MISMATCH' OR
            annual_year_4_difference = 'MISMATCH' OR
            annual_year_5_difference = 'MISMATCH' OR
            multi_year_difference = 'MISMATCH'
          THEN 'MISMATCH'
          ELSE 'MATCH'
        END AS mismatch_filter   
      FROM sdfc_vs_sap_core
    )
      
    ```

### 4. Determine mismatched token entries

This final step is finding the mismatched token entry from the final table by selecting the 'MISMATCH' `agreement_names` from each accounts.
It will give the list of all the mismatches validating both SDFC and CORE tables


??? abstract "Selecting only the `Mismatch` entries from the final table"
    #### Step 4

    ``` sql linenums="1" 
    -- This code is calculating final output
    -- This steps needs to use CTE from step 2 and 3:

    -- step 2 -----------------------------------------------------------------------------------------------
    With sdfc_vs_sap_core AS
    (
        SELECT
            acc.name AS account_name
            , acc.account_csn__c AS account_csn
            , contracts.name AS agreement_name
            , exhibit.start_date__c AS exhibit_start_date
            , exhibit.end_date__c AS exhibit_end_date
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 1 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_1__c IS NOT NULL THEN exhibit.annual_token_baseline_year_1__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_1_difference
            , exhibit.annual_token_baseline_year_1__c AS sfdc_annual_tokens_year_1
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 1 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_1
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 2 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_2__c IS NOT NULL THEN exhibit.annual_token_baseline_year_2__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_2_difference
            , exhibit.annual_token_baseline_year_2__c AS sfdc_annual_tokens_year_2
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 2 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_2
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 3 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_3__c IS NOT NULL THEN exhibit.annual_token_baseline_year_3__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_3_difference
            , exhibit.annual_token_baseline_year_3__c AS sfdc_annual_tokens_year_3
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 3 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_3
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 4 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_4__c IS NOT NULL THEN exhibit.annual_token_baseline_year_4__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_4_difference
            , exhibit.annual_token_baseline_year_4__c AS sfdc_annual_tokens_year_4
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 4 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_4
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 5 AND prov.units_provisioned_qty IS NOT NULL THEN prov.units_provisioned_qty ELSE 0 END)
                    - (CASE WHEN exhibit.annual_token_baseline_year_5__c IS NOT NULL THEN exhibit.annual_token_baseline_year_5__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS annual_year_5_difference
            , exhibit.annual_token_baseline_year_5__c AS sfdc_annual_tokens_year_5
            , SUM(CASE WHEN prov.token_type_nm = 'ANNUAL' AND prov.end_customer_agreement_yr_ind = 5 THEN prov.units_provisioned_qty END) AS core_annual_tokens_year_5
            , CASE WHEN
                    (SUM(CASE WHEN prov.token_type_nm = 'MULTI_YEAR' THEN prov.units_provisioned_qty END)
                    - (CASE WHEN exhibit.multi_year_token__c IS NOT NULL THEN exhibit.multi_year_token__c ELSE 0 END)) = 0
                THEN 'MATCH' ELSE 'MISMATCH' END AS multi_year_difference
            , exhibit.multi_year_token__c AS sfdc_multi_year_tokens
            , SUM(CASE WHEN prov.token_type_nm = 'MULTI_YEAR' THEN prov.units_provisioned_qty END) AS core_multi_year_tokens
        FROM
            bsd_publish.sfdc_shared.account AS acc   
            JOIN bsd_publish.sfdc_shared.end_customer_contracts__c AS contracts ON (acc.id = contracts.account__c )
            JOIN bsd_publish.sfdc_shared.contract_exhibit__c AS exhibit ON (contracts.id = exhibit.end_customer_contracts__c)
            JOIN adp_publish.token_flex_core_public.t_eccr_contract_provision AS prov ON (contracts.id = prov.end_customer_agreement_id)
        WHERE
            contracts.agreemen_type__c = 'Purchasing & Services Agreement'
            AND exhibit.type__c = 'Token-Flex'
            AND exhibit.reporting_platform__c = 'NLRS'
            AND contracts.status__c = 'Active'
            AND exhibit.active__c = True
            AND prov.exhibit_status_flg = True
            AND exhibit.name <> 'EX-050728' -- Bechtel Exception
        GROUP BY
            acc.name
            , acc.account_csn__c
            , contracts.name
            , exhibit.start_date__c
            , exhibit.end_date__c
            , exhibit.annual_token_baseline_year_1__c
            , exhibit.annual_token_baseline_year_2__c
            , exhibit.annual_token_baseline_year_3__c
            , exhibit.annual_token_baseline_year_4__c
            , exhibit.annual_token_baseline_year_5__c
            , exhibit.multi_year_token__c
        ORDER BY
            acc.name
    ),

    -- Calculate the overall mismatch filter (step 3) --------------------------------------------------------
    sdfc_vs_sap_core_with_mismatch AS
    (
      SELECT 
        * ,
        CASE
          WHEN
            annual_year_1_difference = 'MISMATCH' OR
            annual_year_2_difference = 'MISMATCH' OR
            annual_year_3_difference = 'MISMATCH' OR
            annual_year_4_difference = 'MISMATCH' OR
            annual_year_5_difference = 'MISMATCH' OR
            multi_year_difference = 'MISMATCH'
          THEN 'MISMATCH'
          ELSE 'MATCH'
        END AS mismatch_filter   
      FROM sdfc_vs_sap_core
    )

    --  Determine mismatched token entries (step 4) ------------------------------------------------------------------
    SELECT * FROM sdfc_vs_sap_core_with_mismatch WHERE mismatch_filter = 'MISMATCH'
      
    ```

### Output table

This table is the output result for accounts with mismatch in annual/multiyear tokens.

| ACCOUNT_NAME        | ACCOUNT_CSN | AGREEMENT_NAME | EXHIBIT_START_DATE | EXHIBIT_END_DATE | ANNUAL_YEAR_1_DIFFERENCE | SFDC_ANNUAL_TOKENS_YEAR_1 | CORE_ANNUAL_TOKENS_YEAR_1 | ANNUAL_YEAR_2_DIFFERENCE | SFDC_ANNUAL_TOKENS_YEAR_2 | CORE_ANNUAL_TOKENS_YEAR_2 | ANNUAL_YEAR_3_DIFFERENCE | SFDC_ANNUAL_TOKENS_YEAR_3 | CORE_ANNUAL_TOKENS_YEAR_3 | ANNUAL_YEAR_4_DIFFERENCE | SFDC_ANNUAL_TOKENS_YEAR_4 | CORE_ANNUAL_TOKENS_YEAR_4 | ANNUAL_YEAR_5_DIFFERENCE | SFDC_ANNUAL_TOKENS_YEAR_5 | CORE_ANNUAL_TOKENS_YEAR_5 | MULTI_YEAR_DIFFERENCE | SFDC_MULTI_YEAR_TOKENS | CORE_MULTI_YEAR_TOKENS | MISMATCH_FILTER |
| ------------------- | ----------- | -------------- | ------------------ | ---------------- | ------------------------ | ------------------------- | ------------------------- | ------------------------ | ------------------------- | ------------------------- | ------------------------ | ------------------------- | ------------------------- | ------------------------ | ------------------------- | ------------------------- | ------------------------ | ------------------------- | ------------------------- | --------------------- | ---------------------- | ---------------------- | --------------- |
| ADIENT              | 5126233401  | US22TFP011     | 27-07-22           | 26-07-25         | MISMATCH                 | 0                         | 1                         | MATCH                    | 0                         | 0                         | MATCH                    | 0                         | 0                         | MATCH                    |                           |                           | MATCH                    |                           |                           | MATCH                 | 1570000                | 1570000                | MISMATCH        |
| AECOM GLOBAL INC.   | 5070253078  | US20TFP037     | 30-04-22           | 29-04-25         | MISMATCH                 | 0                         | 1                         | MATCH                    | 0                         | 0                         | MATCH                    | 0                         | 0                         | MATCH                    |                           |                           | MATCH                    |                           |                           | MATCH                 | 94671120               | 94671120               | MISMATCH        |
| AMAZON              | 5106942369  | US20TF0007     | 20-11-20           | 30-11-23         | MISMATCH                 | 0                         | 1                         | MATCH                    | 0                         | 0                         | MATCH                    | 0                         | 0                         | MATCH                    |                           |                           | MATCH                    |                           |                           | MATCH                 | 8100000                | 8100000                | MISMATCH        |
| BLUESCOPE STEEL Ltd | 5112945896  | AU21TFP002     | 15-12-21           | 14-12-24         | MISMATCH                 | 0                         | 1                         | MATCH                    | 0                         | 0                         | MATCH                    | 0                         | 0                         | MATCH                    | 0                         |                           | MATCH                    | 0                         |                           | MATCH                 | 4212013                | 4212013                | MISMATCH        |
| BONAVA AB           | 5150239536  | SE20TFP003     | 18-06-22           | 17-06-25         | MATCH                    | 896019                    | 896019                    | MATCH                    | 896019                    | 896019                    | MISMATCH                 | 896019                    | 896020                    | MATCH                    |                           |                           | MATCH                    |                           |                           | MATCH                 | 1792038                | 1792038                | MISMATCH        |
| Bechtel Group       | 5070251120  | US21TFP003     | 01-01-21           | 31-12-25         | MISMATCH                 | 0                         | 1                         | MATCH                    | 0                         | 0                         | MATCH                    | 0                         | 0                         | MATCH                    |                           | 0                         | MATCH                    |                           | 0                         | MATCH                 | 7350000                | 7350000                | MISMATCH        |

## :material-head-question:{ .grey-icon-heading } Clarifications

### FAQs

??? question "Is there a use case where the above logic is applied?"
    #### FAQ 1
    Yes, there is a RPA bot which uses this Validation calculation logic to calculate mismtahces in tokens. 

    If any mismatch is found between SDFC and CORE by this method, the BOT performs the following: 

      1. 1st time case is created via email to Premier
      2. 2nd time if case remains opened for more than a week, then reminder is sent to JiHyun and Linda
      3. If case status is closed in SFDC  , then reminder is sent to JiHyun and Linda only if same account data remains open in SFDC/CORE SAP report
  
    For more details on this use case the [PDD-Automation with Token Mismatch and BIM CSN Mapping Report](https://wiki.autodesk.com/display/DES/PDD-Automation+with+Token+Mismatch+and+BIM+CSN+Mapping+Report). It makes use of the same approach to report on mismatched tokens as a data quality check and create [Token Mismatch Case Creation](https://wiki.autodesk.com/display/PREX/Token+Mismatch+Case+Creation)


## :material-link:{ .grey-icon-heading } Relevant Links

- [Metric: Token Consumption (Flex Access) (Wiki)](https://wiki.autodesk.com/pages/viewpage.action?pageId=1872122661)
- [Token Consumption - Use cases (Wiki)](https://wiki.autodesk.com/display/EAX/Token+Consumption++-+Use+cases)
- [Validation Dashboard - Scope Reduction and retirement (Wiki)](https://wiki.autodesk.com/display/EAX/Validation+Dashboard+-+Scope+Reduction+and+retirement#expand-1DetailedCurrentScenario)

