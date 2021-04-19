#!/usr/bin/env bash

CLIVE_LOCATION=/opt/emr/dataworks-clive

chmod u+x $CLIVE_LOCATION/scripts/build_clive.sh

TARGET_DB=${target_db}
SERDE="${serde}"
INPUT_DATE=$(date '+%Y-%m-%d')
RAW_DIR="${data_path}"

#currently commented out as not fully ready to run
#/$CLIVE_LOCATION/scripts/build_clive.sh "$TARGET_DB" "$SERDE" "$INPUT_DATE" "$RAW_DIR"