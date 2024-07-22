<#
    .SYNOPSIS
    An example Powershell module script that calls an internal/"private" function.

    .Description
    Determine if it's time to drink decaf or regular coffee. Call the internal Confirm-CoffeeTime
    function defined in $PSModuleRoot\Private\ps1\Confirm-CoffeeTime.ps1.

    .EXAMPLE
    Get-Coffee -CoffeeType ['regular', 'decaf']

    .NOTES
    Version: 1.0
    Author: Jack Kenyon
    Creation Date: 07-22-2024
    Modified Date: 
    Purpose/Change: Init
    Link: 
#>

function Get-Coffee {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Regular', 'Decaf')]
        [String]$CoffeeType
    )

    begin {}
    process {

        try {
            # Call the private function to confirm coffee time
            $confirmation = Confirm-CoffeeTime -CoffeeType $CoffeeType
            Write-Host $confirmation -ForegroundColor Green
        }
        catch {
            throw $_
        }

    }
    end {}

}