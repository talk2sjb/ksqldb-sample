#!/usr/bin/env bash

################################################################
# Source Confluent Platform versions
################################################################
# source "./config.env"


################################################################
# Library of functions
################################################################

retry() {
    local -r -i max_wait="$1"; shift
    local -r cmd="$@"

    local -i sleep_interval=5
    local -i curr_wait=0

    until $cmd
    do
        if (( curr_wait >= max_wait ))
        then
            echo "ERROR: Failed after $curr_wait seconds. Please troubleshoot and run again."
            return 1
        else
            printf "."
            curr_wait=$((curr_wait+sleep_interval))
            sleep $sleep_interval
        fi
    done
    printf "\n"
}

check_connect_up() {
  containerName=$1
  log_to_find=$2

  FOUND=$(docker-compose logs $containerName | grep $log_to_find)
  if [ -z "$FOUND" ]; then
    return 1
  fi
  return 0
}


host_check_ksqlDBserver_up() {
  KSQLDB_CLUSTER_ID=$(curl -s http://localhost:8088/info | jq -r ".KsqlServerInfo.ksqlServiceId")
  if [ "$KSQLDB_CLUSTER_ID" == "ksql-cluster" ]; then
    return 0
  fi
  return 1
}

checkIfFileExists() {
  RED=$(tput setaf 1)
  BOLD=$(tput bold)
  NORMAL=$(tput sgr0)
  filename=$1
  result=0
  echo "Checking for $filename"
  if [[ ! -f $filename ]] ; then
    echo "${BOLD}${RED}File $filename is not present, aborting.${NORMAL}"
    result=1
  fi

  return $result
}
