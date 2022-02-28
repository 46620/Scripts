FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y python \
    bc \
    bison \
    build-essential \
    git \
    imagemagick \
    lib32readline-dev \
    lib32z1-dev \
    liblz4-tool \
    libncurses5 \
    libncurses5-dev \
    libsdl1.2-dev \
    libxml2 lzop \
    pngcrush \
    rsync \
    schedtool \
    git-core \
    gnupg flex \
    gperf \
    zip \
    curl \
    zlib1g-dev \
    gcc-multilib \
    g++-multilib \
    libc6-dev-i386 \
    lib32ncurses5-dev \
    x11proto-core-dev \
    libx11-dev \
    lib32z-dev \
    ccache \
    libgl1-mesa-dev \
    libxml2-utils \
    xsltproc \
    unzip \
    squashfs-tools \
    python-mako \
    libssl-dev \
    ninja-build \
    lunzip \
    syslinux \
    syslinux-utils \
    gettext \
    genisoimage \
    xorriso \
    xmlstarlet \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo && \
chmod a+x /usr/bin/repo

ADD builder.sh /
RUN chmod +x bliss-sunfish.sh

WORKDIR /bliss

CMD ["/bliss-sunfish.sh"]