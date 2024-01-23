---
title: Quote and Quote Line Item (R2.1.2)
author: Enterprise Data and Analytics, Global Revenue Operations
tags:
  - NxM
  - data impact
---

<div id="data-impact-assessment-template-info-main">
  <ul>
    <li><strong>Subject Matter Experts:</strong>
      <a target="_blank" href="https://aware.autodesk.com/ameya.dattanand.kambli">Ameya Dattanand Kambli</a>,
      <a target="_blank" href="https://aware.autodesk.com/michael.aubry">Mike Aubrey</a>,
      <a target="_blank" href="https://aware.autodesk.com/trishna.patel">Trishna Patel</a>
    </li>
    <li class="doc-status"><strong>Status:</strong> <span class="doc-ok">Published<span></li>
    <!-- <li><strong class="doc-status">Status:</strong> <span class="doc-wip">In Progress</span>.</li> -->
  </ul>
</div>


## :fontawesome-solid-magnifying-glass-chart: Introduction

This article provides a overview of the changes made to the Quote and Quote Line item table through Apollo's 2.1.2 release and how these changes impact the underlying business. The article is structured to provide the federated analytical community with a summary of the changes made to the table, and discuss possible uses and outline potential business impacts or tactical challenges for analysts introduced by these changes.

## :material-book-search: Background

The Quote dataset is a physical representation of the Sales Document Data Model. It is the source of truth for analytics of pre-sale sales documents and promotions, and works in conjunction with pricing and orders. As part of Apollo R2.1.2, single user subscriptions will be available in addition to FLEX, which was previously offered.

Starting October you will start seeing quotes coming in for countries where agency for SUS is being rolled out, starting with Australia in November, 2023. North America will follow with a target of May. EMEA in August. Then, Japan in the second half of the year. This wiki will cover the changes observed to meet the Apollo and NxM (Next Generation Model) requirements.

R2.1 builds upon what has already been enabled in R2.0.  The foundation of Solution Providers using CPQ and PWS to quote customers has been implemented.  R2.1 will further those capabilities for the Solution Providers and enable Autodesk user to use the new capabilities in their business processes.

### Guiding principals

1. R2.1.2 builds upon what has already been enabled in R2.0, the foundation of Solution Providers using CPQ and PWS to quote customers has been implemented.  
2. R2.1.2 Expands the list of offerings that can be quoted by Solution Provider's via the New Transaction Model.

### High level workflows

| Quote | Purchase | Post |
| ----- | -------- | ---- |
| - Create Quote <br> - Customer Match & Create <br> - Add Offering & Configure <br> - Get Price <br> - Non-Standard Approval <br> - Finalize Quote | - Review & Accept Quote <br> - Add Payment Type <br> - Submit Order | - Process Order <br> - Fulfillmentv <br> - Core Finance Processes <br> - Manage Subscription & Access <br> - Reporting

## :material-format-list-bulleted: Summary of changes

Quote and Quote Line Item are relatively new object, and changes are mostly related to the addition of subscription business

