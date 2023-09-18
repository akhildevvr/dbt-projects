/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



with generic_resources_id as
(
    SELECT
    *
    FROM
    EIO_INGEST.ENGAGEMENT_SHAREPOINT.GENERIC_RESOURCES_ID_SHEET_1
)
SELECT
*
FROM
generic_resources_id