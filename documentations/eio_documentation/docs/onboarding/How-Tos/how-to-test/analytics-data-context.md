---
title: Analytics Data Context
author: Enterprise Data and Analytics, Global Revenue Operations
---

If you are new to the customer analytics domain here at Autodesk then this is a great place to get started.

When we think of analytics data, we often think of the platform that hosts the data rather than the data itself.  Here at Autodesk the platform is known as [ADP](https://wiki.autodesk.com/pages/viewpage.action?spaceKey=ADP&title=ADP+--+The+Autodesk+Data+Platform) (the Analytics Data Platform or Autodesk Data Platform).   Within the platform there are many tools and services that can be leveraged for analytics use cases.  The good news is that it is not necessary to know all the details or ADP, or indeed all of the services that ADP provides.   Many of the analytics use cases can be satisfied with knowing about:

    - Snowflake - the production instance
    - SQL Clients - for example Jetbrains DataGrip
    - PowerBI Desktop
    - Jupyter / Python

Much of this **Getting Started** section is devoted to these tools.

# Analytics data context

``` mermaid
flowchart TB

subgraph analyticsUser[Data Analyst]
    h1[-Person]:::type
    d1[A Data or Insights Analyst who \n requires access to curated data \n for developing insights and actions]:::description
end

analyticsUser:::person


subgraph powerBIDesktop[PowerBI Desktop]
    h4[-Visualization Application-]
    d4[Analytics and Insights visualization tool.]
end

subgraph jupyterNotebook[Jupyter Notebook]
    h5[-Visualization Application-]
    d5[Analytics and Insights visualization tool.]
end

subgraph sqlClient[SQL Client]
    h6[-Query Application-]
    d6[Executes queries against the database.]
end


subgraph analyticsDataPlatform[Analytics Data Platform]

    subgraph snowflakeInstance[Snowfake Production Instance]
        direction LR
        h2[-Database Application-]
        d2[Cloud provisioned database hosting \n curated analytics and raw ingested data.]

        subgraph edhSchema[EDH Customer Data]
            direction LR
            d7[Primary source for curated customer data]
        end

        subgraph eioSchema[EIO Analytics Data and Metrics]
            direction LR
            d8[Source for curated analytics metrics and objects]
        end

        subgraph otherADPSchemas[ADP Schemas]
            direction LR
            d9[Source for other schemas of data note yet integrated into EDH.  \n For example SFDC]
        end



    end

    subgraph s3_hive_datalake[S3 and Hive Data Lake]
        h3[-Database Application-]
        d3[Low level and raw ingested data including \n product instrumentation logs.]
    end



end


analyticsUser--Executes queries using-->sqlClient
analyticsUser--Uses PowerBI to analyze and visualize data in-->powerBIDesktop
analyticsUser--Uses python and jupyter to analyze and visualize data in-->jupyterNotebook

powerBIDesktop--Queries data from-->snowflakeInstance
jupyterNotebook--Queries data from-->snowflakeInstance
sqlClient--Queries data from-->snowflakeInstance

```