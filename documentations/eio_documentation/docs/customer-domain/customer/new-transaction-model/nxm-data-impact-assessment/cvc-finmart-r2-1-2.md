---
title: Cvc_Finmart (R2.1.2)
author: Enterprise Data and Analytics, Global Revenue Operations
tags:
  - NxM
  - data impact
---

<div id="data-impact-assessment-template-info-main">
  <ul>
    <li><strong>Subject Matter Expert:</strong>
      <a target="_blank" href="https://aware.autodesk.com/devin.drewry">Devin Drewry</a>
    </li>
    <li class="doc-status"><strong>Status:</strong> <span class="doc-ok">Published<span></li>
    <!-- <li><strong class="doc-status">Status:</strong> <span class="doc-wip">In Progress</span>.</li> -->
  </ul>
</div>

## :fontawesome-solid-magnifying-glass-chart: Introduction

This article provides a overview of the changes made to the CVC_FINMART table through Apollo's 2.1.2 release and how these changes impact the underlying business. The article is structured to provide the federated analytical community with a summary of the changes made to the table, and discuss possible uses and outline potential business impacts or tactical challenges for analysts introduced by these changes.

## :material-book-search: Background

Autodesk uses SAP S4 as the order processing and invoicing platform. Finmart is the financial reporting platform. The main source of information for Finmart is SAP S4/RAR & Pelican. As part of R2.1.2, Finmart will be enhanced with some additional metrics and price waterfall KPIs to account for the New Transaction Model (NxM) changes.

At a high level, the new metrics include fields to store discounts and commissions. Commission information is sourced from Forma SPM. Finmart will also now have additional columns storing information about the purchased subscription.

## :material-format-list-bulleted: Summary of changes

CVC_FINMART will have no columns or objects being depreciated. There are some additional columns (listed below) that are mostly implemented to handle a new discounting process. With new purchasing flows through the agency model, discounts and commission calculations will be tweaked slightly. This largely impacts the pricing waterfall (Net0-Net4 + the addition of a new Net5). There will also be some dimensions with a change in values to account for the new ODM setup + updates to purchasing flows. Most usage will not change, though new analyses will need to account for the new Net5 reporting level

