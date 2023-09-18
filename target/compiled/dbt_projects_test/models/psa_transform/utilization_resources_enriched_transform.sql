/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



WITH utilization_resources as 
(
SELECT 
*
FROM
EIO_INGEST.ENGAGEMENT_TRANSFORM.utilization_resources
),

utilization_resources_enriched as (
    SELECT 
row_number,
user_id,
employee_id,
user_last_name,
user_first_name,
concat(user_last_name, ', ', user_first_name) as user_name,
email,master_site,
active_site,
title,
approval_group,
approval_group_manager,
functional_group,
case when LEFT(functional_group,10)='Functional'
              then SUBSTR(functional_group,12,30) end as functional_group_derived,
functional_group_manager,
holiday_set,
security_role,
user_type,
hire_date,
service_date,
termination_date,
forecasted_cost_rate,
forecasted_billing_rate,
user_is_active,
user_time_factor,
user_utilization_target,
current_rate_currency_code,
current_rate,
rate_effective_date,
was_new_table,
 concat (user_last_name,',',user_first_name) as Resource,
 IFF (holiday_set like '% %', TRIM(LEFT (holiday_set, POSITION( ' ' IN holiday_set ) )), holiday_set) as Region,
 IFF ( hire_date is NULL, NULL , ADD_MONTHS (hire_date, 3) ) as hire_date_90,
  IFF ( employee_id is NULL, user_id , employee_id ) as resource_id,
  IFF ( LEN(title) >1, title , user_first_name ) as Role,
 '2000-01-01' as byMonth_Default,
 IFF ( Functional_Group in ('Functional-Global Delivery Hub','Functional-Spacemaker','Functional-Sustainability'), 'Other Teams' , active_site ) as active_site_new
 
 FROM utilization_resources
)

SELECT 
row_number,
user_id,
employee_id,
user_last_name,
user_first_name,
email,master_site,
active_site,
title,
approval_group,
approval_group_manager,
functional_group,
functional_group_manager,
holiday_set,
security_role,
user_type,
hire_date,
service_date,
termination_date,
forecasted_cost_rate,
forecasted_billing_rate,
user_is_active,
user_time_factor,
user_utilization_target,
current_rate_currency_code,
current_rate,
rate_effective_date,
was_new_table,
Resource,
 CASE WHEN region='USA' THEN 'USA'
            WHEN region='CANADA' THEN 'Canada'
            WHEN region='MEXICO' THEN 'Mexico'
            WHEN region='GERMANY' THEN 'Central Europe'
            WHEN region='SWITZERLAND' THEN 'Central Europe'
            WHEN region='CZECH' THEN 'Central Europe'
            WHEN region='UK' THEN 'UK&I'
            WHEN region='UAE' THEN 'Middle East'
            WHEN region='QATAR' THEN 'Middle East'
            WHEN region='SWEDEN' THEN 'Nordics'
            WHEN region='NORWAY' THEN 'Nordics'
            WHEN region='DENMARK' THEN 'Benelux'
            WHEN region='NETHERLANDS' THEN 'Benelux'
            WHEN region='BELGIUM' THEN 'Benelux'
            WHEN region='SPAIN' THEN 'South Europe'
            WHEN region='FRANCE' THEN 'South Europe'
            WHEN region='ITALY' THEN 'South Europe'
            WHEN region='JAPAN' THEN 'Japan'
            WHEN region='AUSTRALIA' THEN 'ANZ'
            WHEN region='NEW' THEN 'ANZ'
            WHEN region='INDIA' THEN 'India'
            WHEN region='Hong' THEN 'Hong Kong'
            WHEN region='SINGAPORE' THEN 'Singapore'
            WHEN region='South' THEN 'South Korea'
            ELSE region END as region,
            hire_date_90,
            to_varchar(resource_id) as resource_id,
            Role,
            byMonth_Default,
            active_site_new

 FROM
 utilization_resources_enriched