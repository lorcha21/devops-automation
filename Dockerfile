FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y procps systemctl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY scripts/check_service.sh /app/check_service.sh

RUN chmod +x /app/check_service.sh

ENTRYPOINT ["/app/check_service.sh"]
