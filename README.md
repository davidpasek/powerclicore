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

