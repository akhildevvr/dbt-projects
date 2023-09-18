/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/


with capacity_demand as
(
    SELECT
    *
    FROM
    EIO_INGEST.ENGAGEMENT_SHAREPOINT.CAPACITY_DEMAND_FC_PARAMETERS
)
SELECT
*
FROM
capacity_demand