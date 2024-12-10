#!/usr/bin/env bash

if [ ! -d "${HOME}" ]
then
  mkdir -p "${HOME}"
fi

if ! whoami &> /dev/null
then
  if [ -w /etc/passwd ]
  then
    echo "${USER_NAME:-cassandra}:x:$(id -u):0:${USER_NAME:-cassandra} user:${HOME}:/bin/bash" >> /etc/passwd
    echo "${USER_NAME:-cassandra}:x:$(id -u):" >> /etc/group
  fi
fi

# test to see if I'm already deployed
if [ ! -f /cassandra/deployed ]
then
   echo "Creating Cassandra Node Resources"

   mkdir -p /cassandra/data
   mkdir -p /cassandra/commitlog
   mkdir -p /cassandra/saved_caches
   mkdir -p /cassandra/hints
   cp -r ${CASSANDRA_HOME}/conf /cassandra
   cp /cassandra.yaml /cassandra/conf
   touch /cassandra/deployed
fi

CASSANDRA_CONFIG_FILE=${CASSANDRA_CONFIG_FILE:-/cassandra/conf/cassandra.yaml}

echo "Starting Cassandra Node"
exec ${CASSANDRA_HOME}/bin/cassandra -f -R -D cassandra.config="file://${CASSANDRA_CONFIG_FILE}"
