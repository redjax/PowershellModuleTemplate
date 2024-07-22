function Get-SystemInfo {
    [CmdletBinding()]
    param(
        $ComputerName = "localhost"
    )

    Get-WmiObject -ComputerName $ComputerName -Class Win32_BIOS
}