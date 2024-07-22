function Get-SystemUptime {
    $Uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

    return $Uptime
}