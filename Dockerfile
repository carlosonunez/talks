FROM buildkite/puppeteer:1.19
MAINTAINER Carlos Nunez <dev@carlosnunez.me>
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN npm install -g reveal-md
ENTRYPOINT ["reveal-md", "/app/slides.md"]
