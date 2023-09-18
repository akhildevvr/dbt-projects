
  create or replace   view EIO_INGEST.ENGAGEMENT_TRANSFORM.pac_full_expiry_schedule
  
   as (
    /*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with expiry_union as (
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_1 as expiration_date,PA_Agreement_Expiring_Credits_1  as credits, 1 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_2 as expiration_date,PA_Agreement_Expiring_Credits_2  as credits, 2 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_3 as expiration_date,PA_Agreement_Expiring_Credits_3  as credits, 3 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_4 as expiration_date,PA_Agreement_Expiring_Credits_4 as credits, 4 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_5 as expiration_date,PA_Agreement_Expiring_Credits_5  as credits, 5 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_6 as expiration_date,PA_Agreement_Expiring_Credits_6  as credits, 6 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_7 as expiration_date,PA_Agreement_Expiring_Credits_7  as credits, 7 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_8 as expiration_date,PA_Agreement_Expiring_Credits_8  as credits, 8 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_9 as expiration_date,PA_Agreement_Expiring_Credits_9  as credits, 9 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_10 as expiration_date,PA_Agreement_Expiring_Credits_10  as credits, 10 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_11 as expiration_date,PA_Agreement_Expiring_Credits_11  as credits, 11 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_12 as expiration_date,PA_Agreement_Expiring_Credits_12  as credits, 12 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_13 as expiration_date,PA_Agreement_Expiring_Credits_13  as credits, 13 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_14 as expiration_date,PA_Agreement_Expiring_Credits_14  as credits, 14 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_15 as expiration_date,PA_Agreement_Expiring_Credits_15  as credits, 15 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_16 as expiration_date,PA_Agreement_Expiring_Credits_16  as credits, 16 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_17 as expiration_date,PA_Agreement_Expiring_Credits_17  as credits, 17 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_18 as expiration_date,PA_Agreement_Expiring_Credits_18  as credits, 18 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_19 as expiration_date,PA_Agreement_Expiring_Credits_19  as credits, 19 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
  union all
  select PROJECT_UNIQUE_ID,PA_Agreement_Expiration_Date_20 as expiration_date,PA_Agreement_Expiring_Credits_20  as credits, 20 as seq from
  EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules
   
),
proj as (
select 
aa.Project_Unique_ID,
aa.PA_Agreement_Term_Start_Date,
aa.PA_Master___Total_Credits_Purchased as PA_MASTER_TOTAL_CREDITS_PURCHASED , 
eu.expiration_date,
eu.credits,eu.seq
from EIO_INGEST.ENGAGEMENT_TRANSFORM.active_agreement_expiry_schedules aa
left join expiry_union eu on aa.PROJECT_UNIQUE_ID = eu.PROJECT_UNIQUE_ID
),
start_date_df as (
select Project_Unique_ID, 
expiration_date,
seq + 1 as seq, 
dateadd(day, 1, expiration_date) as start_date 
from proj
  ),
   
proj_start_df as (
   
select p.Project_Unique_ID as project_id,
  p.PA_Agreement_Term_Start_Date,
  p.PA_MASTER_TOTAL_CREDITS_PURCHASED,
  p.expiration_date,
  p.credits,
  p.seq,
  case when p.seq = 1 then p.PA_AGREEMENT_TERM_START_DATE
        else sd.START_DATE end as start_date
  from proj p
  left join start_date_df sd on (p.Project_Unique_ID = sd.Project_Unique_ID and p.seq = sd.seq)
)
select *,
(datediff(day, expiration_date,
          PA_Agreement_Term_Start_Date) +1) as days_from_agreement_start ,
(datediff(day,expiration_date,
          start_date)+1) as days_from_term_start ,
credits/days_from_agreement_start as pac_dare_from_agreement_start,
credits/days_from_term_start as pac_rate_from_term_start
from proj_start_df
where PA_AGREEMENT_TERM_START_DATE is not null and PA_MASTER_TOTAL_CREDITS_PURCHASED is not null
  and start_date is not null and expiration_date is not null
  );

