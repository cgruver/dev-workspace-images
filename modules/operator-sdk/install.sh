#!/usr/bin/env bash

curl -fsSL -o /usr/local/bin/operator-sdk https://github.com/operator-framework/operator-sdk/releases/download/${OPERATOR_SDK_VERSION}/operator-sdk_linux_amd64
chmod +x /usr/local/bin/operator-sdk