[FM2.0 - R2.1.2 New/Impacted Objects (AUS Nov release)](https://wiki.autodesk.com/pages/viewpage.action?pageId=1721074430)

## :material-table-edit: Data structure updates

### Data dictionary for new fields

This section provides a data dictionary for the new R2.1.2 columns, as well as some fields with updates to logic.

??? info "Data dictionary for new CVC_FINMART fields"

    This section provides a data dictionary for the new R2.1.2 columns, as well as some fields with updates to logic.

    | Column | Finmart column name | Data type | Field definition | New/Existing | Source | Notes |
    | ------ | ------------------- | --------- | ---------------- | ------------ | ------ | ----- |
    | Special Program Discount ($) | BILLED_SPECIAL_PROGRAM_DISC_USD_AMT | Numeric | Discount based on special program that offered price locks to customers. (e.g., maintenance to subscription trade-ins) | New | SAP S4 ||
    | Special Program Discount (DC) | BILLED_SPECIAL_PROGRAM_DISC_DC_AMT | Numeric | Discount based on special program that offered price locks to customers. (e.g., maintenance to subscription trade-ins) | New | SAP S4 ||
    | Special Program Discount (LC) | BILLED_SPECIAL_PROGRAM_DISC_LC_AMT | Numeric | Discount based on special program that offered price locks to customers. (e.g., maintenance to subscription trade-ins) | New | SAP S4 ||
    | Special Program Discount (CC) | CC_BILLED_SPECIAL_PROGRAM_DISC_BGT_USD_CUR | Numeric | Discount based on special program that offered price locks to customers. (e.g., maintenance to subscription trade-ins)	| New | SAP S4 ||
    | Renewal Discount ($) | BILLED_RENEWAL_DISC_USD_AMT | Numeric | Discount based on renewal of a subscription | New | SAP S4 ||
    | Renewal Discount (LC) | BILLED_RENEWAL_DISC_LC_AMT | Numeric | Discount based on renewal of a subscription | New | SAP S4	||
    | Renewal Discount (DC) | BILLED_RENEWAL_DISC_DC_AMT | Numeric | Discount based on renewal of a subscription | New | SAP S4	||
    | Renewal Discount (CC) | CC_BILLED_RENEWAL_DISC_BGT_USD_CUR | Numeric | Discount based on renewal of a subscription | New | SAP S4	||
    | Service Duration Discount ($) | BILLED_SERVICE_DURATION_DISC_USD_AMT | Numeric | Discount based on the term length of the subscription (e.g., 10% discount on 3-year contracts) | New | SAP S4	||
    | Service Duration Discount (LC) | BILLED_SERVICE_DURATION_DISC_LC_AMT | Numeric | Discount based on the term length of the subscription (e.g., 10% discount on 3-year contracts) | New | SAP S4	||
    | Service Duration Discount (DC) | BILLED_SERVICE_DURATION_DISC_DC_AMT | Numeric | Discount based on the term length of the subscription (e.g., 10% discount on 3-year contracts) | New | SAP S4	||
    | Service Duration Discount (CC) | CC_BILLED_SERVICE_DURATION_DISC_BGT_USD_CUR | Numeric | Discount based on the term length of the subscription (e.g., 10% discount on 3-year contracts) | New | SAP S4 ||
    | Service Duration Discount (CC- Future) | CC_BILLED_SERVICE_DURATION_DISC_BGT_USD_FUT || Numeric | Discount based on the term length of the subscription (e.g., 10% discount on 3-year contracts) | New | SAP S4	||
    | Backlog Agency Commission (DC) | BACKLOG_OPEX_DC_AMT | Numeric | Future expected agent commission payments for multi-year annual billing contracts | New | Forma ||
    | Backlog Agency Commission (LC) | BACKLOG_OPEX_LC_AMT | Numeric | Future expected agent commission payments for multi-year annual billing contracts | New | Forma ||
    | Backlog Agency Commission ($) | BACKLOG_OPEX_USD_AMT | Numeric | Future expected agent commission payments for multi-BILLED_SRP_PROMO_ADJ_PERyear annual billing contracts| New | Forma ||
    | Backlog Agency Commission (CC) | CC_BACKLOG_OPEX_BGT_USD_CUR| Numeric | Future expected agent commission payments for multi-year annual billing contracts | New | Forma ||
    | Backlog Agency Commission (CC - Future) | CC_BACKLOG_OPEX_BGT_USD_FUT | Numeric | Future expected agent commission payments for multi-year annual billing contracts | New | Forma ||
    | Unbilled Deferred Agency Commission (DC) | UNBILLED_OPEX_DC_AMT | Numeric | Future expected agent commission expenses for unbilled (MYAB contracts) in the form of a waterfall schedule | New | Derived in Finmart ||
    | Unbilled Deferred Agency Commission (LC) | UNBILLED_OPEX_LC_AMT | Numeric | Future expected agent commission expenses for unbilled (MYAB contracts) in the form of a waterfall schedule | New | Derived in Finmart ||
    | Unbilled Deferred Agency Commission ($) | UNBILLED_OPEX_USD_AMT | Future expected agent commission expenses for unbilled (MYAB contracts) in the form of a waterfall schedule | Numeric |  | New | Derived in Finmart ||
    | Unbilled Deferred Agency Commission (CC) | CC_UNBILLED_OPEX_BGT_USD_CUR | Numeric | Future expected agent commission expenses for unbilled (MYAB contracts) in the form of a waterfall schedule | New | Derived in Finmart ||
    | Unbilled Deferred Agency Commission (CC - Future) | CC_UNBILLED_OPEX_BGT_USD_FUT | Numeric | Future expected agent commission expenses for unbilled (MYAB contracts) in the form of a waterfall schedule | New | Derived in Finmart ||
    | MOAB Indicator | MOAB_IND | Text | Identifies an order as Multi Year Order with Annual Billings (MYAB). LOV is "MB - Multiple Billings". | Existing | SAP S4 ||
    | Pelican Item Number | PELICAN_ORDER_LINE_NBR | Numeric | Order Line number used as Pelican's order line identifier (distinct from SAP's order line number) | New | SAP S4 ||
    | Subscription Status | SUBSCRIPTION_STATUS | Text | Subscription status at a point in time to show if a subscription is active, expired, suspended, terminated or re-active |  | Pelican ||
    | Payment Status | PAYMENT_STATUS | Text | For visibility into outstanding payments, especially for new line of credit payments. |  | SAP S4/Pelican ||
    | PQ QE Subscription Status | SUBSCRIPTION_STATUS_PQ | Text | Subscription status as of the last QE to show if a subscription is active, expired, suspended, terminated or re-active (as of midnight PST) |  | Derived using Pelican ||
    | PQ QE Payment Status | PAYMENT_STATUS_PQ | Text | Payment status as of the last QE (as of midnight PST) |  | Derived using SAP | Paid, Unpaid |
    | Subscription Reactivation Date | SUBSCRIPTION_REACTIVATION_DATE | Date | Shows when a subscription moved from suspended to active based on payment receipt.  (If never in suspend, date will show 1900) |  | Pelican ||
    | Subscription Reactivation Date Fy And Fq Name | SUBSCRIPTION_REACTIVATION_DATE_FY_AND_FQ_NAME | Date | Shows when a subscription moved from suspended to active based on payment receipt.  (If never in suspend, date will show 1900) |  | Pelican ||
    | Subscription Reactivation Date Fy And Month Name | SUBSCRIPTION_REACTIVATION_DATE_FY_AND_MONTH_NAME | Date | Shows when a subscription moved from suspended to active based on payment receipt.  (If never in suspend, date will show 1900) |  | Pelican ||
    | Subscription Reactivation Date Fy Name | SUBSCRIPTION_REACTIVATION_DATE_FY_NAME | Date | Shows when a subscription moved from suspended to active based on payment receipt.  (If never in suspend, date will show 1900) |  | Pelican ||
    | Auto Renewal Status | AUTO_RENEWAL_STATUS | Text | Whether this subscription will auto-renew at end of current term. Customer can toggle during term as often as they like. This status is based on the customer's lastest toggle. |  | Pelican ||
    | Reference Subscription Id | REFERENCE_SUBSCRIPTION_ID | Text | In the event of a co-term/switch, the original Subscription ID prior to the co-term/switch event |  | Pelican | 	Used for both co-term and switch |
    | From | TERM_FROM | Text | If the customer switched term at renewal, this value represents the original term of the expired subscription |  | Pelican ||
    | From | PRODUCT_FROM | Text | If the customer switched product at renewal, this value represents the original product of the expired subscription |  | Pelican ||
    | Subscription Updated Dt | SUBSCRIPTION_UPDATED_DT | Date | Date the subscription had updates made |  | Derived in Finmart ||

