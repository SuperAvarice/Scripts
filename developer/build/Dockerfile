ARG BASE_IMAGE=null
FROM ${BASE_IMAGE} AS final

# ------ Build Args ------ (Required build args defaulted to "null")
ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER_USER=null
ARG PACKAGES=null
ARG HOMEDIR=/home/${DOCKER_USER}

# ------ Environment ------
ENV LANG=C.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=C.UTF-8

# Copy build files
COPY build/pip.conf /root/.config/pip/pip.conf
COPY build/requirements.txt /tmp/requirements.txt
COPY bin /usr/local/sbin/

# Base Setup
RUN set -eux; \
    # Remove default ubuntu user if it exists
    userdel -r ubuntu 2>/dev/null || true; \
    rm -rf /home/ubuntu || true; \
    # Update and install required packages
    apt-get -yq update; \
    apt-get -yq --no-install-recommends install ${PACKAGES}; \
    update-ca-certificates; \
    # Create user and setup workspace
    useradd -rlm --home ${HOMEDIR} --gid 100 --uid 1000 --groups sudo --shell /bin/bash ${DOCKER_USER}; \
    chown -R ${DOCKER_USER}:100 ${HOMEDIR}; \
    # Grant sudo privileges without password
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers; \
    # Setup podman registry configuration
    mkdir -p /etc/containers; \
    echo "[registries.search]\nregistries = ['docker.io']" > /etc/containers/registries.conf; \
    # Setup docker
    ln -sf /usr/bin/podman /usr/local/bin/docker; \
    # Set permissions for scripts
    chmod +x /usr/local/sbin/*.sh || true; \
    # Clean up apt cache
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN set -eux; \
    pip3 install --no-cache-dir --break-system-packages -r /tmp/requirements.txt; \
    rm -rf /root/.cache /root/.config/pip/tmp/requirements.txt

# Switch to user mode
USER ${DOCKER_USER}
WORKDIR ${HOMEDIR}

# Setup custom environment in startup file (.bashrc)
RUN set -eux; { \
    echo ""; \
    echo "uname -a"; \
    echo "# Custom Setup ----------"; \
    echo "if [ -n \"\${PODMAN_SOCKET:-}\" ] && [ -S \"\${PODMAN_SOCKET}\" ]; then sudo chmod 666 \"\${PODMAN_SOCKET}\"; fi" ; \
    echo "export PATH=$PATH:~/bin" ; \
    echo "export LOGNAME=${DOCKER_USER}" ; \
    echo "[ ! -f ~/.bash_aliases ] && /usr/local/sbin/setup_aliases.sh" ; \
    echo "source ~/.bash_aliases 2>/dev/null || true" ; \
    #echo "echo 'sudo chmod -R g=u /workspace --> Commamnd to sync container to host permissions on linux'" ; \
    echo "echo ''" ; \
    echo "cd /workspace/ || true" ; \
    } >> ${HOMEDIR}/.bashrc

CMD [ "bash" ]
