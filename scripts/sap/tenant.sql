-- Create Tenant stream backed by tenant topic
CREATE STREAM tenant_stream (
    `id` VARCHAR,
    `name` VARCHAR,
    `status` VARCHAR,
    `licenses` VARCHAR,
    `edr_version` VARCHAR,
    `edr_licenses` VARCHAR,
    `edr_username` VARCHAR,
    `edr_password` VARCHAR,
    `edr_host` VARCHAR,
    `ngav_version` VARCHAR,
    `ngav_licenses` VARCHAR,
    `ngav_username` VARCHAR,
    `ngav_password` VARCHAR,
    `ngav_host` VARCHAR,
	`ngav_database` VARCHAR,
    `ngav_port` VARCHAR,
    `ngav_license_key` VARCHAR
)
WITH (
	VALUE_FORMAT='AVRO', 
	KAFKA_TOPIC='tenant',
	PARTITIONS=1
);

-- Insert into tenant_stream
INSERT INTO tenant_stream
SELECT
    PROCESSID(e.tenant, endpoint_id, e.source_process_pid, e.source_process_backing_file_path, e.source_process_time_started) AS `id`,
    e.tenant AS `tenant`,
    MDRENDPOINTID(e.endpoint_id, 0) AS `endpoint_id`,
    e.source_process_pid AS `pid`,
    PROCESSID() AS `parent_id`,
    USERID(e.tenant, e.source_process_user) AS `user_id`,
    e.source_process_time_started AS `started`,
    CASE
        WHEN e.action = 'PROCESS_CREATE' THEN e.time_stamp
        ELSE CAST(0 as BIGINT)
    END AS `ended`,
    e.source_process_command_line AS `commandline`,
    e.source_process_backing_file_path AS `backing_file_id`
FROM all_events_stream AS e
WHERE e.source_process_pid IS NOT NULL
EMIT CHANGES;