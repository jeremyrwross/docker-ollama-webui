#!/bin/bash

# Define container names and ports as an array of associative arrays
declare -A CONTAINER_INSTANCES=(
    ["ollama"]="11434"
)

# Define Open WebUI variables
OPEN_WEBUI_CONTAINER="open-webui"
OPEN_WEBUI_IMAGE="ghcr.io/open-webui/open-webui:main"
OPEN_WEBUI_PORT="3000"

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color (reset to default)

# Pull the latest Ollama image
docker pull ollama/ollama

# Loop through each container instance to stop, remove, and recreate
for container in "${!CONTAINER_INSTANCES[@]}"; do
    port="${CONTAINER_INSTANCES[$container]}"
    
    # Check if the container exists
    if docker ps -a --format '{{.Names}}' | grep -q "^$container$"; then
        echo -e "${GREEN}Stopping and removing existing container: $container${NC}"
        docker stop "$container"
        docker rm "$container"
    else
        echo -e "${GREEN}Container $container does not exist, skipping stop and remove.${NC}"
    fi
    
    # Recreate and start the container with the latest image
    docker run -d --gpus=all -v ollama:/root/.ollama -p "$port":11434 --name "$container" ollama/ollama
    if [ $? -ne 0 ]; then
        echo "Failed to create $container container."
        exit 1
    fi
done

# Pull the latest Open WebUI image
docker pull $OPEN_WEBUI_IMAGE

# Check if Open WebUI container exists, stop and remove if necessary
if docker ps -a --format '{{.Names}}' | grep -q "^$OPEN_WEBUI_CONTAINER$"; then
    echo -e "${GREEN}Stopping and removing existing container: $OPEN_WEBUI_CONTAINER${NC}"
    docker stop "$OPEN_WEBUI_CONTAINER"
    docker rm "$OPEN_WEBUI_CONTAINER"
else
    echo -e "${GREEN}Container $OPEN_WEBUI_CONTAINER does not exist, skipping stop and remove.${NC}"
fi

# Recreate and start the Open WebUI container with the latest image
docker run -d -p "$OPEN_WEBUI_PORT":8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name $OPEN_WEBUI_CONTAINER --restart always $OPEN_WEBUI_IMAGE
if [ $? -ne 0 ]; then
    echo "Failed to create Open WebUI container."
    exit 1
fi

# Loop through the models and update them for the first Ollama instance
models=$(docker exec -i ollama ollama list | awk 'NR>1 {print $1}')

for model in $models; do
    echo -e "${GREEN}Updating $model${NC}"
    docker exec -i ollama ollama pull "$model"
done

echo -e "${GREEN}Ollama and Open WebUI Update Complete${NC}"
