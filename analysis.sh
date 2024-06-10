#!/bin/sh
set -eu

cat results.json | jq -r '.[].connection_result' | sort | uniq -c | sort -n -r > stats.txt

cat results.json | jq '.[] | select(.connection_result == "key_accepted")' | jq -s > key_accepted.json
cat results.json | jq '.[] | select(.connection_result == "requires_more_authentication")' | jq -s > requires_more_authentication.json
cat results.json | jq '.[] | select(.connection_result == "bad_authentication_type")' | jq -s > bad_authentication_type.json

cat bad_authentication_type.json | jq -r '.[].connection_details' | sort | uniq -c | sort -n -r > bad_authentication_type_details.txt
cat requires_more_authentication.json | jq -r '.[].connection_details' | sort | uniq -c | sort -n -r > requires_more_authentication_details.txt

cat key_accepted.json | jq '.[].autonomous_system | [.asn, .name] | @tsv' -r | sort | uniq -c | sort -n -r > key_accepted_ases.txt
cat key_accepted.json | jq '.[].services[] | select(.port == 22) | .banner_hex' -r | sort | uniq -c | sort -n -r > key_accepted_banners.txt
cat key_accepted.json | jq '.[].services[] | select(.port == 22) | .ssh.endpoint_id.raw' | sort | uniq -c | sort -n -r > key_accepted_endpoint_ids.txt
cat key_accepted.json | jq '.[].services[] | select(.port == 22) | .ssh.server_host_key.fingerprint_sha256' -r | sort | uniq -c --repeated | sort -n -r > key_accepted_key_fingerprints.txt
cat key_accepted.json | jq '.[].services[] | select(.port == 22) | .ssh.hassh_fingerprint' -r | sort | uniq -c --repeated | sort -n -r > all_hassh_fingerprints.txt

cat results.json | jq '.[].autonomous_system | [.asn, .name] | @tsv' -r | sort | uniq -c | sort -n -r > all_ases.txt
cat results.json | jq '.[].services[] | select(.port == 22) | .ssh.endpoint_id.raw' | sort | uniq -c | sort -n -r > all_endpoint_ids.txt
cat results.json | jq '.[].services[] | select(.port == 22) | .ssh.server_host_key.fingerprint_sha256' -r | sort | uniq -c --repeated | sort -n -r > all_key_fingerprints.txt
cat results.json | jq '.[].services[] | select(.port == 22) | .ssh.hassh_fingerprint' -r | sort | uniq -c --repeated | sort -n -r > all_hassh_fingerprints.txt
