#!/bin/bash

cat > ./kafka.properties <<EOL
broker.id=1
listeners=PLAINTEXT://:$KAFKA_PORT
zookeeper.connect=localhost:$ZOOKEEPER_PORT
log.dirs=/var/logs/kafka-logs-1
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


cat > ./connect-distributed.properties <<EOL
bootstrap.servers=localhost:$KAFKA_PORT
group.id=$GROUP_ID
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter.schemas.enable=true
value.converter.schemas.enable=true
offset.storage.topic=$OFFSET_STORAGE_TOPIC
offset.storage.replication.factor=$OFFSET_STORAGE_RF
status.storage.replication.factor=$STATUS_STORAGE_RF
config.storage.replication.factor=$CONFIG_STORAGE_RF
config.storage.topic=$CONFIG_STORAGE_TOPIC
status.storage.topic=$STATUS_STORAGE_TOPIC
offset.flush.interval.ms=$OFFSET_FLUSH_INTERVAL
rest.port=$REST_PORT
rest.advertised.host.name=localhost
rest.advertised.port=$REST_PORT
plugin.path=/opt/connectors
EOL

supervisord --nodaemon --configuration /etc/supervisord.conf
