#!/bin/bash

(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_aws_clive_message "$${1}" "config_hcs.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    log_wrapper_message "Getting tags..."
    ec2-get-tag () {
        if [ -z $1 ]; then
            scriptName=`basename "$0"`
            echo  >&2 "Usage: $scriptName <tag_name>"
            exit 1
        fi

        # check that aws and ec2-metadata commands are installed
        command -v $(which aws) >/dev/null 2>&1 || { echo >&2 'aws command not installed.'; exit 2; }
        command -v ec2-metadata >/dev/null 2>&1 || { echo >&2 'ec2-metadata command not installed.'; exit 3; }

        # set filter parameters
        instanceId=$(ec2-metadata -i | cut -d ' ' -f2)
        filterParams=( --filters "Name=key,Values=$1" "Name=resource-type,Values=instance" "Name=resource-id,Values=$instanceId" )

        # get region
        region=$(ec2-metadata --availability-zone | cut -d ' ' -f2)
        region=${region%?}

        # retrieve tags
        tagValues=$($(which aws) ec2 describe-tags --output text --region "$region" "${filterParams[@]}")
        if [ $? -ne 0 ]; then
            echo >&2 "Error retrieving tag value."
            exit 4
        fi

        # extract required tag value
        tagValue=$(echo "$tagValues" | cut -f5)
        echo "$tagValue"
        }

    export TECHNICALSERVICE=$(ec2-get-tag Application)
    export ENVIRONMENT=$(ec2-get-tag Environment)

    echo $TECHNICALSERVICE
    echo $ENVIRONMENT

    log_wrapper_message "Exporting proxy"

    if [[ "$ENVIRONMENT" == "Dev" || "$ENVIRONMENT" == "DT_Tooling" ]]; then
        export PROXY="egress.nonprod.dwpcloud.uk"
      else
        export PROXY="egress.service.dwpcloud.uk"
    fi

    log_wrapper_message "Configuring tenable agent"

    /opt/nessus_agent/sbin/nessuscli agent link --key=$TENABLE_LINKING_KEY \ 
      --cloud --groups=$TECHNICALSERVICE_$ENVIRONMENT,TVAT \ 
      --proxy-host=$PROXY --proxy-port=3128

)   >> /var/log/aws-clive/config_hcs.log 2>&1