-- Create Process stream backed by process topic
CREATE STREAM process_stream (
    `id` VARCHAR,
    `tenant` VARCHAR,
    `endpoint_id` VARCHAR,
    `pid` BIGINT,
    `parent_id` VARCHAR,
    `user_id` VARCHAR,
    `started` BIGINT,
    `ended` BIGINT,
    `commandline` VARCHAR,
    `backing_file_id` VARCHAR
)
WITH (
	VALUE_FORMAT='AVRO', 
	KAFKA_TOPIC='process',
	PARTITIONS=1
);

-- Source process
CREATE STREAM source_process_stream
AS
SELECT
    TENANTID(e.tenant) AS `tenant`,
    MDRENDPOINTID(e.endpoint_id, 0) AS `mdr_endpoint_id`,
    e.source_process_pid AS `pid`,
    PROCESSID() AS `parent_id`,
    CASE
        WHEN e.source_process_user IS NOT NULL THEN USERID(e.tenant, e.source_process_user)
        ELSE USERID(e.tenant, '')
    END AS `user_id`,
    e.source_process_time_started AS `started`,
    CASE
        WHEN e.action = 'PROCESS_CREATE' THEN e.time_stamp
        ELSE CAST(0 as BIGINT)
    END AS `ended`,
    e.source_process_command_line AS `commandline`,
    e.source_process_backing_file_path AS `backing_file_path`
FROM all_events_stream AS e
WHERE e.source_process_pid IS NOT NULL
EMIT CHANGES;

INSERT INTO process_stream
SELECT
    PROCESSID(sp.`tenant`, sp.`mdr_endpoint_id`, sp.`pid`, sp.`backing_file_path`, sp.`started`) AS `id`,
    sp.`tenant` AS `tenant`,
    sp.`mdr_endpoint_id` AS `endpoint_id`,
    sp.`pid` AS `pid`,
    sp.`parent_id` AS `parent_id`,
    sp.`user_id` AS `user_id`,
    sp.`started` AS `started`,
    sp.`ended` AS `ended`,
    sp.`commandline` AS `commandline`,
    sp.`backing_file_path` AS `backing_file_id`
FROM source_process_stream AS sp
EMIT CHANGES;

-- Target process
CREATE STREAM target_process_stream
AS
SELECT
    TENANTID(e.tenant) AS `tenant`,
    MDRENDPOINTID(e.endpoint_id, 0) AS `mdr_endpoint_id`,
    e.target_process_pid AS `pid`,
    PROCESSID(e.tenant, endpoint_id, e.source_process_pid, e.source_process_backing_file_path, e.source_process_time_started) AS `parent_id`,
    CASE
        WHEN e.target_process_user IS NOT NULL THEN USERID(e.tenant, e.target_process_user)
        ELSE USERID(e.tenant, '')
    END AS `user_id`,
    e.target_process_time_started AS `started`,
    CASE
        WHEN e.action = 'PROCESS_CREATE' THEN e.time_stamp
        ELSE CAST(0 as BIGINT)
    END AS `ended`,
    e.target_process_command_line AS `commandline`,
    e.target_process_backing_file_path AS `backing_file_path`
FROM all_events_stream AS e
WHERE e.target_process_pid IS NOT NULL
EMIT CHANGES;

INSERT INTO process_stream
SELECT
    PROCESSID(tp.`tenant`, tp.`mdr_endpoint_id`, tp.`pid`, tp.`backing_file_path`, tp.`started`) AS `id`,
    tp.`tenant` AS `tenant`,
    tp.`mdr_endpoint_id` AS `endpoint_id`,
    tp.`pid` AS `pid`,
    tp.`parent_id` AS `parent_id`,
    tp.`user_id` AS `user_id`,
    tp.`started` AS `started`,
    tp.`ended` AS `ended`,
    tp.`commandline` AS `commandline`,
    tp.`backing_file_path` AS `backing_file_id`
FROM target_process_stream AS tp
EMIT CHANGES;

