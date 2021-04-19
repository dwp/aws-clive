#!/bin/bash
(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_aws_clive_message "$${1}" "download_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    SCRIPT_DIR=/opt/emr/clive

    echo "Download & install latest dataworks-clive scripts"
    log_wrapper_message "Downloading & install latest dataworks-clive scripts"

    VERSION="${version}"
    URL="s3://${s3_artefact_bucket_id}/dataworks-clive/dataworks-clive-$VERSION.zip"
    "$(which aws)" s3 cp "$URL" /opt/emr/sql

    echo "dataworks-clive_VERSION: $VERSION"
    log_wrapper_message "dataworks-clive_version: $VERSION"

    echo "SCRIPT_DOWNLOAD_URL: $URL"
    log_wrapper_message "script_download_url: $URL"

    echo "Unzipping location: $SCRIPT_DIR"
    log_wrapper_message "script unzip location: $SCRIPT_DIR"

    echo "$version" > /opt/emr/version
    echo "${aws_clive_log_level}" > /opt/emr/log_level
    echo "${environment_name}" > /opt/emr/environment

    echo "START_UNZIPPING ......................"
    log_wrapper_message "start unzipping ......................."

    unzip /opt/emr/sql/dataworks-clive-"$VERSION".zip -d $SCRIPT_DIR  >> /var/log/aws-clive/download_unzip_sql.log 2>&1

    echo "FINISHED UNZIPPING ......................"
    log_wrapper_message "finished unzipping ......................."

)  >> /var/log/aws-clive/download_sql.log 2>&1