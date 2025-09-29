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
    
    # Extract access token from JSON response
    access_token=$(echo "$response" | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$access_token" ]; then
        echo "Error: Failed to get access token"
        echo "Response: $response"
        exit 1
    fi
    
    echo "$access_token"
}

# Function to control device
control_device() {
    local device_id=$1
    local action=$2
    
    # Get fresh access token
    access_token=$(get_access_token)
    
    if [ "$action" == "on" ]; then
        power_state="On"
    elif [ "$action" == "off" ]; then
        power_state="Off"
    else
        echo "Invalid action. Use 'on' or 'off'"
        return 1
    fi
    
    # Prepare the JSON payload
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
    
    # Check if successful
    if echo "$response" | grep -q '"success":true'; then
        echo "✓ Success"
    else
        echo "✗ Failed: $response"
    fi
}

# Main menu
case "$1" in
    "shed-on")
        echo "Turning lamp shed ON..."
        control_device "$LAMP_SHED_ID" "on"
        ;;
    "shed-off")
        echo "Turning lamp shed OFF..."
        control_device "$LAMP_SHED_ID" "off"
        ;;
    "table-on")
        echo "Turning table lamp ON..."
        control_device "$TABLE_LAMP_ID" "on"
        ;;
    "table-off")
        echo "Turning table lamp OFF..."
        control_device "$TABLE_LAMP_ID" "off"
        ;;
    "all-on")
        echo "Turning all lights ON..."
        control_device "$LAMP_SHED_ID" "on"
        control_device "$TABLE_LAMP_ID" "on"
        ;;
    "all-off")
        echo "Turning all lights OFF..."
        control_device "$LAMP_SHED_ID" "off"
        control_device "$TABLE_LAMP_ID" "off"
        ;;
    *)
        echo "Usage: $0 {shed-on|shed-off|table-on|table-off|all-on|all-off}"
        echo ""
        echo "Examples:"
        echo "  $0 shed-on     - Turn lamp shed on"
        echo "  $0 table-off   - Turn table lamp off"
        echo "  $0 all-on      - Turn all lights on"
        exit 1
        ;;
esac
