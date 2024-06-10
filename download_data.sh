#!/bin/bash
set -eu

output_file="$1"
country="$2"
extra_filter="$3"

censys search "services.port=22 and location.country_code=$country $extra_filter" --pages -1 --fields "service_count" "autonomous_system.asn" "autonomous_system.name" "dns.reverse_dns.names" "location.country_code" "services.port" "services.service_name" "services.banner_hex" "services.ssh.endpoint_id.raw" "services.ssh.hassh_fingerprint" "services.ssh.server_host_key.fingerprint_sha256" -o "$output_file"
