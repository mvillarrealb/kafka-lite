# kafka-lite

Single-node kafka cluster for local development and testing in an Alpine-based
Docker image, forked from [mvillarrealb/kafka-lite].

**⚠️ Not for production use! ⚠️**

## Docker images

Images are available at [mccutchen/kafka-lite] on Docker Hub, tagged with
specific Kafka versions.

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

## Credits

As noted above, this repo is based on [mvillarrealb/kafka-lite]. Differences
from the upstream image:
- No kafka-connect
- Builds on arm64 (e.g. M1 Macs)
- Uses non-deprecated JVM


[mccutchen/kafka-lite]: https://hub.docker.com/r/mccutchen/kafka-lite
[mvillarrealb/kafka-lite]: https://github.com/mvillarrealb/kafka-lite
