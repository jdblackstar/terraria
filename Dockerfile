FROM alpine:3.11.6 AS base

RUN apk add --update-cache \
    unzip

# add the bootstrap file
COPY bootstrap.sh /tshock/bootstrap.sh

# Download and unpack TShock
# Change ADD to point to current stable release in GitHub
# Change RUN to point to the last path in GitHub address
ADD https://github.com/Pryaxis/TShock/releases/download/v4.4.0-pre6/TShock_4.4.0_Pre6_Terraria1.4.0.3.zip /
RUN unzip TShock_4.4.0_Pre6_Terraria1.4.0.3.zip -d /tshock && \
    rm TShock_4.4.0_Pre6_Terraria1.4.0.3.zip && \
    chmod +x /tshock/TerrariaServer.exe && \
    # add executable perm to bootstrap
    chmod +x /tshock/bootstrap.sh

FROM mono:6.8.0.96-slim

LABEL maintainer="Josh Black-Star <josh@blackstar.dev>"

# documenting ports
EXPOSE 7777 7878

# env used in the bootstrap
ENV CONFIGPATH=/root/.local/share/Terraria/Worlds
ENV LOGPATH=/tshock/logs
ENV WORLD_FILENAME=""

# Allow for external data
VOLUME ["/root/.local/share/Terraria/Worlds", "/tshock/logs", "/plugins"]

# install nuget to grab tshock dependencies
RUN apt-get update -y && \
    apt-get install -y nuget && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# copy game files
COPY --from=base /tshock/ /tshock/

# Set working directory to server
WORKDIR /tshock

# run the bootstrap, which will copy the TShockAPI.dll before starting the server
ENTRYPOINT [ "/bin/sh", "bootstrap.sh" ]
