#!/bin/bash
# script to convert signal into packets using direwolf and rx_fm

# Variables
FREQUENCY=434.905M # Previous Value: 434.9e6
SAMPLE=48000
CONFIG='/home/cubesat-gs/CubeSatSim-1.3.2/groundstation/direwolf/direwolf.conf'

# Start loopback interface and kill all possible conflicting programs
sudo modprobe snd-aloop

sudo systemctl stop openwebrx

sudo systemctl stop rtl_tcp

pkill -o chromium &>/dev/null

sudo killall -9 rtl_fm &>/dev/null

sudo killall -9 direwolf &>/dev/null

sudo killall -9 aplay &>/dev/null

sudo killall -9 qsstv &>/dev/null

sudo killall -9 rtl_tcp &>/dev/null

sudo killall -9 java &>/dev/null

sudo killall -9 CubicSDR &>/dev/null

sudo killall -9 zenity &>/dev/null

# HackRF
SoapySDRUtil --probe="driver=hackrf" > /dev/null 2>&1

# Start direwolf
echo -e "Starting direwolf with config file: $CONFIG and sample rate: $SAMPLE"
direwolf -c $CONFIG -r $SAMPLE -t 0 &

# Find loopback device
value=`aplay -l | grep "Loopback"`
echo "$value" > /dev/null
set -- $value

# Start rx_fm
rx_fm -M fm -f $FREQUENCY -s $SAMPLE -l 30 -w 48000 -vvvv -o 1,4 | tee >(aplay -D hw:${2:0:1},0,0 -r 48000 -t raw -f S16_LE -c 1) | aplay -D hw:0,0 -r 48000 -t raw -f S16_LE -c 1
# The above line uses the tee command to send the output of rtl_fm to two different aplay commands. 
# The first aplay command plays the audio on a specific hardware device (determined by ${2:0:1}), and 
# the second aplay command plays the audio on the default hardware device (hw:0,0). 
# The $frequency variable is used to set the frequency for the rtl_fm command.

sleep 5