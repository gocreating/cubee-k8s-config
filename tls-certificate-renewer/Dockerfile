FROM certbot/dns-google:v0.36.0

RUN apk add --no-cache curl && \
    apk add --no-cache bash

# install gcloud (https://stackoverflow.com/a/38306691/2443984)
RUN curl -sSL https://sdk.cloud.google.com | bash
# https://stackoverflow.com/a/44819306/2443984
ENV PATH $PATH:/root/google-cloud-sdk/bin

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /bin/kubectl

COPY ./tls-certificate-renewer /srv/tls-certificate-renewer

ENV DNS_GOOGLE_CREDENTIALS=${DNS_GOOGLE_CREDENTIALS} \
    GCLOUD_SERVICE_KEY=${GCLOUD_SERVICE_KEY} \
    GOOGLE_PROJECT_ID=${GOOGLE_PROJECT_ID} \
    GOOGLE_COMPUTE_ZONE=${GOOGLE_COMPUTE_ZONE} \
    GOOGLE_CLUSTER_NAME=${GOOGLE_CLUSTER_NAME} \
    K8S_TLS_SECRET_NAME=${K8S_TLS_SECRET_NAME} \
    # https://certbot.eff.org/docs/using.html#changing-the-acme-server
    ACME_SERVER=${ACME_SERVER} \
    EMAIL=${EMAIL} \
    ROOT_DOMAIN={ROOT_DOMAIN} \
    REQUEST_DOMAINS=${REQUEST_DOMAINS}

ENTRYPOINT ["sh", "/srv/tls-certificate-renewer/docker-entrypoint.sh"]
