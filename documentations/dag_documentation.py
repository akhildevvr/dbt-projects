## Airflow dependencies
from airflow import DAG
from airflow.models import Variable
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
import boto3

#Common python libraries
from datetime import datetime, timedelta
import json
import logging
import inspect

#ADP specific low code dag integration libraries
from low_code_dags.operators.dbt import DbtOperator

#Common utilities and scripts
from common.scripts.utilities import *
from dags.common.scripts.service_now import *


# Load variables from Airflow
var_airflow_env = Variable.get("env")
var_airflow_support_notification_email = Variable.get("support_notification_email")
var_airflow_dag_owner = Variable.get("dag_owner")
var_dbt_docs_s3 = Variable.get("dbt_docs_s3")

## calculated variables
var_snowflake_conn_id="eio_snowflake_conn"
var_target_variables="""'{{"env" : {0}}}'""".format(var_airflow_env)

# Defining success & failure callback functions
def success_callback(context):
    success_email(context, var_airflow_support_notification_email)


def failure_callback(context):
    failure_email(context, var_airflow_support_notification_email)

def py_load_to_s3(**kwargs):
    client = boto3.client('s3')

    local_directory = kwargs['local_directory']
    destination_path = kwargs['destination_path']
    bucket = var_dbt_docs_s3
    # Test is DBT target directory is present
    l_files = os.listdir("/home/astro/documentations/target")
    print ("lfiles {0}".format (l_files))


    try:
        # enumerate local files recursively
        for root, _, files in os.walk(local_directory):
            #print(root, _, files)
            for filename in files:
                # construct the full local path
                local_path = os.path.join(root, filename)
                if destination_path is None:
                # construct the full S3 path
                    relative_path = os.path.relpath(local_path, local_directory)
                else :
                    relative_path = "{0}/{1}".format(destination_path,filename)

                if  "css" in filename :
                    client.upload_file(local_path, bucket, relative_path, ExtraArgs={'ContentType': "text/css"} )
                if  "html" in filename :
                    client.upload_file(local_path, bucket, relative_path, ExtraArgs={'ContentType': "text/html"} )
                if  "svg" in filename :
                    client.upload_file(local_path, bucket, relative_path, ExtraArgs={'ContentType': "image/svg+xml"} )
                if  "png" in filename :
                    client.upload_file(local_path, bucket, relative_path, ExtraArgs={'ContentType': "image/svg+xml"} )
                if  "xml" in filename :
                    client.upload_file(local_path, bucket, relative_path, ExtraArgs={'ContentType': "text/xml"} )
                if  "json" in filename :
                    client.upload_file(local_path, bucket, relative_path, ExtraArgs={'ContentType': "text/json"} )
                if  ".gz" in filename or ".js" in filename or ".map" in filename or ".png" in filename  :
                    client.upload_file(local_path, bucket, relative_path )


                #logging.info(f"Uploaded file: {filename} from {local_path}")
    except Exception as e:
        print('%s:%s:%s',
                 inspect.stack()[0][3],
                 type(e),
                 e)
        print ("Exception is {0}".format (e))


## Default DAG properties
default_args = {
    'owner': var_airflow_dag_owner,
    'depends_on_past': False,
    'on_failure_callback': failure_callback,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

# Project Path
model_path = "dags/dbt/documentations"

with DAG(
    dag_id='documentation',
    start_date=datetime(2023, 3, 24),
    max_active_runs=3,
    schedule_interval='0 */8 * * *',
    default_args=default_args,
    catchup=False,
) as dag:

    start = DummyOperator(task_id="start")


    # 1. Generate dbt docs for the models in packages.yml
    task1 = DbtOperator(
            task_id = 'generate_dbt_docs',
            path = model_path,
            conn_id = var_snowflake_conn_id,
            dbt_command = "docs generate",
            dbt_args=["--vars", var_target_variables],
            dag = dag
        )

    # 2. Load the generated EDA docs to
    task2 = PythonOperator(
        task_id='load_s3_eio_doc',
        python_callable=py_load_to_s3,
        op_kwargs={'local_directory': '/home/astro/documentations/eio_documentation_site', 'destination_path': None},
        retries=10,
        dag=dag
    )

    # 3. Load the generated dbt docs to
    task3 = PythonOperator(
        task_id='load_s3_dbt_doc',
        python_callable=py_load_to_s3,
        op_kwargs={'local_directory': '/home/astro/documentations/target', 'destination_path': 'reference/code_docs'},
        retries=10,
        dag=dag
    )

    end = DummyOperator(task_id="end", on_success_callback=success_callback)

# Define workflow

start >> task1 >> task2 >> task3 >> end

