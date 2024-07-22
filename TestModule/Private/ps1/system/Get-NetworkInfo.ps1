function Get-NetworkInfo {
    [CmdletBinding()]
    
    $IPTable = Get-NetIPAddress | Format-Table

    return $IPTable
}