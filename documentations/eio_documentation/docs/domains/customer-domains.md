# EIO Domain Overview







What are EIO domains are currently divided into the following domains:


| Name | Shared | Private | Description | 
| :--- | :---:  |  :---:  | :---        |
| ACCESS  | Yes | Yes | User Assignment details and summaries |
| CALABRIO| Yes | Yes | Tables abd views that support the Customer Technical Success (CTS) organisation with operational reporting data. |
| CUSTOMER | Yes | Yes | Tables and views that summarise Autodesk customers and how Autodesk field team individuals are assigned to the customer |
| ENGAGEMENT | Yes | Yes | Tables and views that summarise how Autodesk is engaging with customers |
| OPERATIONAL | Yes | Yes | Tables and views that summarise operational engagements. |
| PURCHASE | Yes | Yes | Tables and view that summarise customer purchases |
| REFERENCE | No | Yes | Reference datasets used for enrichment of analytics |
| TENROX | Yes | Yes | Tables and views that support the Enterprise Customer Success (ECS) organisation with operational reporting data. |
| USAGE | Yes | Yes | Tables and views that summarise product usage by Autodesk product and services users. | 


## Private vs. Shared
The very nature of Autodesk customer data means that there are strict rules guiding how data can be used.   There are two main constraints:

- PII - Personal Identifiable Information
- Current Quarter Financial

Any data which includes either (or both) of the above cannot be openly or publicly shared within or beyond Autodesk.   Strict **GDPR** rules govern if and when an individuals personal details can be shared.   Financial data and associated insights that can provide material understanding of Autodesk's financial performance cannot be shared publicly (mean within and beyond Autodesk) before it has been disclosed to Wall Street which typically happens one month after the end of the fiscal quarter.   

Any data that **does** include either of the above is only available within the <DOMANIN>_PRIVATE schema.   To access this schema, individuals need to be on the [**Trading Window List**](https://one.autodesk.com/LEGAL/articles/819cf0b6dba724105e0caa82ca961930).
