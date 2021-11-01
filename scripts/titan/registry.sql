-- Create Registry stream backed by process topic
CREATE STREAM registry_stream (
    `id` VARCHAR,
    `tenant` VARCHAR,
    `endpoint_id` VARCHAR,
    `process_id` VARCHAR,
    `action` VARCHAR,
    `path` VARCHAR,
    `namehash` VARCHAR,
    `key` VARCHAR,
    `type` VARCHAR,
    `value` VARCHAR,
    `occurred` BIGINT,
    `user_id` VARCHAR
)
WITH (
	VALUE_FORMAT='AVRO', 
	KAFKA_TOPIC='registry',
	PARTITIONS=1
);

-- Source registry
CREATE STREAM source_registry_stream
AS
SELECT
    CASE
        WHEN e.source_type = LCASE('process') THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.source_process_pid, e.source_process_backing_file_path, e.source_process_time_started)
        WHEN e.source_type = LCASE('thread') THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.source_thread_process_pid, e.source_thread_process_backing_file_path, e.source_thread_process_time_started)
        WHEN e.target_type = LCASE('process') THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.target_process_pid, e.target_process_backing_file_path, e.target_process_time_started)
        WHEN e.target_type = LCASE('thread') THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.target_thread_process_pid, e.target_thread_process_backing_file_path, e.target_thread_process_time_started)
    END AS `process_id`,
    CASE
        WHEN UCASE(e.action) = 'REGISTRY_CREATE' THEN 'create'
        WHEN UCASE(e.action) = 'REGISTRY_DELETE' THEN 'delete'
        WHEN UCASE(e.action) = 'REGISTRY_ERASE' THEN 'erase'
        WHEN UCASE(e.action) = 'REGISTRY_OVERWRITE' THEN 'overwrite'
        WHEN UCASE(e.action) = 'REGISTRY_RENAME' THEN 'rename'
        WHEN UCASE(e.action) = 'REGISTRY_READ' THEN 'read'
        ELSE NULL
    END AS `action`,
    CASE
        WHEN e.source_type = LCASE('process') THEN REGISTRYID(e.tenant, e.endpoint_id, 0, e.source_process_pid, e.source_process_backing_file_path, e.source_process_time_started, action, e.source_registry_key, e.time_stamp)
        WHEN e.source_type = LCASE('thread') THEN REGISTRYID(e.tenant, e.endpoint_id, 0, e.source_thread_process_pid, e.source_thread_process_backing_file_path, e.source_thread_process_time_started, action, e.source_registry_key, e.time_stamp)
        WHEN e.target_type = LCASE('process') THEN REGISTRYID(e.tenant, e.endpoint_id, 0, e.target_process_pid, e.target_process_backing_file_path, e.target_process_time_started, action, e.source_registry_key, e.time_stamp)
        WHEN e.target_type = LCASE('thread') THEN REGISTRYID(e.tenant, e.endpoint_id, 0, e.target_thread_process_pid, e.target_thread_process_backing_file_path, e.target_thread_process_time_started, action, e.source_registry_key, e.time_stamp)
    END AS `id`,
    TENANTID(e.tenant) AS `tenant`, 
    MDRENDPOINTID(e.endpoint_id, 0) AS `mdr_endpoint_id`,
    REGISTRYKEYPATH(e.source_registry_key) AS `path`,
    REGISTRYNAMEHASH(e.source_registry_key) AS `namehash`,
    e.source_registry_key AS `key`,
    CASE
        WHEN e.source_registry_type = 0 THEN 'None'
        WHEN e.source_registry_type = 1 THEN 'String'
        WHEN e.source_registry_type = 2 THEN 'Environment String'
        WHEN e.source_registry_type = 3 THEN 'Binary'
        WHEN e.source_registry_type = 4 THEN 'Little-endian 32-bit number'
        WHEN e.source_registry_type = 5 THEN 'Big-endian 32-bit number'
        WHEN e.source_registry_type = 6 THEN 'Registry Symbolic link'
        WHEN e.source_registry_type = 7 THEN 'REG_MULTI_SZ'
        WHEN e.source_registry_type = 8 THEN 'Device driver resource list'
        WHEN e.source_registry_type = CAST('0x0B' AS INT) THEN 'Little-endian 64-bit number'
        ELSE CAST(e.source_registry_type AS STRING)
    END AS `type`,
    REGISTRYVALUE(e.source_registry_value, e.source_registry_type) AS `value`,
    e.time_stamp AS `occurred`,
    CASE
        WHEN e.source_type = LCASE('process') THEN USERID(e.tenant, e.source_process_user)
        WHEN e.source_type = LCASE('thread') THEN USERID(e.tenant, e.source_thread_process_user)
        WHEN e.target_type = LCASE('process') THEN USERID(e.tenant, e.target_process_user)
        WHEN e.target_type = LCASE('thread') THEN USERID(e.tenant, e.target_thread_process_user)
    END AS `user_id`
