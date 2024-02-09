import snowflake.snowpark.functions as F

def add_one(x):
    return x + 1

def model(dbt, session):
    dbt.config(materialized="table")
    temps_df = dbt.ref("tflex_usage")

    # warm things up just a little
    df = temps_df
    return df