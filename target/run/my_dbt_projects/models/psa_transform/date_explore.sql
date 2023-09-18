
  
    

        create or replace transient table EIO_INGEST.ENGAGEMENT_TRANSFORM.date_explore  as
        (/*

Calculating calender weeks
Total number of weeks to generate dates for - 57


*/



SELECT DATEADD(WEEK, SEQ4(), date_trunc('month', current_date())) AS DT
  FROM TABLE(GENERATOR(ROWCOUNT => 57 ))
        );
      
  