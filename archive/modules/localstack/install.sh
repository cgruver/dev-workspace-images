#!/usr/bin/env bash

TEMP_DIR="$(mktemp -d)"
curl -fsSL -o ${TEMP_DIR}/localstack.tgz https://github.com/localstack/localstack-cli/releases/download/v${LOCALSTACK_VERSION}/localstack-cli-${LOCALSTACK_VERSION}-linux-amd64-onefile.tar.gz
tar -xzf ${TEMP_DIR}/localstack.tgz -C /usr/local/bin
rm -rf "${TEMP_DIR}"
npm install -g serverless
rm -rf ${HOME}/.npm
