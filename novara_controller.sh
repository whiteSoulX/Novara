#!/bin/bash

# Configuration - Replace with your actual values
# Get API Key from: https://sinric.pro -> Credentials -> Create API Key
API_KEY="9e756141-1a54-48f7-aa07-403f4419d365"

# Get Device IDs from: https://sinric.pro -> Devices -> Click on device
LAMP_SHED_ID="68cac6a5b73c366187ee5cea"
TABLE_LAMP_ID="68cac66fc6e948341599f9ac"

# Sinric Pro API endpoints
AUTH_URL="https://api.sinric.pro/api/v1/auth"
API_URL="https://api.sinric.pro/api/v1/devices"

# Function to get access token
get_access_token() {
    response=$(curl -s -X POST "$AUTH_URL" \
        -H "x-sinric-api-key: ${API_KEY}")
    
    access_token=$(echo "$response" | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$access_token" ]; then
        echo "Error: Failed to get access token"
        exit 1
    fi
    
    echo "$access_token"
}

# Function to get device status
get_device_status() {
    local device_id=$1
    
    access_token=$(get_access_token)
    
    response=$(curl -s -X GET "${API_URL}/${device_id}" \
        -H "Authorization: Bearer ${access_token}")
    
    # Extract powerState from response
    status=$(echo "$response" | grep -o '"powerState":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$status" ]; then
        echo "Unknown"
    else
        echo "$status"
    fi
}

# Function to control device
control_device() {
    local device_id=$1
    local action=$2
    
    access_token=$(get_access_token)
    
    if [ "$action" == "on" ]; then
        power_state="On"
    else
        power_state="Off"
    fi
    
    payload=$(cat <<EOF
{
    "type": "request",
    "action": "setPowerState",
    "value": "{\"state\":\"${power_state}\"}"
}
EOF
)
    
    response=$(curl -s -X POST "${API_URL}/${device_id}/action" \
        -H "Authorization: Bearer ${access_token}" \
        -H "Content-Type: application/json" \
        -d "$payload")
    
    if echo "$response" | grep -q '"success":true'; then
        echo "✓ Success"
    else
        echo "✗ Failed"
    fi
}

# Clear screen function
clear_screen() {
    clear
}

# Main interactive menu
show_menu() {
    while true; do
        clear_screen
        
        # Get current status
        echo "Fetching device status..."
        shed_status=$(get_device_status "$LAMP_SHED_ID")
        table_status=$(get_device_status "$TABLE_LAMP_ID")
        
        # Display status icons
        if [ "$shed_status" == "On" ]; then
            shed_icon="💡 ON "
        else
            shed_icon="⚫ OFF"
        fi
        
        if [ "$table_status" == "On" ]; then
            table_icon="💡 ON "
        else
            table_icon="⚫ OFF"
        fi
        
        clear_screen
        echo "════════════════════════════════════"
        echo "    SINRIC PRO LIGHT CONTROLLER"
        echo "════════════════════════════════════"
        echo ""
        echo "  Current Status:"
        echo "  📍 Lamp Shed:  $shed_icon"
        echo "  📍 Table Lamp: $table_icon"
        echo ""
        echo "────────────────────────────────────"
        echo ""
        echo "  1) Turn Lamp Shed ON"
        echo "  2) Turn Lamp Shed OFF"
        echo ""
        echo "  3) Turn Table Lamp ON"
        echo "  4) Turn Table Lamp OFF"
        echo ""
        echo "  5) Turn ALL Lights ON"
        echo "  6) Turn ALL Lights OFF"
        echo ""
        echo "  r) Refresh Status"
        echo "  0) Exit"
        echo ""
        echo "════════════════════════════════════"
        echo -n "Select option [0-6/r]: "
        
        read -n 1 choice
        echo ""
        echo ""
        
        case $choice in
            1)
                echo "⚡ Turning Lamp Shed ON..."
                control_device "$LAMP_SHED_ID" "on"
                ;;
            2)
                echo "⚡ Turning Lamp Shed OFF..."
                control_device "$LAMP_SHED_ID" "off"
                ;;
            3)
                echo "⚡ Turning Table Lamp ON..."
                control_device "$TABLE_LAMP_ID" "on"
                ;;
            4)
                echo "⚡ Turning Table Lamp OFF..."
                control_device "$TABLE_LAMP_ID" "off"
                ;;
            5)
                echo "⚡ Turning ALL Lights ON..."
                control_device "$LAMP_SHED_ID" "on"
                control_device "$TABLE_LAMP_ID" "on"
                ;;
            6)
                echo "⚡ Turning ALL Lights OFF..."
                control_device "$LAMP_SHED_ID" "off"
                control_device "$TABLE_LAMP_ID" "off"
                ;;
            0)
                echo "👋 Goodbye!"
                exit 0
                ;;
            r|R)
                echo "🔄 Refreshing status..."
                sleep 1
                continue
                ;;
            *)
                echo "❌ Invalid option. Please select 0-6 or r"
                ;;
        esac
        
        echo ""
        echo -n "Press any key to continue..."
        read -n 1
    done
}

# Run the interactive menu
show_menu
