# syntax=docker/dockerfile:1.4

# See: https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md

FROM ubuntu

RUN useradd ubuntu

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata

RUN apt upgrade -y

# Node

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install -y nodejs

# Web gateway

WORKDIR /home/ubuntu/web

COPY Caddyfile .
RUN mv Caddyfile /etc/caddy/Caddyfile

COPY package.json .
COPY package-lock.json .
COPY server.mjs .

RUN mkdir -p public
#RUN cp /home/ubuntu/.lotus-local-net/token public/token

RUN chown -R ubuntu. .

USER ubuntu

RUN npm install

EXPOSE 3000

CMD bash -c 'caddy start --config /etc/caddy/Caddyfile; node server.mjs'

