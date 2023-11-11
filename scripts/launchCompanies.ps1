
# configuration customization

# Set CSV file path and column headers
$Chromepath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$CSVFile = "companies.csv"
$URLColumn = "Url"
$CompanyColumn = "Company"

# Control and optional filter
$NumPerBatch = 10
# Start with company greater than (assumes sorted file)
$StartGreaterThan
# suppress or require based on 1 in column values
$SuppressColumn
$RequireColumn

# other vars
$webcount = 0

# Read CSV and process each row
Import-Csv -Path $CSVFile | ForEach-Object {
    $url = $_.$URLColumn
    $company = $_.$CompanyColumn

    # optional filters
    if ($StartGreaterThan -and $company -gt $StartGreaterThan) {
        return
    }

    if ($RequireColumn -and $_.$RequireColumn -ne "1") {
        #Write-Host ("Required $RequireColumn ignoring value $_.$RequireColumn")
        return
    }

    if ($SuppressColumn -and $_.$SuppressColumn -eq "1") {
        return
    }

    # open url
    if ($url -and $company) {
        Start-Process $Chromepath -ArgumentList $url -NoNewWindow -Wait

        $webcount = $webcount + 1
        if ($webcount % $NumPerBatch -eq 0) {
            Read-Host -Prompt "Press enter to continue"
        }
    }

}
    
