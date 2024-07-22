# Private/ps1

Powershell `.ps1` scripts in this module will be imported for use within the app, but will not be exposed to the user. For example, in the [`Test-Command.ps1`](./Test-Command.ps1) script, there is a function named `Test-Command`. Throughout this module, in scripts in `Public/ps1` (for example), you can call the `Test-Command`, but the user will not be able to run `Test-Command` after importing the module.

The private directory can be used for things like JSON/CSV files the script loads to run commands, variables for use throughout the app, etc.
