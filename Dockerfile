FROM ubuntu:16.04
# -- --
# -- image parameters
ARG CHEFDK_VERSION=1.5.0
ARG OS_DISTRIBUTION=ubuntu
ARG OS_VERSION=16.04
ARG USER=abienkow
# --
ENV CHEFDK_PACKAGE_FILE="chefdk_${CHEFDK_VERSION}-1_amd64.deb"
ENV CHEFDK_PACKAGE_URL="https://packages.chef.io/files/stable/chefdk/${CHEFDK_VERSION}/${OS_DISTRIBUTION}/${OS_VERSION}/${CHEFDK_PACKAGE_FILE}"
# -- --
# -- install typical devops tools
RUN apt-get update \
 && apt-get install -y \
    autoconf \
    binutils-doc \
    bison \
    build-essential \
    libssl-dev \
    libreadline-dev \
    flex \
    gettext \
    git-core \
    ncurses-dev \
    openssh-server \
    sudo \
    zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# -- --
# -- add user
RUN groupadd -g 1000 $USER \
 && useradd -m -g $USER -s /bin/bash $USER \
 && echo 'eval -e "\n$(chef shell-init bash)"' >> /home/$USER/.bashrc \
 && echo 'abienkow ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/abienkow

# -- --
# -- chefdk specific version requested
# -- download, install and remove the package
RUN curl -Lo $CHEFDK_PACKAGE_FILE $CHEFDK_PACKAGE_URL \
 && dpkg -i $CHEFDK_PACKAGE_FILE \
 && rm -f $CHEFDK_PACKAGE_FILE

# -- become user
USER $USER

# -- --
# -- run sshd
EXPOSE 22
CMD ["/usr/bin/sshd", "-D"]
