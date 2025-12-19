#!/bin/bash


declare -A HDD_MAP=(
   ["Last_5_Serial_number_Hdd"]="hddname,tb capacity"
   
   
)

TOTAL_EXPECTED=${#HDD_MAP[@]}


FOUND_HDDs=()
for disk in $(lsblk -d -n -o NAME | grep -v "loop\|sr"); do
    serial=$(udevadm info --query=all --name=/dev/$disk | grep ID_SERIAL= | cut -d= -f2)
    if [ -n "$serial" ]; then
        serial_short=${serial: -5}   
        FOUND_HDDs+=("$serial_short")
    fi
done


declare -A COUNT_BY_SIZE
declare -A MISSED_HDD

for serial in "${!HDD_MAP[@]}"; do
    entry=${HDD_MAP[$serial]}
    name=$(echo $entry | cut -d, -f1)
    size=$(echo $entry | cut -d, -f2)
    if [[ " ${FOUND_HDDs[@]} " =~ " $serial " ]]; then
        COUNT_BY_SIZE[$size]=$(( ${COUNT_BY_SIZE[$size]:-0} + 1 ))
    else
        MISSED_HDD[$size]="${MISSED_HDD[$size]} $name"
    fi
done


TOTAL_FOUND=0
for size in "${!COUNT_BY_SIZE[@]}"; do
    TOTAL_FOUND=$((TOTAL_FOUND + COUNT_BY_SIZE[$size]))
done


if [ "$TOTAL_FOUND" -eq "$TOTAL_EXPECTED" ]; then
    echo "$TOTAL_FOUND"
else
    echo "Mismatch: $TOTAL_FOUND / $TOTAL_EXPECTED"
    echo "Details:"
    for size in $(printf "%s\n" "${!COUNT_BY_SIZE[@]}" "${!MISSED_HDD[@]}" | sort -n | uniq); do
        expected_count=0
        for serial in "${!HDD_MAP[@]}"; do
            entry=${HDD_MAP[$serial]}
            h_size=$(echo $entry | cut -d, -f2)
            if [ "$h_size" -eq "$size" ]; then
                expected_count=$((expected_count+1))
            fi
        done
        found_count=${COUNT_BY_SIZE[$size]:-0}
        echo "  $size TB: $found_count / $expected_count"
        if [ -n "${MISSED_HDD[$size]}" ]; then
            for hdd in ${MISSED_HDD[$size]}; do
                echo "    Missed hdd name $hdd"
            done
        fi
    done
fi
read -p "Press Enter to close..."
