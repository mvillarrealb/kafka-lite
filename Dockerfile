FROM alpine as downloader

ENV KAFKA_TARBALL=https://www-eu.apache.org/dist/kafka/2.4.0/kafka_2.11-2.4.0.tgz
#Better to keep this on a separate layer :D
RUN apk --no-cache add wget

RUN mkdir -p /apps/kafka && \
    wget -O /apps/kafka.tgz ${KAFKA_TARBALL} && \
    tar -xvzf /apps/kafka.tgz -C /apps/kafka --strip-components 1

FROM adoptopenjdk/openjdk8:alpine-slim

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

RUN apk update && \
    apk --no-cache add curl bash supervisor && \
    mkdir -p ${KAFKA_HOME} && \
    mkdir -p ${CONNECTOR_DIR} && \
    mkdir -p /var/logs/kafka-logs-1 && \
    addgroup ${KAFKA_GROUP} && \
    adduser -h ${KAFKA_HOME} -D -s /bin/bash -G ${KAFKA_GROUP} ${KAFKA_USER} && \
    chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_HOME} ${KAFKA_HOME}

COPY --from=downloader /apps/kafka ${KAFKA_HOME}

ADD scripts/start.sh ${KAFKA_HOME}

ADD scripts/kafka.conf /etc/supervisord.conf

RUN chown ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_HOME}/start.sh && \ 
    chown ${KAFKA_USER}:${KAFKA_GROUP} /var/logs/kafka-logs-1  && \
    chown ${KAFKA_USER}:${KAFKA_GROUP} /var/logs  && \
    chmod +x ${KAFKA_HOME}/start.sh

USER ${KAFKA_USER}

EXPOSE ${REST_PORT}

EXPOSE ${KAFKA_PORT}

EXPOSE ${ZOOKEEPER_PORT}

WORKDIR ${KAFKA_HOME}

CMD [ "/bin/bash", "-c",  "./start.sh"]