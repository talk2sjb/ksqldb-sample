-- Create Registry stream backed by process topic
CREATE STREAM sap_registry_stream (
    `oid` VARCHAR,
    `endpoint_id` VARCHAR,
    `data` VARCHAR,
    `key` VARCHAR,
    `type` INT,
    `value` VARCHAR
)
WITH (
	VALUE_FORMAT='AVRO', 
	KAFKA_TOPIC='sap_registry',
	PARTITIONS=1
);

-- Registry Stream
CREATE STREAM sap_enriched_registry_stream
AS
SELECT
    e.id AS `oid`,
    e.endpoint_id AS `endpoint_id`,
    CASE
        WHEN e.action = 'REGISTRY_CREATE' THEN NULL
        WHEN e.action = 'REGISTRY_DELETE' THEN NULL
        WHEN e.action = 'REGISTRY_ERASE' THEN e.target_registry_data
        WHEN e.action = 'REGISTRY_OVERWRITE' THEN e.target_registry_data
        WHEN e.action = 'REGISTRY_SCAN' THEN e.source_registry_data
    END AS `data`,
    CASE
        WHEN e.action = 'REGISTRY_CREATE' THEN e.target_registry_key
        WHEN e.action = 'REGISTRY_DELETE' THEN e.target_registry_key
        WHEN e.action = 'REGISTRY_ERASE' THEN e.target_registry_key
        WHEN e.action = 'REGISTRY_OVERWRITE' THEN e.target_registry_key
        WHEN e.action = 'REGISTRY_SCAN' THEN e.source_registry_key
    END AS `key`,
    CASE
        WHEN e.action = 'REGISTRY_CREATE' THEN 0
        WHEN e.action = 'REGISTRY_DELETE' THEN 0
        WHEN e.action = 'REGISTRY_ERASE' THEN e.target_registry_type
        WHEN e.action = 'REGISTRY_OVERWRITE' THEN e.target_registry_type
        WHEN e.action = 'REGISTRY_SCAN' THEN e.source_registry_type
    END AS `type`,
    CASE
        WHEN e.action = 'REGISTRY_CREATE' THEN NULL
        WHEN e.action = 'REGISTRY_DELETE' THEN NULL
        WHEN e.action = 'REGISTRY_ERASE' THEN e.target_registry_value
        WHEN e.action = 'REGISTRY_OVERWRITE' THEN e.target_registry_value
        WHEN e.action = 'REGISTRY_SCAN' THEN e.source_registry_value
    END AS `value`
FROM all_events_stream AS e
WHERE e.action LIKE '%REGISTRY%'
EMIT CHANGES;

INSERT INTO sap_registry_stream
SELECT
    rs.`oid` AS `oid`,
    rs.`endpoint_id` AS `endpoint_id`,
    rs.`data` AS `data`,
    rs.`key` AS `key`,
    rs.`type` AS `type`,
    rs.`value` AS `value`
FROM sap_enriched_registry_stream AS rs
EMIT CHANGES;


-- Sink connector for Registry table in HANA
CREATE SINK CONNECTOR registry_hana_sink WITH (
'connector.class' = 'io.confluent.connect.jdbc.JdbcSinkConnector',
'tasks.max' = '1',
'topics' = 'sap_registry',
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
'table.name.format' = 'registry');