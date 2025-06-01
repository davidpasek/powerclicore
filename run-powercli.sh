#!/bin/bash

# === Constants ===
BASE_DIR="$HOME/powerclicore"
BASE_DIR_SETTINGS="$BASE_DIR/settings"
BASE_DIR_DATA="$BASE_DIR/data"                                                  
BASE_DIR_SCRIPTS="$BASE_DIR/scripts"  
DOCKER_IMAGE="vmware/powerclicore"

# === Ensure base directory exists ===                                          
echo "BASE_DIR: $BASE_DIR"                                                      
mkdir -p "$BASE_DIR"                                                            
                                                                                
# === Ensure settings directory exists ===                                      
echo "BASE_DIR_SETTINGS: $BASE_DIR_SETTINGS"                                    
mkdir -p "$BASE_DIR_SETTINGS"                                                   
                                                                                
# === Ensure data directory exists ===                                          
echo "BASE_DIR_DATA: $BASE_DIR_DATA"                                            
mkdir -p "$BASE_DIR_DATA"                                                       
                                                                                
# === Ensure scripts directory exists ===                                       
echo "BASE_DIR_SCRIPTS: $BASE_DIR_SCRIPTS"                                      
mkdir -p "$BASE_DIR_SCRIPTS"  

docker run -it --rm \
  -v "$BASE_DIR_SCRIPTS:/root/scripts" \
  -v "$BASE_DIR_DATA:/root/data" \
  -v "$BASE_DIR_SETTINGS:/root/.local/share/VMware/PowerCLI" \
  --entrypoint='/usr/bin/pwsh' \
  "$DOCKER_IMAGE" \
  -NoExit
