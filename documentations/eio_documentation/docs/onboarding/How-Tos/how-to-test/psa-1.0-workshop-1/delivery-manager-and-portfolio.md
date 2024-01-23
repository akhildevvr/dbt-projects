Delivery Manager and Project Portfolio Example
==============================================

!!! question
    As a **Delivery Manager** I want to keep track of hours allocated for the accounts within my portfolio with the results being summarized by month.



!!! abstract "Let's understand the data"
    The **Account Name** and **Delivery Manager** are dimensions of the project and can therefore be found in the **GCD_PROJECT_DETAILS** table.

    **Hours** are a very granular dataset as they are captured on individual timesheets by each consultant however these times are aggregated into and made available in the following reporting table **GCD_UTILISATION_HOUR_FORECAST**. 

    Both the **GCD_PROJECT_DETAILS** and the **GCD_UTILISATION_HOUR_FORECAST** can be found in the **ENGAGEMENT_PRIVATE** schema of **EIO_PUBLISH**. 



### Entity Relationship
``` mermaid 
erDiagram 
  GCD_PROJECT_DETAILS ||--o{ GCD_UTILISATION_HOUR_FORECAST : "booked time"
  GCD_PROJECT_DETAILS {
    varchar account_name
    varchar project_code
    varchar delivery_manager
  }
  GCD_UTILISATION_HOUR_FORECAST {
    varchar project_code
    float hours
    date bymonth
  }
```

The **GCD_UTILISATION_HOUR_FORECAST** table can be joined to the **GCD_PROJECT_DETAILS** table using the join column of PROJECT_CODE.


### SQL Code
``` sql title="Query for hours by portfolio manager" linenums="1" hl_lines="7"
SELECT 
    pd.account_name
    , uhf.bymonth
    , SUM(uhf.hours) as total_hours
FROM eio_publish.engagement_private.gcd_project_details pd
    LEFT JOIN eio_publish.engagement_private.gcd_utilization_hour_forecast uhf
        ON pd.project_code = uhf.project_code
WHERE pd.govpmdoc_delivery_manager = 'Fred Flintstone'
    AND uhf.bymonth = DATE'2023-03-01'
    AND pd.account_name IS NOT NULL
GROUP BY
    pd.account_name
    , uhf.bymonth
```


### PowerBI Promoted Dataset
