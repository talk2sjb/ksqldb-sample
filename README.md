# Overview

The citadel project uses ksqldb to build an abstraction on top of kafka streams to extract, transform and load data from kafka to persistence sinks.
All the modules are run as docker containers (except SAP HANA).

## Dependencies:
1. Docker
2. jq
3. ksqtools project (in Titan)

In order to successfuly start/run the citadel project, it needs the ksqldb plugins (UDFs) to be placed in the correct directory. Please follow the steps in the `README.md` file of the corresponding project [here](https://gitlab.com/gosecure/development/titan/backend/ksqltools)

# To start
## On Ubuntu
```
bash start.sh
```
## On Mac
```
sh start.sh
```

# To stop
## On Ubuntu
```
bash stop.sh
```

## On Mac
```
sh stop.sh
```

# Produce data in Kafka using CLI
The script automatically prodecues some static test data into the kafka topic.
In order to produce custom message, login into the broker:
```
docker exec -it broker /bin/bash
```
Then enter the kafka-console-producer and start pushing data like this:
```
kafka-console-producer --bootstrap-server localhost:9092 --topic events --property "parse.key=true" --property "key.separator=:"

>"event_1":{"eventId": "event_1", "event_type": "behavior", "count": 5, "meta": "test event"}
>^C
```
__*Note: To quit the producer-console, use the `ctrl + C` (`^C`).*__


# Test sinks
The data is transformed by KSQLDB and then forwarded to the sinks. We may verify if data ended up in our configured sinks.

## Elasticsearch
We may query the REST API exposed by elasticsearch. e.g.
```
curl -X GET http://localhost:9200/transformed_behavior_events/_search?pretty=true&q=*:*
```

## Postgres
Login into the postgres container
```
docker exec -it postgres /bin/bash
```

Using `psql` enter the interactive shell
```
psql -d transformedevents
```

Query using SQL commands e.g.:
```
SELECT * from events;
```

# NOTES, CONCERNS AND LIMITATIONS
1. `delete.enabled` value is set to `false` for sinks, meaning delete operation would not be allowed. This has been done because in order to support delete `pk.mode` needs to be set to `record_key`. But, in order to achieve that, we need to explicitly identify keys in each stream (which is currently not supported by `create stream by select`).
2. Support for array fields have not been decided yet (Should they fan out as multiple rows?)
3. One event may lead to multiple entries across multiple tables. It needs to be statically defined and can't be inferred on the fly (dynamically using logic) in KSQLDB. It also leads to creation of mutiple streams and topics.
4. Primarily for Mac: If some pods keep crashing with stattus codes 127 or 137, most probably that's due to OOM. We may increase the memory limit in docker panel (dashboard) to allocate a higher memory. Default is 1GB. More details [here](https://github.com/10up/wp-local-docker/issues/6)
5. Primarily for Linux/WSL : Docker containers nay not be able to connect to the external world (internet). For that, please update the `/etc/docker/daemon.json` file (create if doesn't exist) with a DNS entry e.g. 
```
{
    "dns" ["10.1.2.3", "8.8.8.8"]
}
```