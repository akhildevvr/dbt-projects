---
title: Insights Driven Engagement (IDE) Base Dataset
author: Enterprise Data and Analytics, Global Revenue Operations
search:
  exclude: true
---

# WIP

### Data Sources

#### Source Systems

#####  Snowflake

| Schema/Database  | View/Table | Basic Filters |
| :----------------| :----------| :---------------- |
| adp_publish.common_reference_data_optimized | data_time_hierarchy | calendar_dates  > '2022-01-31' |   
| adp_publish.account_optimized | account_edp_optimized | |
| adp_publish.account_optimized | transactional_csn_mapping_optimized | |
| edm_publish.edm_public | victim_survivor_mapping | final_merge_status = 'COMPLETED' (only in the final output table) |
| bsd_publish.sfdc_shared | opportunity | 1) recordtypeid = '0123A000001dymhQAA' (AIR opportunity); 2) closedate > '2022-01-31' |
| bsd_publish.sfdc_shared | opportunitylineitem | | 
| adp_workspaces.customer_success_finance_private | subs_billed_seats_finmart | | 
| eio_publish.customer_shared | ews_opportunity_enriched | | 
| eio_publish.engagement_shared | rnk_metrics_join_product_level | | 

#### Data Model

![IDE data model overview](../images/ide_base/ide-base-data-model.jpg)
