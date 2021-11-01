-- TODO : Ignoring source file type as it's not tracked in Venus at the moment
-- Create File stream backed by file topic
CREATE STREAM file_stream (
    `id` VARCHAR,
    `tenant` VARCHAR,
    `endpoint_id` VARCHAR,
    `path` VARCHAR,
    `md5` VARCHAR,
    `sha256` VARCHAR,
    `ngavhash` VARCHAR,
    `created` BIGINT,
    `created_by_process_id` VARCHAR,
    `created_by_user_id` VARCHAR,
    `deleted` BIGINT,
    `deleted_by_process_id` VARCHAR,
    `deleted_by_user_id` VARCHAR
)
WITH (
	VALUE_FORMAT='AVRO', 
	KAFKA_TOPIC='file',
	PARTITIONS=1
);


-- File Stream
CREATE STREAM enriched_file_stream
AS
SELECT
    CASE
        WHEN UCASE(e.action) = 'FILE_COPY' THEN e.target_destination_file_path
        WHEN UCASE(e.action) = 'FILE_MOVE' THEN e.target_destination_file_path
        ELSE e.target_file_path
    END AS `file_path`,
    TENANTID(e.tenant) AS `tenant`,
    MDRENDPOINTID(e.endpoint_id, 0) AS `mdr_endpoint_id`,
    -- Use target file wherever destination file is not created, else use destination file
    CASE
        WHEN UCASE(e.action) = 'FILE_COPY' THEN e.target_destination_file_path
        WHEN UCASE(e.action) = 'FILE_MOVE' THEN e.target_destination_file_path
        ELSE e.target_file_path
    END AS `path`,
    CASE
        WHEN UCASE(e.action) = 'FILE_COPY' THEN e.target_destination_file_md5
        WHEN UCASE(e.action) = 'FILE_MOVE' THEN e.target_destination_file_md5
        ELSE e.target_file_md5
    END AS `md5`,
    CASE
        WHEN UCASE(e.action) = 'FILE_COPY' THEN e.target_destination_file_sha256
        WHEN UCASE(e.action) = 'FILE_MOVE' THEN e.target_destination_file_sha256
        ELSE e.target_file_sha256
    END AS `sha256`,
    CAST('' AS STRING) AS `ngavhash`,
    CASE
        WHEN UCASE(e.action) != 'FILE_DELETE' AND LCASE(source_type) = 'process' THEN e.time_stamp
        WHEN UCASE(e.action) != 'FILE_DELETE' AND LCASE(source_type) = 'thread' THEN e.time_stamp
        ELSE NULL
    END AS `created`,
    CASE
        WHEN UCASE(e.action) != 'FILE_DELETE' AND LCASE(source_type) = 'process' THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.source_process_pid, e.source_process_backing_file_path, e.source_process_time_started)
        WHEN UCASE(e.action) != 'FILE_DELETE' AND LCASE(source_type) = 'thread' THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.source_thread_process_pid, e.source_thread_process_backing_file_path, e.source_thread_process_time_started)
        ELSE NULL
    END AS `created_by_process_id`,
    CASE
        WHEN UCASE(e.action) != 'FILE_DELETE' AND LCASE(e.source_type) = 'process' THEN USERID(e.tenant, e.source_process_user)
        WHEN UCASE(e.action) != 'FILE_DELETE' AND LCASE(e.source_type) = 'thread' THEN USERID(e.tenant, e.source_thread_process_user)
        ELSE NULL
    END AS `created_by_user_id`,
    CASE
        WHEN UCASE(e.action) != 'FILE_CREATE' AND LCASE(source_type) = 'process' THEN e.time_stamp
        WHEN UCASE(e.action) != 'FILE_CREATE' AND LCASE(source_type) = 'thread' THEN e.time_stamp
        WHEN UCASE(e.action) != 'FILE_COPY' AND LCASE(source_type) = 'process' THEN e.time_stamp
        WHEN UCASE(e.action) != 'FILE_COPY' AND LCASE(source_type) = 'thread' THEN e.time_stamp
        ELSE NULL
    END AS `deleted`,
    CASE
        WHEN UCASE(e.action) != 'FILE_CREATE' AND LCASE(source_type) = 'process' THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.source_process_pid, e.source_process_backing_file_path, e.source_process_time_started)
        WHEN UCASE(e.action) != 'FILE_CREATE' AND LCASE(source_type) = 'thread' THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.source_thread_process_pid, e.source_thread_process_backing_file_path, e.source_thread_process_time_started)
        WHEN UCASE(e.action) != 'FILE_COPY' AND LCASE(source_type) = 'process' THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.source_process_pid, e.source_process_backing_file_path, e.source_process_time_started)
        WHEN UCASE(e.action) != 'FILE_COPY' AND LCASE(source_type) = 'thread' THEN PROCESSID(e.tenant, e.endpoint_id, 0, e.source_thread_process_pid, e.source_thread_process_backing_file_path, e.source_thread_process_time_started)
        ELSE NULL
    END AS `deleted_by_process_id`,
    CASE
        WHEN UCASE(e.action) != 'FILE_CREATE' AND LCASE(e.source_type) = 'process' THEN USERID(e.tenant, e.source_process_user)
        WHEN UCASE(e.action) != 'FILE_CREATE' AND LCASE(e.source_type) = 'thread' THEN USERID(e.tenant, e.source_thread_process_user)
        WHEN UCASE(e.action) != 'FILE_COPY' AND LCASE(e.source_type) = 'process' THEN USERID(e.tenant, e.source_process_user)
        WHEN UCASE(e.action) != 'FILE_COPY' AND LCASE(e.source_type) = 'thread' THEN USERID(e.tenant, e.source_thread_process_user)
        ELSE NULL
    END AS `deleted_by_user_id`
FROM all_events_stream AS e
WHERE LCASE(e.target_type) = 'file'
EMIT CHANGES;


INSERT INTO file_stream
SELECT
    FILEID(fs.`tenant`, fs.`mdr_endpoint_id`, fs.`file_path`) AS `id`,
    fs.`tenant` AS `tenant`,
    fs.`mdr_endpoint_id` AS `endpoint_id`,
    fs.`path` AS `path`,
    fs.`md5` AS `md5`,
    fs.`sha256` AS `sha256`,
    fs.`ngavhash` AS `ngavhash`,
    fs.`created` AS `created`,
    fs.`created_by_process_id` AS `created_by_process_id`,
    fs.`created_by_user_id` AS `created_by_user_id`,
    fs.`deleted` AS `deleted`,
    fs.`deleted_by_process_id` AS `deleted_by_process_id`,
    fs.`deleted_by_user_id` AS `deleted_by_user_id`
FROM enriched_file_stream AS fs
EMIT CHANGES;


-- Sink connector for File table in Postgres
CREATE SINK CONNECTOR file_pg_sink WITH (
'connector.class' = 'io.confluent.connect.jdbc.JdbcSinkConnector',
'tasks.max' = '1',
'topics' = 'file',
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
'table.name.format' = 'file');