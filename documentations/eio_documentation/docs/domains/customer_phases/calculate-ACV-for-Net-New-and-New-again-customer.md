---
title: Calculate ACV for Net-New and New-Again Customers
author: Enterprise Data and Analytics, Global Revenue Operations
tags:
  - how-to
  - analysis
search:
  exclude: true
---

## :material-list-box-outline:{ .red-icon-heading } Introduction

<!-- 1. INTRODUCTION 
      1.1. Write one introductory sentence to explain the objective of this document.
      1.2. Add another sentence, a paragraph and/or a list to explain the purpose of the guide, the problem that it helps to solve, and/or its main use case.
      1.3. (Optional) Write "Notes", each note on a bullet point. For example:
            1.3.1. Will you need to explain other situations besides the main use case? (Use the "Other Use Cases" section in template to explain them, if any).
            1.3.2. Is this how-to guide a part of a series of how-tos?
-->

<h3>Objective</h3>
This document explains how to calculate a financial metric `ACV` for a specific cohort of `customer phases`. This enables the analyst community to compare the Annual Contract value (ACV) between a "Net-New" and "New-Again" customer, and therefore provide valuable insight for the organization.

<h3>Purpose</h3>

The purpose of this guide is to help the analysts community to correlate those two different data domains (ie. Finance and Customer data) in the most appropriate and standardized way. Account data links business transactions to customer organizations and it is fundamental to nearly all analytics. Due to it's fluid behaviour, can be tricky to navigate when joining datasets across systems.

!!! note "Notes"
    It is fundamental to get familiar with the following concepts:

    - [ACV metric definition](../../onboarding/metrics/acv-metric.md)
    - [Customer Phases Concept](customer-phases.md/)


## :material-format-list-checks:{ .green-icon-heading } Prerequisites

<!-- 2. PREREQUISITES
      2.1. Indicate if there any prerequisites using as many paragraphs as you need and/or a list of items. If there isn't any relevant requisite, you can just write "None."
      2.2. (Optional) Add elements (image, video, etc.) that help users understand what they need.
-->

In order to perform the following query, you need to have a access to the following tables:

