/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



WITH TUSER AS (
    SELECT 
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TUSER
),

TUSERPERSONAL  AS (
    SELECT
    *
    FROM
     EIO_PUBLISH.TENROX_PRIVATE.TUSERPERSONAL
),
TUSERPLANNINGROLE AS (
    SELECT
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TUSERPLANNINGROLE
),
TPLANNINGROLE AS (
    SELECT
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TPLANNINGROLE
),

TTITLE AS (
    SELECT
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TTITLE
),
TGROUP AS (
    SELECT
    *
    FROM
    EIO_PUBLISH.TENROX_PRIVATE.TGROUP
)

 SELECT        u.UNIQUEID AS User_Unique_ID,
       u.ACCCONSETID AS Company_Unique_ID,
                         CONCAT(u.LASTNAME, ', ', u.FIRSTNAME) AS User_Name,
       u.FIRSTNAME AS User_First_Name,
       u.LASTNAME AS User_Last_Name,
       u.LOGINNAME AS User_Logon_Name,
                         COALESCE(TRY_CAST(u.ID AS STRING), '') AS User_ID,
       COALESCE(u.EMAILADDRESS, '') AS User_Email,
       t.NAME AS User_Title,
       CASE WHEN u.USERACCESSSTATUS = 1 THEN 1 ELSE 0 END AS User_Is_Active,
                         CASE WHEN u.USERACCESSSTATUS = 2 THEN 1 ELSE 0 END AS User_Is_Suspended,
       CASE WHEN u.USERACCESSSTATUS = 4 THEN 1 ELSE 0 END AS User_Is_Decommissioned,
                         CASE WHEN up.GENDER = 1 THEN 'Male' ELSE 'Female' END AS User_Gender,

                         u.DATEHIRED AS User_Hire_Date,

       pr.NAME AS User_Primary_Role,
        
       G.NAME AS USER_RESOURCE_GROUP


FROM           TUSER u  INNER JOIN
                        TUSERPERSONAL up  ON u.UNIQUEID = up.USERID INNER JOIN
                        TUSERPLANNINGROLE upl  ON upl.USERID = u.UNIQUEID AND upl.ISPRIMARYROLE = 1 INNER JOIN
                        TPLANNINGROLE pr  ON pr.UNIQUEID = upl.PLANNINGROLEID INNER JOIN
                        TTITLE t  ON u.TITLEID = t.UNIQUEID LEFT JOIN 
                         TGROUP G ON G.UNIQUEID = U.RESGROUPID


WHERE        (u.USERACCESSSTATUS BETWEEN 1 AND 4)