#!/usr/bin/env bash

TEMP_DIR="$(mktemp -d)"
curl -fsSL -o ${TEMP_DIR}/cockroach.tgz https://binaries.cockroachdb.com/cockroach-${COCKROACH_VERSION}.linux-amd64.tgz
tar -xzf ${TEMP_DIR}/cockroach.tgz -C /usr/local
rm -rf "${TEMP_DIR}"
ln -s /usr/local/cockroach-${COCKROACH_VERSION}.linux-amd64/cockroach /usr/local/bin/cockroach
