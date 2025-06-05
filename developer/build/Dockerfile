ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu

# Docker env
ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER_USER
ARG PACKAGES
ARG HOMEDIR=/home/${DOCKER_USER}

# Install the packages
#RUN groupadd ${DOCKER_USER}
RUN apt-get -yq update && \
    apt-get -yq upgrade && \
    apt-get -yq --no-install-recommends install ${PACKAGES} && \
    apt-get -yq autoremove && \
    rm -rf /var/lib/apt/lists/*

# Add modules
ADD build/pip.conf /root/.config/pip/pip.conf
ADD build/requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages --upgrade awscli && \
    pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Add the generic user -- https://linux.die.net/man/8/useradd
RUN useradd -rlm --home ${HOMEDIR} --gid 100 --uid 1000 --groups sudo,docker --shell /bin/bash --password "$(openssl passwd -1 ${DOCKER_USER})" ${DOCKER_USER}

# Add user scripts
ADD bin/* /usr/local/sbin/
RUN chmod +x /usr/local/sbin/*.sh
RUN chown -R ${DOCKER_USER}:100 ${HOMEDIR}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to user mode
USER ${DOCKER_USER}
WORKDIR ${HOMEDIR}

# Append to startup file (.bashrc)
RUN echo "" >> ${HOMEDIR}/.bashrc && \
    echo "# Custom Setup ----------" >> ${HOMEDIR}/.bashrc && \
    echo "export PATH=$PATH:~/bin" >> ${HOMEDIR}/.bashrc && \
    echo "export LOGNAME=${DOCKER_USER}" >> ${HOMEDIR}/.bashrc && \
    echo "[ \${IS_WINDOWS_HOST} = \"true\" ] && sudo chmod 666 /var/run/docker.sock" >> ${HOMEDIR}/.bashrc && \
    echo "[ ! -f ${HOMEDIR}/.bash_aliases ] && ${HOMEDIR}/bin/setup_aliases.sh" >> ${HOMEDIR}/.bashrc && \
    echo "echo 'sudo chmod -R g=u /workspace --> Commamnd to sync container to host permissions on linux'" >> ${HOMEDIR}/.bashrc && \
    echo "echo 'Packages --> ${PACKAGES}'" >> ${HOMEDIR}/.bashrc && \
    echo "echo ''" >> ${HOMEDIR}/.bashrc && \
    echo "cat ~/.bash_aliases" >> ${HOMEDIR}/.bashrc && \
    echo "source ~/.bash_aliases" >> ${HOMEDIR}/.bashrc && \
    echo "echo ''" >> ${HOMEDIR}/.bashrc && \
    echo "cd /workspace/" >> ${HOMEDIR}/.bashrc

CMD [ "bash" ]
