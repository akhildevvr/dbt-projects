---
title: Dataset name
author: Enterprise Data and Analytics, Global Revenue Operations
---

{==

## **Template instructions checklist**

* [x] Read the [Contribute to Customer Analytics Knowledge Network](https://eda-data-docs.autodesk.com/contribution/contribute-to-cakn) document before proceeding with this template.
* [ ] Create your markdown file in the corresponding folder (`usage`, `engagement`, etc.) of the `eio_documentation/docs/customer-domain/` directory.
* [ ] Copy all the content from the Markdown file of this template and paste it into the new Markdown file that you will create to build your document. 
* [ ] **Title**: Replace the `Dataset name` with the title of your document at the top of the page, between the initial `---` lines in the Markdown file.
* [ ] **Sections overview**: Familiarize yourself with the structure for this template.
      ```
      ├─ Key contacts
      ├─ Introduction
      │   └─ Notes
      ├─ Business relevance
      ├─ Overview
      │   ├─ Table 1 name
      │   │   ├─ Upstream sources
      │   │   ├─ Lowest granularity
      │   │   ├─ Business logic for derived fields      
      │   │   └─ Caveats & clarifications
      │   ├─ Table 2 name
      │   │   ├─ Upstream sources
      │   │   ├─ Lowest granularity
      │   │   ├─ Business logic for derived fields      
      │   │   └─ Caveats & clarifications
      │   └─ Data model
      ├─ Dataset details
      │   ├─ Dataset location
      │   ├─ Access
      │   ├─ Refresh frequency
      │   └─ Data dictionary
      ├─ Sample queries
      └─ Related links
      ```
  * [ ] **Key contacts**: Replace `Product Manager:`, `Business Intelligence:`, and `Subject Matter Expert:` with the roles of the key contacts for this document, and add their name. Then, replace `#` with the link to their Aware URL profile. This content block is located at the top of the right sidebar.
  * [ ] **Introduction**: Summarize the objective or purpose of the dataset, preferably starting with one sentence. Then, optionally, add between one and three other paragraphs to describe introductory details, writing for a non-technical audience.
      - **Note**: In the `note` block, indicate any metrics that are built from this dataset, including the link to their page. Add any extra note in another bullet point. If there aren't any metrics or relevant notes, remove this `note` block entirely.
  * [ ] **Business relevance**: Complete the diagram replacing each `Benefit` label with an actual benefit the dataset provides to the business. Add between 3 and 5 benefits. Then, use the ordered list below to describe each benefit in one paragraph, writing for a non-technical audience.
  * [ ] **Overview**: Describe the type of information this dataset contains and introduce its corresponding table names. This should reflect the scope of the data it covers.
      - Add the name of each table as section title, following the examples.
      - **Upstream sources**: Describe the information about its upstream sources.
      - **Lowest granularity**: Indicate the lowest granularity using one or two paragraphs, or a list if needed.
      - **Business logic for derived fields**: Complete the table by adding each field and its corresponding logic and business context. Add the `<br>` tag to create a new line. If there isn't any field, remove this section entirely.
      - **Caveats & clarifications**: Add the title of each impacted use case and its description. Optionally, each impacted use case can have a collapsible block with an Example/Recommendation, where you can include images if needed. Add Known issues separately where it is indicated, each on a separate bullet point.
      - **Data model**: Follow the highlighted instructions located in this section below.
  * [ ] **Dataset details**: Follow the same structure and format as the examples provided.
      - **Dataset location**: Complete the table.
      - **Access**: Replace only the ADP Access Management link in the first bullet point only. If this dataset is a standalone table, add the link to the specific schema page. Otherwise, link to the main [ADP Access Management page](https://access.adp.autodesk.com/).
      - **Data Dictionary**: Add the link to each table name to its corresponding page on Atlan.
      - **Refresh frequency**: Replace the example with the dataset details.
  * [ ] **Sample queries**: Follow the examples. Each SQL sample query should have a title and include a description. Keep the `### Sample query 1`, the `sql linenums="1"` information as it is in order to enable standardization. Follow the best practices regarding coding standards, and check that the sample queries are not repeated on the dataset document.
  * [ ] **Related links**: Optionally, add links to pages that complement this document. Avoid the repetition of links that have been added in the previous sections. Indicate in parenthesis the platform where it links to, provided it is not the CAKN website (e.g. (wiki)).
  * [ ] Once you complete the document, copy the Markdown file from the `eio_documentation/docs/customer-domain/` directory and paste it into the corresponding `dags/dbt` directory (this is a temporary required step).

  The examples provided in each section below are taken from different documents. For additional examples, refer to the documents created in the  `eio_documentation/docs/customer-domain/` directory.

!!! warning
    When you complete your document, remove both this instructions block and the instruction comments between `==` from the rest of the sections in this Markdown file.

!!! note "Publish the document on GitHub for review"
    Use the GitHub Desktop or the Terminal to create a branch, commit your changes, and push the document to GitHub. Follow these guidelines:

    1. Create a branch with the following naming pattern, replacing the Jira-ID and the rest of the words with the details of your task:
      - `jira-2120/cakn/create-name-of-document`.
    2. Add your changes to your branch and commit them. Write a commit message where indicated if you are using GitHub Desktop. If you are using the Terminal, you can write something similar to this example: `git commit -m "Created the (title of your document) document on CAKN"`.
    3. Push your changes and create a Pull Request, adding a screenshot of the document on your local environment in the description under a `## Test Case` section (drag and drop or copy and paste the image file into the GitHub description box).
    4. Add the Technical Writers and Delivery Managers as reviewers.

==}


<!-- Key contacts -->

<div id="dataset-template-info-main">
  <ul>
    <li><strong>Product Manager:</strong>
      <a href="#">Name of Product Manager</a>
    </li>
    <li><strong>Data Analyst Subject Matter Expert:</strong>
      <a target="_blank" href="#">Name of SME1</a>,
      <a target="_blank" href="#">Name of SME2</a>
    </li>
    <li><strong>Engineer Subject Matter Expert:</strong>
      <a target="_blank" href="#">Name of SME1</a>,
      <a target="_blank" href="#">Name of SME2</a>
    </li>
    <li class="doc-status"><strong>Status:</strong> <span class="doc-ok">Published</span></li> 
   <!-- <li><strong class="doc-status">Status:</strong> <span class="doc-wip">In Progress</span></li>  -->
  </ul>
</div>


## :material-table-multiple:{ .red-icon-heading } Introduction

The Assignment dataset provides basic information in one table about how the business is performing in terms of onboarding our customers to start using their subscription. 

!!! note
    - To learn about the metric related to this dataset, visit the [Active Users document](../../onboarding/metrics/active-users-metric.md).


<!-- Business relevance -->

## :fontawesome-solid-suitcase:{ .green-icon-heading } Business relevance

``` mermaid
flowchart TB
    Dataset[(Write the dataset name here)]

    %% STEP 1: Each benefit label should have between 1 and 3 words that to indicate how the dataset helps the business. Add between 3 and 5 benefit labels.%% 

    Benefit1>1. Customer satisfaction]
    Benefit2>2. Churn prevention]
    Benefit3>3. Benefit 3]
    Benefit4>4. Benefit 4]

    Dataset --> Benefit1 & Benefit2 & Benefit3 & Benefit4

    %% STYLES %% 
    
    style Dataset fill:#666,color:#fff,stroke:#000;
    style Benefit1 fill:#5f60ff;
    style Benefit2 fill:#ffc21a;
    style Benefit3 fill:#2bc275;
    style Benefit4 fill:#d74e26;
    %% style Benefit5 fill:#ccc,stroke:#666,color:#000; %%
    classDef Benefits color:#fff,stroke:#666;
    class Benefit1,Benefit2,Benefit3,Benefit4 Benefits;
```

1. The more a customer uses a product, the more satisfied they are likely to be with it. When a product meets a customer's needs and expectations, they are more likely to continue using it, recommend it to others, and even purchase additional products or services.
2. Assignment is one of the widely tracked metric for customer overall health, but it also can be one of a signals showing that customer is likely to churn. By providing early signs to the support/CSM team, the churn risk can be mitigated.
3. Explain Benefit 3 here.
4. Explain Benefit 4 here.


<!-- Overview -->

## :material-book-search:{ .purple-icon-heading } Overview

The Product Usage dataset gathers the data of users from single user subscription and commercial usage only in a table named `usage_sus_daily`.

### :material-table: `usage_sus_daily`

#### Upstream sources

This table contains information from different systems such as CLic (Cloud Licensing) and data sources such as entitlement and subscriptions.

#### Lowest granularity

A unique record for the table is at the combination of `usage_date`, `oxygen_id`, `tenant_id`, `pool_id`, `subscription_id`, `subscription_src`, `product_line_code`, `offering_product_line_code`, and `feature_name` granularity.

#### Business logic for derived fields

??? info "Fields with logic and business context"

    | ID | Field | Logic | Business context |
    | -- | ----- | ----- | ---------------- |
    | 1  | `offering_product_line_code` |`coalesce(usage.offering_product_line_code, entitlement.offering_product_line_code)` | Offering product line code is sourced from Authorisation CLic table, if that is absent, the information from Entitlement CED will be filled in. |
    | 2  | `subscription_src` | One of two values:<br>1. `clic_subscription` -> subscription ID was captured in CLic.<br>2. `aum_subscription` -> the subscription ID was not captured directly in CLic but is also on the same offering and team in AUM. | Identifies if the subscription ID was captured directly in CLic or if the subscription has inferred usage from being of the same offering on the same team. |
    | 3  | `add_field_here`   | Add the logic here. | Add the business context here. |

#### Caveats & clarifications

??? info "Specifications"

    #### 1. Which Account CSN(s) are included
    Victim survivor table is used to join the Entitlement CED and Account CED tables but the CSN surfaced in the product usage dataset depend on the which ever CSN available in the Entitlement CED and Account CED on the load date.

    #### 2. Account CSN availability
    Account CSN is available for all of the records. However the logic to get the account information for the records depends on the date partitions.

    ??? question "Example/Recommendation"
        There are two different codes for historic data depending on if the date partitions is before or after March 9, 2021. For dates prior to March 9, 2021, instead of using the point-in-time partition, the account CSN is brought into the data using the earliest available partition from the entitlement CED with the `end_customer_acct_csn` column populated (2021-03-09).

    #### 3. Impacted use case 3 title
    Describe impacted use case here.

    ??? question "Example/Recommendation"
        This block is optional.

!!! warning "Known issues"
    No known issues.


### :material-table: `table_2_name`

#### Upstream sources

Explain the upstream sources here.

#### Lowest granularity

Indicate the lowest granularity here.

#### Business logic for derived fields

??? info "Fields with logic and business context"

    | ID | Field | Logic | Business context |
    | -- | ----- | ----- | ---------------- |
    | 1  | `add_field_here`   | Add the logic here. | Add the business context here. |
    | 2  | `add_field_here`   | Add the logic here. | Add the business context here <br> with a new line if needed. |

#### Caveats & clarifications

??? info "Specifications"

    #### 1. Which Account CSN(s) are included
    Victim survivor table is used to join the Entitlement CED and Account CED tables but the CSN surfaced in the product usage dataset depend on the which ever CSN available in the Entitlement CED and Account CED on the load date.

    #### 2. Account CSN availability
    Account CSN is available for all of the records. However the logic to get the account information for the records depends on the date partitions.

    ??? question "Example/Recommendation"
        There are two different codes for historic data depending on if the date partitions is before or after March 9, 2021. For dates prior to March 9, 2021, instead of using the point-in-time partition, the account CSN is brought into the data using the earliest available partition from the entitlement CED with the `end_customer_acct_csn` column populated (2021-03-09).

    #### 3. Impacted use case 3 title
    Describe impacted use case here.

    ??? question "Example/Recommendation"
        This block is optional.

!!! warning "Known issues"
    No known issues.


### :fontawesome-solid-diagram-project: Data model

==If this dataset contains only a standalone table, simply add the following sentence like the following example:==

`table_1_name` is a standalone table.

==If there are more tables, build an entity relationship diagram in the following collapsible block, using the sample mermaid code:==

??? abstract "Entity Relationship Diagram"
    ``` mermaid
    erDiagram

    %% Instructions: Add the Entities and Relationships sections.
    %% You can find more information about mermaid Entity Relationship Diagrams (ERD) here: https://mermaid.js.org/syntax/entityrelationshipdiagram.html %%

    %% Entities %%

    "eio_publish.engagement_private.survey_question_option" {
        survey_id varchar
        question_id varchar
        sub_question_id varchar
        question_option_key varchar
        version_id number
        question_text varchar
        sub_question_text varchar
        question_option_value varchar
        question_option_text varchar
        survey_name varchar
        survey_status varchar
        survey_division_id varchar   
    }
        "eio_publish.engagement_private.survey_question_response" {
        survey_id varchar
        question_id varchar
        sub_question_id varchar
        question_option_key varchar
        version_id number
        question_text varchar
        sub_question_text varchar
        question_option_value varchar
        question_option_text varchar
        survey_name varchar
        survey_status varchar
        survey_division_id varchar   
    }
        "eio_publish.engagement_private.survey_embedded_data" {
        survey_id varchar
        question_id varchar
        sub_question_id varchar
        question_option_key varchar
        version_id number
        question_text varchar
        sub_question_text varchar
        question_option_value varchar
        question_option_text varchar
        survey_name varchar
        survey_status varchar
        survey_division_id varchar   
    }
  
    %% Relationships %%

    "eio_publish.engagement_private.survey_question_option" }|--|{ "eio_publish.engagement_private.survey_question_response" : "survey_id"
    "eio_publish.engagement_private.survey_question_response" ||--|| "eio_publish.engagement_private.survey_embedded_data" : "survey_id"
    "eio_publish.engagement_private.survey_question_option" ||--|| "eio_publish.engagement_private.survey_embedded_data" : "survey_id"


    %% ERD styles (this is common to all CAKN ERDs. For standardization, leave this section as is.) %%

    %%{init:{'theme':'base'}}%%
    %%{init:{'themeCSS':'.er.attributeBoxEven { fill:#fff; stroke: #000; };.er.attributeBoxOdd { fill:#fff; stroke: #000;  }; .er.entityBox { fill: #ccc; stroke: #000; }; .er.entityLabel{ fill: #000; }; .er.relationshipLine { stroke:#ccc!important; }'}}%%
    ```


<!-- Dataset details -->

## :material-table-search:{ .yellow-icon-heading } Dataset details

### :material-table-eye: Dataset location

| Data Warehouse | Schema/Database | View/Table      | Notes |
| -------------- | --------------- | --------------- | ----------------- |
| `eio_publish`    | `usage_shared`    | `usage_sus_daily` | |

### :material-table-key: Access

- Request access via [ADP Access Management](https://access.adp.autodesk.com/data-access/snowflake?id=2a9RWoU8iTcnqRkvLKj47J). 
- For more information, please refer to [ADP Access Management User Guide](https://wiki.autodesk.com/pages/viewpage.action?spaceKey=CPDDPS&title=ADP+Access+Management+User+Guide), or contact the team on their slack channel [#adp-access-support](https://autodesk.enterprise.slack.com/archives/C05JFCCB0FK).

### :material-table-sync: Refresh frequency

Daily (1PM UTC)

### :material-table-cog: Data dictionaries

Atlan (data catalog) link:

- [`usage_sus_daily`](https://autodesk.atlan.com/assets/cdf46c92-add3-4282-9684-b8619eb6a6e9/overview)
- [`table_2_name`](#)


<!-- Sample queries -->

## :material-file-code:{ .grey-icon-heading } Sample queries

==If the sample queries are in a metric document, write a sentence here indicating it, including the link to that specific section of the metric page. See the following example as a reference:==

To obtain specific information about Active Users using SQL, you can see sample queries on the metric documentation [here](../../onboarding/metrics/active-users-metric.md#sample-queries). 

==If there isn't any other related page where the sample queries are located, add each sample query in a separate collapsible block as follows:==

??? abstract "1. Calculate assignment rate at the team and pool level"
    #### Sample query 1

    This query calculates assignment rate at the team and pool level which is the lowest level of granularity to accurately measure this metric. 

    ``` sql linenums="1"
    WITH distinct_tp_assignment AS(
        SELECT DISTINCT
            by_month
            ,tenant_id
            ,pool_id
            ,offering_external_key
            ,seats_assigned
            ,seats_purchased
        FROM eio_publish.access_shared.assignment_monthly
        WHERE seats_purchased <> 0
    )
    
    SELECT
        by_month
        ,tenant_id
        ,pool_id
        ,ROUND(seats_assigned/seats_purchased,4) * 100 AS assignment_rate
    FROM distinct_tp_assignment
    ```

??? abstract "2. Calculate assignment rate at the child account CSN level"
    #### Sample query 2

    This query calculates assignment rate at the account CSN level. Purchased seats and seats assigned will get allocated to all CSNs associated to the team and pool. 

    ``` sql linenums="1"
    WITH distinct_tp_assignment AS(
    SELECT DISTINCT
         by_month
        ,account_csn
        ,tenant_id
        ,pool_id
        ,offering_external_key        
        ,seats_assigned
        ,seats_purchased
    FROM eio_publish.access_shared.assignment_monthly
    ),
    
    account_csn_aggregated AS(
        SELECT
            by_month
            ,account_csn
            ,SUM(seats_assigned) AS seats_assigned
            ,SUM(seats_purchased) AS seats_purchased
        FROM eio_publish.access_shared.assignment_monthly
        GROUP BY by_month, account_csn
    )
    
    SELECT
        by_month
        ,account_csn
        ,ROUND(seats_assigned/seats_purchased,4) * 100 AS assignment_rate
    FROM account_csn_aggregated
    ```
??? abstract "3. Title of sample query 3"
    #### Sample query 3

    Description of sample query 3.

    ``` sql linenums="1"
    Paste the SQL code here.
    ```
    
<!-- Related links -->

## :material-link:{ .grey-icon-heading } Related links

- [Product Usage Prototype (wiki)](https://wiki.autodesk.com/display/EAX/Product+Usage%3A+Prototype)
- [Proof of Concept (wiki)](https://wiki.autodesk.com/display/EAX/Usage+Findings)
- [Customer analytics standardization (wiki)](https://wiki.autodesk.com/display/EAX/Customer+analytics+standardisation)
