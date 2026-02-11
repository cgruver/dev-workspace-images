#!/usr/bin/env bash

TEMP_DIR="$(mktemp -d)"
HELM_VERSION=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/helm/helm/releases/latest))
curl -fsSL -o ${TEMP_DIR}/helm.tgz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
tar -xzf ${TEMP_DIR}/helm.tgz -C ${TEMP_DIR}
mv ${TEMP_DIR}/linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm
rm -rf "${TEMP_DIR}"