??? info "Existing impacted objects from CVC_FINMART"

    | Name | Haas Technical Name  | Definition | Comments |
    | ---- | -------------------- | ---------- | -------- |
    | Grace Period Indicator | GRACE_PERIOD_IND | Grace Period Indicator will be Y, if the order is placed during grace period and will be N, if it is placed during renewal period. | Additional Logic change based on the new Shut Off Policy |
    | NET1 SRP Billed - Promo/Bundle Adj Billed($) <br> NET1 SRP Billed - Promo/Bundle Adj Billed(DC) <br> NET1 SRP Billed - Promo/Bundle Adj Billed(LC) <br> NET1 SRP Billed - Promo/Bundle Adj Billed(CC) <br> NET1 SRP Billed - Promo/Bundle Adj Billed(CC - Future) <br> NET1 SRP Billed - Promo/Bundle Adj Billed(CC EUR) <br> NET1 SRP Billed - Promo/Bundle Adj Billed(CC EUR - Future) | BILL_NET1_USD_AMT <br> BILL_NET1_LC_AMT <br> BILL_NET1_DC_AMT <br> CC_NET1_BILLED_BGT_USD_CUR <br> CC_NET1_BILLED_BGT_USD_FUT <br> CC_NET1_BILLED_BGT_EUR_CUR <br> CC_NET1_BILLED_BGT_EUR_FUT | Net 1 Billed Amount on the Order (USD, LC, DC, CC Current/Future USD, CC Current/Future Euro) | Inclusion of new Discounts as mentioned above in the summation( total) |
    | Agency Indicator | AGENCY_IND | Indicator for what kind of agency was on the transaction <br> LOV: Agency, Agency Self-Serve, Commissionaire, N/A | Addition of new logic as part of R2.1.2. The logic will be captured here(Wiki in Progress. Will be updated once we get the logic from Business) |
    | Order Action <br> Order Action Code <br> Order Action Description | ORDER_ACTION <br> ORDER_ACTION_CD <br> ORDER_ACTION_DESC | The type of order within SAP (New, Renewal, Switch, Add Extension, Etc.) | New LOV to be added. The details about the LOV is captured [here](https://wiki.autodesk.com/display/DBP/System+Values+%7C+Line+Item+Actions) |
    | Order Action Indicator | ORDER_ACTION_INDICATOR | This field is a flag associated with the Order Action that gives details about the action for a given order. | Additional logic to be added as part of new LOV introduced in Order Action. <br> Not in ADP's CVC_FINMART |
    | PO Type | PO_TYPE | The “Purchase Order Type” field is used to provide segment reporting on EDI, Web OE, and ABC order entry.  SAP source is VBKD-BSARK | Probability of new PO Type LOV to be added. The details are documented [here](https://wiki.autodesk.com/pages/viewpage.action?spaceKey=DBP&title=Core+Finance+Architecture+for+Single+User+%28SU%29+Agency) |
    | Order Reason <br> Order Reason Code <br> Order Reason Desc | SALES_ORDER_REASON <br> SALES_ORDER_REASON_CD <br> SALES_ORDER_REASON_DESC | SAP's order reason - only sometimes used, examples include "Z81 - Token Flex", 
    "135 - SP – Sales/Finance Approval" | There is open item on how the Order Reason code is going to be translated in R2.1.2 world. |
    | Agency Commission Paid <br> **(this is rename only)** <br> Partner Commission - OpEx (Current Name) <br> ($, LC,DC, CC, CC future) <br> **(existing fields)** |  |  | No impact on the Database object. |
    | Promo Type <br> Promo Type Code <br> Promo Type Description  | PROMO_TYPE <br> PROMO_TYPE_CD <br> PROMO_TYPE_DESC | Source: SAP tables KONA-BOTEXT, CAWNT-ATWTB, SAP custom database tables ZCA_VARTABLE_008 (license) & ZCA_VARTABLE_010 (service) <br> Custom logic “Promo type” to look at 4 different values and pick one of them based on the below order: <br> 1. Sales Deal # <br> 2. Promo Type <br> 3. Service Promo Type <br> 4. Bundle Promo Type [New] |  |
    | Promo Start Date | PROMO_START_DT | The start date for a promotion |  |
    | Promo End Date | PROMO_END_DT | The end date for a promotion |  |
    | Promo Sub Type BIC | PROMO_SUBTYPE | Values include - Discount Amount or Discount Percentage. |  |
    | Promo Group | PROMO_GROUP_NM | Derived object that categorizes promotions into BIC, SALES DEAL, or SVC PROMO (ADN).  This object is new field that replaces all the Promo Group Finmart 1.0 objects | Current LOV: <br> Sales Deal <br> BIC <br> New LOV: <br> Sales Deal <br> BIC <br> O2P. |
    | End User Trade Account Type | CORPORATE_ACCOUNT_TYPE_NM | Type of the End User of goods / services.  Original data source is Siebel. |  |
    | Promo Category | PROMO_CATEGORY | Currently blank or *. <br> **New LOV:** <br> Promotion <br> Program <br> Pilot <br> Note: New LOV applicable only for O2P Promotions(R2.1.2) orders. | Currently blank or *. <br> **New LOV:** <br> Promotion <br> Program <br> Pilot <br> Note: New LOV applicable only for O2P Promotions(R2.1.2) orders. |

Some descriptions taken from these pages:

- [FM2.0 - R2.1.2 New/Impacted Objects (AUS Nov release)](https://wiki.autodesk.com/pages/viewpage.action?pageId=1721074430)
- [FM 2.0 - R2.1.2 FINBI Objects](https://wiki.autodesk.com/display/DBP/FM+2.0+-+R2.1.2+FINBI+Objects)
- [Fimart 2.0 PowerBI Data Dictionary](https://app.powerbi.com/groups/me/reports/d082a066-394f-45da-b04c-eb95d6a4577c/ReportSection19fd7dc8a3df9c36ed71?experience=power-bi)

### Fields removed

No fields were removed from cvc_finmart for R2.1.2.

### Fields with logic changes

| Index | Column name | Data type | Values | Description | Notes | Logic change |
| ----- | ----------- | --------- | ------ | ----------- | ----- | ------------ |
| 1 | CC_FBM_SF_SUBS_SEATS_BILLED | NUMBER |  |  |  | Not defined on the page yet (likely no impact to end users) |
| 2 | CC_FBM_STD_SEATS | NUMBER |  |  |  | Not defined on the page yet (likely no impact to end users) |
| 3 | CC_FBM_SWITCH_SEATS | NUMBER |  |  |  | Not defined on the page yet (likely no impact to end users) |
| 4 | CC_FBD_BSM_ORDER_ACTION | TEXT |  |  |  | Not defined on the page yet (likely no impact to end users) |
| 5 | CC_FBD_BSM_ESTORE_ORDER_ORIGIN | TEXT |  |  |  | Not defined on the page yet (likely no impact to end users) |
| 6 | CC_FBD_BSM_ESTORE_STORE | TEXT |  |  |  | Not defined on the page yet (likely no impact to end users) |
| 6 | CC_FBD_BSM_SALES_CH | TEXT |  |  |  | Not defined on the page yet (likely no impact to end users) |
| 8 | CC_FBD_SF_ESTORE_SALES_PF | TEXT |  |  |  | Not defined on the page yet (likely no impact to end users) |
| 9 | AGENCY_IND | TEXT |  |  |  | Not defined on the page yet (likely no impact to end users) |

## :material-head-question: Open Questions

??? question "Questions as of 10/18/2023"

    ### 1. How will the different CSN columns be used? Will they all be populated? Account or Contact CSNs?

    - corporate_csn
    - corporate_parent_account_csn
    - agency_account_csn
    - bill_to_csn
    - dealer_csn
    - end_user_csn
    - payer_csn
    - ship_to_csn
    - sold_to_csn
    - survivor_csn

    Derived from Flex orders in production:

    ### 2. How will the different CSN columns be used? Will they all be populated? Account or Contact CSNs?

    - corporate_csn - End user CSN (same as before)
    - corporate_parent_account_csn - Parent CSN (same as before)
    - agency_account_csn - Agent's account CSN (matches quote)
    - bill_to_csn - End User CSN
    - dealer_csn - "UNKNOWN" - previously reseller's CSN, but not used in new orders
    - end_user_csn - always blank
    - payer_csn - Not in CVC_FINMART
    - ship_to_csn - End User CSN
    - sold_to_csn - End User CSN (Previously distributor where applicable)
    - survivor_csn - End user CSN after victim/survivor mapping

## :material-file-code: Sample queries

This section has sample queries for analysis on Finmart post-2.1.2. changes.

### Billings and ACV by Offering Purchased on NXM

??? abstract "Billings by offering"

    ``` sql linenums="1"
      select
          offering_desc
          , sum(CC_BILLED_BGT_USD_CUR) as net3_billed_cc
          , sum(cc_fbm_recur_acv_net3_cc) as  net3_recurring_acv
      from bsd_publish.finmart_private.cvc_finmart
      where quote_nbr != '*'
      and corporate_country_cd = 'AU'
      group by 1
      order by 3 desc;
    ```

1. Query transaction volume for new data model orders
2. Sums of new Opex fields and potential discount fields


## :material-text: Impact Assessment

EIO Projects referencing these tables:

- IDE
    - Should have no changes
- BMT Pipeline
    - Renewal rate and AOV calculations should be staying the same with 2.1.2, so impact should be basically none from a logic perspective
    - Some consideration for pulling in new agency fields potentially (or needing to add net5 once that gets implemented)
- GTM hierarchy merge schema (in reference)

## :material-text-short: Conclusion

The changes to the CVC_FINMART table are centered around adding new columns for the agency discount values and some additional LOVs to existing SAP fields. Overall impact to table users will be very low (the same measure fields will exist and apply for billings/seats/tokens). Users who are assessing impact or incorporating new agency fields will need to check which of the additional columns or column LOV changes apply to their use cases.

