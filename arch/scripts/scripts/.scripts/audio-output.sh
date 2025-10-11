#!/bin/bash

# You can get the sink name with:
# wpctl status --name
#
# alsa_output.usb-Apple__Inc._USB-C_to_3.5mm_Headphone_Jack_Adapter_DWH43470N0FJKLTAT-00.analog-stereo
# alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink
# bluez_output.C0_28_8D_4A_7E_00.1

# Check if a sink name was provided
if [[ -z "$1" ]]; then
	echo "Usage: $0 <sink-name>"
	exit 1
fi

sinkName="$1"

sinkId=$(pw-cli info "$sinkName" | head -n 1 | awk '{print $2}')

if [[ -z "$sinkId" ]]; then
	echo "Sink not found for: $sinkName"
	exit 1
fi

# Set the audio output to the specified sink
wpctl set-default "$sinkId"

echo "Audio output changed to: $sinkName"

