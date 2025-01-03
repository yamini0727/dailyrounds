# System Monitor Script

This script monitors system resource usage, including CPU, memory, and disk usage, and saves the information in a specified format (`text`, `csv`, or `json`). It also triggers alerts if resource usage exceeds specified thresholds.

## Features
- Monitors:
  - CPU usage
  - Memory usage
  - Disk usage
  - Top 5 CPU-consuming processes
- Saves system information in `text`, `csv`, or `json` formats.
- Triggers alerts for high CPU, memory, or disk usage.
- Customizable monitoring interval.

## Requirements
- Bash shell
- Tools used in the script:
  - `top`
  - `free`
  - `df`
  - `awk`
  - `bc`
  - `ps`
  - `jq` (required for `json` output)

### if we get any error for jq while running the script insatll those dependencies.
sudo apt-get install jq

## Usage
### 1. Clone or Copy the Script
Save the script to a file named `system_monitor.sh`.

### 2. Make the Script Executable
Run the following command to make the script executable:

chmod +x system_monitor.sh

### 3. run the script in local systems or inside the servers.

./system_monitor.sh --interval 10 --format text
./system_monitor.sh --interval 10 --format csv
./system_monitor.sh --interval 10 --format json





