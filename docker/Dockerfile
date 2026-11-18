FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    mininet openvswitch-switch openvswitch-testcontroller \
    iproute2 iputils-ping net-tools tcpdump iperf iperf3 traceroute \
    python3 python3-pip xterm procps ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /work
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
