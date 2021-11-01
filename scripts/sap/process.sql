-- Create Process stream backed by process topic
CREATE STREAM sap_process_stream (
    `oid` VARCHAR,
    `endpoint_id` VARCHAR,
    `parent_process_oid` VARCHAR,
    `backing_file_oid` VARCHAR,
    `pid` BIGINT,
    `name` VARCHAR,
    `sid` VARCHAR,
    `time_started` BIGINT,
    `command_line` VARCHAR,
    `domain` VARCHAR,
    `username` VARCHAR
)
WITH (
	VALUE_FORMAT='AVRO', 
	KAFKA_TOPIC='sap_process',
	PARTITIONS=1
);

-- Source process
CREATE STREAM sap_source_process_stream
AS
SELECT
    PROCESSID(e.endpoint_id, e.source_process_time_started, e.source_process_pid) AS `oid`,
    CASE
        WHEN e.endpoint_id IS NULL THEN ''
        ELSE e.endpoint_id
    END AS `endpoint_id`,
    CASE
        WHEN e.source_process_parent_pid IS NOT NULL THEN CAST(e.source_thread_process_parent_pid AS STRING)
        ELSE NULL
    END AS `parent_process_oid`,
    CASE
        WHEN e.source_thread_process_backing_file_path IS NULL OR e.action IS NULL then NULL
        ELSE BACKINGFILEID(e.endpoint_id, e.source_thread_process_backing_file_path, e.source_thread_process_backing_file_time_stamp)
    END AS `backing_file_oid`,
    e.source_process_pid AS `pid`,
    e.source_process_name AS `name`,
    e.source_process_sid AS `sid`,
    CASE
        WHEN e.source_process_time_started IS NOT NULL THEN e.source_process_time_started
        ELSE CAST(0 AS BIGINT)
    END AS `time_started`,
    CASE
        WHEN e.source_process_command_line IS NOT NULL THEN TRIM(e.source_process_command_line)
        ELSE NULL
    END AS `command_line`,
    SPLIT(e.target_process_user, '\\')[0] AS `domain`,
    SPLIT(e.target_process_user, '\\')[1] AS `username`
FROM all_events_stream AS e
WHERE e.action = 'PROCESS_CREATE'
EMIT CHANGES;

INSERT INTO sap_process_stream
SELECT
    sps.`oid` AS `oid`,
    sps.`endpoint_id` AS `endpoint_id`,
    sps.`parent_process_oid` AS `parent_process_oid`,
    sps.`backing_file_oid` AS `backing_file_oid`,
    sps.`pid` AS `pid`,
    sps.`name` AS `name`,
    sps.`sid` AS `sid`,
    sps.`time_started` AS `time_started`,
    sps.`command_line` AS `command_line`,
    sps.`domain` AS `domain`,
    sps.`username` AS `username`
FROM sap_source_process_stream AS sps
EMIT CHANGES;

-- Target process
CREATE STREAM sap_target_process_stream
AS
SELECT
    PROCESSID(e.endpoint_id, e.target_process_time_started, e.target_process_pid) AS `oid`,
    CASE
        WHEN e.endpoint_id IS NULL THEN ''
        ELSE e.endpoint_id
    END AS `endpoint_id`,
    CASE
        WHEN e.target_process_parent_pid IS NOT NULL THEN CAST(e.source_thread_process_parent_pid AS STRING)
        ELSE NULL
    END AS `parent_process_oid`,
    CASE
        WHEN e.source_thread_process_backing_file_path IS NULL OR e.action IS NULL then NULL
        ELSE BACKINGFILEID(e.endpoint_id, e.source_thread_process_backing_file_path, e.source_thread_process_backing_file_time_stamp)
    END AS `backing_file_oid`,
    e.target_process_pid AS `pid`,
    e.target_process_name AS `name`,
    e.target_process_sid AS `sid`,
    CASE
        WHEN e.target_process_time_started IS NOT NULL THEN e.target_process_time_started
        ELSE CAST(0 AS BIGINT)
    END AS `time_started`,
    CASE
        WHEN e.target_process_command_line IS NOT NULL THEN TRIM(e.target_process_command_line)
        ELSE NULL
    END AS `command_line`,
    SPLIT(e.target_process_user, '\\')[0] AS `domain`,
    SPLIT(e.target_process_user, '\\')[1] AS `username`
