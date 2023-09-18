
  
    

        create or replace transient table eio_publish.tenrox_private.cust_adsk_servicesimpact_actuals  as
        (

select 
	 ROWNUMBER  as ROW_NUMBER
	,PROJECTID  as PROJECT_ID
	,HRSMONTH  as HRS_MONTH
	,USERROLE  as USER_ROLE
	,HRSACTUAL  as HRS_ACTUAL
	,cast(WASNEWTABLE as boolean)   as WAS_NEW_TABLE
	,SQLSCRIPTVERSION  as SQL_SCRIPT_VERSION

from eio_ingest.tenrox_transform.cust_adsk_servicesimpact_actuals
        );
      
  