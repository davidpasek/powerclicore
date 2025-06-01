# powerclicore

A simple shell wrapper around the `vmware/powerclicore` Docker image.

## `run-powercli.sh`

The script `run-powercli.sh` launches a Docker container with VMware PowerCLI and opens an interactive PowerShell session inside it.

When started, it automatically creates and mounts the following directories:

| Host Directory  | Container Directory                             | Purpose                                       |
|-----------------|--------------------------------------------------|-----------------------------------------------|
| `./data`        | `/root/data`                                     | Share input/output files with the container   |
| `./scripts`     | `/root/scripts`                                  | Store your PowerCLI scripts                   |
| `./settings`    | `/root/.local/share/VMware/PowerCLI`             | Persist your PowerCLI settings                |

This setup allows you to:

- Easily run PowerCLI scripts from your local machine.
- Persist settings between runs.
- Exchange input/output data with the container.

## Usage

```bash
./run-powercli.sh

## `run-powercli-and-connect-vc.sh`

The script `run-powercli-and-connect-vc.sh` behaves like `run-powercli.sh`, but it also automatically connects to a specified vCenter server upon startup.

### vCenter Connection Files

The following files are used to store connection information:

- `./scripts/vcenter-server.txt` — vCenter server hostname or IP address
- `./scripts/vcenter-user.txt` — vCenter username
- `./scripts/vcenter-password.txt` — vCenter password

If any of these files are missing, the script will prompt you to enter the values interactively and create the files for future use.

### Benefits

- Automatically connects your PowerCLI session to a specific vCenter
- Enables you to run PowerCLI scripts easily from your local environment
- Persists vCenter connection settings between sessions
- Shares input/output data with the container through mapped directories

### Usage

```bash
./run-powercli-and-connect-vc.sh

## `run-script-get-vms.sh`

The script `run-script-get-vms.sh` behaves like `run-powercli-and-connect-vc.sh`, but it also automatically run a specified PowerCLI script upon startup.

### PowerCLI script to run

The script to run is defined as PS1_SCRIPT="$REMOTE_BASE_DIR_SCRIPTS/get-vms.ps1"

### Benefits

- It shows how to triger PowerCLI container to run a particular PowerShell scripti, and exit.
- This is kind of ephemeral Function as a Service approach to run PowerCLI script
- You can follow this pattern to run any script you prepare in directory ./scripts

### Usage

```bash
./run-script-get-vms.sh

