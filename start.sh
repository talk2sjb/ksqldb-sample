#!/usr/bin/env bash

# Source library
source utils/helper.sh

echo "Cleaning up.."
bash stop.sh
rm -rf database-data/*


# Create (if doesn't exist) ksqldb-plugins directory for UDFs
mkdir -p ksqldb-plugins

# Check for required KSQLDB plugins
echo "Validating ksqldb plugins are present..."
checkIfFileExists "ksqldb-plugins/HashGeneratorPlugin.jar" "$filename found." || exit 1

# Use database folder for mounting
echo "Creating database folder for mounting"
mkdir -p database-data/ 

docker-compose up -d

MAX_WAIT=90
echo "Waiting up to $MAX_WAIT seconds for ksqlDB server's embedded Connect to be ready"
retry $MAX_WAIT check_connect_up ksqldb-server "API server started" || exit 1

# Verify ksqlDB server has started
MAX_WAIT=120
echo "Waiting up to $MAX_WAIT seconds for ksqlDB server to be ready to serve requests"
retry $MAX_WAIT host_check_ksqlDBserver_up "Attaching" || exit 1

sleep 2

# Create required topics in kafka
docker-compose exec broker kafka-topics --create --bootstrap-server localhost:9092 --topic events
# docker-compose exec broker kafka-topics --create --bootstrap-server localhost:9092 --topic TRANSFORMED_EVENTS

# Run the source connectors (with ksqlDB CLI) that generate data
docker-compose exec ksqldb-cli bash -c "ksql http://ksqldb-server:8088 <<EOF
run script '/scripts/all_events.sql';
run script '/scripts/titan/process.sql';
run script '/scripts/titan/registry.sql';
run script '/scripts/titan/file.sql';
run script '/scripts/sap/process.sql';
run script '/scripts/sap/registry.sql';
run script '/scripts/sap/file.sql';
exit ;
EOF"

# Put some sample data into the events topic
# echo "Producing some sample events to events topic in kafka"
cat sample_events | docker exec -i broker kafka-console-producer --bootstrap-server broker:9092 --topic events --property "parse.key=true" --property "key.separator=:"
