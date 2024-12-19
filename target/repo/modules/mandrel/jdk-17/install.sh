#!/usr/bin/env bash

TEMP_DIR="$(mktemp -d)"
mkdir -p /usr/local/graalvm 
curl -fsSL -o ${TEMP_DIR}/mandrel-${JAVA_VERSION}-linux-amd64-${MANDREL_VERSION}.tar.gz https://github.com/graalvm/mandrel/releases/download/mandrel-${MANDREL_VERSION}/mandrel-${JAVA_VERSION}-linux-amd64-${MANDREL_VERSION}.tar.gz 
tar xzf ${TEMP_DIR}/mandrel-${JAVA_VERSION}-linux-amd64-${MANDREL_VERSION}.tar.gz -C /usr/local/graalvm --strip-components=1 
rm -rf "${TEMP_DIR}"
