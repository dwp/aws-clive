#!/usr/bin/env bash

CLIVE_LOCATION=/opt/emr/dataworks-clive

chmod u+x $CLIVE_LOCATION/scripts/build_clive.sh

S3_PREFIX_FILE=/opt/emr/s3_prefix.txt
S3_PREFIX=$(cat $S3_PREFIX_FILE)

PUBLISHED_BUCKET="${published_bucket}"
TARGET_DB=${target_db}
SERDE="${serde}"
RAW_DIR="$PUBLISHED_BUCKET"/"$S3_PREFIX"

echo "$TARGET_DB" "$SERDE" "$RAW_DIR"
#/$CLIVE_LOCATION/scripts/build_clive.sh "$TARGET_DB" "$SERDE" "$RAW_DIR"