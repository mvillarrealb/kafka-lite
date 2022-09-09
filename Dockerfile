FROM alpine:latest as downloader

# See https://kafka.apache.org/downloads for available Kafka versions and the
# Scala versions with which they are built.
ENV KAFKA_VERSION=3.2.1
ENV KAFKA_SCALA_VERSION=2.13
ENV KAFKA_TARBALL=https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN apk --no-cache add wget

RUN mkdir -p /apps/kafka && \
    wget -O /apps/kafka.tgz ${KAFKA_TARBALL} && \
    tar -xvzf /apps/kafka.tgz -C /apps/kafka --strip-components 1

FROM eclipse-temurin:18-jre

ENV KAFKA_USER=kafka \
    KAFKA_GROUP=kafka \
    KAFKA_HOME=/opt/kafka/ \
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

RUN apt-get update && \
    apt-get install -y supervisor && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${KAFKA_HOME} && \
    mkdir -p ${CONNECTOR_DIR} && \
    mkdir -p /var/logs/kafka-logs-1 && \
    addgroup ${KAFKA_GROUP} && \
    adduser --home ${KAFKA_HOME} --shell /bin/bash --ingroup ${KAFKA_GROUP} ${KAFKA_USER} && \
    chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_HOME} ${KAFKA_HOME}

COPY --from=downloader /apps/kafka ${KAFKA_HOME}

COPY start.sh ${KAFKA_HOME}

COPY supervisord.conf /etc/supervisord.conf

RUN chown ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_HOME}/start.sh && \
    chown ${KAFKA_USER}:${KAFKA_GROUP} /var/logs/kafka-logs-1  && \
    chown ${KAFKA_USER}:${KAFKA_GROUP} /var/logs  && \
    chmod +x ${KAFKA_HOME}/start.sh

USER ${KAFKA_USER}

EXPOSE ${REST_PORT}

EXPOSE ${KAFKA_PORT}

EXPOSE ${ZOOKEEPER_PORT}

WORKDIR ${KAFKA_HOME}

CMD ["./start.sh"]