- **New Offerings:** R2.1.2 Expands the list of offerings that can be quoted by Partner/Solution Provider's via the New Transaction Model.​
- **Payment Terms:** No new payment terms added, but a few invalid ones like Cash in Advance, 60 Days From Month End are removed, more details can be found here​
- **Order Context Details:** Additional details are available for Quote or Order created in the context of standard sale, license compliance, or Make it Right.​
- **Subscription Lookback:** Access to subscription details from switch and co-term subscriptions is now available.​
- **Discount Amounts:** Various applicable individual price adjustments (aka DISCOUNT) are available, such as special programs (M2S, MU2SU, I2S), renewal discount, transaction volume discount, service duration discount, and additional negotiated discount amounts.​
- **New Transaction Categories:** Introducing new transaction categories like New, Renewal, Switch, Co-Term (Add), Extension, and True Up, as well as Partial renewal.
- **Promotion:** When quoting a promo that ends >30 days from the quote creation date the quote expiration would be 30 days from the creation of the quote. When quoting a promo that ends <30 days from the quote creation date the quote expiration date should align with the promo end date, so the quote expiration and the promo expiration align. If Autodesk chooses to end a promotion early any quotes should be honored with the promo price, but no new quotes should be created with the promo.​
- **Multi-Year Billed Annually:** Autodesk will invoice customers annually for 3-year contracts, instead of invoicing all three years up-front. There are no options for customers to pay upfront for multi-year contracts. MYAB occurs between ADSK and the customer via self-service options; CPQ and Auto-Renew. eStore customer transaction are included in MYAB. The purchase price will remain identical regardless of billing frequency. MYAB supports existing Agency co-term rules. *More details on Multi Year Annual (MYA)?* [Visit relevant Wiki page](https://wiki.autodesk.com/x/2akJWw).
- **Standard Subscription Terms:** Customers can only purchase standard terms, which are: Monthly(only available on eStore), Annual , Multi-Year (3 Year)
- **Delayed Start Date:** Customers have the option to purchase new subscriptions and Flex with a start date up to 30 days in the future, and if no future date is specified, the start date will be the date the transaction is processed. It's important to note that once the order is processed, the start date cannot be changed. 
- **Switch Product:** Customers can switch products during the renewal window, 90 days prior to the renewal date. Switching at renewal requires a quote. S2S mid-term switch is not supported in the Agency. Switching to unavailable products like EOS or EOR is not permitted. Customers can switch terms through Autodesk Account anytime during the subscription. Solution Providers can switch terms in a renewal quote, effective on the next
- **Auto-Renew:** Currently, there are two billing behaviors: renewable (auto-renew off) and recurring (auto-renew on), and they remain unchanged. However, a new change will be implemented where all renewals placed after the NxM launch will default to "auto-renew on". Customers will need to manually disable it in their ADSK account if they wish. Contracts that were previously renewable will now be converted to recurring. This change aims to streamline the renewal process and provide a more consistent billing experience for customers.
- **Opportunities:** With the launch of NxM, for eligible subscriptions, we will no longer use AIR Renewal and ROMs opportunities but there will be a new renewal Opportunity type called "Subscription Opportunity". You can find more information [here](https://wiki.autodesk.com/pages/viewpage.action?pageId=1865537443). 
Service Contract & Contract Line Item: New service contracts and CLIs will be created for the ODM subscriptions, which could have some impacts on existing analyses looking at contract-level information. You can find more information here. 
- **Finmart:** CVC_FINMART will have no columns or objects being depreciated. There are some additional columns that are mostly implemented to handle a new discounting process. With new purchasing flows through the agency model, discounts and commission calculations will be tweaked slightly. This largely impacts the pricing waterfall (Net0-Net4 + the addition of a new Net5). You can find more information [here](https://wiki.autodesk.com/pages/viewpage.action?pageId=1878601085). 
- **Finmart:** CVC_FINMART will have no columns or objects being depreciated. There are some additional columns that are mostly implemented to handle a new discounting process. With new purchasing flows through the agency model, discounts and commission calculations will be tweaked slightly. This largely impacts the pricing waterfall (Net0-Net4 + the addition of a new Net5). You can find more information [here](https://wiki.autodesk.com/display/EAX/CVC_FINMART+%28R2.1.2%29+Impact+Assessment).
- **Quotes:** Quotes can include multiple configured offers, such as different products and term lengths, as well as different business models (Flex & Single User Subscription). Orders must precisely reflect the details on the quote.  If a customer wants to place an order that does not reflect the quote, a new quote is required. Quotes are valid for 30 days by default. Upon review, purchasers receive an email notification with the quote number, expiration date, and total price, including taxes and discounts. To proceed with the purchase, purchasers simply click "buy". Quote is generated (triggered) for following scenarios: 

    | Index | Quote event | Description |
    | ----- | ----------- | ----------- |
    | 1 | NEW | Order new product / subscription, user can specify start date, otherwise transaction date becomes the start date |
    | 2 | COTERM | Create new subscription to align to another subscription with existing end date |
    | 3 | EXTENSION | 	Extend existing subscription end date to a selected end date |
    | 4 | RENEWAL | Renew existing subscription. |
    | 5 | SWITCH (AT RENEWAL) | Create new subscription for new offering (Switch from product A → B) and/or new term (e.g. Annual → 3-year) during renewal window, while maintaining existing renewal month and day. |
    | 6 | TRUE-UP | Add additional Premium (for now) to align with total seats for a team. |

- Purchase of a product via a quote can either happen through Autodesk Sales or a Solution Provider. 
    - This table shows the type of customer transitioning to NxM:

    | New Transaction Model | Stays in Buy/Sell |
    | --------------------- | ----------------- |
    | - Active Single User Subscriptions <br> - Renewals with Special Pricing (M2S, MU2SU, I2S) <br> - Premium <br> - Flex <br> - End of Sale (EOS) <br> - NFR | - Government <br> - Excluded products (PlanGrid, Moldflow, etc.) <br> - Initial transition of Multi-User to trade in (MU2SU) & InfoCare to Subscription (I2S). These will remain in buy/sell and be processed as it is today <br> - Multi-user subscriptions, [Single-user Extended Offline](https://wiki.autodesk.com/display/WSPP/Single-user+Extended+Offline) <br> - End of Life Offerings |

## :material-table-edit: Data structure updates

This section outlines additions and omissions to the following tables:

- Quote
- Quote Line Item

| Object | Table version | Snowflake instance | Souce table | # of columns | Date inspected |
| ------ | ------------- | ------------------ | ----------- | ------------ | -------------- |
| Quote | Production | Snowflake PRoduction | bsd_publish.sfdc_shared_latest.sbqq__quote__c | 94 | 9/25/23 |
| Quote | R2.1.2 | TBA | TBA | TBA | TBA |
| Quote Line Item | Production | Snowflake Production | bsd_publish.sfdc_shared_latest.sbqq__quoteline__c | 83 | 9/25/23 |
| Quote Line Item | R2.1.2 | TBA | TBA | TBA ||

### Fields added

#### Quote fields added

??? info "Quote fields added"

    Ref: [Quote Fields#-1067692426](https://wiki.autodesk.com/display/DBP/Quote+Fields#QuoteFields--1067692426)

    | Index | Column name | Field type | Values (LOV) | Description | Notes |
    | ----- | ----------- | ---------- | ------------ | ----------- | ----- |
    | 1 | BillPlanUpdateStatus__c | Picklist | Values, Failed | Bill Plan Update Status ||
    | 2 | SBQQ__PaymentTerms__c | Picklist | C008,C010,C032,C037,C041,C050,C053 | Payment Terms agreed with customer. <br> [wiki](https://nam11.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwiki.autodesk.com%2Fpages%2Fviewpage.action%3FpageId%3D1737202241%23Opportunity%26QuoteWave2-PaymentTerms&data=05%7C01%7Cameya.dattanand.kambli%40autodesk.com%7C90445c5547334e19421d08dbd4e6a6c2%7C67bff79e7f914433a8e5c9252d2ddc1d%7C0%7C0%7C638337859321778976%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=Syls7E2n%2Bz3%2FLA4R3IjmIz%2B9IwALOvgWPFhuy7nGG9M%3D&reserved=0) | [DBP: Payment Terms Update](https://wiki.autodesk.com/pages/createpage.action?spaceKey=EAX&title=R2.1.2&linkCreation=true&fromPageId=1916601864) |
    | 3 | Primary_Admin_Email__c | Email |  | Primary Admin Email ||
    | 4 | TotalExtendedSRP__c | Roll up summary | SUM of ExtendedSRP__c field in QuoteLine object | SRP is generated by applying Market Factor (MF), Currency Factor (CF), and Rounding Rules ? |

#### Quote Line Item fields added

??? info "Quote Line Item fields added"

    Ref: [Quote Fields#-1463250846](https://wiki.autodesk.com/display/DBP/Quote+Fields#QuoteFields--1463250846)

    | Index | Column name | Field type | Values (LOV) | Description | Notes |
    | ----- | ----------- | ---------- | ------------ | ----------- | ----- |
    | 1 | BillPlans__c | Long Text Area |  | MYAB Annual bill plans. Shows yearly breakdown of payment for 3-year subscription.  |  |
    | 2 | DiscountsApplied__c | Currency |  | Discounts Applied	 |  |
    | 3 | EndDateUTC__c | DateTime |  | Line item (Subscription) End Date in UTC. |  |
    | 4 | Exclusive_Discount_QLE__c | Formula(Currency) |  | End customer  negotiated discount AKA DDA Discount. |  |
    | 5 | ExclusiveDiscountsApplied__c | Currency |  | Exclusive Discounts Applied |  |
    | 6 | ExtendedSRP__c | Currency |  | It is about Quantity times SRP. If it is a prorated purchase, it represents partial term total. |  |
    | 7 | OrderContext__c | Picklist | LC | This represent if Quote or Order is created in the context of standard sale or license compliance or Make it Right. |  |
    | 8 | PlanPriceWaterfall__c | Long Text Area |  | MYAB bill plan water fall for 1 year.  |  |
    | 9 | PromotionCode__c | Text(20) |  | Promo Code |  |
    | 10 | PromotionEndDate__c | Date |  | Promotion End Date |  |
    | 11 | PromotionDescription__c | Text(100) |  | Promotions Applied |  |
    | 12 | ReferenceSubscription__c | Lookup(ContractLineItem) |  | Subscription id used for switch and co-term subscriptions to get end date so that new subs can align with same end date. |  |
    | 13 | RenewalDiscountAmount__c | Currency |  | Discount  Offered due to RENEWAL .This is part of price waterfall. [wiki](https://nam11.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwiki.autodesk.com%2Fdisplay%2FBMP%2FR2.1.x%2BPricing%2BRelated%2BCapabilities%23tab-Pricing%2BFrameworks&data=05%7C01%7Cameya.dattanand.kambli%40autodesk.com%7C90445c5547334e19421d08dbd4e6a6c2%7C67bff79e7f914433a8e5c9252d2ddc1d%7C0%7C0%7C638337859321778976%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=%2FvIvnDZ2TUilygswxpQUmXjE0m4lIjZG0iF3%2BPYYET4%3D&reserved=0) |  |
    | 14 | SpecialProgramDiscountAmount__c | Currency |  | Discount offered part of special programs like M2S, MU2SU, I2S. This is part of price waterfall. [wiki](https://nam11.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwiki.autodesk.com%2Fdisplay%2FBMP%2FR2.1.x%2BPricing%2BRelated%2BCapabilities%23tab-Pricing%2BFrameworks&data=05%7C01%7Cameya.dattanand.kambli%40autodesk.com%7C90445c5547334e19421d08dbd4e6a6c2%7C67bff79e7f914433a8e5c9252d2ddc1d%7C0%7C0%7C638337859321778976%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=%2FvIvnDZ2TUilygswxpQUmXjE0m4lIjZG0iF3%2BPYYET4%3D&reserved=0) |  |
    | 15 | Subscription__c | Lookup(ContractLineItem) |  | Subscription that is being transacted part of quote line. Applicable for transactions like Renewal, Extension etc. |  |
    | 16 | SWITCH_PRICE_CONDITION__C | Picklist | M2S, SU1, None, SU2, SU4, SU9, SU3, MY4 | Switch price condition mapping will be used in O2P when special program discount is applied during the contextual price  |  |

### List of Values (LOV's) added

??? info "List of Values added"

    In the following table, we can see how the field values are likely to change as a result of NxM. The backend values are stored in the database, and the front end values are displayed on the user interface.

    | Index | Column name | Existing LOV | Apollo 2.1.2 LOV - Backend | Apollo 2.1.2 LOV - Front End | Notes |
    | ----- | ----------- | ------------ | -------------------------- | ---------------------------- | ----- |
    | 1 | Term__c | A01 | A01 <br> *A06* <br> *A07* <br> *A02* | Annual <br> *3 year* <br> *Daily* <br> *Monthly* |  |
    | 2 | Access_Model__c | F | F <br> *X* <br> *A* <br> *S* <br> *N* | F <br> *None* <br> *Multi User Session Specific* <br> *Single User (SU)* <br> *Multi User (MU)* |  |
    | 3 | Billing_Behavior__c | A300 | A300 <br> *A100* <br> *A200* | Once <br> *Renewable* <br> *Recurring* |  |
    | 4 | SBQQ__BillingFrequency__c | B01 | B01 <br> *B02* <br> *B03* <br> *B04* <br> *B05* <br> *B06* | One-Time <br> *Daily* <br> *Monthly* <br> *Quarterly* <br> *Annual* <br> *3 Years* |  |
    | 5 | SBQQ__BillingType__c | B100 | B100 <br> *B200* | Up front <br> *Arrears* |  |
    | 6 | Connectivity__c | C100 | C100 <br> *C200* | Online <br> *Offline* |  |
    | 7 | SBQQ__ChargeType__c | One-Time | One-Time <br> *Recurring* <br> *Usage* | One-Time <br> *Recurring* <br> *Usage* |  |
    | 8 | Connectivity_Interval__c | C03Connectivity__c | C03 <br> *C04* <br> *C05* <br> *C01* <br> *C02* | 1 Day <br> *30 days* <br> *1095 days* <br> *0 day* <br> *365 days* |  |
    | 9 | Intended_Usage__c | COM | COM <br> *GOV* <br> *HOB* <br> *NFR* <br> *ADN* | Commercial <br> *Government* <br> *Hobbyist* <br> *Not for Resale* <br> *Autodesk Developers Network* |  |
    | 10 | Service_Plan__c | Standard | STND <br> *PREMSUB* <br> *ENT* <br> *STNDNS* <br> *PREMNS* <br> *BSC* | Standard <br> *Premium* <br> *Enterprise* <br> *Standard no Support* <br> *Premium no Support* <br> *Basic* |  |

## :material-text-short: Conclusion

As of November 13th, Australian customers have several avenues available to purchase our products.

1. **New Transaction Model:** All products will be quoted in SFDC via the CPQ tool or GUAC Moe. As part of Apollo R2.1.2, single user subscriptions will be available in addition to FLEX, which was previously offered.
2. **Preferred Solution Provider:** Customers can choose to work with their preferred Solution Provider. They can request a quote generated from the Solution Provider via CPQ or directly via Partner Web services if they have enabled APIs to connect their order processing systems with ours. Solution Providers will now create quotes in our systems.
3. **Self-Serve via eStore:** Customers can access the eStore through our website or the Autodesk account. The eStore now supports Line of Credit. However, customers cannot self-service a quote from the eStore. They will need to contact a Solution Provider or Adsk representative for a quote for the procurement process.
4. **Direct Sales Rep:** Customers can continue to work directly with their Sales representative. They can get a quote generated in SFDC from CPQ or a cart link generated via GUAC Moe.
5. Introducing SUS has added an additional scope of Subscription Management, including extension, proration, switch, and auto-renewal.

These avenues provide different options for Australian customers to purchase our products based on their preferences and requirements.

## :material-link: References

### Cited in Article

- [Apollo | R2.1.2 Quote to Order (Q2O)#Features+and+Capabilities](https://wiki.autodesk.com/pages/viewpage.action?pageId=1566701908#Apollo|R2.1.2QuotetoOrder(Q2O)-Features+and+Capabilities)
- [Apollo BMP R2.1 | General Q&A + FAQ](https://wiki.autodesk.com/pages/viewpage.action?pageId=1453692073)
- [NxM Eligible Countries and Rollout Timing](https://wiki.autodesk.com/display/BMP/NxM+Eligible+Countries+and+Rollout+Timing)

### Others

- [Opportunity Management#1CreateanOpportunity](https://wiki.autodesk.com/display/WSPP/Opportunity+Management#OpportunityManagement-1CreateanOpportunity)
- [Sales Opportunity - Migration during R2.1.2 Launch](https://wiki.autodesk.com/display/DPED/Sales+Opportunity+-+Migration+during+R2.1.2+Launch)
- [EDH Opportunity Dataset Details#DataModel](https://wiki.autodesk.com/display/ESAE/EDH+Opportunity+Dataset+Details#EDHOpportunityDatasetDetails-DataModel)
- [Apollo R2.1.2 Impact Assessment (CED) - Enterprise Data Management (EDM) - Autodesk Confluence Wiki](https://wiki.autodesk.com/pages/viewpage.action?pageId=1737210596)

