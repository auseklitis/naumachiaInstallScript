#!/bin/bash

# Path to the docker-compose.yml file
COMPOSE_FILE="docker-compose.yml"

# Define the content to be added for the registrar service
REGISTRAR_NET="      internalNet:\n        ipv4_address: 10.10.10.2\n"

# Define the content for the networks section to be added at the end of the file
INTERNAL_NET="internalNet:\n        name: internalNet\n        external: true\n"

# Check if internalNet is already present under registrar
if grep -q "registrar:" "$COMPOSE_FILE" && grep -q "internalNet" "$COMPOSE_FILE"; then
    echo "internalNet is already configured. Exiting."
    exit 0
fi

# Add the network configuration under the registrar service
sed -i '/registrar:/,/restart: on-failure/ {
    /networks:/,/ports:/ {
            /internal:/a\
        \    internalNet:\
        \        ipv4_address: 10.10.10.2
        }
}' "$COMPOSE_FILE"

#sed -i '/networks:/,/ports:/ {
#    /default:/a\
#            internalNet:\
#                ipv4_address: 10.10.10.2
#}' "$COMPOSE_FILE"

# Add the internalNet network at the end of the file if it's not already there
if ! grep -q "networks:.*internalNet:" "$COMPOSE_FILE"; then
    echo -e "$INTERNAL_NET" >> "$COMPOSE_FILE"
fi

echo "Docker Compose file updated successfully."

