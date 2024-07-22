# PowerShell Modules

This is an example Powershell module for reference building future modules.

**Note**: There are many ways to build Powershell modules. This guide lays out an auto-sourcing module, with Public and Private folders to separate app logic from use-facing functions. This is not the only way to build a module! If you find other guides that show different methodologies, try them and find the solution that works best for you.

For more ways to create Powershell modules, check the [Links & Additional Reading section](#links--additional-reading).

## Description

The module has 2 folders, [`Public`](./ModSystemInformation/Public) and [`Private`](./ModSystemInformation/Private); the `Public` folder is where methods that are exposed to the user (like `Get-SystemInformation` in the [`GetSystemInfo`](./ModSystemInformation/Public/GetSystemInfo/) package), while `Private` can be used for functions/constants used internally by the module, without exposing them to the user.

Read the [Post-module init](#post-module-init) section below for more information on how to set up automated sourcing of your module's scripts.

After creating a new manifest, you can "test" it with `Test-ModuleManifest ./path/to/manifest.psd1`. If there is no output, it means the manifest is valid.

## Create a new module

The [`Add-NewPSModule.ps1`](./Add-NewPSModule.ps1) script can be used to aid in generating new Powershell modules. The script accepts params for things like the module's name and description; the script will prompt for required values that were not passed at runtime.

After answering the prompts, a new module will be created at the local `.\` path. For example, if you called `.\Add-NewPSModule.ps1 -ModuleName Example-Module`, a folder named "Example-Module/" will be created, with a manifest, root `.psm1` module, and a `Public/` and `Private/` folder.

### Post-module init

After initializing the module, you need to tell it which functions to "export" to the user. This step can be very manual and involved. You can automate "sourcing" the script files in your module by pasting the following code into the module's `$ModuleName.psm1` script. This code iterates over the `Public/` and `Private/` folders, sourcing all `.ps1` files it encounters. If the script file was in the `Public/` folder, it will be exposed to the user, otherwise functions defined in `Private/` are only available to call from within the module (i.e. a script in the `Public/` folder can access functions defined in scripts in `Private/`, but the user cannot).

Add this to the module's `.psm1` file:

```powershell
## Set directory separator character, i.e. '\' on Windows
$DirectorySeparator = [System.IO.Path]::DirectorySeparatorChar
## Set name of module from $PSScriptRoot
$ModuleName = $PSScriptRoot.Split($DirectorySeparator)[-1]
## Look for module manifest file
$ModuleManifest = $PSScriptRoot + $DirectorySeparator + $ModuleName + '.psd1'
## Loop Public/ directory and load all .ps1 files into var
$PublicFunctionsPath = $PSScriptRoot + $DirectorySeparator + 'Public' + $DirectorySeparator + 'ps1'
## Loop Private/ directory and load all .ps1 files into var
$PrivateFunctionsPath = $PSScriptRoot + $DirectorySeparator + 'Private' + $DirectorySeparator + 'ps1'

## Test the module manifest
$CurrentManifest = Test-ModuleManifest $ModuleManifest

$Aliases = @()

## Get list of .ps1 files in Public/ recursively
$PublicFunctions = Get-ChildItem -Path $PublicFunctionsPath -Recurse -Filter *.ps1
## Get list of .ps1 files in Private/ recursively
$PrivateFunctions = Get-ChildItem -Path $PrivateFunctionsPath -Recurse -Filter *.ps1

## Load all Powershell functions from script files
$PrivateFunctions | ForEach-Object { 
    Write-Verbose "Loading private function from: $($_.FullName)"
    . $_.FullName 
}  # Load private functions first

$PublicFunctions | ForEach-Object { 
    Write-Verbose "Loading public function from: $($_.FullName)"
    . $_.FullName 
}   # Load public functions after

## Export all public functions
$PublicFunctionNames = $PublicFunctions | ForEach-Object { $_.BaseName }
Export-ModuleMember -Function $PublicFunctionNames

## Handle aliases if needed
$PublicFunctions | ForEach-Object {
    $alias = Get-Alias -Definition $_.BaseName -ErrorAction SilentlyContinue
    if ($alias) {
        $Aliases += $alias
        ## Export aliased function, if one is defined
        Export-ModuleMember -Alias $alias
    }
}

## Add all functions loaded from $PublicFunctions to an array
$FunctionsAdded = $PublicFunctions | Where-Object { $_.BaseName -notin $CurrentManifest.ExportedFunctions.Keys }
## Remove any undetected functions from module manifest
$FunctionsRemoved = $CurrentManifest.ExportedFunctions.Keys | Where-Object { $_ -notin $PublicFunctions.BaseName }

$AliasesAdded = $Aliases | Where-Object { $_ -notin $CurrentManifest.ExportedAliases.Keys }
$AliasesRemoved = $CurrentManifest.ExportedAliases.Keys | Where-Object { $_ -notin $Aliases }

if ($FunctionsAdded -or $FunctionsRemoved -or $AliasesAdded -or $AliasesRemoved) {
    try {
        ## Update module manifest when changes are detected
        $UpdateModuleManifestParams = @{}
        $UpdateModuleManifestParams.Add('Path', $ModuleManifest)
        $UpdateModuleManifestParams.Add('ErrorAction', 'Stop')
        if ($Aliases.Count -gt 0) { $UpdateModuleManifestParams.Add('AliasesToExport', $Aliases) }
        if ($PublicFunctionNames.Count -gt 0) { $UpdateModuleManifestParams.Add('FunctionsToExport', $PublicFunctionNames) }

        Update-ModuleManifest @updateModuleManifestParams
    }
    catch {
        $_ | Write-Error
    }
}

```

## Add scripts to your module

Keeping in mind that the `Private/ps1` folder is for functions/code meant only for internal use within the module, and the `Public/ps1` folder is for functions/code you wish to expose to the user, start adding your scripts to the appropriate folder.

This may feel counter-intuitive, but your script files should be as simple as possible, and named like a function. For example, the [`Get-Uptime.ps1`](./TestModule/Public/ps1/system/Get-Uptime.ps1) module has a single function, also called `Get-Uptime`, which is sourced by the code in the [module's `.psm1` file](./TestModule/TestModule.psm1). The `Get-Uptime.ps1` script is exposed to the user, but calls the [`Get-SystemUptime` function in the private/folder](./TestModule/Private/ps1/system/Get-SystemUptime.ps1).

Follow this pattern for "hiding" app logic/core features from the user. Treat the `Public/` folder like your script's API that the user will be interacting with by calling various functions.

## Links & Additional Reading

- [benheater.com: Creating a Powershell module](https://benheater.com/creating-a-powershell-module/)
- [Powershell Module Building Basics](https://powershellexplained.com/2017-05-27-Powershell-module-building-basics/)
- [Building a Powershell Module](https://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/)
- [AdamTheAutomator: Powershell Modules](https://adamtheautomator.com/powershell-modules/)
- [LazyAdmin: Powershell Scripting - Get started with this ultimate guide](https://lazyadmin.nl/powershell/powershell-script/)
