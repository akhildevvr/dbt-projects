
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.pac_expiry_schedule_by_qtr
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with pac_full_expiry_schedule as 
(
  SELECT
  *
  FROM
  EIO_INGEST.ENGAGEMENT_TRANSFORM.pac_full_expiry_schedule

),
ids as (select distinct project_id from pac_full_expiry_schedule),
proj_limited_prev_qtr as (select project_id, sum(credits) as pac_expire_prev_qtr from pac_full_expiry_schedule pl
                where expiration_date <= (select max(case when PREVIOUS_QRTR_FLAG =1 then dt end) as previous_quarter_dt from  ADP_PUBLISH.CUSTOMER_SUCCESS_OPTIMIZED.DATE_INFO )
                group by
                project_id
                ),
proj_limited_cur_qtr as (select project_id, sum(credits) as pac_expire_cur_qtr from pac_full_expiry_schedule
                where expiration_date <= (select max(case when CURRENT_QRTR_FLAG = 1 then dt end) as current_quarter_dt from  ADP_PUBLISH.CUSTOMER_SUCCESS_OPTIMIZED.DATE_INFO )
                group by
                project_id),
proj_limited_next_qtr as (select project_id, sum(credits) as pac_expire_nxt_qtr from pac_full_expiry_schedule
                where expiration_date <= (select max(case when NEXT_QRTR_VALUE_FLAG = 1 then dt end) as next_quarter_dt from ADP_PUBLISH.CUSTOMER_SUCCESS_OPTIMIZED.DATE_INFO )
                group by
                project_id),
proj_limited_next_qtr1 as (select project_id, sum(credits) as pac_expire_nxt1_qtr from pac_full_expiry_schedule
                where expiration_date <= (select max(case when NEXT_QRTR_PLUS_1_FLAG = 1 then dt end) as next_quarter1_dt from ADP_PUBLISH.CUSTOMER_SUCCESS_OPTIMIZED.DATE_INFO )
                group by
                project_id),
proj_limited_next_qtr2 as (select project_id, sum(credits) as pac_expire_nxt2_qtr from pac_full_expiry_schedule
                where expiration_date <= (select max(case when NEXT_QRTR_PLUS_2_FLAG = 1 then dt end) as next_quarter2_dt from ADP_PUBLISH.CUSTOMER_SUCCESS_OPTIMIZED.DATE_INFO )
                group by
                project_id),
proj_limited_next_days as (select project_id, sum(credits) as pac_expire_nxt_days from pac_full_expiry_schedule
                where expiration_date <= (select dateadd(day,180,current_date()) as next_180_days_dt )
                group by
                project_id),
expiry_schedule_by_qtr as (
select
try_to_number(replace(i.project_id,',')) as project_id, 
ppq.pac_expire_prev_qtr,
pcq.pac_expire_cur_qtr, 
pnq.pac_expire_nxt_qtr, 
pn1q.pac_expire_nxt1_qtr, 
pn2q.pac_expire_nxt2_qtr, 
pnd.pac_expire_nxt_days
from ids i 
left join proj_limited_prev_qtr ppq 
  on i.project_id = ppq.project_id
left join proj_limited_cur_qtr pcq 
  on i.project_id = pcq.project_id
left join proj_limited_next_qtr pnq 
  on i.project_id = pnq.project_id
left join proj_limited_next_qtr1 pn1q 
  on i.project_id = pn1q.project_id
left join proj_limited_next_qtr2 pn2q 
  on i.project_id = pn2q.project_id
left join proj_limited_next_days pnd 
  on i.project_id = pnd.project_id
)
SELECT
*
FROM
expiry_schedule_by_qtr
  );

