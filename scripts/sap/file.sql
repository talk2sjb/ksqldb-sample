-- Create File stream backed by file topic
CREATE STREAM sap_file_stream (
    `oid` VARCHAR,
    `endpoint_id` VARCHAR,
    `device_oid` VARCHAR,
    `drive_letter` VARCHAR,
    `path` VARCHAR,
    `removable` BOOLEAN,
    `skip_letter` BOOLEAN,
    `type` INT
)
WITH (
	VALUE_FORMAT='AVRO', 
	KAFKA_TOPIC='sap_file',
	PARTITIONS=1
);


-- Source Thread Process Backing File
CREATE STREAM sap_source_thread_process_backing_file_stream
AS
SELECT
    FILEID('', e.endpoint_id, e.source_thread_process_backing_file_path, e.source_thread_process_backing_file_time_stamp) AS `oid`,
    e.endpoint_id AS `endpoint_id`,
    DEVICEID(e.source_thread_process_backing_file_device_type, 
            e.source_thread_process_backing_file_device_name, 
            e.source_thread_process_backing_file_device_label, 
            e.source_thread_process_backing_file_device_serial_number, 
            e.source_thread_process_backing_file_device_product_name, 
            e.source_thread_process_backing_file_device_vendor_name, 
            e.source_thread_process_backing_file_device_dos_name, 
            e.source_thread_process_backing_file_device_mount_point, 
            e.source_thread_process_backing_file_device_size) AS `device_oid`,
    e.source_thread_process_backing_file_drive_letter AS `drive_letter`,
    e.source_thread_process_backing_file_path AS `path`,
    e.source_thread_process_backing_file_removable AS `removable`,
    e.source_thread_process_backing_file_skip_letter AS `skip_letter`,
    e.source_thread_process_backing_file_type AS `type`
FROM all_events_stream AS e
EMIT CHANGES;


INSERT INTO sap_file_stream
SELECT
    stpbfs.`oid` AS `oid`,
    stpbfs.`endpoint_id` AS `endpoint_id`,
    stpbfs.`device_oid` AS `device_oid`,
    stpbfs.`drive_letter` AS `drive_letter`,
    stpbfs.`path` AS `path`,
    stpbfs.`removable` AS `removable`,
    stpbfs.`skip_letter` AS `skip_letter`,
    stpbfs.`type` AS `type`
FROM sap_source_thread_process_backing_file_stream AS stpbfs
WHERE stpbfs.`oid` IS NOT NULL
EMIT CHANGES;


-- Target File
CREATE STREAM sap_target_file_stream
AS
SELECT
    FILEID('', e.endpoint_id, e.target_file_path, e.target_file_time_stamp) AS `oid`,
    e.endpoint_id AS `endpoint_id`,
    DEVICEID(e.target_file_device_type, 
            e.target_file_device_name, 
            e.target_file_device_label, 
            e.target_file_device_serial_number, 
            e.target_file_device_product_name, 
            e.target_file_device_vendor_name, 
            e.target_file_device_dos_name, 
            e.target_file_device_mount_point, 
            e.target_file_device_size) AS `device_oid`,
    e.target_file_drive_letter AS `drive_letter`,
    e.target_file_path AS `path`,
    e.target_file_removable AS `removable`,
    e.target_file_skip_letter AS `skip_letter`,
    e.target_file_type AS `type`
FROM all_events_stream AS e
EMIT CHANGES;


INSERT INTO sap_file_stream
SELECT
    tfs.`oid` AS `oid`,
    tfs.`endpoint_id` AS `endpoint_id`,
    tfs.`device_oid` AS `device_oid`,
    tfs.`drive_letter` AS `drive_letter`,
    tfs.`path` AS `path`,
    tfs.`removable` AS `removable`,
    tfs.`skip_letter` AS `skip_letter`,
    tfs.`type` AS `type`
FROM sap_target_file_stream AS tfs
WHERE tfs.`oid` IS NOT NULL
EMIT CHANGES;


-- Target Destination File
CREATE STREAM sap_target_destination_file_stream
AS
SELECT
    FILEID('', e.endpoint_id, e.target_destination_file_path, e.target_destination_file_time_stamp) AS `oid`,
    e.endpoint_id AS `endpoint_id`,
    DEVICEID(e.target_destination_file_device_type, 
            e.target_destination_file_device_name, 
            e.target_destination_file_device_label, 
            e.target_destination_file_device_serial_number, 
            e.target_destination_file_device_product_name, 
            e.target_destination_file_device_vendor_name, 
            e.target_destination_file_device_dos_name, 
            e.target_destination_file_device_mount_point, 
            e.target_destination_file_device_size) AS `device_oid`,
    e.target_destination_file_drive_letter AS `drive_letter`,
    e.target_destination_file_path AS `path`,
    e.target_destination_file_removable AS `removable`,
    e.target_destination_file_skip_letter AS `skip_letter`,
    e.target_destination_file_type AS `type`
FROM all_events_stream AS e
EMIT CHANGES;


INSERT INTO sap_file_stream
SELECT
    tfs.`oid` AS `oid`,
    tfs.`endpoint_id` AS `endpoint_id`,
    tfs.`device_oid` AS `device_oid`,
    tfs.`drive_letter` AS `drive_letter`,
    tfs.`path` AS `path`,
    tfs.`removable` AS `removable`,
    tfs.`skip_letter` AS `skip_letter`,
    tfs.`type` AS `type`
FROM sap_target_destination_file_stream AS tfs
WHERE tfs.`oid` IS NOT NULL
EMIT CHANGES;


-- Sink connector for File table in HANA
CREATE SINK CONNECTOR file_hana_sink WITH (
'connector.class' = 'io.confluent.connect.jdbc.JdbcSinkConnector',
'tasks.max' = '1',
'topics' = 'sap_file',
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
'table.name.format' = 'file');