-- Source Thread process
CREATE STREAM source_thread_process_stream
AS
SELECT
    TENANTID(e.tenant) AS `tenant`,
    MDRENDPOINTID(e.endpoint_id, 0) AS `mdr_endpoint_id`,
    e.source_thread_process_pid AS `pid`,
    PROCESSID() AS `parent_id`,
    CASE
        WHEN e.source_thread_process_user IS NOT NULL THEN USERID(e.tenant, e.source_thread_process_user)
        ELSE USERID(e.tenant, '')
    END AS `user_id`,
    e.source_thread_process_time_started AS `started`,
    CASE
        WHEN e.action = 'PROCESS_CREATE' THEN e.time_stamp
        ELSE CAST(0 as BIGINT)
    END AS `ended`,
    e.source_thread_process_command_line AS `commandline`,
    e.source_thread_process_backing_file_path AS `backing_file_path`
FROM all_events_stream AS e
WHERE e.source_thread_process_pid IS NOT NULL
EMIT CHANGES;

INSERT INTO process_stream
SELECT
    PROCESSID(stp.`tenant`, stp.`mdr_endpoint_id`, stp.`pid`, stp.`backing_file_path`, stp.`started`) AS `id`,
    stp.`tenant` AS `tenant`,
    stp.`mdr_endpoint_id` AS `endpoint_id`,
    stp.`pid` AS `pid`,
    stp.`parent_id` AS `parent_id`,
    stp.`user_id` AS `user_id`,
    stp.`started` AS `started`,
    stp.`ended` AS `ended`,
    stp.`commandline` AS `commandline`,
    stp.`backing_file_path` AS `backing_file_id`
FROM source_thread_process_stream AS stp
EMIT CHANGES;

-- Target Thread process
CREATE STREAM target_thread_process_stream
AS
SELECT
    TENANTID(e.tenant) AS `tenant`,
    MDRENDPOINTID(e.endpoint_id, 0) AS `mdr_endpoint_id`,
    e.target_thread_process_pid AS `pid`,
    PROCESSID(e.tenant, endpoint_id, e.source_thread_process_pid, e.source_thread_process_backing_file_path, e.source_thread_process_time_started) AS `parent_id`,
    CASE
        WHEN e.target_thread_process_user IS NOT NULL THEN USERID(e.tenant, e.target_thread_process_user)
        ELSE USERID(e.tenant, '')
    END AS `user_id`,
    e.target_thread_process_time_started AS `started`,
    CASE
        WHEN e.action = 'PROCESS_CREATE' THEN e.time_stamp
        ELSE CAST(0 as BIGINT)
    END AS `ended`,
    e.target_thread_process_command_line AS `commandline`,
    e.target_thread_process_backing_file_path AS `backing_file_path`
FROM all_events_stream AS e
WHERE e.target_thread_process_pid IS NOT NULL
EMIT CHANGES;

INSERT INTO process_stream
SELECT
    PROCESSID(ttp.`tenant`, ttp.`mdr_endpoint_id`, ttp.`pid`, ttp.`backing_file_path`, ttp.`started`) AS `id`,
    ttp.`tenant` AS `tenant`,
    ttp.`mdr_endpoint_id` AS `endpoint_id`,
    ttp.`pid` AS `pid`,
    ttp.`parent_id` AS `parent_id`,
    ttp.`user_id` AS `user_id`,
    ttp.`started` AS `started`,
    ttp.`ended` AS `ended`,
    ttp.`commandline` AS `commandline`,
    ttp.`backing_file_path` AS `backing_file_id`
FROM target_thread_process_stream AS ttp
EMIT CHANGES;

-- Target Memory Region Process is not persisted by Venus at the moment. Skipping.

-- Sink connector for Process table in Postgres
CREATE SINK CONNECTOR process_pg_sink WITH (
'connector.class' = 'io.confluent.connect.jdbc.JdbcSinkConnector',
'tasks.max' = '1',
'topics' = 'process',
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
'table.name.format' = 'process');