
  
    

        create or replace transient table eio_publish.tenrox_private.cust_adsk_utilization_hours  as
        (

select 
	ROWNUMBER  as ROW_NUMBER
	,USERID  as USER_ID
	,USERNAME  as USER_NAME
	,ENTRYDATE  as ENTRY_DATE
	,LIMITDATE  as LIMIT_DATE
	,TOTALTIME  as TOTAL_TIME
	,PROJECTCODE  as PROJECT_CODE
	,PROJECTNAME  as PROJECT_NAME
	,TASKNAME  as TASK_NAME
	,cast(BILLABLE as boolean) as BILLABLE
	,cast(UTILIZED as boolean) as UTILIZED
	,cast(ENTRYISAPPROVED as boolean)  as ENTRY_IS_APPROVED
	,TASKCODE  as TASK_CODE
	,cast(WASNEWTABLE as boolean) as WAS_NEW_TABLE
	,SQLSCRIPTVERSION  as SQL_SCRIPT_VERSION 
from eio_ingest.tenrox_transform.cust_adsk_utilization_hours
        );
      
  