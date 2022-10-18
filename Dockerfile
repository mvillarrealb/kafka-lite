FROM eclipse-temurin:18-jre AS runtime

RUN apt-get update && \
    apt-get install -y curl supervisor && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# See https://kafka.apache.org/downloads for available Kafka versions and the
# Scala versions with which they are built.
ARG KAFKA_VERSION=3.3.1
ARG KAFKA_SCALA_VERSION=2.13
ARG KAFKA_TARBALL=https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

ENV KAFKA_USER=kafka \
    KAFKA_GROUP=kafka \
    KAFKA_HOME=/opt/kafka/ \
    KAFKA_LOGS_DIR=/var/logs/kafka

ENV KAFKA_PORT=9092 \
    REST_PORT=8083 \
    ZOOKEEPER_PORT=2181

ENV CONFIG_STORAGE_RF=1 \
    CONFIG_STORAGE_TOPIC=connect-configs \
    CONNECTOR_DIR=/opt/connectors \
    GROUP_ID=connect-cluster \
    OFFSET_FLUSH_INTERVAL=10000 \
    OFFSET_STORAGE_RF=1 \
    OFFSET_STORAGE_TOPIC=connect-offsets \
    STATUS_STORAGE_RF=1 \
    STATUS_STORAGE_TOPIC=connect-status

RUN addgroup ${KAFKA_GROUP} && \
    adduser --home ${KAFKA_HOME} --shell /bin/bash --ingroup ${KAFKA_GROUP} ${KAFKA_USER} && \
    mkdir -p ${KAFKA_HOME} && \
    mkdir -p ${CONNECTOR_DIR} && \
    mkdir -p ${KAFKA_LOGS_DIR} && \
    chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_HOME} ${KAFKA_HOME} && \
    chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_LOGS_DIR}

RUN curl -sSL ${KAFKA_TARBALL} > /tmp/kafka.tgz && \
    tar -xvzf /tmp/kafka.tgz -C /opt/kafka --strip-components 1

COPY start-kafka-lite.sh ${KAFKA_HOME}
COPY supervisord.conf /etc/supervisord.conf

USER ${KAFKA_USER}
EXPOSE ${REST_PORT}
EXPOSE ${KAFKA_PORT}
EXPOSE ${ZOOKEEPER_PORT}

WORKDIR ${KAFKA_HOME}
CMD ["./start-kafka-lite.sh"]
