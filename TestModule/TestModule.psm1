<#
    A "docstring" at the top of the module is not required, but when included, will add a "help"
    entry to the Get-Help command.

    .SYNOPSIS
    An example Powershell module, to be used as a reference when creating future modules.

    .Description
    Module entrypoint. Loops scripts in Public/ and Private/, exposing functions found in scripts
    in the Public/ folder to the user. Scripts in Private/ are reserved for use within the module.

    This module does not do much of use on its own, it is merely an example of how to structure
    a Powershell module.

    .EXAMPLE
    Import-Module .\TestModule
    Get-Module TestModule

    .NOTES
    Version: 1.0
    Author: Jack Kenyon
    Creation Date: 07-22-2024
    Modified Date: 
    Purpose/Change: Init
    Link: 
#>

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
