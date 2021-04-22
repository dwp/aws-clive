#!/usr/bin/env bash

CORRELATION_ID="$2"
S3_PREFIX="$4"

# Set the ddb values as this is the initial step
echo "$CORRELATION_ID" >>     /opt/emr/correlation_id.txt
echo "$S3_PREFIX" >>          /opt/emr/s3_prefix.txt

hive -e "CREATE DATABASE IF NOT EXISTS ${clive_db} LOCATION '${published_bucket}/${hive_metastore_location}';"