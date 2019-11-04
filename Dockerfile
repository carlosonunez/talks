FROM node:8-alpine
MAINTAINER Carlos Nunez <dev@carlosnunez.me>
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN npm install -g reveal-md
COPY ./assets /_assets
ENTRYPOINT ["reveal-md", "/app/slides.md"]
