#!/bin/bash

# === Constants ===
DEBUG=1 # 1-on, 0-off

BASE_DIR="$HOME/powerclicore"
BASE_DIR_SETTINGS="$BASE_DIR/settings"
BASE_DIR_DATA="$BASE_DIR/data"
BASE_DIR_SCRIPTS="$BASE_DIR/scripts"

REMOTE_BASE_DIR="/root"
REMOTE_BASE_DIR_SETTINGS="$REMOTE_BASE_DIR/.local/share/VMware/PowerCLI"
REMOTE_BASE_DIR_DATA="$REMOTE_BASE_DIR/data"
REMOTE_BASE_DIR_SCRIPTS="$REMOTE_BASE_DIR/scripts"

DOCKER_IMAGE="vmware/powerclicore"

# === Colors ===
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

# Debug output function
debug() {
  if [[ "$DEBUG" -eq 1 ]]; then
    echo -e "${GREEN}[DEBUG] $*${NC}"
  fi
}
        
# === Ensure base directory exists ===
debug "BASE_DIR: $BASE_DIR"
debug "REMOTE_BASE_DIR: $REMOTE_BASE_DIR"
mkdir -p "$BASE_DIR"
                                                                                
# === Ensure settings directory exists ===
debug "BASE_DIR_SETTINGS: $BASE_DIR_SETTINGS"
debug "REMOTE_BASE_DIR_SETTINGS: $REMOTE_BASE_DIR_SETTINGS"
mkdir -p "$BASE_DIR_SETTINGS"
                                                                                
# === Ensure data directory exists ===
debug "BASE_DIR_DATA: $BASE_DIR_DATA"
debug "REMOTE_BASE_DIR_DATA: $REMOTE_BASE_DIR_DATA"
mkdir -p "$BASE_DIR_DATA"
                                                                                
# === Ensure scripts directory exists ===
debug "BASE_DIR_SCRIPTS: $BASE_DIR_SCRIPTS"
debug "REMOTE_BASE_DIR_SCRIPTS: $REMOTE_BASE_DIR_SCRIPTS"
mkdir -p "$BASE_DIR_SCRIPTS"

# === Check Docker image exists ===                                             
if ! docker image inspect "$DOCKER_IMAGE" > /dev/null 2>&1; then                
  echo -e "${RED}❌ Docker image '$DOCKER_IMAGE' not found. Pulling now...${NC}"
  docker pull "$DOCKER_IMAGE" || {                                              
    echo -e "${RED}❌ Failed to pull Docker image. Exiting.${NC}"               
    exit 2                                                                      
  }                                                                             
fi 

# === Run Docker PowerCLI === 
docker run -it --rm \
  -v "$BASE_DIR_SCRIPTS:$REMOTE_BASE_DIR_SCRIPTS" \
  -v "$BASE_DIR_DATA:$REMOTE_BASE_DIR_DATA" \
  -v "$BASE_DIR_SETTINGS:$REMOTE_BASE_DIR_SETTINGS" \
  --entrypoint='/usr/bin/pwsh' \
  "$DOCKER_IMAGE" \
  -NoExit

