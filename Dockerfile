FROM ubuntu:20.04
MAINTAINER cht.andy@gmail.com

## 安裝sshd
RUN set -eux \
  && echo "######### apt install sshd ##########" \
  && apt-get update \
  && apt-get install --assume-yes openssh-client openssh-server curl \
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && sed -i 's|#PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config \
  && { \
     echo "    StrictHostKeyChecking no"; \
     echo "    UserKnownHostsFile /dev/null"; \
     } >> /etc/ssh/ssh_config \
  && mkdir /run/sshd

## 安裝kubectl
RUN set -eux \
  && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod +x kubectl \
  && mv kubectl /usr/bin/kubectl

## 新增user 並給予sudo, root 權限
ARG USERNAME
ARG USER_ID
RUN set -eux \
  && echo "######### useradd ${USERNAME} ##########" \
  && apt-get update \
  && apt install --assume-yes sudo \
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && useradd -m -G sudo,root -u ${USER_ID} -s /bin/bash ${USERNAME} \
  && echo "${USERNAME} ALL=NOPASSWD: ALL" >> /etc/sudoers

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
