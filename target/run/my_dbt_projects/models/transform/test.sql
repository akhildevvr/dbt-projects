
  create or replace   view EIO_INGEST.USER_RAVINDA_TENROX_TRANSFORM.test
  
   as (
     


SELECT 
PROJECTID,


  
    ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_all 
         ELSE IFNULL(forecast.hrsact_total_all, 0.00) END AS hrsact_total_all
  
  
    ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_past 
         ELSE IFNULL(forecast.hrsact_total_past, 0.00) END AS hrsact_total_past
  
  
    ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_currentmonth 
         ELSE IFNULL(forecast.hrsact_total_currentmonth, 0.00) END AS hrsact_total_currentmonth
  
  
    ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_pastqtrs 
         ELSE IFNULL(forecast.hrsact_total_pastqtrs, 0.00) END AS hrsact_total_pastqtrs
  
  
    ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_entirecurrentqtr 
         ELSE IFNULL(forecast.hrsact_total_entirecurrentqtr, 0.00) END AS hrsact_total_entirecurrentqtr
  
  
    ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_currentqtrm1 
         ELSE IFNULL(forecast.hrsact_total_currentqtrm1, 0.00) END AS hrsact_total_currentqtrm1
  
  
    ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.hrsact_total_currentqtrm2 
         ELSE IFNULL(forecast.hrsact_total_currentqtrm2, 0.00) END AS hrsact_total_currentqtrm2
  


FROM
"EIO_INGEST"."USER_RAVINDA_TENROX_TRANSFORM"."ADSK_CM_LABOR_HRS_V02"
  );

