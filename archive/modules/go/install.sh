#!/usr/bin/env bash

TEMP_DIR="$(mktemp -d)"
curl -fsSL -o ${TEMP_DIR}/go.tgz https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
tar -zxf ${TEMP_DIR}/go.tgz -C /usr/local
rm -rf "${TEMP_DIR}"
cd /usr/local/bin
ln -s ../go/bin/go go
ln -s ../go/bin/gofmt gofmt
