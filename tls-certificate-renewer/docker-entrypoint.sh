#!/bin/bash

echo $GCLOUD_SERVICE_KEY > /tmp/gcloud-service-key.json
echo $DNS_GOOGLE_CREDENTIALS > /tmp/dns-google-credentials.json

echo ''
echo '************************'
echo '*                      *'
echo '* Setup gcloud context *'
echo '*                      *'
echo '************************'

gcloud auth activate-service-account --key-file=/tmp/gcloud-service-key.json
gcloud container clusters get-credentials ${GOOGLE_CLUSTER_NAME} \
  --zone ${GOOGLE_COMPUTE_ZONE} \
  --project ${GOOGLE_PROJECT_ID}

echo ''
echo '*********************'
echo '*                   *'
echo '* Issue certificate *'
echo '*                   *'
echo '*********************'

certbot certonly \
  --dns-google \
  --agree-tos \
  --non-interactive \
  --dns-google-propagation-seconds 100 \
  --server ${ACME_SERVER} \
  --dns-google-credentials "/tmp/dns-google-credentials.json" \
  --email ${EMAIL} \
  --domains ${REQUEST_DOMAINS}

echo ''
echo '********************'
echo '*                  *'
echo '* Apply TLS secret *'
echo '*                  *'
echo '********************'

# apply new certificate without deleting older one
# https://stackoverflow.com/a/45881259/2443984
kubectl create secret tls ${K8S_TLS_SECRET_NAME} \
  --cert /etc/letsencrypt/live/${ROOT_DOMAIN}/fullchain.pem \
  --key /etc/letsencrypt/live/${ROOT_DOMAIN}/privkey.pem \
  --dry-run \
  -o yaml | kubectl apply -f -

echo ''
echo '************************'
echo '*                      *'
echo '* Clean sensitive data *'
echo '*                      *'
echo '************************'

rm /tmp/dns-google-credentials.json
rm /tmp/gcloud-service-key.json
rm /etc/letsencrypt/live/${ROOT_DOMAIN}/fullchain.pem
rm /etc/letsencrypt/live/${ROOT_DOMAIN}/privkey.pem
