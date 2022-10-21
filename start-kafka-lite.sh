#!/bin/bash

cat > ./kafka.properties <<EOL
broker.id=1
listeners=PLAINTEXT://:$KAFKA_PORT
zookeeper.connect=localhost:$ZOOKEEPER_PORT
log.dirs=$KAFKA_LOGS_DIR
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
EOL

cat > ./zookeeper.properties <<EOL
dataDir=/tmp/zookeeper
clientPort=$ZOOKEEPER_PORT
maxClientCnxns=0
admin.enableServer=false
EOL

exec supervisord --nodaemon --configuration /etc/supervisord.conf
