ARG TAG=latest
FROM rocker/rstudio:${TAG}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo \
    libcurl4-openssl-dev \
    libssl-dev \
    zlib1g-dev \
    libssh2-1-dev \
    libopenblas0 \
    libopenblas-dev \
    psmisc \
    libapparmor1 \
    libxml2-dev \
    libgit2-dev \
    libgmp3-dev \
    libmpfr-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libclang-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    fonts-noto-cjk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# tidyverse インストール
RUN R -e "install.packages(c('tidyverse', 'devtools'), repos='https://cloud.r-project.org/')"

# 環境変数
ENV RSTUDIO_USER=rstudio \
    RSTUDIO_PASSWORD=passwd \
    RSTUDIO_GRANT_SUDO=nopass \
    RSTUDIO_PORT=8787 \
    TZ=Asia/Tokyo

# エントリポイント
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8787
VOLUME /home/rstudio

ENTRYPOINT ["/entrypoint.sh"]
