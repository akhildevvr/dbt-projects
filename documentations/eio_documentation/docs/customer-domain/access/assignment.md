---
title: Assignment
author: Enterprise Data and Analytics, Global Revenue Operations
tags:
  - dataset
---

<div id="dataset-template-info-main">
  <ul>
    <li><strong>Product Owner:</strong> <span id="dataset-po">
      <a href="https://aware.autodesk.com/ola.sadowska">Ola Sadowska</a>
    </span></li>    
    <li><strong>Analyst SME:</strong> <span id="dataset-analyst-sme">
      <a target="_blank" href="https://aware.autodesk.com/jayme.kielo">Jayme Kielo</a>,
    </span></li>
    <li class="doc-status"><strong>Status:</strong> <span class="doc-ok">Published</span></li> 
   <!-- <li><strong class="doc-status">Status:</strong> <span class="doc-wip">In Progress</span></li>  -->
  </ul>
</div>

## :material-table-multiple:{ .red-icon-heading } Introduction

The Assignment dataset provides the basic information in one table about how the business is performing in terms of onboarding our customers to start using their subscription. 

!!! note
    - To learn about the metric related to this dataset, visit the [Assignment Rate](https://eda-data-docs.autodesk.com/metrics/assignment-rate/). 


## :fontawesome-solid-suitcase:{ .green-icon-heading } Business relevance

``` mermaid
flowchart TB
    Dataset[(Assignment Dataset)]

    Benefit1>1. Process improvements]
    Benefit2>2. Customer satisfaction]
    Benefit3>3. Revenue growth]

    Dataset --> Benefit1 & Benefit2 & Benefit3


    %% STYLES %% 
    style Dataset fill:#666,color:#fff,stroke:#000;
    style Benefit1 fill:#5f60ff
    style Benefit2 fill:#ffc21a;
    style Benefit3 fill:#2bc275;
    %% style Benefit5 fill:#ccc,stroke:#666,color:#000; %%
    classDef Benefits color:#fff,stroke:#666;
    class Benefit1,Benefit2,Benefit3,Benefit4 Benefits;
```

1. Set up and start using ADSK products should be a very easy and seamless process, but there are some particularities that can turn users from doing it. By understanding the pain-points in this process, ADSK can better understand how to improve its onboarding services and features.
2. The earlier customer start using a product, the more satisfied they are likely to be with it. When a product meets a customer's needs and expectations, they are more likely to continue using it, recommend it to others, and even purchase additional products or services. 
3. Assignment is one of the widely tracked metric for customer overall health, but it also can be one of a signals showing that customer is likely to churn. By providing early signs to the support/CSM team, the churn risk can be mitigated.

## :material-book-search:{ .purple-icon-heading } Overview

After a customer purchases a product subscription for a number of seats (number of people / licenses who can use that product), in order to enable this customer to use the product, it is necessary to "assign" seats to particular users. This process is called "Assignment". 

### :material-table-plus: `assignment_monthly`

#### Upstream source

The `assignment_monthly` is a table that joins the most relevant information regarding this process, so the analyst community can have a solid point to start their discovery for insights. It joins **subscription, contracts, tenants and pool,** along with **seats purchased** information in one single table.

#### Lowest granularity
A unique record for the table is at the month (`by_month`), team (`tenant_id`), pool (`pool_id`), subscription (`subscription_id`), product (`product_line_code`), offering (`offering_external_key`) and feature name (` feature_name`) level, where feature name is the lowest level of granularity. 

That said it is important to note for assignment related fields (seats assigned) and metrics (assignment rate) the lowest level these can be correctly measured at is the tenant and pool level. This means caution should be taken when aggregating assignment related metrics and fields to different levels of aggregation. 

#### Business logic for derived fields

??? info "Fields with logic and business context"

    | ID | Field | Logic | Business context |
    | - | ----- | ----- | ---------------- |
    | 1 | `seats_unassigned` | (seats_purchased - seats_assigned) | Shows the number of seats at the tenant and pool level left unassigned to a named user | 
    | 2 | `ent_subs_id` | COALESCE(subscription_id, entitlement_id) | A unique identifier for the subscription/entitlement identifier if the subscription ID is null. Note all subscriptions in AUM have a subscription ID but some examples were missing in the source data |

  

#### Caveats & clarifications

??? info "Specifications"
    #### 1. Entitlement Sync Nuance

    One of the dependant data sources is the entitlement CED which is dependent on both Pelican and SFDC. There is a sync issue between the two where Pelican refreshes every hour but SFDC refresh time is every six hours. Implications on the assignment data set is there is a small set of records for new customers which have not fully synced who will be excluded from the end of month refresh. These records will be captured in the following refresh. 

    #### 2. Assignable Products Caveat
    Certain products on offerings are specified as being assignable or not. There is a bug in the current AUM data model where when a customer has both Single User Subscriptions and Token Flex subscriptions of the same product there is no way to differentiate which product is intended to be assignable and which one isn't. This bug is intended to be fixed in the new AUM data model but until so implications on the assignment data set are in these scenarios there will be two records for the product, one which is assignable and once which is not as we're unable to distinguish between them with certainty. Note this is a very small proportion of records (<0.1%).

    #### 3. Offering External Key Nuance
    Offering external key is an AUM based field and is often used for internal linkages within the data model. There are a handful of offerings that can follow more than one offering model based product, usage_type, price_model and years of subscription, but it cannot tell which subscription it is (i.e. dirty pooling issue). In these cases since they are the same offering subscriptions will share a pool ID but have a distinct offering_external_key to differentiate. Implications on the assignment data is the offering external key becomes a dependant column for the primary key of the data table. As a result of not knowing which subscription the offering_external_key ties to, in the data it gets associated to all subscription in the same pool type so there will be a record for each offering_external_key at the subscription level.

    #### 3. Multiple Primary Admins
    In AUM each team should only have one primary admin. However there are cases where multiple primary admins have been assigned. It is an infrequent occurrence but is against standard policy and teams have worked with customers to reconcile the issue but the effort is ongoing. As an impact to the data there may duplicate records in cases where they have one than one primary admin for the associated team.

    #### 4. Multiple Owner IDs 
    There are instances where entitlements have more than one associated owner_id. These cases are infrequent but as an impact to the data there may duplicate records where more than one owner ID ties to the entitlement.

    #### 5. Missing CSNs
    Known accounts CSNs are not synced in Salesforce and thus missing in the data. This impacts <0.1% of records for both the account_csn and corporate_parent_account_csn columns. The Enterprise Analytics & Experience has determined the imprecision is nominal for analytical purposes. 

    #### 6. Using the data to calculate assignment rate
    
    - **Don't use this for entitlement models other than single user subscriptions**: Assignment rate calculation is limited to  "Single User Subscription" business model, because it needs to be calculated based on seats assigned or seats purchased. 

    - **Don't use this for product offerings which do not follow standard configuration within AUM.** More details on the specific product list can be found [here](https://wiki.autodesk.com/display/CPDDPS/PLC+Lists+for+SUS+Reporting+and+Premium+Eligibility).

    - **Don't take averages as assignment rates are rolled up are down to different levels of aggregation.** As the level of aggregation changes seats purchased and seats assigned need to be re-summed before divided.

    - **It is possible for a tenant and pools assignment rate to be greater than 100%.** 
         - As part of Autodesk's current policy if a subscription within a tenant and pool expires but another active subscription remains in the same tenant and pool (the same product), then users are not unassigned seats. 
    ??? question "Example/Recommendation"
        - For example consider the following scenario:
            - Tenant 123 and Pool XYZ has the following two subscriptions of AutoCAD for a total of 6 purchased seats:
                - Subscription 444 with 2 purchased seats of AutoCAD expiring February 1st, 2022
                - Subscription 777 with 4 purchase seats of AutoCAD expiring March 1, 2022
            - As of January 31, 2022 all 6 seats of AutoCAD in the tenant and pool are assigned so the Assignment Rate is 100% (6 seats assigned / 6 seats purchased)
            - As of February 1st, Subscription 444 expires however no users are unassigned since another AutoCAD subscription (Subscription 777) is still active and so the current assignment rate 150% (6 seats assigned / 4 seats purchased)  

        - IMPORTANT: Depending on the use of assignment rate for analysis it may be necessary to cap assignment rates at 100%.

!!! warning "Known issues"
    No known issues.

### :fontawesome-solid-diagram-project: Data model

`eio_publish.access_shared.assignment_monthly` is a standalone table.

## :material-table-search:{ .yellow-icon-heading } Dataset details 

### :material-table-eye: Dataset location

| Data Warehouse | Schema/Database | View/Table      | Notes |
| -------------- | --------------- | --------------- | ----- |
| `eio_publish`    | `access_shared`   | `assignment_monthly` |     |

- GitHub location: [here](https://git.autodesk.com/dpe/adp-astro-cso-analytics/blob/b3492a17e02b47ed9756576eb346a203dfbdc811/dags/dbt/access/assignment/models/publish/shared/assignment/assignment_monthly_shared.sql)

### :material-table-key: Access

- Request access via [ADP Access Management](https://access.adp.autodesk.com/data-access/snowflake?id=76J63sBIsf2CL9uqtKjLtQ). 
- For more information, please refer to [ADP Access Management User Guide](https://wiki.autodesk.com/pages/viewpage.action?spaceKey=CPDDPS&title=ADP+Access+Management+User+Guide), or contact the team on their slack channel [#adp-access-support](https://autodesk.enterprise.slack.com/archives/C05JFCCB0FK).

### :material-table-sync: Refresh frequency

- monthly, 2nd of each month, at 02:45 UTC

### :material-table-cog: Data dictionary

Atlan (data catalog) link:

- [`assignment_monthly`](https://autodesk.atlan.com/assets/321d8a56-fd26-4629-970d-3e2da73d4005/overview)

## :material-file-code:{ .grey-icon-heading } Sample queries

To obtain specific information about Assignment Rate using SQL, you can see sample queries on the [metric documentation here](https://eda-data-docs.autodesk.com/metrics/assignment-rate/).

## :material-link:{ .grey-icon-heading } Related links

- [Technical Documentation (wiki)](https://wiki.autodesk.com/display/EAX/Assignments+-+Dataset)
- [Proof of Concept (wiki)](https://wiki.autodesk.com/display/EAX/Assignment+Prototype)
- [Customer analytics standardisation (wiki)](https://wiki.autodesk.com/display/EAX/Customer+analytics+standardisation)
