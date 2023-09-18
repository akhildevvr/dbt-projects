/*

Calculating demand SFDC 


*/

SELECT service_engagement_id, name,
                  stage_name, sub_stage_name,
                  close_date, contract_type,
                  delivery_geo, delivery_language, service_line,
                  service_type, primary_product_name, total_hours,
                  production_assurance_credits_pac,
                  total_amount, estimated_total_hours,
                  delivery_month,
                  sum(forecasted_hours_week) as hours
FROM

(
SELECT service_engagement_id,
             name,
             stage_name,
             sub_stage_name,
             close_date,
             contract_type,
             delivery_geo,
             delivery_language,
             service_line,
             service_type,
             primary_product_name,
             hours,
             production_assurance_credits_pac,
             total_amount,
             estimated_total_hours,
             data.bucket,
             wk,
             data.project_week,
round(pc_hours_forecast * estimated_total_hours, 1) as  forecasted_hours_week,
date_trunc('month', wk) AS delivery_month,
hours as total_hours

FROM

(
SELECT     sed.service_engagement_id,
             name,
             stage_name,
             sub_stage_name,
             close_date,
             contract_type,
             delivery_geo,
             delivery_language,
             service_line,
             service_type,
             primary_product_name,
             hours,
             production_assurance_credits_pac,
             total_amount,
             estimated_total_hours,
             bucket,
             wk,
             round(DATEDIFF(day, close_date, wk) / 7 ) as project_week


FROM


(   SELECT

    service_engagement_id,
             name,
             stage_name,
             sub_stage_name,
             close_date,
             contract_type,
             delivery_geo,
             delivery_language,
             service_line,
             service_type,
             primary_product_name,
             hours,
             production_assurance_credits_pac,
             total_amount,
    CASE WHEN hours > 0 THEN hours
         WHEN production_assurance_credits_pac > 0 THEN (production_assurance_credits_pac * 8 / 2.79)
         WHEN total_amount > 0 THEN (total_amount / (2200 / 8))
         ELSE 160.0 END as estimated_total_hours,

    CASE WHEN estimated_total_hours between 0 and 60 THEN '(0,60]'
         WHEN  estimated_total_hours between 60 and 100 THEN '(60,100]'
         WHEN  estimated_total_hours between 100 and 150 THEN '(100,150]'
         WHEN  estimated_total_hours between 150 and 200 THEN '(150,200]'
         WHEN  estimated_total_hours between 200 and 300 THEN '(200,300]'
         ELSE '(300,Inf]' END as bucket

    FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.service_engagement_details  ) sed

    JOIN
(
SELECT se.service_engagement_id,de.DT as wk FROM (SELECT DISTINCT service_engagement_id FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.service_engagement_details ) se
CROSS JOIN
(SELECT DT FROM EIO_INGEST.ENGAGEMENT_TRANSFORM.date_explore )  de
ORDER BY se.service_engagement_id,de.DT
) wk_u

ON (sed.service_engagement_id=wk_u.service_engagement_id)

) data
JOIN

EIO_INGEST.ENGAGEMENT_SHAREPOINT.CAPACITY_DEMAND_FC_PARAMETERS cdp

ON (cdp.bucket=data.bucket AND cdp.project_week=data.project_week )

)

WHERE forecasted_hours_week > 0
GROUP BY

service_engagement_id, name,
                  stage_name, sub_stage_name,
                  close_date, contract_type,
                  delivery_geo, delivery_language, service_line,
                  service_type, primary_product_name, total_hours,
                  production_assurance_credits_pac,
                  total_amount, estimated_total_hours,
                  delivery_month
ORDER BY
service_engagement_id,delivery_month