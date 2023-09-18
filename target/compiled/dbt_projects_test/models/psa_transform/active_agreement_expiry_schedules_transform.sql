/*

    We can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml


*/



SELECT PROJECT_UNIQUE_ID,MASTER_AGREEMENT_NAME,PROJECT_STATE,
PA_AGREEMENT_EXPIRATION_DATE_1,PA_Agreement_Term_Start_Date,PA_Master___Total_Credits_Purchased,
	PA_AGREEMENT_EXPIRING_CREDITS_1,
	PA_AGREEMENT_EXPIRATION_DATE_2,
	PA_AGREEMENT_EXPIRING_CREDITS_2,
	PA_AGREEMENT_EXPIRATION_DATE_3,
	PA_AGREEMENT_EXPIRING_CREDITS_3,
	PA_AGREEMENT_EXPIRATION_DATE_4,
	PA_AGREEMENT_EXPIRING_CREDITS_4,
	PA_AGREEMENT_EXPIRATION_DATE_5,
	PA_AGREEMENT_EXPIRING_CREDITS_5,
	PA_AGREEMENT_EXPIRATION_DATE_6,
	PA_AGREEMENT_EXPIRING_CREDITS_6,
	PA_AGREEMENT_EXPIRATION_DATE_7,
	PA_AGREEMENT_EXPIRING_CREDITS_7,
	PA_AGREEMENT_EXPIRATION_DATE_8,
	PA_AGREEMENT_EXPIRING_CREDITS_8,
	PA_AGREEMENT_EXPIRATION_DATE_9,
	PA_AGREEMENT_EXPIRING_CREDITS_9,
    PA_AGREEMENT_EXPIRATION_DATE_10,
	PA_AGREEMENT_EXPIRING_CREDITS_10,
	PA_AGREEMENT_EXPIRATION_DATE_11,
	PA_AGREEMENT_EXPIRING_CREDITS_11,
	PA_AGREEMENT_EXPIRATION_DATE_12,
	PA_AGREEMENT_EXPIRING_CREDITS_12,
	PA_AGREEMENT_EXPIRATION_DATE_13,
	PA_AGREEMENT_EXPIRING_CREDITS_13,
	PA_AGREEMENT_EXPIRATION_DATE_14,
	PA_AGREEMENT_EXPIRING_CREDITS_14,
	PA_AGREEMENT_EXPIRATION_DATE_15,
	PA_AGREEMENT_EXPIRING_CREDITS_15,
	PA_AGREEMENT_EXPIRATION_DATE_16,
	PA_AGREEMENT_EXPIRING_CREDITS_16,
	PA_AGREEMENT_EXPIRATION_DATE_17,
	PA_AGREEMENT_EXPIRING_CREDITS_17,
	PA_AGREEMENT_EXPIRATION_DATE_18,
	PA_AGREEMENT_EXPIRING_CREDITS_18,
	PA_AGREEMENT_EXPIRATION_DATE_19,
	PA_AGREEMENT_EXPIRING_CREDITS_19,
	PA_AGREEMENT_EXPIRATION_DATE_20,
	PA_AGREEMENT_EXPIRING_CREDITS_20,
	PA_CHANGE_ORDER_CREDITS_1,
    PA_CHANGE_ORDER_DATE_1,
	PA_CHANGE_ORDER_CREDITS_2,
    PA_CHANGE_ORDER_DATE_2,
	PA_CHANGE_ORDER_CREDITS_3,
	PA_CHANGE_ORDER_DATE_3
    from EIO_INGEST.ENGAGEMENT_TRANSFORM.project_list
WHERE PROJECT_STATE IN ('Active','Chg Order Review','At Risk','End Time Capture','Funnel','PA Review-Active') 
and MASTER_AGREEMENT___PROJECT_TYPE in ('AS Child','AS Master','IS Child','IS Master','Master')