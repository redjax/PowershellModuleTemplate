function Confirm-CoffeeTime {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Regular', 'Decaf')]
        [String]$CoffeeType
    )

    begin {
        $currentDateTime = Get-Date
        $regularCoffeeHours = 4..20
        $decafCoffeeHours = 0..3 + 21..23
    }
    process {

        if ($CoffeeType -eq 'Regular') {

            if ($currentDateTime.Hour -in $regularCoffeeHours) {
                $result = $true
            }
            else {
                $result = $false
            }

        }
        else {

            if ($currentDateTime.Hour -in $decafCoffeeHours) {
                $result = $true
            }
            else {
                $result = $false
            }

        }

    }
    end {

        if ($result -eq $true) {
            return "Enjoy your cup of $CoffeeType coffee!"
        }
        else {
            throw "You may not drink $CoffeeType right now!"
        }

    }

}