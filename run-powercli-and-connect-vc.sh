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

VCSERVER_FILE="$BASE_DIR_SETTINGS/vcenter-server.txt"
VCUSER_FILE="$BASE_DIR_SETTINGS/vcenter-user.txt"
VCPASS_FILE="$BASE_DIR_SETTINGS/vcenter-password.txt"

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

# === Prompt for server if not set ===
debug "VCSERVER_FILE: $VCSERVER_FILE"
if [[ ! -f "$VCSERVER_FILE" ]]; then
  read -rp "🌐 Enter vCenter server (e.g., vc01.example.com): " VC_SERVER
  echo "$VC_SERVER" > "$VCSERVER_FILE"
  echo "✅ Saved vCenter server to $VCSERVER_FILE"
else
  VC_SERVER=$(<"$VCSERVER_FILE")
fi

# === Prompt for username if not set ===
debug "VCUSER_FILE: $VCSERVER_FILE"
if [[ ! -f "$VCUSER_FILE" ]]; then
  read -rp "👤 Enter vCenter username (e.g., vsphere.local\user): " VC_USER
  echo "$VC_USER" > "$VCUSER_FILE"
  echo "✅ Saved vCenter username to $VCUSER_FILE"
else
  VC_USER=$(<"$VCUSER_FILE")
fi

# === Prompt for password if not set ===
debug "VCPASS_FILE: $VCPASS_FILE"
if [[ ! -f "$VCPASS_FILE" ]]; then
  echo "🔐 Password for $VC_USER@$VC_SERVER not found. Please enter it."
  read -s -p "Enter password: " VC_PASS
  echo
  read -s -p "Confirm password: " VC_PASS_CONFIRM
  echo
  if [[ "$VC_PASS" != "$VC_PASS_CONFIRM" ]]; then
    echo "❌ Passwords do not match. Aborting."
    exit 1
  fi
  echo "$VC_PASS" > "$VCPASS_FILE"
  chmod 600 "$VCPASS_FILE"
  echo "✅ Password saved to $VCPASS_FILE"
fi

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
  -NoExit \
  -Command "
    try {
      \$password = Get-Content '/root/.local/share/VMware/PowerCLI/vcenter-password.txt' | ConvertTo-SecureString -AsPlainText -Force;
      \$cred = New-Object System.Management.Automation.PSCredential((Get-Content '/root/.local/share/VMware/PowerCLI/vcenter-user.txt'), \$password);
      Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP \$true -Confirm:\$false | Out-Null; 
      Set-PowerCLIConfiguration -InvalidCertificateAction:ignore -Confirm:\$false | Out-Null;
      Connect-VIServer -Server (Get-Content '/root/.local/share/VMware/PowerCLI/vcenter-server.txt') -Credential \$cred -WarningAction Stop;
      Write-Host '✅ Connected successfully.' -ForegroundColor Green;
    }
    catch {
      Write-Host '❌ Connection failed:' -ForegroundColor Red;
      Write-Host \$_.Exception.Message -ForegroundColor Red;
      exit 1;
    }
  "

