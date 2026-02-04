FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Force HTTP mirrors (avoid TLS cert issues in minimal base image)
RUN sed -i 's|https://|http://|g' /etc/apt/sources.list || true

# Install only what we need for container-mode checks (ps/pgrep)
RUN apt-get update && \
    apt-get install -y procps && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY scripts/check_service.sh /app/check_service.sh
RUN chmod +x /app/check_service.sh

ENTRYPOINT ["/app/check_service.sh"]
