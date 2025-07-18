#!/usr/bin/env bash

echo "Enter the user ID for mssql:"
read MSSQL_USER_NAME

MSSQL_PASSWD="red"
MSSQL_PASSWD_CHK="blue"
while [[ ${MSSQL_PASSWD} != ${MSSQL_PASSWD_CHK} ]]
do
  echo "Enter the password for mssql:"
  read -s MSSQL_PASSWD
  echo "Re-Enter the password for mssql:"
  read -s MSSQL_PASSWD_CHK
  if [[ ${MSSQL_PASSWD} != ${MSSQL_PASSWD_CHK} ]]
  then
    echo "Passwords do not match. Please Try Again"
  fi
done

MSSQL_USER_NAME_64=$(echo ${MSSQL_USER_NAME} | base64)
MSSQL_PASSWD_64=$(echo ${MSSQL_PASSWD} | base64)
cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: mssql-secret
  labels:
    controller.devfile.io/mount-to-devworkspace: 'true'
    controller.devfile.io/watch-secret: 'true'
  annotations:
    controller.devfile.io/mount-as: env
data:
  MSSQL_USER_NAME: ${MSSQL_USER_NAME_64}
  MSSQL_PASSWD: ${MSSQL_PASSWD_64}
EOF