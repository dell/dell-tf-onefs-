
FROM debian:bullseye

ARG TERRAFORM_VERSION=1.1.9
RUN  apt-get update \
  && apt-get install -y wget unzip curl python3 ca-certificates curl apt-transport-https lsb-release gnupg\
  && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
   | funzip > /usr/local/bin/terraform && chmod +x /usr/local/bin/terraform
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

RUN AZ_REPO=$(lsb_release -cs) \ 
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list

RUN apt-get update
RUN apt-get install azure-cli
WORKDIR /usr/src/app
COPY . ./

ENV TF_REGISTRY_CLIENT_TIMEOUT=120
ENV TF_PLUGIN_CACHE_DIR=/usr/src/terraform.d/plugins
RUN terraform init -input=false
RUN terraform providers mirror ${TF_PLUGIN_CACHE_DIR}


