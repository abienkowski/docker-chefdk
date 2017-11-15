FROM ubuntu:16.04
# -- --
# -- image parameters
ARG CHEFDK_VERSION=1.5.0
ARG OS_DISTRIBUTION=ubuntu
ARG OS_VERSION=16.04
ARG USER=abienkow
# --
ENV USER=$USER
ENV CHEFDK_PACKAGE_FILE="chefdk_${CHEFDK_VERSION}-1_amd64.deb"
ENV CHEFDK_PACKAGE_URL="https://packages.chef.io/files/stable/chefdk/${CHEFDK_VERSION}/${OS_DISTRIBUTION}/${OS_VERSION}/${CHEFDK_PACKAGE_FILE}"
# -- --
# -- install typical devops tools
RUN apt-get update \
 && apt-get install -y \
    autoconf \
    bash-completion \
    binutils-doc \
    bison \
    build-essential \
    curl \
    dnsutils \
    git \
    iputils-ping \
    openssh-server \
    openssl \
    netcat \
    python-pip \
    sudo \
    tmux \
    vim \
    wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# -- --
# -- chefdk specific version requested
# -- download, install and remove the package
RUN curl -Lo $CHEFDK_PACKAGE_FILE $CHEFDK_PACKAGE_URL \
 && dpkg -i $CHEFDK_PACKAGE_FILE \
 && rm -f $CHEFDK_PACKAGE_FILE

# -- --
# -- entrypoint file
ADD entrypoint.sh /

# -- --
# -- fix sshd start problem on ubuntu platform
RUN mkdir -p /var/run/sshd \
 && chmod 0755 /var/run/sshd \
 && chmod +x /entrypoint.sh

# -- --
# -- run sshd
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