| Schema/Database | View/Table | Basic Filters | Usage | 
| --------------- | ---------- | ------------- | ----- |
| BSD_PUBLISH.FINMART_PRIVATE | [CVC_FINMART](https://autodesk.atlan.com/assets/95f1294a-9e49-4639-af06-05087297a6d0/overview) | RECORD_TYPE = 'BILLING' | Used to capture ACV for all quarters |
| BSD_PUBLISH.FINMART_SHARED | [CVC_FINMART](https://autodesk.atlan.com/assets/0a4909f8-3f19-4d9c-b6ea-fd4b3a2e5128/overview)| RECORD_TYPE = 'BILLING' | Used to capture ACV for previous quarters |
| EIO_PUBLISH.CUSTOMER_SHARED | [CUSTOMER_PHASES](https://autodesk.atlan.com/assets/8ce20999-1cf0-42ab-b66d-507a52818401/overview)| | Purchase phases of Autodesk customers| 
| ADP_PUBLISH.ACCOUNT_OPTIMIZED | [ACCOUNT_EDP_OPTIMIZED](https://autodesk.atlan.com/assets/39323831-808d-4799-8731-93f571972032/overview) | | The Account Core Enterprise Dataset (CED) |
| EDM_PUBLISH.EDM_PUBLIC | [VICTIM_SURVIVOR_MAPPING](https://autodesk.atlan.com/assets/f1c8d15f-7038-4cee-92a4-82890b2dd08d/overview) | final_merge_status = 'COMPLETED' | Correlated merges between duplicated accounts
| ADP_PUBLISH.ACCOUNT_OPTIMIZED | [TRANSACTIONAL_CSN_MAPPING_OPTIMIZED](https://autodesk.atlan.com/assets/c2755a87-0dc4-4059-9366-a65c8bfc0ad5/overview) | | Allow users to join to the account_csns and source system IDs that make up each site_uuid_csn |
| EIO_PUBLISH.REFERENCE_PRIVATE | [ACCOUNT_TOTAL_MERGED_GTM_HIERARCHY](https://autodesk.atlan.com/assets/845f0119-b148-4806-9b5d-c7ecb42a7aae/overview) | | Provide an interim solution to remove known duplicates from Account CED data. When EDH goes live this code should be sunset. | 


To request access, refer to [ADP Snowflake Access](../../onboarding/How-Tos/how-to-test/access-adp-snowflake.md)

## :fontawesome-solid-map-location:{ .purple-icon-heading } Methodology

Joining datasets across different systems is challenging as they might not reflect the same population nor updates regarding the account data. This is not different when joining **Finance data**, sourced from SAP, with **customer data**, sourced from SalesForce. 

It is important to understand the nature of the different systems:

1. **Finance Data**: transactional based = "point in time", represented in the table `cvc_finmart`
2. **Customer Data**: current account status, represented in the table `account_ced`
3. **Customer Phase Data**: categorize in which phase of the customer purchase cycle, represented in the table `customer_phases`.


<figure markdown>
  ![](./assets/overview/traversing-account-data-navigate-between-populations.png){ width="900px" }
  <figcaption></figcaption>
</figure>

To navigate from `cvc_finmart`, which is a point in time fact table, to the consolidated status from `customer_phases`, and pulling the dimensions from `account_ced`, the following the steps will guide you:

### 1. Prepare the data with deduplicated accounts and dimensions  

This query removes known duplicates accounts from Account CED data, selects required dimensions, and joins with customer phases table. In this example e are selecting `account_geo`, `site_individual_flag` and `is_visible_in_sfdc`. For more information on those last 2 flags, please refer to [traversing account data](../customer_phases/traversing-account-data.md).

??? abstract "Deduplicating accounts from `account_total_merged_gtm_hierarchy` and getting dimensions from `account_ced` and `customer phases`"
    #### Step 1

   
    ``` sql linenums="1"
      -- this CTE is account_ced_dimension

        SELECT
          h.final_parent_account_csn    AS parent_csn,
          t.account_csn                 AS account_csn,
          c.customer_phase,
          c.customer_phase_start_date,
          CONCAT(SUBSTRING(c.customer_phase_start_date,1,4),'-',SUBSTRING(c.customer_phase_start_date,6,2),'-','01')  AS by_month_customer_phase_start_date,
          c.customer_phase_end_date,
          CONCAT(SUBSTRING(c.customer_phase_end_date,1,4),'-',SUBSTRING(c.customer_phase_end_date,6,2),'-','01')  AS by_month_customer_phase_end_date,

          a.site_geo                        AS account_geo,
          a.site_individual_flag, 
          a.is_visible_in_sfdc, 
          a.site_uuid_csn,
          CONCAT('FY',SUBSTRING(start_fiscal_year_quarter, 3, 2)) AS fiscal_year,
          c.START_FISCAL_YEAR_QUARTER
        FROM adp_publish.account_optimized.account_edp_optimized  a
        LEFT JOIN adp_publish.account_optimized.transactional_csn_mapping_optimized t
            ON a.site_uuid_csn = t.site_uuid_csn
        INNER JOIN ( -- this is deduplicating accounts
                SELECT 
                  DISTINCT site_account_csn,
                  final_account_csn, 
                  final_parent_account_csn     
                FROM eio_publish.reference_private.account_total_merged_gtm_hierarchy) h
            ON t.account_csn =  h.site_account_csn 
        LEFT JOIN  eio_publish.customer_shared.customer_phases c
            ON  h.final_parent_account_csn = c.parent_csn 
  
    ```

### 2. Join Finance data with Customer data  

This query is selects the relevant fields for the metrics `ACV`, `Billings` and `Multi-year Billings` from `cvc_finmart`, joins with `victim_survivor_mapping` to get the most updated view on merged accounts. It filters `final_merge_status = 'COMPLETED'`.

??? abstract "Joining `cvc_finmart` with `victim_survivor_mapping`"
    #### Step 2

    ``` sql linenums="1"
    -- this CTE is cvc_finmart_vs_mapping:

          SELECT 
            COALESCE( v.surviving_account_csn, fm.corporate_csn) AS account_csn, --swapping victim accounts with surviving
            fm.fy_and_fq_name,
            fm.settlement_start_dt,
          
            ---ACV
            fm.cc_fbm_total_acv_net1_usd,
            fm.cc_fbm_total_acv_net2_usd,
            fm.cc_fbm_total_acv_net3_usd,
            fm.cc_fbm_total_acv_net4_usd,
            fm.record_type,
            fm.transaction_dt,
 
            ---MY (additional example)
            fm.cc_fbd_bil_term_sgrp,
            fm.cc_billed_bgt_usd_cur,

            ---billings (additional example)
            fm.billed_srp_usd_amt,
            fm.bill_net1_usd_amt,
            fm.bill_net2_usd_amt,
            fm.billed_usd_amt,
            fm.billed_post_bcknd_disc_usd_amt

          FROM  bsd_publish.finmart_private.cvc_finmart AS fm 
          LEFT JOIN edm_publish.edm_public.victim_survivor_mapping v
            ON fm.corporate_csn = v.victim_account_csn AND final_merge_status ='COMPLETED'
          LEFT JOIN adp_publish.customer_success_optimized.date_info dt
            ON fm.settlement_start_dt =dt.dt
        
    ```

### 3. Calculate the metric

This query is selecting the necessary fields to calculate ACV by quarter. It can be replaced by other metrics, provided that it is at the same granularity, in this case, `account_csn` and `date`.

??? abstract "Calculating `ACV`"
    #### Step 3

    ``` sql linenums="1"  
    -- This CTE is calculating_acv

    -- This steps needs to use CTE from step 2:
    -------------------------------------------------------------------------------------------------
      -- this CTE is cvc_finmart_vs_mapping:
      WITH cvc_finmart_vs_mapping AS 
        (
          SELECT 
            COALESCE( v.surviving_account_csn, fm.corporate_csn) AS account_csn, --swapping victim accounts with surviving
            fm.fy_and_fq_name,
            fm.settlement_start_dt,
            
            ---ACV
            fm.cc_fbm_total_acv_net1_usd,
            fm.cc_fbm_total_acv_net2_usd,
            fm.cc_fbm_total_acv_net3_usd,
            fm.cc_fbm_total_acv_net4_usd,
            fm.record_type,
            fm.transaction_dt,

            ---MY (additional example)
            fm.cc_fbd_bil_term_sgrp,
            fm.cc_billed_bgt_usd_cur,
          
            ---billings (additional example)
            fm.billed_srp_usd_amt,
            fm.bill_net1_usd_amt,
            fm.bill_net2_usd_amt,
            fm.billed_usd_amt,
            fm.billed_post_bcknd_disc_usd_amt  

          FROM  bsd_publish.finmart_private.cvc_finmart AS fm 
          LEFT JOIN edm_publish.edm_public.victim_survivor_mapping v
            ON fm.corporate_csn = v.victim_account_csn AND final_merge_status ='COMPLETED'
          LEFT JOIN adp_publish.customer_success_optimized.date_info dt
            ON fm.settlement_start_dt =dt.dt
        )
      -------------------------------------------------------------------------------------------------
        -- This CTE is calculating_acv (step 3)
      SELECT
        account_csn,
          CONCAT('FY',SUBSTRING(fy_and_fq_name, 3, 2)) AS fiscal_year,
          CONCAT('FY',SUBSTRING(fy_and_fq_name, 3, 2), RIGHT(fy_and_fq_name,2)) AS fiscal_quarter,
          settlement_start_dt,
          
          SUM(cc_fbm_total_acv_net1_usd) AS acv_net1_usd,
          SUM(cc_fbm_total_acv_net2_usd) AS acv_net2_usd,
          SUM(cc_fbm_total_acv_net3_usd) AS acv_net3_usd,
          SUM(cc_fbm_total_acv_net4_usd) AS acv_net4_usd
      
      FROM   cvc_finmart_vs_mapping -- this is CTE step 2

      WHERE 
          UPPER(record_type) = 'BILLING' 
          AND transaction_dt >= '2019-02-01' 
      GROUP BY 
          account_csn,
          fiscal_year,
          fiscal_quarter,
          settlement_start_dt
      
    ```

### 4. Determine Customer Phase

This final step is finding the customer phase for each transaction, by checking if the `settlement_start_dt` falls between `customer_phase_start_date` and `customer_phase_end_date`. Else, it will assign "Other" in the customer_phase field.

??? abstract "Allocating `customer_phase`"
    #### Step 4

    ``` sql linenums="1"  
    -- this is CTE acv_with_customer_phases
    -- for his we must put together steps 1, 2 and 3

    -- this CTE is account_ced_dimension (step 1) ---------------------------------------------------------
      WITH account_ced_dimension AS 
        (
        SELECT
          h.final_parent_account_csn    AS parent_csn,
          t.account_csn                 AS account_csn,
          c.customer_phase,
          c.customer_phase_start_date,
          CONCAT(SUBSTRING(c.customer_phase_start_date,1,4),'-',SUBSTRING(c.customer_phase_start_date,6,2),'-','01')  AS by_month_customer_phase_start_date,
          c.customer_phase_end_date,
          CONCAT(SUBSTRING(c.customer_phase_end_date,1,4),'-',SUBSTRING(c.customer_phase_end_date,6,2),'-','01')  AS by_month_customer_phase_end_date,

          a.site_geo                        AS account_geo,
          a.site_individual_flag, 
          a.is_visible_in_sfdc,  
          a.site_uuid_csn,
          CONCAT('FY',SUBSTRING(start_fiscal_year_quarter, 3, 2)) AS fiscal_year,
          c.START_FISCAL_YEAR_QUARTER
        FROM adp_publish.account_optimized.account_edp_optimized  a
        LEFT JOIN adp_publish.account_optimized.transactional_csn_mapping_optimized t
            ON a.site_uuid_csn = t.site_uuid_csn
        INNER JOIN (
                SELECT 
                  DISTINCT site_account_csn,
                  final_account_csn, 
                  final_parent_account_csn     
                FROM eio_publish.reference_private.account_total_merged_gtm_hierarchy) h
            ON t.account_csn =  h.site_account_csn 
        LEFT JOIN  eio_publish.customer_shared.customer_phases c
            ON  h.final_parent_account_csn = c.parent_csn 
        ),

    --  this CTE is cvc_finmart_vs_mapping (step 2): ----------------------------------------------------------------
      cvc_finmart_vs_mapping AS 
        (
          SELECT 
            COALESCE( v.surviving_account_csn, fm.corporate_csn) AS account_csn, --swapping victim accounts with surviving
            fm.fy_and_fq_name,
            fm.settlement_start_dt,
           
            ---ACV
            fm.cc_fbm_total_acv_net1_usd,
            fm.cc_fbm_total_acv_net2_usd,
            fm.cc_fbm_total_acv_net3_usd,
            fm.cc_fbm_total_acv_net4_usd,
            fm.record_type,
            fm.transaction_dt,

            ---MY (additional example)
            fm.cc_fbd_bil_term_sgrp,
            fm.cc_billed_bgt_usd_cur,

            ---billings (additional example)
            fm.billed_srp_usd_amt,
            fm.bill_net1_usd_amt,
            fm.bill_net2_usd_amt,
            fm.billed_usd_amt,
            fm.billed_post_bcknd_disc_usd_amt

          FROM  bsd_publish.finmart_private.cvc_finmart AS fm 
          LEFT JOIN edm_publish.edm_public.victim_survivor_mapping v
            ON fm.corporate_csn = v.victim_account_csn AND final_merge_status ='COMPLETED'
          LEFT JOIN adp_publish.customer_success_optimized.date_info dt
            ON fm.settlement_start_dt =dt.dt
        ),
    --  this CTE is calculating_acv (step 3): ----------------------------------------------------------------      
      calculating_acv AS
        (
          SELECT
          account_csn,
          CONCAT('FY',SUBSTRING(fy_and_fq_name, 3, 2)) AS fiscal_year,
          CONCAT('FY',SUBSTRING(fy_and_fq_name, 3, 2), RIGHT(fy_and_fq_name,2)) AS fiscal_quarter,
          settlement_start_dt,
          
          SUM(cc_fbm_total_acv_net1_usd) AS acv_net1_usd,
          SUM(cc_fbm_total_acv_net2_usd) AS acv_net2_usd,
          SUM(cc_fbm_total_acv_net3_usd) AS acv_net3_usd,
          SUM(cc_fbm_total_acv_net4_usd) AS acv_net4_usd
      
      FROM   cvc_finmart_vs_mapping

      WHERE 
          UPPER(record_type) = 'BILLING' 
          AND transaction_dt >= '2019-02-01' 
      GROUP BY 
          account_csn,
          fiscal_year,
          fiscal_quarter,
          settlement_start_dt
        ),
      -- This is step 4: introducing customer phase dimensions -----------------------------------------
      distinct_account_ced_values AS 
      (
        SELECT 
        DISTINCT account_csn, account_geo, site_individual_flag, is_visible_in_sfdc 
        FROM  account_ced_dimension 
      )

        SELECT 
          cvcd.account_csn,
          acdw.account_geo,
          acdw.site_individual_flag,
          acdw.is_visible_in_sfdc,    
          cvcd.fiscal_quarter,
          cvcd.acv_net1_usd,
          cvcd.acv_net2_usd,
          cvcd.acv_net3_usd,
          cvcd.acv_net4_usd,
          
        
        CASE WHEN cvcd.settlement_start_dt BETWEEN acd.customer_phase_start_date AND acd.customer_phase_end_date
            THEN acd.customer_phase
            ELSE 'Other'
        END AS customer_phase

      FROM calculating_acv cvcd
      LEFT JOIN account_ced_dimension acd
        ON cvcd.account_csn= acd.account_csn --for Customer Phase
        AND (cvcd.settlement_start_dt >= acd.customer_phase_start_date AND cvcd.settlement_start_dt  <= acd.customer_phase_end_date )    
      LEFT JOIN distinct_account_ced_values acdw -- to add geo, site_individual_flag and is_visible_in_sfdc
        ON cvcd.account_csn= acdw.account_csn
      
    ```

### Output query for ACV with Customer Phases

| ACCOUNT_CSN | ACCOUNT_GEO | FISCAL_QUARTER | ACV_NET1_USD | ACV_NET2_USD | ACV_NET3_USD | ACV_NET4_USD | CUSTOMER_PHASE | SITE_INDIVIDUAL_FLAG | IS_VISIBLE_IN_SFDC |
| ----------- | ----------- | -------------- | ------------ | ------------ | ------------ | ------------ | -------------- | -------------- | -------------- |
| 5102514937 | AMER	|	FY21Q4 | 20,755.00	| 20,755.00 | 17,122.87	| 13,768.862 |	New Again | False | True |
| 5501010864 | EMEA | FY24Q1 | 500.58 | 500.58 | 500.58 | 500.58 | Net New | False | True |
| 5155957639 | APAC | FY23Q3 | 294.11 | 294.11 | 267.64 | 263.23 | Net New | False | True |

## :material-head-question:{ .grey-icon-heading } Clarifications

### FAQs

??? question "Is there a dashboard where the above logic is applied?"
    #### FAQ 1
    Yes, the [Executive Insights Dashboard](https://app.powerbi.com/groups/0cd3aea6-b4f2-47ea-b466-6e336b8b8216/reports/800d01ff-769a-437f-9631-d7e3db9c4322/ReportSection9212f1eabeb5ed59d63e?experience=power-bi) makes use of the same approach to report on prioritized KPIs. As it contains current quarter Financial data, users must be on the Trading Window List (TWL). Please email [insider.trading.compliance@autodesk.com](mailto:insider.trading.compliance@autodesk.com) for access. 

??? question "How can I calculate other metric for Net-New or New-Again customers?"
    #### FAQ 2
    To make use of the same logic, the metric dataset which will be queried in step 3 must have the same granularity as the other steps. which is by `account_csn` and `date`. This is required in order to place the correct customer phase based on `customer_phase_start_date` and `customer_phase_end_date`.

??? question "Can a customer have more than one customer phase in the same fiscal quarter?"
    #### FAQ 3
    Yes, as the `customer_phase_end_date` can fall in the middle of a fiscal quarter, and another `customer_phase_start_date` can start subsequently, the same account can have more than 1 customer phase in the same quarter.
    


## :material-link:{ .grey-icon-heading } Relevant Links

- [ACV metric definition](../../onboarding/metrics/acv-metric.md)
- [Customer Phases Concept](customer-phases.md/)
- [CAKN Blog: Traversing Account Data](https://wiki.autodesk.com/pages/viewpage.action?spaceKey=EAX&title=CAKN+Blog%3A+Traversing+Account+Data)

