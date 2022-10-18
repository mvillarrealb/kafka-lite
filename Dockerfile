FROM alpine:latest AS downloader

# See https://kafka.apache.org/downloads for available Kafka versions and the
# Scala versions with which they are built.
ENV KAFKA_VERSION=3.3.1
ENV KAFKA_SCALA_VERSION=2.13
ENV KAFKA_TARBALL=https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN apk --no-cache add curl

RUN mkdir -p /kafka && \
    curl -sSL ${KAFKA_TARBALL} > /tmp/kafka.tgz && \
    tar -xvzf /tmp/kafka.tgz -C /kafka --strip-components 1


FROM eclipse-temurin:18-jre AS runtime

RUN apt-get update && \
    apt-get install -y supervisor && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

ENV KAFKA_USER=kafka \
    KAFKA_GROUP=kafka \
    KAFKA_HOME=/opt/kafka/ \
    KAFKA_LOGS_DIR=/var/logs/kafka \
    CONNECTOR_DIR=/opt/connectors \
    REST_PORT=8083 \
    KAFKA_PORT=9092 \
    ZOOKEEPER_PORT=2181 \
    GROUP_ID=connect-cluster \
    OFFSET_STORAGE_TOPIC=connect-offsets \
    CONFIG_STORAGE_TOPIC=connect-configs \
    STATUS_STORAGE_TOPIC=connect-status \
    OFFSET_STORAGE_RF=1 \
    CONFIG_STORAGE_RF=1 \
    STATUS_STORAGE_RF=1 \
    OFFSET_FLUSH_INTERVAL=10000

RUN mkdir -p ${KAFKA_HOME} && \
    mkdir -p ${CONNECTOR_DIR} && \
    mkdir -p ${KAFKA_LOGS_DIR} && \
    addgroup ${KAFKA_GROUP} && \
    adduser --home ${KAFKA_HOME} --shell /bin/bash --ingroup ${KAFKA_GROUP} ${KAFKA_USER} && \
    chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_HOME} ${KAFKA_HOME} && \
    chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_LOGS_DIR}

COPY --from=downloader /kafka ${KAFKA_HOME}

RUN chown ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_LOGS_DIR}

COPY start.sh ${KAFKA_HOME}
COPY supervisord.conf /etc/supervisord.conf

USER ${KAFKA_USER}
EXPOSE ${REST_PORT}
EXPOSE ${KAFKA_PORT}
EXPOSE ${ZOOKEEPER_PORT}

WORKDIR ${KAFKA_HOME}

CMD ["./start.sh"]
