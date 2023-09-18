

select
  $1:account_uuid::string as account_uuid,
  $1:sfdc_opportunity_id::string as sfdc_opportunity_id
from 
    @__STAGE_TOKEN__
