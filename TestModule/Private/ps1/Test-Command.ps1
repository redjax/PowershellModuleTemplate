function Test-Command {
    [CmdletBinding()]
    param(
        [string]$CommandName = $null
    )

    If ( -Not $CommandName ) {
        Write-Error "Missing a command to test"
    }

    ## Store current $ErrorActionPreference in a variable
    $oldPreference = $ErrorActionPreference
    ## Temporarily set $ErrorActionPreference, overriding previous value
    $ErrorActionPreference = 'stop'

    try {
        If (Get-Command $command) { "$command exists" }
    }
    catch {
        "$command does not exist" 
    }
    finally {
        ## Reset $ErrorActionPreference, regardless of function outcome
        $ErrorActionPreference = $oldPreference
    }
}