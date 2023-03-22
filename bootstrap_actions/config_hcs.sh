#!/usr/bin/env bash

(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_aws_clive_message "$${1}" "config_hcs.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    log_wrapper_message "Populate tags..."

    export TECHNICALSERVICE="DataWorks"
    export ENVIRONMENT=$(environment)

    echo $TECHNICALSERVICE
    echo $ENVIRONMENT

    log_wrapper_message "Exporting proxy"

    if [[ "$ENVIRONMENT" == "Dev" || "$ENVIRONMENT" == "DT_Tooling" ]]; then
        export PROXY="egress.nonprod.dwpcloud.uk"
      else
        export PROXY="egress.service.dwpcloud.uk"
    fi

    log_wrapper_message "Configuring tenable agent"

    sudo /opt/nessus_agent/sbin/nessuscli agent link --key=$TENABLE_LINKING_KEY --cloud --groups=$TECHNICALSERVICE_$ENVIRONMENT,TVAT --proxy-host=$PROXY --proxy-port=3128

)   >> /var/log/aws-clive/config_hcs.log 2>&1