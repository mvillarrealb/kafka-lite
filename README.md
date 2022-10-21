# kafka-lite

Single-node kafka cluster for local development and testing in an Alpine-based
Docker image.

**⚠️ Not for production use!**

## Building and releasing

```sh
# Build an image tagged with the latest git commit
make

# Build an image tagged with latest
make VERSION=latest

# Build and push an image tagged with latest
make release VERSION=latest
```

## Usage

```sh
docker run --rm -P mccutchen/kafka-lite
```

Or, using docker-compose:

```yaml
version: '3.1'
services:
  kafka:
    image: mccutchen/kafka-lite
    ports:
      - 9092:9092 # Kafka port
      - 2181:2181 # Zookeeper port
    volumes:
      - /tmp/kafka-data:/var/kafka/logs
```