FROM all_events_stream AS e
EMIT CHANGES;

INSERT INTO registry_stream
SELECT
    sr.`id` AS `id`,
    sr.`tenant` AS `tenant`,
    sr.`mdr_endpoint_id` AS `endpoint_id`,
    sr.`process_id` AS `process_id`,
    sr.`action` AS `action`,
    sr.`path` AS `path`,
    sr.`namehash` AS `namehash`,
    sr.`key` AS `key`,
    sr.`type` AS `type`,
    sr.`value` AS `value`,
    sr.`occurred` AS `occurred`,
    sr.`user_id` AS `user_id`
FROM source_registry_stream AS sr
WHERE sr.`id` IS NOT NULL AND sr.`action` IS NOT NULL
EMIT CHANGES;

-- Target registry
CREATE STREAM target_registry_stream
AS
SELECT
    CASE
        WHEN e.source_type = LCASE('process') THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.source_process_pid, e.source_process_backing_file_path, e.source_process_time_started)
        WHEN e.source_type = LCASE('thread') THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.source_thread_process_pid, e.source_thread_process_backing_file_path, e.source_thread_process_time_started)
        WHEN e.target_type = LCASE('process') THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.target_process_pid, e.target_process_backing_file_path, e.target_process_time_started)
        WHEN e.target_type = LCASE('thread') THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.target_thread_process_pid, e.target_thread_process_backing_file_path, e.target_thread_process_time_started)
    END AS `process_id`,
    CASE
        WHEN UCASE(e.action) = 'REGISTRY_CREATE' THEN 'create'
        WHEN UCASE(e.action) = 'REGISTRY_DELETE' THEN 'delete'
        WHEN UCASE(e.action) = 'REGISTRY_ERASE' THEN 'erase'
        WHEN UCASE(e.action) = 'REGISTRY_OVERWRITE' THEN 'overwrite'
        WHEN UCASE(e.action) = 'REGISTRY_RENAME' THEN 'rename'
        WHEN UCASE(e.action) = 'REGISTRY_READ' THEN 'read'
        ELSE NULL
    END AS `action`,
    CASE
        WHEN e.source_type = LCASE('process') THEN REGISTRYID(e.tenant, e.endpoint_id, 0, e.source_process_pid, e.source_process_backing_file_path, e.source_process_time_started, action, e.target_registry_key, e.time_stamp)
        WHEN e.source_type = LCASE('thread') THEN REGISTRYID(e.tenant, e.endpoint_id, 0, e.source_thread_process_pid, e.source_thread_process_backing_file_path, e.source_thread_process_time_started, action, e.target_registry_key, e.time_stamp)
        WHEN e.target_type = LCASE('process') THEN REGISTRYID(e.tenant, e.endpoint_id, 0, e.target_process_pid, e.target_process_backing_file_path, e.target_process_time_started, action, e.target_registry_key, e.time_stamp)
        WHEN e.target_type = LCASE('thread') THEN REGISTRYID(e.tenant, e.endpoint_id, 0, e.target_thread_process_pid, e.target_thread_process_backing_file_path, e.target_thread_process_time_started, action, e.target_registry_key, e.time_stamp)
    END AS `id`,
    TENANTID(e.tenant) AS `tenant`,
    MDRENDPOINTID(e.endpoint_id, 0) AS `mdr_endpoint_id`,
    REGISTRYKEYPATH(e.target_registry_key) AS `path`,
    REGISTRYNAMEHASH(e.target_registry_key) AS `namehash`,
    e.target_registry_key AS `key`,
    CASE
        WHEN e.target_registry_type = 0 THEN 'None'
        WHEN e.target_registry_type = 1 THEN 'String'
        WHEN e.target_registry_type = 2 THEN 'Environment String'
        WHEN e.target_registry_type = 3 THEN 'Binary'
        WHEN e.target_registry_type = 4 THEN 'Little-endian 32-bit number'
        WHEN e.target_registry_type = 5 THEN 'Big-endian 32-bit number'
        WHEN e.target_registry_type = 6 THEN 'Registry Symbolic link'
        WHEN e.target_registry_type = 7 THEN 'REG_MULTI_SZ'
        WHEN e.target_registry_type = 8 THEN 'Device driver resource list'
        WHEN e.target_registry_type = CAST('0x0B' AS INT) THEN 'Little-endian 64-bit number'
        ELSE CAST(e.target_registry_type AS STRING)
    END AS `type`,
    REGISTRYVALUE(e.target_registry_value, e.target_registry_type) AS `value`,
    e.time_stamp AS `occurred`,
    CASE
        WHEN e.source_type = LCASE('process') THEN USERID(e.tenant, e.source_process_user)
        WHEN e.source_type = LCASE('thread') THEN USERID(e.tenant, e.source_thread_process_user)
        WHEN e.target_type = LCASE('process') THEN USERID(e.tenant, e.target_process_user)
        WHEN e.target_type = LCASE('thread') THEN USERID(e.tenant, e.target_thread_process_user)
    END AS `user_id`
