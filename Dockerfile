FROM alpine:3.16

# See VERSIONS in this repo for the versions used when building this image.
#
# See https://kafka.apache.org/downloads for available Kafka versions and the
# Scala versions with which they are built.
ARG KAFKA_VERSION
ARG SCALA_VERSION
ARG KAFKA_TARBALL=https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

ENV KAFKA_USER=kafka \
    KAFKA_GROUP=kafka \
    KAFKA_HOME=/opt/kafka/ \
    KAFKA_LOGS_DIR=/var/kafka/logs

ENV KAFKA_PORT=9092 \
    ZOOKEEPER_PORT=2181

RUN apk add --no-cache bash curl openjdk17-jre-headless supervisor

RUN addgroup ${KAFKA_GROUP} && \
    adduser -h ${KAFKA_HOME} -D -s /bin/bash -G ${KAFKA_GROUP} ${KAFKA_USER} && \
    mkdir -p ${KAFKA_HOME} && \
    mkdir -p ${KAFKA_LOGS_DIR} && \
    chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_HOME} ${KAFKA_HOME} && \
    chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_LOGS_DIR}

RUN curl -sSL ${KAFKA_TARBALL} | tar -zxv -C ${KAFKA_HOME} --strip-components=1

COPY start-kafka-lite.sh ${KAFKA_HOME}
COPY supervisord.conf /etc/supervisord.conf

VOLUME ${KAFKA_LOGS_DIR}

EXPOSE ${KAFKA_PORT}
EXPOSE ${ZOOKEEPER_PORT}

USER ${KAFKA_USER}
WORKDIR ${KAFKA_HOME}

CMD ["./start-kafka-lite.sh"]
