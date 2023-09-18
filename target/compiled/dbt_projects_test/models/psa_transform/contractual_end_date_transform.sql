/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



select 
PROJECT_UNIQUE_ID,
PROJECT_CODE, 
PROJECT,
PROJECT_STATE,
c.NAME as CLIENT_NAME, 
concat(U.USER_FIRST_NAME,' ',U.USER_LAST_NAME) as PROJECT_MANAGER,
DELIVERY_MANAGER,
DELIVERY_GEO,GEO,PROJECT_START,PROJECT_END,
PA_SCO_CUSTOMER_SIGNATURE_DATE,
PLANNED_END_DATE as contractual_end_date
from EIO_INGEST.ENGAGEMENT_TRANSFORM.project_list p 
left join EIO_INGEST.ENGAGEMENT_TRANSFORM.user_list u on p.PROJECT_MANAGER_UNIQUE_ID = u.USER_UNIQUE_ID
left join EIO_PUBLISH.TENROX_PRIVATE.TCLIENT c on p.CLIENT_UNIQUE_ID = c.UNIQUEID 
WHERE 
MASTER_AGREEMENT___PROJECT_TYPE in ('AS Child','AS Master','IS Child','IS Master','Master','Delivery Specialist','SCO-Non-Ratable','SCO-Ratable','N/A')
and PROJECT_STATE IN ('Active','Chg Order Review','At Risk','End Time Capture','Funnel',
                      'PA Review-Active','Closed','Completed','PA Review - Completion',
                      'SCO-Active','SCO-Closed','SCO-Completed','TECO')