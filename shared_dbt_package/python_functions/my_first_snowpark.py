from snowflake.snowpark.session import Session
from snowflake.snowpark.functions import udf, avg, col,lit,call_udf
from snowflake.snowpark.types import IntegerType, FloatType, StringType, BooleanType
import pandas as pd
from Numops import *



connection_parameters = {
  "account": "autodesk_stg.us-east-1",
  "user": "svc_aad_q_eio_snf",
  "password": "br3lgEIOSTG1!",
  "role": "EIO_INGEST_GROUP",
  "warehouse": "EIO_INGEST",
  "database": "EIO_INGEST",
  "schema": "engagement_transform"
}

session = Session.builder.configs(connection_parameters).create()
print(session.sql("select current_warehouse(), current_database(), current_schema()").collect())


# mod5() in that file has type hints
'''add_one = session.udf.register_from_file(
    file_path="/Users/ravinda/Documents/my_astro_projects/shared_dbt_projects/models/transform/my_python_model.py",
    func_name="add_one",
    return_type=IntegerType()
) 
session.range(1, 8, 2).select(add_one("id")).to_df("col1").collect()  '''


#session.sql("create or replace stage pythonudfstage").collect()
#session.sql("create or replace stage pythonsourcestage").collect()
print(session.sql('list @pythonudfstage').collect())

@udf(name="add_num",is_permanent=True,stage_location="@pythonudfstage",replace=True,imports=[("/Users/ravinda/Documents/my_astro_projects/utils/Numops.py", "utils/Numops")])
def lookup_function(col1:float,col2:float)->float:
    return AddNums(col1,col2)
#session.file.put("/Users/ravinda/Documents/my_astro_projects/utils/Numops.py", "@pythonsourcestage", auto_compress=False,overwrite=True)
df = session.create_dataframe([[10,20],[30,40],[60,70]], schema=["Col1","Col2"])

df.select(df.Col1,df.Col2,call_udf("add_num",df.col1,df.col2).alias("SumofValues")).show()