FROM all_events_stream AS e
WHERE e.target_registry_type IS NOT NULL
EMIT CHANGES;

INSERT INTO registry_stream
SELECT
    tr.`id` AS `id`,
    tr.`tenant` AS `tenant`,
    tr.`mdr_endpoint_id` AS `endpoint_id`,
    tr.`process_id` AS `process_id`,
    tr.`action` AS `action`,
    tr.`path` AS `path`,
    tr.`namehash` AS `namehash`,
    tr.`key` AS `key`,
    tr.`type` AS `type`,
    tr.`value` AS `value`,
    tr.`occurred` AS `occurred`,
    tr.`user_id` AS `user_id`
FROM target_registry_stream AS tr
WHERE tr.`id` IS NOT NULL AND tr.`action` IS NOT NULL
EMIT CHANGES;


-- Sink connector for Registry table in Postgres
CREATE SINK CONNECTOR registry_pg_sink WITH (
'connector.class' = 'io.confluent.connect.jdbc.JdbcSinkConnector',
'tasks.max' = '1',
'topics' = 'registry',
'connection.url' = 'jdbc:postgresql://postgres:5432/Citadel',
'connection.user' = 'root',
'connection.password' = 'root',
'insert.mode' = 'UPSERT',
'db.timezone' = 'UTC',
'auto.create' = 'true',
'auto.evolve' = 'true',
'value.converter.schema.registry.url' = 'http://schema-registry:8081',
'key.converter' = 'org.apache.kafka.connect.storage.StringConverter',
'key.converter.schemas.enable' = 'false',
'value.converter'= 'io.confluent.connect.avro.AvroConverter',
'value.converter.schemas.enable' = 'false',
'pk.mode' = 'record_value',
'schemas.enable' = 'false',
'pk.fields' = 'id',
'delete.enabled' = 'false',
'table.name.format' = 'registry');