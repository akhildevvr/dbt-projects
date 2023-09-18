/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with utilization_geo_targets as
(
    SELECT
    *
    FROM
    EIO_INGEST.ENGAGEMENT_SHAREPOINT.UTILIZATION_GEO_TARGETS_TARGETS
)
SELECT
*
FROM
utilization_geo_targets