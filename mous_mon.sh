#!/bin/bash

JID="user name"
PASSWORD='pass'
JID_RX="recipient_jid@server"
Server="server name"


function send_message() {
    message="$1"
    echo "$message" | sendxmpp -j "$Server" -u "$JID" -p "$PASSWORD" -t "$JID_RX"
}

touch /tmp/usb_devices.txt
mouse_id=$(xinput list | grep -i "mouse" | grep -o "id=[0-9]*" | cut -d "=" -f 2)
prev_mouse_state=$(xinput query-state "$mouse_id")


while true; do

############ Mouse #############################################

    mouse_state=$(xinput query-state "$mouse_id")

    if [[ "$mouse_state" != "$prev_mouse_state" ]]; then
        # Отправляем сообщение в Jabber
        send_message "$(date '+%Y-%m-%d %H:%M:%S') Mouse allert"
	echo "$(date '+%Y-%m-%d %H:%M:%S') Mouse allert"
    fi

    prev_mouse_state="$mouse_state"
    
################################################################

############ USB ###############################################

    new_devices=$(lsusb)

    diff=$(diff /tmp/usb_devices.txt <(echo "$new_devices"))

    if [ "$diff" != "" ]; then

        device_id=$(echo "$diff" | tail -n 1 | cut -d ':' -f1 | cut -d ' ' -f5)
	device_ser=$(lsusb -v -s $device_id  | grep -i iSerial | rev | cut -d ' ' -f1 | rev)
	device_name=$(lsusb -v -s $device_id  | grep -i idProduct | cut -d 'x' -f 2)
	
	if [ -n "$device_name" ]
		then

	        send_message "$(date '+%Y-%m-%d %H:%M:%S') USB device connected: $device_name Serial: $device_ser"
		echo "$(date '+%Y-%m-%d %H:%M:%S') USB device connected: $device_name Serial: $device_ser"
		
        	echo "$new_devices" > /tmp/usb_devices.txt
        fi
    fi

#################################################################

    sleep 3
done
