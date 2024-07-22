function Get-BatteryHealthReport {
    [CmdletBinding()]
    param(
        [string]$OutputFile = "$env:USERPROFILE\battery-report.html"
    )

    Write-Debug "Outputting battery report to file: $($OutputFile)"

    try {
        powercfg /batteryreport /output $OutputFile
    }
    catch {
        Write-Error "Error saving battery health report to file '$($OutputFile).' Details: $($_.Exception.Message)"
    }
}