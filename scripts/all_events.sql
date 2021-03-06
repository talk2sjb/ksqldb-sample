-- Stream definition for all event types (parent with all fields)
CREATE STREAM all_events_stream (
  id VARCHAR,
  time_stamp BIGINT,
  insertion_time_stamp BIGINT,
  action VARCHAR,
  impact INT,
  is_origin BOOLEAN,
  is_key BOOLEAN,
  is_basic BOOLEAN,
  is_taint_transfer BOOLEAN,
  taint VARCHAR,
  is_tainted BOOLEAN,
  target_destination_file_md5 VARCHAR,
  target_destination_file_sha256 VARCHAR,
  target_destination_file_device_size INT,
  target_destination_file_device_dos_name VARCHAR,
  target_destination_file_device_label VARCHAR,
  target_destination_file_device_name VARCHAR,
  target_destination_file_device_product_name VARCHAR,
  target_destination_file_device_serial_number VARCHAR,
  target_destination_file_device_vendor_name VARCHAR,
  target_destination_file_device_type VARCHAR,
  target_destination_file_drive_letter VARCHAR,
  target_destination_file_device_mount_point VARCHAR,
  target_destination_file_path VARCHAR,
  target_destination_file_reference_number INT,
  target_destination_file_removable BOOLEAN,
  target_destination_file_skip_letter BOOLEAN,
  target_destination_file_type INT,
  target_destination_file_time_stamp BIGINT,
  condition_ids ARRAY<VARCHAR>,
  condition_names ARRAY<VARCHAR>,
  responses_ids ARRAY<VARCHAR>,
  analyses_ids ARRAY<VARCHAR>,
  endpoint_id VARCHAR,
  removable_device_ids ARRAY<VARCHAR>,
  behavior_id ARRAY<VARCHAR>,
  event_type VARCHAR,
  target_memory_region_allocation_protect ARRAY<VARCHAR>,
  target_memory_region_protect ARRAY<VARCHAR>,
  target_file_property_fields ARRAY<VARCHAR>,
  target_file_property_values ARRAY<VARCHAR>,
  source_type VARCHAR,
  target_type VARCHAR,
  source_driver_backing_file_md5 VARCHAR,
  source_driver_backing_file_device_type VARCHAR,
  source_driver_backing_file_path VARCHAR,
  source_driver_backing_file_reference_number INT,
  source_driver_backing_file_type INT,
  source_driver_name VARCHAR,
  source_driver_time_started BIGINT,
  source_file_md5 VARCHAR,
  source_file_device_type VARCHAR,
  source_file_drive_letter VARCHAR,
  source_file_device_name VARCHAR,
  source_file_removable BOOLEAN,
  source_file_skip_letter BOOLEAN,
  source_file_path VARCHAR,
  source_file_reference_number INT,
  source_file_type INT,
  source_file_device_label VARCHAR,
  source_file_device_serial_number VARCHAR,
  source_file_device_product_name VARCHAR,
  source_file_device_vendor_name VARCHAR,
  source_file_device_size INT,
  source_process_backing_file_md5 VARCHAR,
  source_process_backing_file_device_type VARCHAR,
  source_process_backing_file_drive_letter VARCHAR,
  source_process_backing_file_device_name VARCHAR,
  source_process_backing_file_removable BOOLEAN,
  source_process_backing_file_skip_letter BOOLEAN,
  source_process_backing_file_path VARCHAR,
  source_process_backing_file_reference_number INT,
  source_process_backing_file_type INT,
  source_process_name VARCHAR,
  source_process_sid VARCHAR,
  source_process_user VARCHAR,
  source_process_parent_pid BIGINT,
  source_process_pid BIGINT,
  source_process_time_started BIGINT,
  source_process_command_line VARCHAR,
  source_registry_data VARCHAR,
  source_registry_key VARCHAR,
  source_registry_type INT,
  source_registry_value VARCHAR,
  source_tcpip_direction VARCHAR,
  source_tcpip_local_host VARCHAR,
  source_tcpip_local_port INT,
  source_tcpip_remote_host VARCHAR,
  source_tcpip_remote_port INT,
  source_tcpip_version INT,
  source_process_backing_file_device_label VARCHAR,
  source_process_backing_file_device_serial_number VARCHAR,
  source_process_backing_file_device_product_name VARCHAR,
  source_process_backing_file_device_vendor_name VARCHAR,
  source_process_backing_file_device_size INT,
  source_thread_process_backing_file_md5 VARCHAR,
  source_thread_process_backing_file_device_type VARCHAR,
  source_thread_process_backing_file_device_dos_name VARCHAR,
  source_thread_process_backing_file_device_mount_point VARCHAR,
  source_thread_process_backing_file_drive_letter VARCHAR,
  source_thread_process_backing_file_device_name VARCHAR,
  source_thread_process_backing_file_removable BOOLEAN,
  source_thread_process_backing_file_skip_letter BOOLEAN,
  source_thread_process_backing_file_path VARCHAR,
  source_thread_process_backing_file_reference_number INT,
  source_thread_process_backing_file_type INT,
  source_thread_process_backing_file_time_stamp BIGINT,
  source_thread_process_name VARCHAR,
  source_thread_process_sid VARCHAR,
  source_thread_process_user VARCHAR,
  source_thread_process_parent_pid BIGINT,
  source_thread_process_pid BIGINT,
  source_thread_process_time_started BIGINT,
  source_thread_process_command_line VARCHAR,
  source_thread_process_backing_file_device_label VARCHAR,
  source_thread_process_backing_file_device_serial_number VARCHAR,
  source_thread_process_backing_file_device_product_name VARCHAR,
  source_thread_process_backing_file_device_vendor_name VARCHAR,
  source_thread_process_backing_file_device_size INT,
  source_thread_start_address INT,
  source_thread_tid INT,
  source_thread_time_finished VARCHAR,
  source_thread_time_started BIGINT,
  target_driver_backing_file_md5 VARCHAR,
  target_driver_backing_file_device_type VARCHAR,
  target_driver_backing_file_path VARCHAR,
  target_driver_backing_file_reference_number INT,
  target_driver_backing_file_type INT,
  target_driver_name VARCHAR,
  target_driver_time_started BIGINT,
  target_file_device_type VARCHAR,
  target_file_drive_letter VARCHAR,
  target_file_device_name VARCHAR,
  target_file_device_dos_name VARCHAR,
  target_file_removable BOOLEAN,
  target_file_skip_letter BOOLEAN,
  target_file_path VARCHAR,
  target_file_reference_number INT,
  target_file_type INT,
  target_file_device_label VARCHAR,
  target_file_device_serial_number VARCHAR,
  target_file_device_product_name VARCHAR,
  target_file_device_vendor_name VARCHAR,
  target_file_device_mount_point VARCHAR,
  target_file_device_size INT,
  target_link_type INT,
  target_link_name VARCHAR,
  target_memory_region_allocation_base INT,
  target_memory_region_base_address INT,
  target_memory_region_page_type INT,
  target_memory_region_process_backing_file_md5 VARCHAR,
  target_memory_region_process_backing_file_device_type VARCHAR,
  target_memory_region_process_backing_file_drive_letter VARCHAR,
  target_memory_region_process_backing_file_device_name VARCHAR,
  target_memory_region_process_backing_file_removable BOOLEAN,
  target_memory_region_process_backing_file_skip_letter BOOLEAN,
  target_memory_region_process_backing_file_path VARCHAR,
  target_memory_region_process_backing_file_reference_number INT,
  target_memory_region_process_backing_file_type INT,
  target_memory_region_process_name VARCHAR,
  target_memory_region_process_sid VARCHAR,
  target_memory_region_process_user VARCHAR,
  target_memory_region_process_parent_pid BIGINT,
  target_memory_region_process_pid BIGINT,
  target_memory_region_process_time_started BIGINT,
  target_memory_region_process_command_line VARCHAR,
  target_memory_region_size INT,
  target_memory_region_process_backing_file_device_label VARCHAR,
  target_memory_region_process_backing_file_device_serial_number VARCHAR,
  target_memory_region_process_backing_file_device_product_name VARCHAR,
  target_memory_region_process_backing_file_device_vendor_name VARCHAR,
  target_memory_region_process_backing_file_device_size INT,
  target_process_backing_file_device_type VARCHAR,
  target_process_command_line VARCHAR,
  target_process_backing_file_drive_letter VARCHAR,
  target_process_backing_file_device_name VARCHAR,
  target_process_backing_file_removable BOOLEAN,
  target_process_backing_file_skip_letter BOOLEAN,
  target_process_backing_file_path VARCHAR,
  target_process_backing_file_reference_number INT,
  target_process_backing_file_type INT,
  target_process_backing_file_device_label VARCHAR,
  target_process_backing_file_device_serial_number VARCHAR,
  target_process_backing_file_device_product_name VARCHAR,
  target_process_backing_file_device_vendor_name VARCHAR,
  target_process_backing_file_device_size INT,
  target_process_name VARCHAR,
  target_process_sid VARCHAR,
  target_process_user VARCHAR,
  target_process_parent_pid BIGINT,
  target_process_pid BIGINT,
  target_process_time_started BIGINT,
  target_registry_data VARCHAR,
  target_registry_key VARCHAR,
  target_registry_type INT,
  target_registry_value VARCHAR,
  target_tcpip_direction VARCHAR,
  target_tcpip_local_host VARCHAR,
  target_tcpip_local_port INT,
  target_tcpip_remote_host VARCHAR,
  target_tcpip_remote_port INT,
  target_tcpip_version INT,
  target_thread_process_backing_file_md5 VARCHAR,
  target_thread_process_backing_file_device_type VARCHAR,
  target_thread_process_backing_file_drive_letter VARCHAR,
  target_thread_process_backing_file_device_name VARCHAR,
  target_thread_process_backing_file_removable BOOLEAN,
  target_thread_process_backing_file_skip_letter BOOLEAN,
  target_thread_process_backing_file_path VARCHAR,
  target_thread_process_backing_file_reference_number INT,
  target_thread_process_backing_file_type INT,
  target_thread_process_name VARCHAR,
  target_thread_process_sid VARCHAR,
  target_thread_process_user VARCHAR,
  target_thread_process_parent_pid BIGINT,
  target_thread_process_pid BIGINT,
  target_thread_process_time_started BIGINT,
  target_thread_process_backing_file_device_label VARCHAR,
  target_thread_process_backing_file_device_serial_number VARCHAR,
  target_thread_process_backing_file_device_product_name VARCHAR,
  target_thread_process_backing_file_device_vendor_name VARCHAR,
  target_thread_process_backing_file_device_size INT,
  target_thread_start_address INT,
  target_thread_tid INT,
  target_thread_time_finished VARCHAR,
  target_thread_time_started BIGINT,
  target_thread_process_command_line VARCHAR,
  target_process_backing_file_sha256 VARCHAR,
  target_process_backing_file_ssdeep VARCHAR,
  target_process_backing_file_md5 VARCHAR,
  target_file_sha256 VARCHAR,
  target_file_ssdeep VARCHAR,
  target_file_md5 VARCHAR,
  target_file_time_stamp BIGINT,
  source_mutex_name VARCHAR,
  target_mutex_name VARCHAR,
  source_tcpip_reverse_dns_hostname ARRAY<VARCHAR>,
  target_tcpip_reverse_dns_hostname ARRAY<VARCHAR>,
  source_tcpip_whois VARCHAR,
  target_tcpip_whois VARCHAR,
  source_tcpip_country VARCHAR,
  target_tcpip_country VARCHAR,
  source_tcpip_region VARCHAR,
  target_tcpip_region VARCHAR,
  source_tcpip_city VARCHAR,
  target_tcpip_city VARCHAR,
  source_tcpip_latitude VARCHAR,
  target_tcpip_latitude VARCHAR,
  source_tcpip_longitude VARCHAR,
  target_tcpip_longitude VARCHAR,
  source_tcpip_proxy_type VARCHAR,
  target_tcpip_proxy_type VARCHAR,
  tcpip_corresponding_event VARCHAR,
  tags ARRAY<VARCHAR>,
  tenant VARCHAR,
  target_dns_query_name VARCHAR,
  target_http_request_host VARCHAR,
  target_http_request_uri VARCHAR,
  target_dns_query_ips ARRAY<VARCHAR>,
  target_http_request_method VARCHAR,
  endpoint_ip VARCHAR,
  endpoint_name VARCHAR,
  endpoint_mac VARCHAR,
  endpoint_domain VARCHAR,
  driver_version VARCHAR,
  sensor_mode VARCHAR,
  policy_id VARCHAR,
  policy_name VARCHAR,
  target_http_request_user_agent VARCHAR,
  target_device_size INT,
  target_device_type VARCHAR,
  target_device_dos_name VARCHAR,
  target_device_label VARCHAR,
  target_device_mount_point VARCHAR,
  target_device_is_removable BOOLEAN,
  target_device_name VARCHAR,
  target_device_product_name VARCHAR,
  target_device_serial_number VARCHAR,
  target_device_time_stamp BIGINT,
  target_device_vendor_name VARCHAR,
  target_dns_ip ARRAY<VARCHAR>,
  target_dns_name VARCHAR,
  target_http_host VARCHAR,
  target_http_method VARCHAR,
  target_http_url VARCHAR,
  target_http_user_agent VARCHAR,
  target_thread_process_parent_id INT,
  dns_query_name VARCHAR,
  dns_query_ips VARCHAR,
  http_request_host VARCHAR,
  http_request_method VARCHAR,
  http_request_user_agent VARCHAR,
  http_request_uri VARCHAR,
  process_name VARCHAR,
  registry_key VARCHAR,
  file_path VARCHAR,
  process_pid BIGINT,
  process_time_started BIGINT,
  process_backing_file_path VARCHAR,
  process_user VARCHAR,
  process_sid VARCHAR,
  device_vendor_name VARCHAR,
  device_product_name VARCHAR,
  device_serial_number VARCHAR,
  device_is_removable BOOLEAN,
  device_type VARCHAR,
  tcpip_local_host VARCHAR,
  tcpip_remote_host VARCHAR,
  tcpip_local_port INT,
  file_hashes VARCHAR,
  mutex_name VARCHAR,
  tcpip_reverse_dns_hostname VARCHAR,
  tcpip_whois VARCHAR,
  tcpip_country VARCHAR,
  tcpip_region VARCHAR,
  tcpip_city VARCHAR,
  tcpip_latitude VARCHAR,
  tcpip_longitude VARCHAR,
  tcpip_proxy_type VARCHAR,
  device_product VARCHAR,
  device_vendor VARCHAR,
  device_version VARCHAR
) WITH (
  kafka_topic='events', 
  value_format='json', 
  partitions=1
);


-- Sink connector for Elasticsearch for raw events
CREATE SINK CONNECTOR es_sink WITH (
'connector.class' = 'io.confluent.connect.elasticsearch.ElasticsearchSinkConnector',
'maxInterval' = '30',
'format' = 'json',
'tasks.max' = '1',
'topics' = 'events',
'key.ignore' = 'true',
'connection.url' = 'http://elasticsearch:9200',
'value.converter'= 'org.apache.kafka.connect.json.JsonConverter',
'value.converter.schemas.enable' = 'false',
'schema.ignore' = 'true',
'type.name' = 'kafka-connect');

