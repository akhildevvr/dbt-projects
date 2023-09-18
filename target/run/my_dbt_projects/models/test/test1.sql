
  create or replace   view EIO_INGEST.TENROX_TRANSFORM.test1
  
   as (
    SELECT * FROM 
(
WITH JOINED_DATA as (
    SELECT 
    UNIQUEID AS PROJECT_ID
    FROM 
    EIO_PUBLISH.TENROX_PRIVATE.TPROJECT
)
SELECT 
*
FROM JOINED_DATA
) AS TPROJECT
join 
EIO_PUBLISH.TENROX_PRIVATE.TTASK AS TTASK

    ON TTASK.PROJECTID = TPROJECT.PROJECT_ID
  );

