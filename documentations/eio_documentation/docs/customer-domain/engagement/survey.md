---
title: Survey
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
      <a target="_blank" href="https://aware.autodesk.com/ameya.dattanand.kambli">Ameya Dattanand Kambli</a>
    </span></li>
    <li class="doc-status"><strong>Status:</strong> <span class="doc-ok">Published</span></li> 
   <!-- <li><strong class="doc-status">Status:</strong> <span class="doc-wip">In Progress</span></li>  -->
  </ul>
</div>

## :material-table-multiple:{ .red-icon-heading } Introduction
The Survey dataset provides the complete information about surveys sent to ADSK customers from different business units to answer different business cases.  
!!! note
    The survey dataset is the source of the below metrics:

     - [Case Customer Effort Score (cCES)](../../metrics/case-customer-effort-score-cces.md)
     - Net Promoter Score (NPS)

## :fontawesome-solid-suitcase:{ .green-icon-heading } Business relevance
``` mermaid
flowchart TB
    Dataset[(Survey Dataset)]
    Benefit1>1. Customer satisfaction]
    Benefit2>2. Process improvements]
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

1. After experiencing an ADSK product or service, customers are encouraged to share their opinion. This data can then be analyzed at a product, team, geo level to support business decisions.
2. Getting help from ADSK teams should be a very easy and seamless process, but there are always opportunities to improve it. By understanding the pain-points in this process, ADKS can work on its onboarding and usage programs.
3. When a product or service meets a customer's needs and expectations, they are more likely to continue using it, recommend it to others, and even purchase additional products or services. 

Currently, all the below business cases can make use of the survey dataset:

- **NPS** (Net Promotor Score): 
- **GCSO**(Global Customer Support and Operations): Surveys sent to customers who have opened 'Cases' with Autodesk. This is the source for metrics such as:
    - **CES** (Customer Effort Score)
    - **ASAT** (Agent Satisfaction)
    - **Partner CSAT** (Customer Satisfaction)
  - **PSS Consulting Survey** (Premium Support Services)
  - **DSS/ Accelerator Survey** (Designated Support Specialist)

## :material-book-search:{ .purple-icon-heading } Overview
Every day Autodesk receives many responses from different surveys seeking feedback from customers about specific experiences through out the customer life-cycle. Those surveys are hosted and managed by a 3rd party software called *Qualtrics*. 
Several teams design those surveys with different formats, to answer different questions, which makes the consolidation of all those records a data architecture challenge. 
To be able to answer all those business cases, the Survey Dataset is designed connecting 3 tables in a de-normalized data model:

  - **`survey_question_option`**
  - **`survey_question_response`**
  - **`survey_embedded_data`**

### :material-table: `survey_question_option`
This table contains the **question details** for all surveys and is configured to capture the changes happening to the questions over time.

#### Upstream source
Combined `survey`, `question`, `option` and `sub-question` tables in Qualtrics.

#### Lowest granularity
A unique record is the combinations of the primary keys: `survey_id`, `question_id`, `sub_question_key`, `option_key` and `version_id`.

#### Business logic for derived fields

There is no derived field in the `survey_question_option` dataset.

### :material-table: `survey_question_response`

This table contains the transformed **response details** for the all answers given to survey questions, as well as the progress and details of the individuals who took the survey.

#### Upstream source
Qualtrics tables.

#### Lowest granularity
A unique record is the combinations of the primary keys: `survey_id`, `response_id`, `question_id`, `sub_question_key` , `option_key` and `response_seq_nbr`. 
The `response_seq_nbr` fields is a running sequence number generated for the combination of rest of the primary key fields, and it was created because for some questions, even with the above combination, uniqueness is not guaranteed.

#### Business logic for derived fields

There is no derived field in the `survey_question_response` dataset.

### :material-table: `survey_embedded_data`
This table contains **additional Qualtrics elements related to each survey response**. Commonly used attributes from the existing table is converted as columns. All additional attributes are populated as a JSON variant column.

#### Upstream source
Qualtrics tables.

#### Lowest granularity
A unique record and the primary key of the table is `response_id`.

#### Business logic for derived fields

There is no derived field in the `survey_embedded_data` dataset.

### :fontawesome-solid-diagram-project: Data model
??? abstract "Entity Relationship Diagram"
    ``` mermaid
    erDiagram
    
    %% Instructions: fill in the entities and relationships sections.
    %% you can find more information about mermaid entity relationship diagrams here: https://mermaid.js.org/syntax/entityrelationshipdiagram.html %%

    %% Entities %%
      "eio_publish.engagement_private.survey_question_option" {
        survey_id varchar PK
        question_id varchar PK
        sub_question_key varchar PK
        question_option_key varchar PK
        version_id number PK       
        survey_name varchar
        survey_status varchar
        survey_division_id varchar
        survey_last_activated_dt date
        survey_last_modified_dt date
        survey_option_title varchar
        question_type varchar
        question_selector varchar     
        question_text varchar
        sub_question_text varchar
        question_option_text varchar
        question_option_value varchar
        question_sub_selector varchar
        question_data_export_tag varchar
        sub_question_choice_dt_export_tag varchar
        valid_from timestamp
        valid_to timestamp
        active_flag varchar
        insert_dt date
        update_dt date   
    }
        "eio_publish.engagement_private.survey_question_response" {
        survey_id varchar PK
        response_id varchar PK
        question_id varchar PK
        sub_question_key varchar PK
        question_option_key varchar PK
        response_seq_nbr number PK
        question_text	varchar
        question_sub_question_text	varchar
        sub_question_text	varchar
        option_value	varchar
        value_text	varchar
        additional_value	variant
        survey_name	varchar
        survey_status	varchar
        recipient_email	varchar
        recipient_first_name	varchar
        recipient_last_name	varchar
        status	number
        finished	number
        progress	number
        duration_in_seconds	number
        recorded_date	timestamptz
        ip_address	varchar
        distribution_channel	varchar
        location_latitude	double
        location_longitude	double
        start_date	timestamptz
        end_date	timestamptz
        external_reference	varchar
        user_language	varchar
        loop_id	varchar
        question_data_export_tag	varchar
        insert_dt	date
        update_dt	date
  
    }
        "eio_publish.engagement_private.survey_embedded_data" {
        response_id	varchar PK
        survey_id varchar
        survey_name varchar
        additional_value variant
	      import_id_key variant
        insert_dt	date
        update_dt	date
        
    }
  
    %% Relationships %%

    "eio_publish.engagement_private.survey_question_option" }|--|{ "eio_publish.engagement_private.survey_question_response" : "survey_id"
    "eio_publish.engagement_private.survey_question_response" ||--|| "eio_publish.engagement_private.survey_embedded_data" : "response_id"
    %% ERD STYLES (This is common to all CAKN ERDs. For standardization, leave this section as is.") %%
    %%{init:{'theme':'base'}}%%
    %%{init:{'themeCSS':'.er.attributeBoxEven { fill:#fff; stroke: #000; };.er.attributeBoxOdd { fill:#fff; stroke: #000;  }; .er.entityBox { fill: #ccc; stroke: #000; }; .er.entityLabel{ fill: #000; }; .er.relationshipLine { stroke:#ccc!important; }'}}%%
    ```

## :material-table-search:{ .yellow-icon-heading } Dataset details

### :material-table-eye: Dataset location

#### Snowflake

| Data Warehouse | Schema/Database | View/Table | Notes |
| -------------- | --------------- | ---------- | ----- |
| `eio_publish`  | `engagement_private` | `survey_question_option` | |
| `eio_publish`  | `engagement_private` | `survey_question_response` | |
| `eio_publish`  | `engagement_private` | `survey_embedded_data` | |

- GitHub location: [here](https://git.autodesk.com/dpe/adp-astro-cso-analytics/tree/master/dags/dbt/engagement/survey/models/publish/private)

### :material-table-key: Access

- Request access via [ADP Access Management](https://access.adp.autodesk.com/data-access/snowflake?id=1ip3IHEEFgmvDoatRM85Ds). 
- For more information, please refer to [ADP Access Management User Guide](https://wiki.autodesk.com/pages/viewpage.action?spaceKey=CPDDPS&title=ADP+Access+Management+User+Guide), or contact the team on their slack channel [#adp-access-support](https://autodesk.enterprise.slack.com/archives/C05JFCCB0FK).

### :material-table-sync: Refresh frequency

Daily, 12:15 PM UTC

### :material-table-cog: Data dictionary

Atlan (data catalog) link:

- [`survey_question_option`](https://autodesk.atlan.com/assets/31bb6f3f-0db9-4274-987a-e09ed0c5bd7c/overview)
- [`survey_question_response`](https://autodesk.atlan.com/assets/1694328e-5a12-4b47-a5fb-accfd048ece0/overview)
- [`survey_embedded_data`](https://autodesk.atlan.com/assets/376cf975-0ef2-498e-95b7-e7234cbc5065/overview)

### :material-table-question: Caveats and clarifications

!!!warning "Known issues"
    No known issues

## :material-file-code:{ .grey-icon-heading } Sample queries

To facilitate querying the different surveys, the below table should provide the `survey_name` and `question_id` for the most used analysis:

| User case | Survey Name | Survey ID | Notes |
|---------- | ----------- | --------- | ----- |
| NPS       | qual_nps_listening_post_v20 | SV_82psVcj4tp9CYWV |  
| NPS       | qual_gs_relationship_survey_fy18_version_2prd_sfdc | SV_8f5nHOfARZPjQmV | | 
| NPS       | qual_fy21_eba_relationship_survey__prd__04162020 | SV_0V4ztHcElynqzA1 | | 
| GCSO | GCSO_Improvement_Survey_PRD_-_07282020 | SV_aWd9zzdU4we7QTr | |
| DSS/AC/Partner | DSS/AC/Partner Accelerators | SV_71UoEEFHsVnNjX7 | | 

??? abstract "Explore how many active surveys and questions from `survey_question_option`"
    #### Sample query 1
    The purpose of these scripts is to get all the active `survey_names` and the distinct count of `question_id` in each survey.
    ``` sql linenums="1"  
      SELECT survey_name, survey_id,
      COUNT (DISTINCT (question_id)) AS numbr_of_questions 
        FROM eio_publish.engagement_private.survey_question_option
      WHERE survey_status = 'Active'
      GROUP BY 1, 2; 
    ```

??? abstract "Explore the questions and format of a particular survey from `survey_question_option`"
    #### Sample query 2
    The purpose of these scripts is to get the distinct question and description for GCSO survey.
    ``` sql linenums="1"  
      SELECT DISTINCT question_id , question_text, question_type, question_data_export_tag
        FROM eio_publish.engagement_private.survey_question_option 
      WHERE survey_id = 'SV_aWd9zzdU4we7QTr' -- this is `GCSO_Improvement_Survey_PRD_-_07282020`
      AND active_flag = 'TRUE' 
    ```

??? abstract "Calculate NPS by year from `survey_question_response`"
    #### Sample query 3
    The purpose of this scripts is to calculate hte NPS score from `survey_id = 'SV_82psVcj4tp9CYWV'` and `question_id = 'QID2'`
    ``` sql linenums="1"  
     WITH nps AS (
      SELECT   
        left(end_date,4) AS year,
        ---Count of surveys where score category is Promoters
        SUM(
        CASE
            WHEN additional_value = '{   "NPS_GROUP": "3" }' THEN 1
            ELSE 0
        END ) AS promoters_count,
        ---Count of surveys where score category is Detractors
        SUM(
        CASE
            WHEN additional_value = '{   "NPS_GROUP": "1" }' THEN 1
            ELSE 0
        END ) AS detractors_count,
        ---Count of surveys where score category is PASsive
        SUM(
        CASE
            WHEN additional_value = '{   "NPS_GROUP": "2" }' THEN 1
            ELSE 0
        END ) AS passive_count,
        ---Total Surveys
        COUNT(response_id) AS survey_count,
        ---Average Score
        AVG(value_text) AS average_score,
        ---Total Score
        SUM(value_text) AS sum_score,
        ---NPS score for Promoters
        DIV0(promoters_count, survey_count) AS promoters_combined,
        ---NPS score for Detractors
        DIV0(detractors_count, survey_count) AS detractors_combined,
        ---NPS score: promoters - detractors
        ROUND( ( promoters_combined - detractors_combined ) * 100, 0 ) AS nps_combined
      FROM eio_publish.engagement_private.survey_question_response  nps
        WHERE survey_id =   'SV_82psVcj4tp9CYWV' AND question_id = 'QID2'
        GROUP BY year
        )
        SELECT * FROM nps  
        ORDER BY year 
    ```
??? abstract "Join `survey_question_response` with `survey_embedded_data` for the DSS/AC/Partner accelerators survey"
    #### Sample query 4
    The purpose of this scripts is to get the embedded details for `survey_id = 'SV_71UoEEFHsVnNjX7'`
    ``` sql linenums="1"  
      SELECT *
        FROM eio_publish.engagement_private.survey_question_response r
        JOIN eio_publish.engagement_private.survey_embedded_data e
      WHERE r.response_id = e.response_id 
      AND r.survey_id = 'SV_71UoEEFHsVnNjX7' -- this is ``DSS/AC/Partner Accelerators - PRD - 07302020``
    ```
    
## :material-link:{ .grey-icon-heading } Related links
- [Survey Data Model - EIO vs EDH (wiki)](https://wiki.autodesk.com/pages/viewpage.action?pageId=1948534895)
- [Solution Design - Qualtrics (wiki)](https://wiki.autodesk.com/pages/viewpage.action?spaceKey=EAX&title=Solution+Design+-+Qualtrics#SolutionDesignQualtrics-Queries)
- [Data Model - Survey (wiki)](https://wiki.autodesk.com/pages/viewpage.action?spaceKey=EAX&title=Data+Model+-+Survey)
- [Customer analytics standardization (wiki)](https://wiki.autodesk.com/display/EAX/Customer+analytics+standardisation)
