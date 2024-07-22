# Public/ps1

Powershell `.ps1` scripts in this folder will be "sourced" by the module's main `.psm1` (at the module root). The function in the `.psm1` script at the module root iterates over the `Public/ps1` directory and "sources" all scripts, exposing them to the user.

For example, the [`Install-AzureCLI.ps1`](./Install-AzureCLI.ps1) script calls the private `Test-Command` function to determine if the `az` command is installed, and installs it with `winget` if not.