FROM all_events_stream AS e
WHERE e.action = 'PROCESS_CREATE' OR e.action = 'PROCESS_TERMINATE'
EMIT CHANGES;

INSERT INTO sap_process_stream
SELECT
    tps.`oid` AS `oid`,
    tps.`endpoint_id` AS `endpoint_id`,
    tps.`parent_process_oid` AS `parent_process_oid`,
    tps.`backing_file_oid` AS `backing_file_oid`,
    tps.`pid` AS `pid`,
    tps.`name` AS `name`,
    tps.`sid` AS `sid`,
    tps.`time_started` AS `time_started`,
    tps.`command_line` AS `command_line`,
    tps.`domain` AS `domain`,
    tps.`username` AS `username`
FROM sap_target_process_stream AS tps
EMIT CHANGES;

-- Source Thread process
CREATE STREAM sap_source_thread_process_stream
AS
SELECT
    PROCESSID(e.endpoint_id, e.source_thread_process_time_started, e.source_thread_process_pid) AS `oid`,
    CASE
        WHEN e.endpoint_id IS NULL THEN ''
        ELSE e.endpoint_id
    END AS `endpoint_id`,
    CASE
        WHEN e.source_thread_process_parent_pid IS NOT NULL THEN CAST(e.source_thread_process_parent_pid AS STRING)
        ELSE NULL
    END AS `parent_process_oid`,
    CASE
        WHEN e.source_thread_process_backing_file_path IS NULL OR e.action IS NULL then NULL
        ELSE BACKINGFILEID(e.endpoint_id, e.source_thread_process_backing_file_path, e.source_thread_process_backing_file_time_stamp)
    END AS `backing_file_oid`,
    e.source_thread_process_pid AS `pid`,
    e.source_thread_process_name AS `name`,
    e.source_thread_process_sid AS `sid`,
    CASE
        WHEN e.source_thread_process_time_started IS NOT NULL THEN e.source_thread_process_time_started
        ELSE CAST(0 AS BIGINT)
    END AS `time_started`,
    CASE
        WHEN e.source_thread_process_command_line IS NOT NULL THEN TRIM(e.source_thread_process_command_line)
        ELSE NULL
    END AS `command_line`,
    SPLIT(e.target_process_user, '\\')[0] AS `domain`,
    SPLIT(e.target_process_user, '\\')[1] AS `username`
FROM all_events_stream AS e
WHERE e.action = 'PROCESS_CREATE'
EMIT CHANGES;

INSERT INTO sap_process_stream
SELECT
    stps.`oid` AS `oid`,
    stps.`endpoint_id` AS `endpoint_id`,
    stps.`parent_process_oid` AS `parent_process_oid`,
    stps.`backing_file_oid` AS `backing_file_oid`,
    stps.`pid` AS `pid`,
    stps.`name` AS `name`,
    stps.`sid` AS `sid`,
    stps.`time_started` AS `time_started`,
    stps.`command_line` AS `command_line`,
    stps.`domain` AS `domain`,
    stps.`username` AS `username`
FROM sap_source_thread_process_stream AS stps
EMIT CHANGES;


-- Sink connector for Process table in HANA
CREATE SINK CONNECTOR process_hana_sink WITH (
'connector.class' = 'io.confluent.connect.jdbc.JdbcSinkConnector',
'tasks.max' = '1',
'topics' = 'sap_process',
'connection.url' = 'jdbc:sap://172.27.138.16:39041/?databaseName=Citadel&currentschema=EVENTS',
'connection.user' = 'SYSTEM',
'connection.password' = 'Password0',
'insert.mode' = 'UPSERT',
'auto.create' = 'true',
'auto.evolve' = 'true',
'value.converter.schema.registry.url' = 'http://schema-registry:8081',
'key.converter' = 'org.apache.kafka.connect.storage.StringConverter',
'key.converter.schemas.enable' = 'false',
'value.converter'= 'io.confluent.connect.avro.AvroConverter',
'value.converter.schemas.enable' = 'false',
'pk.mode' = 'record_value',
'pk.fields' = 'oid',
'delete.enabled' = 'false',
'table.name.format' = 'process');