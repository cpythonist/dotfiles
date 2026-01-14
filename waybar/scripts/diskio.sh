#!/usr/bin/env bash

DISK="$1"
STATE="/tmp/waybar-diskio-$DISK"

read_sectors=$(awk "\$3 == \"$DISK\" {print \$6}" /proc/diskstats)
write_sectors=$(awk "\$3 == \"$DISK\" {print \$10}" /proc/diskstats)

SECTOR_SIZE=512
now=$(date +%s)

if [[ -f "$STATE" ]]; then
    read prev_read prev_write prev_time < "$STATE"

    dt=$((now - prev_time))
    (( dt == 0 )) && dt=1

    read_diff=$((read_sectors - prev_read))
    write_diff=$((write_sectors - prev_write))

    read_mib=$(awk "BEGIN {printf \"%.1f\", ($read_diff * $SECTOR_SIZE) / 1024 / 1024 / $dt}")
    write_mib=$(awk "BEGIN {printf \"%.1f\", ($write_diff * $SECTOR_SIZE) / 1024 / 1024 / $dt}")
else
    read_mib="0.0"
    write_mib="0.0"
fi

echo "$read_sectors $write_sectors $now" > "$STATE"

busy="false"
awk "BEGIN {exit !($read_mib > 10 || $write_mib > 10)}" && busy="true"

echo "{\"text\": \"<span font='17'>\ueda4</span> <span rise='2200'>${read_mib}MiB/s</span>  <span font='17'>\udb83\udcb6</span> <span rise='2200'>${write_mib}MiB/s</span>\", \"class\": \"$busy\"}"