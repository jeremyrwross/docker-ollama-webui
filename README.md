# Docker Management Script for Ollama and Open WebUI

This script automates the process of managing Docker containers for multiple Ollama instances and Open WebUI. It pulls the latest Docker images, stops and removes existing containers, and recreates them with the updated images. Additionally, it updates all models for the Ollama containers.

## Features
- Manage multiple Ollama instances.
- Automatically pull the latest Ollama and Open WebUI Docker images.
- Stop, remove, and recreate containers only if they exist.
- Update models in Ollama containers after recreation.
- Configurable container names and ports.

## Prerequisites
- Docker must be installed and running on your system.
- Ensure you have the necessary permissions to run Docker commands.

## Usage

### Clone the Repository
First, clone this repository to your local machine:
```bash
git clone https://github.com/jeremyrwross/docker-ollama-webui.git
cd docker-ollama-webui
```

## Script Configuration
The script is pre-configured to manage the following containers:

- Ollama Instances:
  - `ollama` (Port `11434`)
- Open WebUI:
  - `open-webui` (Port `3000`)

You can modify the container names and ports by editing the following variables at the top of the script:

```bash
declare -A CONTAINER_INSTANCES=(
    ["ollama"]="11434"
)

OPEN_WEBUI_CONTAINER="open-webui"
OPEN_WEBUI_PORT="3000"
```

### Running the Script
To execute the script, navigate to the directory where it is located and run:

```bash
./docker-ollama-webui.sh
```

## What the Script Does
- Pull Latest Docker Images: Pulls the latest images for both Ollama and Open WebUI.
- Stop and Remove Containers: Stops and removes the existing containers only if they exist.
- Recreate Containers: Recreates and starts the containers with the latest images.
- Update Ollama Models: Updates all models for the first Ollama instance after the containers are recreated.