#!/bin/bash

# Script to start x direwolf instances each with their own configuration file and udp port source

# Variables
WORKING_DIR=$(pwd)
MAX_INSTANCES=10
SAMPLE=48000
INIT_AGWPORT=8000
INIT_KISSPORT=8001
INIT_UDP_PORT=1800

# Read amount of direwolf instances from command line
NUM_INSTANCES=$1

# Check if the number of instances is a number and is less than or equal to the maximum allowed
if ! [[ $NUM_INSTANCES =~ ^[0-9]+$ ]] || [ $NUM_INSTANCES -gt $MAX_INSTANCES ]; then
    echo "Usage: $0 <number of instances>"
    echo "The maximum number of instances is $MAX_INSTANCES"
    exit 1
fi

# Start loopback interface and kill all possible conflicting programs
sudo modprobe snd-aloop
sudo systemctl stop openwebrx &>/dev/null
sudo systemctl stop rtl_tcp &>/dev/null
pkill -o chromium &>/dev/null
sudo killall -9 rtl_fm &>/dev/null
sudo killall -9 direwolf &>/dev/null
sudo killall -9 aplay &>/dev/null
sudo killall -9 qsstv &>/dev/null
sudo killall -9 rtl_tcp &>/dev/null
sudo killall -9 java &>/dev/null
sudo killall -9 CubicSDR &>/dev/null
sudo killall -9 zenity &>/dev/null

# Make configuration directory
mkdir -p $WORKING_DIR/dire-configs

# Print information
echo "Starting $NUM_INSTANCES direwolf instances"
echo "Sample rate: $SAMPLE"

# Start each direwolf instance
for ((i = 0; i < $NUM_INSTANCES; i++)); do
    # Variables
    AGWPORT=$((INIT_AGWPORT + (i * 1000)))
    KISSPORT=$((INIT_KISSPORT + (i * 1000)))
    UDP_PORT=$((INIT_UDP_PORT + (i * 100)))

    # Create configuration file
    cat > $WORKING_DIR/dire-configs/direwolf$i.conf << EOF
    AGWPORT $AGWPORT
    KISSPORT $KISSPORT
    ADEVICE UDP:$UDP_PORT default
EOF

    # Start direwolf in seperate terminal tabs with configuration file and sample rate print information after each instance
    gnome-terminal --tab --title="Direwolf $i" -- bash -c "direwolf -c $WORKING_DIR/dire-configs/direwolf$i.conf -r $SAMPLE -t 0"
    sleep 1
    echo "Direwolf $i started with AGWPORT: $AGWPORT, KISSPORT: $KISSPORT, and UDP_PORT: $UDP_PORT"
done