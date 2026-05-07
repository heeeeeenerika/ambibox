#!/bin/bash

PIN=17
API_URL="http://localhost:8090/json-rpc"

cleanup() {
    pinctrl set $PIN op dl
    exit 0
}

trap cleanup INT TERM

echo "Wait for HyperHDR API..."

while true; do
    RESPONSE=$(curl -s -X POST -d '{"command":"serverinfo"}' $API_URL 2>/dev/null)
    if echo "$RESPONSE" | grep -q '"success": true'; then

        for i in {1..3}; do
            pinctrl set $PIN op dh
            sleep 0.2
            pinctrl set $PIN op dl
            sleep 0.2
        done

        echo "HyperHDR is ready!!"
        break
    fi

    pinctrl set $PIN op dh
    sleep 0.5
    pinctrl set $PIN op dl
    sleep 0.5
done