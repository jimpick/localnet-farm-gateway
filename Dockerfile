# syntax=docker/dockerfile:1.4

# See: https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md

FROM ubuntu

RUN useradd ubuntu

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
RUN apt install -y curl

RUN apt upgrade -y

# Node

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install -y nodejs

# Caddy server
# https://caddyserver.com/docs/install#debian-ubuntu-raspbian

RUN apt install -y debian-keyring debian-archive-keyring apt-transport-https
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
RUN apt-get update
RUN apt install -y caddy

RUN apt upgrade -y

# Web gateway

WORKDIR /home/ubuntu/web

COPY Caddyfile .
RUN mv Caddyfile /etc/caddy/Caddyfile

COPY package.json .
COPY package-lock.json .
COPY server.mjs .

RUN mkdir -p public
#RUN cp /home/ubuntu/.lotus-local-net/token public/token

RUN chown -R ubuntu. /home/ubuntu

USER ubuntu

RUN npm install

EXPOSE 3000

CMD bash -c 'caddy start --config /etc/caddy/Caddyfile; node server.mjs'

