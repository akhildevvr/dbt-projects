/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with 
as_is_tenrox_parent_projects as 
(
SELECT
*
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.as_is_tenrox_parent_projects
),
as_is_ma_hours_breakdown as 
(
SELECT
*
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.asis_ma_hours_breakdown
),

consultant_pm_hours as (
SELECT 
TNRX_PRNT.PARENT_CHILD_KEY, 
DIV0(SUM(ASIMA.CONSULTANT_TIME), AVG(round(MONTHS_BETWEEN(ASIMA.CONTRACT_END_DATE, ASIMA.CONTRACT_START_DATE))))
AS Consultant_Hrs_Budget,
DIV0(Consultant_Hrs_Budget, 8) AS Consultant_Days_Budget,
DIV0(SUM(ASIMA.PM_TIME), AVG(round(MONTHS_BETWEEN(ASIMA.CONTRACT_END_DATE, ASIMA.CONTRACT_START_DATE))))
AS PM_Hrs_Budget,
COUNT(TNRX_PRNT.parent_child_key) AS Error
FROM 
as_is_tenrox_parent_projects AS TNRX_PRNT
LEFT JOIN  as_is_ma_hours_breakdown AS ASIMA
 ON TNRX_PRNT.PROJECT_CODE = ASIMA.PROJECT_CODE
GROUP BY TNRX_PRNT.PARENT_CHILD_KEY
)

SELECT
 asisp.*, 
cph.Consultant_Hrs_Budget ,
cph.Consultant_Days_Budget,
cph.PM_Hrs_Budget,cph.error 
FROM 
as_is_tenrox_parent_projects asisp 
LEFT JOIN consultant_pm_hours cph 
 ON asisp.PARENT_CHILD_KEY = cph.PARENT_CHILD_KEY