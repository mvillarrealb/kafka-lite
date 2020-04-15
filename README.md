# KAFKA-LITE

Alpine Based Apache Kafka Docker Image includes the following:

* Apache Kafka
* Apache Zookeeper
* Apache Kafka Connect

Baically an all in one solution for Kafka Developers :D, **NOT FOR PRODUCTION USAGE**

## BUILD THE IMAGE

```sh
docker build -t kafka-lite:0.0.1 .
```

## RUN THE CONTAINER

```sh
docker run --name kafka-lite -p 9092:9092 -p 8083:8083 kafka-lite:0.0.1
```
## USAGE WITH COMPOSE

This sample docker compose file can run kafka lite after successfully build in a simple way

```yaml
version: '3.1'
services:
  kafka_lite:
    image: kafka-lite:0.0.1
    volumes: # MOUNT kafka connect connectors volume
      - ~/connectors:/opt/connectors
    ports:
      - 9092:9092 # Kafka port
      - 8083:8083 # Kafka connect api
      - 2181:2181 # Zookeeper api
```


## ENVIRONMENTS

Environment | Default|Description
---|---|---
KAFKA_USER|kafka |User to run kafka-connect
KAFKA_GROUP|kafka| User group to run kafka-connect
KAFKA_HOME|/opt/kafka/| Kafka connect root directory
CONNECTOR_DIR|/opt/connectors| connectors directory
REST_PORT|8083| Connect rest api port
BOOTSTRAP_SERVERS|127.0.0.1:9092| Connect kafka servers
GROUP_ID|connect-cluster| Worker groupId
OFFSET_STORAGE_TOPIC|connect-offsets| Name of the topic to store connect offsets
CONFIG_STORAGE_TOPIC|connect-configs|Name of the topic to store connect config
STATUS_STORAGE_TOPIC|connect-status\|Name of the topic to store connect status
OFFSET_STORAGE_RF|1| Replication factor for OFFSET_STORAGE_TOPIC
CONFIG_STORAGE_RF|1| Replication factor for CONFIG_STORAGE_TOPIC
STATUS_STORAGE_RF|1| Replication factor for STATUS_STORAGE_TOPIC
OFFSET_FLUSH_INTERVAL|10000| Interval in milliseconds to flush 

