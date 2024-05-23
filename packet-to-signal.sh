#!/bin/bash

# This script saves files of each conversion step of a packet to a signal
# conversion. The files are saved in a subdirectory named "conversion_files"

# Create subdirectory
mkdir -p conversion_files

# Command breakdown saving each step of the conversion
gen_packets -o conversion_files/packets.wav /home/pi/CubeSatSim/t.txt # Generate packets
cat conversion_files/packets.wav | csdr convert_i16_f > conversion_files/converted_i16_f.txt # Convert to float
cat conversion_files/converted_i16_f.txt | csdr gain_ff 7000 > conversion_files/gained_ff.txt # Gain
cat conversion_files/gained_ff.txt | csdr convert_f_samplerf 20833 > conversion_files/converted_f_samplerf.txt # Convert to sample rate
cat conversion_files/converted_f_samplerf.txt | sudo /home/pi/rpitx/rpitx -i- -m RF -f 434.9e3 # Transmit

# display head -5 of each file
for file in conversion_files/*; do
    echo "File: $file"
    head -5 $file
    echo
done
