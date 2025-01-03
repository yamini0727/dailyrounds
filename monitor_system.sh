#!/bin/bash

# Function to display system information and save to a file
display_system_info() {
    # CPU usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk '{printf "%.2f", $1}')

    # Memory usage
    memory_total=$(free -m | awk 'NR==2 {print $2}')
    memory_used=$(free -m | awk 'NR==2 {print $3}')
    memory_free=$(free -m | awk 'NR==2 {print $4}')
    memory_usage=$(echo "($memory_used * 100) / $memory_total" | bc)

    # Disk usage
    disk_usage=$(df -h | awk '{if(NR>1 && $6 != "tmpfs" && $6 != "udev") print $5, $1, $6}')

    # Top 5 CPU-consuming processes
    top_processes=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6)

    # Trigger alerts if thresholds are exceeded
    trigger_alerts "$cpu_usage" "$memory_usage" "$disk_usage"

    # Save system information to the appropriate file
    case $format in
        text)
            {
                echo "===== System Information ====="
                echo "CPU Usage: $cpu_usage%"
                echo "Memory Usage: Total: $memory_total MB, Used: $memory_used MB, Free: $memory_free MB"
                echo "Memory Usage Percentage: $memory_usage%"
                echo "Disk Usage:"
                echo "$disk_usage"
                echo "Top 5 CPU-Consuming Processes:"
                echo "$top_processes"
                echo "==============================="
            } > system_report.txt
            ;;
        csv)
            {
                echo "Metric,Value"
                echo "CPU_Usage,$cpu_usage%"
                echo "Memory_Usage_Percentage,$memory_usage%"
                echo "Memory_Total,$memory_total MB"
                echo "Memory_Used,$memory_used MB"
                echo "Memory_Free,$memory_free MB"
                echo "Disk_Usage"
                echo "$disk_usage"
                echo "Top_Processes"
                echo "$top_processes"
            } > system_report.csv
            ;;
        json)
            disk_json=$(echo "$disk_usage" | jq -R -s -c 'split("\n") | map(select(length > 0))')
            top_processes_json=$(echo "$top_processes" | jq -R -s -c 'split("\n") | map(select(length > 0))')
            {
                echo "{
                    \"CPU_Usage\": \"$cpu_usage%\",
                    \"Memory\": {
                        \"Total\": \"$memory_total MB\",
                        \"Used\": \"$memory_used MB\",
                        \"Free\": \"$memory_free MB\",
                        \"Usage_Percentage\": \"$memory_usage%\"
                    },
                    \"Disk_Usage\": $disk_json,
                    \"Top_Processes\": $top_processes_json
                }"
            } > system_report.json
            ;;
    esac
}

# Function to trigger alerts
trigger_alerts() {
    local cpu=$1
    local memory=$2
    local disk=$3

    if (( $(echo "$cpu > 80" | bc -l) )); then
        echo "WARNING: CPU usage exceeds 80% ($cpu%)"
    fi

    if (( $(echo "$memory > 75" | bc -l) )); then
        echo "WARNING: Memory usage exceeds 75% ($memory%)"
    fi

    while IFS= read -r line; do
        usage=$(echo "$line" | awk '{print $1}' | sed 's/%//')
        mount=$(echo "$line" | awk '{print $3}')
        if (( $(echo "$usage > 90" | bc -l) )); then
            echo "WARNING: Disk space usage exceeds 90% on $mount ($usage%)"
        fi
    done <<< "$disk"
}

# Function to validate user inputs
validate_inputs() {
    if ! [[ $interval =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid interval specified. Please provide a positive integer."
        exit 1
    fi

    if [[ $format != "text" && $format != "csv" && $format != "json" ]]; then
        echo "Error: Unsupported format. Please specify text, csv, or json."
        exit 1
    fi
}

# Default values
interval=5
format="text"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --interval)
            interval=$2
            shift
            shift
            ;;
        --format)
            format=$2
            shift
            shift
            ;;
        *)
            echo "Error: Unknown option $1"
            exit 1
            ;;
    esac
done

# Validate inputs
validate_inputs

# Main loop to monitor system information at the specified interval
while true; do
    display_system_info
    sleep $interval
done

