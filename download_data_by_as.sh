#!/bin/bash
set -eu

report_file="$1"
country="$2"

all_ases="$(jq -r '[.buckets[] | .key | tonumber] | join(" ")' "$report_file")"

script_dir="$(dirname "$0")"

out_dir="by_as"
mkdir "$out_dir"

for as in $all_ases;
do
    "$script_dir"/download_data.sh "$out_dir/censys_$as.json" "$country" "and autonomous_system.asn=$as"
done

"$script_dir"/download_data.sh "$out_dir/censys_other.json" "$country" "and not autonomous_system.asn: {$(sed 's/ /,/g' <<< "$all_ases")}"
