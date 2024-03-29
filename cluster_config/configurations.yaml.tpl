---
Configurations:
- Classification: "yarn-site"
  Properties:
    "yarn.log-aggregation-enable": "true"
    "yarn.nodemanager.remote-app-log-dir": "s3://${s3_log_bucket}/${s3_log_prefix}/yarn"
    "yarn.nodemanager.vmem-check-enabled": "false"
    "yarn.nodemanager.pmem-check-enabled": "false"
    "yarn.acl.enable": "true"
    "yarn.resourcemanager.scheduler.monitor.enable": "true"
    "yarn.resourcemanager.scheduler.class": "org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler"

- Classification: "capacity-scheduler"
  Properties:
    "yarn.scheduler.capacity.root.queues": "default,appqueue,mrqueue"
    "yarn.scheduler.capacity.maximum-am-resource-percent": "0.9"
    "yarn.scheduler.capacity.resource-calculator": "org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"
    "yarn.scheduler.capacity.root.default.capacity": "5"
    "yarn.scheduler.capacity.root.default.maximum-capacity": "10"
    "yarn.scheduler.capacity.root.default.acl_submit_applications": ""
    "yarn.scheduler.capacity.root.appqueue.capacity": "25"
    "yarn.scheduler.capacity.root.appqueue.acl_submit_applications": "*"
    "yarn.scheduler.capacity.root.appqueue.maximum-capacity": "90"
    "yarn.scheduler.capacity.root.appqueue.state": "RUNNING"
    "yarn.scheduler.capacity.root.appqueue.ordering-policy": "fair"
    "yarn.scheduler.capacity.root.appqueue.ordering-policy.fair.enable-size-based-weight": "true"
    "yarn.scheduler.capacity.root.appqueue.default-application-priority": "1"
    "yarn.scheduler.capacity.root.mrqueue.ordering-policy.fair.enable-size-based-weight": "true"
    "yarn.scheduler.capacity.root.mrqueue.capacity": "70"
    "yarn.scheduler.capacity.root.mrqueue.acl_submit_applications": "*"
    "yarn.scheduler.capacity.root.mrqueue.maximum-capacity": "90"
    "yarn.scheduler.capacity.root.mrqueue.state": "RUNNING"
    "yarn.scheduler.capacity.root.mrqueue.ordering-policy": "fair"
    "yarn.scheduler.capacity.root.mrqueue.ordering-policy.fair.enable-size-based-weight": "true"
    "yarn.scheduler.capacity.root.mrqueue.default-application-priority": "2"

- Classification: "hive-site"
  Properties:
    "hive.metastore.warehouse.dir": "s3://${s3_published_bucket}/${hive_metastore_location}"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "hive.enforce.bucketing": "true"
    "hive.exec.dynamic.partition.mode": "nostrict"
    "hive.compactor.initiator.on": "true"
    "hive.compactor.worker.threads": "1"
    "hive.support.concurrency": "true"
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}?createDatabaseIfNotExist=true"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionUserName": "${hive_metsatore_username}"
    "javax.jdo.option.ConnectionPassword": "${hive_metastore_pwd}"
    "hive.metastore.client.socket.timeout": "7200"
    "hive.mapred.mode": "nonstrict"
    "hive.strict.checks.cartesian.product": "false"
    "hive.exec.parallel": "true"
    "hive.exec.parallel.thread.number": "128"
    "hive.exec.failure.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.post.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.pre.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.vectorized.execution.enabled": "false"
    "hive.vectorized.execution.reduce.enabled": "false"
    "hive.vectorized.complex.types.enabled": "false"
    "hive.vectorized.use.row.serde.deserialize": "false"
    "hive.vectorized.execution.ptf.enabled": "false"
    "hive.vectorized.row.serde.inputformat.excludes": ""
    "hive_timeline_logging_enabled": "true"
    "mapred.job.queue.name": "mrqueue"
    "mapreduce.job.queuename": "mrqueue"
    "hive.server2.tez.default.queues": "appqueue"
    "hive.server2.tez.sessions.per.default.queue": "${hive_tez_sessions_per_queue}"
    "hive.server2.tez.initialize.default.sessions": "true"
    "hive.blobstore.optimizations.enabled": "true"
    "hive.blobstore.use.blobstore.as.scratchdir": "false"
    "hive.exec.input.listing.max.threads": "2"
    "hive.prewarm.enabled": "true"
    "hive.tez.container.size": "${hive_tez_container_size}"
    "hive.tez.java.opts": "${hive_tez_java_opts}"
    "hive.auto.convert.join": "true"
    "hive.auto.convert.join.noconditionaltask.size": "${hive_auto_convert_join_noconditionaltask_size}"
    "hive.server2.tez.session.lifetime": "0"
    "hive.server2.async.exec.threads": "1000"
    "hive.server2.async.exec.wait.queue.size": "1000"
    "hive.server2.async.exec.keepalive.time": "60"
    "hive.tez.min.partition.factor": "0.25"
    "hive.tez.max.partition.factor": "2.0"
    "hive.exec.reducers.max": "${hive_max_reducers}"
    "hive.default.fileformat": "ORC"
    "hive.exec.orc.default.compress": "ZLIB"
    "hive.exec.orc.default.block.size": "268435456"
    "hive.exec.orc.encoding.strategy": "SPEED"
    "hive.exec.orc.split.strategy": "HYBRID"
    "hive.exec.orc.default.row.index.stride": "10000"
    "hive.exec.orc.default.stripe.size": "268435456"
    "hive.exec.orc.compression.strategy": "SPEED"

- Classification: "mapred-site"
  Properties:
    "mapred.job.queue.name": "mrqueue"
    "mapreduce.job.queuename": "mrqueue"
    "mapred.reduce.tasks": "-1"

- Classification: "tez-site"
  Properties:
    "tez.grouping.min-size": "${tez_grouping_min_size}"
    "tez.grouping.max-size": "${tez_grouping_max_size}"
    "tez.am.resource.memory.mb": "${tez_am_resource_memory_mb}"
    "tez.am.launch.cmd-opts": "${tez_am_launch_cmd_opts}"
    "tez.am.container.reuse.enabled": "true"

- Classification: "emrfs-site"
  Properties:
    "fs.s3.maxConnections": "10000"
    "fs.s3.maxRetries": "20"

- Classification: "hadoop-env"
  Configurations:
  - Classification: "export"
    Properties:
      "HADOOP_NAMENODE_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7101:/opt/emr/metrics/prometheus_config.yml\""
      "HADOOP_DATANODE_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7103:/opt/emr/metrics/prometheus_config.yml\""
      "HADOOP_HEAPSIZE": "2048"
- Classification: "yarn-env"
  Configurations:
  - Classification: "export"
    Properties:
      "YARN_RESOURCEMANAGER_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7105:/opt/emr/metrics/prometheus_config.yml\""
      "YARN_NODEMANAGER_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7107:/opt/emr/metrics/prometheus_config.yml\""
