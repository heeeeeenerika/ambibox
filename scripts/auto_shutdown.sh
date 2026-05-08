#!/bin/bash

COUNTER=0
LIMIT=5
CHECK_INTERVAL=60
URL="http://localhost:8090/json-rpc"
DATA='{"command":"current-state","subcommand":"average-color","instance":0}'

echo "Auto-Shutdown onitor started!"

while true; do
    RESPONSE=$(curl -s -X POST -d "$DATA" "$URL")

    RED=$(echo "$RESPONSE" | jq -r '.info.red // empty')
    GREEN=$(echo "$RESPONSE" | jq -r '.info.green // empty')
    BLUE=$(echo "$RESPONSE" | jq -r '.info.blue // empty')

    if [ -n "$RED" ] && [ -n "$GREEN" ] && [ -n "$BLUE" ]; then
        if [ "$RED" -eq 0 ] && [ "$GREEN" -eq 0 ] && [ "$BLUE" -eq 0 ]; then
            COUNTER=$((COUNTER + 1))
            echo "LEDs are off. Counter: $COUNTER/$LIMIT"
        else
            if [ "$COUNTER" -gt 0 ]; then
                echo "LEDs are on again. Resetting counter..."
            fi
            COUNTER=0
        fi
    else
        COUNTER=0
    fi

    # when limit is reached, shutdown the system
    if [ "$COUNTER" -ge "$LIMIT" ]; then
        echo "Auto-Shutdown: Inactivity limit reached. Shutting down the system..."
        sudo shutdown -h now
        exit 0
    fi

    sleep "$CHECK_INTERVAL"
done