#!/usr/bin/env bash

hive -e "CREATE DATABASE IF NOT EXISTS ${clive_db} LOCATION '${published_bucket}/${hive_metastore_location}';"