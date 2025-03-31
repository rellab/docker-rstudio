ARG TAG=latest
FROM rocker/rstudio:${TAG}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo \
    whois && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV RSTUDIO_USER       rstudio
ENV RSTUDIO_PASSWORD   passwd
ENV RSTUDIO_GRANT_SUDO nopass
ENV RSTUDIO_PORT       8787
ENV TZ                 Asia/Tokyo

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8787
VOLUME /home/rstudio

ENTRYPOINT ["/entrypoint.sh"]