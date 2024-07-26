import functions_framework
from google.cloud import bigquery
from google.cloud import storage
from google.cloud.bigquery import LoadJobConfig
import time

# Triggered by a change in a storage bucket
@functions_framework.cloud_event
def hello_gcs(cloud_event):
    data = cloud_event.data

    event_id = cloud_event["id"]
    event_type = cloud_event["type"]

    bucket = data["bucket"]
    filename = data["name"]
    metageneration = data["metageneration"]
    timeCreated = data["timeCreated"]
    updated = data["updated"]

    print(f"Event ID: {event_id}")
    print(f"Event type: {event_type}")
    print(f"Bucket: {bucket}")
    print(f"File: {filename}")
    print(f"Metageneration: {metageneration}")
    print(f"Created: {timeCreated}")
    print(f"Updated: {updated}")
    
    load_bq(filename)

#TODO change variables to your names
dataset = 'housing_in_poland'
table = 'apartment_sales'
bucket = 'gcs_housing_in_poland'

def load_bq(filename):
    client = bigquery.Client()
    filename = filename
    table_ref = client.dataset(dataset).table(table)
    job_config = LoadJobConfig()
    job_config.source_format = bigquery.SourceFormat.CSV
    job_config.skip_leading_rows = 1
    job_config.autodetect = True
    uri = f'gs://{bucket}/{filename}'
    load_job = client.load_table_from_uri(uri, table_ref, job_config=job_config)
    load_job.result()  
    time.sleep(10)
    num_rows = load_job.output_rows
    print(f"{num_rows} rows loaded into {table}.")

    archive_csv(filename)


def archive_csv(filename):
    storage_client = storage.Client()

    source_bucket = storage_client.bucket(bucket)
    source_blob = source_bucket.blob(filename)
    destination_bucket = storage_client.bucket(bucket)
    destination_blob_name = f"archived/{filename}"

    blob_copy = source_bucket.copy_blob(
        source_blob, destination_bucket, destination_blob_name
    )
    source_bucket.delete_blob(filename)

    print(
        "Blob {} in bucket {} moved to blob {} in bucket {}.".format(
            source_blob.name,
            source_bucket.name,
            blob_copy.name,
            destination_bucket.name,
        )
    )