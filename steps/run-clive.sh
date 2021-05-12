#!/usr/bin/env bash
set -Eeuo pipefail

(
    # Import the logging functions
    source /opt/emr/logging.sh

    source /var/ci/resume_step.sh

    function log_wrapper_message() {
        log_aws_clive_message "$${1}" "run-clive.sh" "Running as: ,$USER"
    }

    CLIVE_LOCATION="${clive_scripts_location}" 

    chmod u+x "$CLIVE_LOCATION"/scripts/build_clive.sh

    S3_PREFIX_FILE=/opt/emr/s3_prefix.txt
    S3_PREFIX=$(cat $S3_PREFIX_FILE)

    PUBLISHED_BUCKET="${published_bucket}"
    TARGET_DB=${target_db}
    SERDE="${serde}"
    RAW_DIR="$PUBLISHED_BUCKET"/"$S3_PREFIX"
    RETRY_SCRIPT=/var/ci/with_retry.sh
    PROCESSES="${clive_processes}"

    log_wrapper_message "Set the following. published_bucket: $PUBLISHED_BUCKET, target_db: $TARGET_DB, serde: $SERDE, raw_dir: $RAW_DIR, Retry_script: $RETRY_SCRIPT, processes: $PROCESSES, clive_dir: $CLIVE_LOCATION"

    log_wrapper_message "Starting Clive job"

    "$CLIVE_LOCATION"/scripts/build_clive_parallel.sh "$TARGET_DB" "$SERDE" "$RAW_DIR" "$RETRY_SCRIPT" "$PROCESSES" "$CLIVE_LOCATION/sql"

    log_wrapper_message "Finished Clive job"

) >> /var/log/aws-clive/run-clive.log 2>&1
