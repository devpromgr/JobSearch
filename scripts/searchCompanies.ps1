<#
This script was meant to download a companies job search page and allow searches that summarize job posts based on pattern matches.
Unfortunately the default downloader is pulling down raw HTML and more of a rendered scraper is needed.
Plus many websites have small page sizes of like 10 entries so automation of paging would be very helpful.
Given these issues this effort is abandoned for now in favor of doing manual review using the jobLaunch script.
#>

# Set CSV file path and column headers
$CSVFile = "companies.csv"
$URLColumn = "Url"
$CompanyColumn = "Company"

# Create top-level directory based on current date
$Date = Get-Date -Format "yyyyMMdd"
$TopLevelDir = Join-Path -Path (Get-Location) -ChildPath $Date
New-Item -Path $TopLevelDir -ItemType Directory -Force

# Function to remove HTML tags and replace common HTML entities
function Get-PlainText {
    param (
        [string]$HtmlContent
    )

    # Remove HTML tags
    $text = $HtmlContent -replace '<[^>]+>', ' '

    # Replace HTML entities
    $text = $text -replace '&nbsp;', ' ' -replace '&lt;', '<' -replace '&gt;', '>' -replace '&amp;', '&'

    # Optionally, remove additional HTML entities and control characters as needed

    return $text
}


# Read CSV and process each row
Import-Csv -Path $CSVFile | ForEach-Object {
    $url = $_.$URLColumn
    $company = $_.$CompanyColumn
    
    if ($url -and $company -and $False) {
        
        $companyDir = Join-Path -Path $TopLevelDir -ChildPath $company

        # Create company directory if it doesn't exist
        if (-not (Test-Path -Path $companyDir)) {
            New-Item -Path $companyDir -ItemType Directory
        }

        # Download webpage content
        $localFilePath = Join-Path -Path $companyDir -ChildPath "page.htm"
        #Invoke-WebRequest -Uri $url -OutFile $localFilePath

        & wget $Uri -O $localFilePath
        #$Response = Invoke-WebRequest -Uri $url 
        # Extract text content
        #$plainText = Get-PlainText -HtmlContent $Response.Content
        #$plainText $Response.Content
        #Set-Content -Path $localFilePath -Value $plainText

        <#
        if ($Response.RawContentStream.Length -gt 0) {
            $FileStream = [System.IO.File]::Create($localFilePath)
            try {
                $FileStream.Write($plaintext)
                #$Response.RawContentStream.CopyTo($FileStream)
            } finally {
                $FileStream.Dispose()
            }
        }
        #>

    }
    
}

# Function to search for text matches
function Search-TextMatches {
    param (
        [string]$SearchString,
        [string]$OutputFile
    )

    Get-ChildItem -Path $TopLevelDir -Recurse -Filter "*.htm" | ForEach-Object {
        
        <#
        $content = Get-Content -Path $_.FullName
        $matches1 = Select-String -InputObject $content -Pattern $SearchString
        foreach ($match in $matches1) {
            "$($_.FullName): $($match.Line)" | Out-File -Append -FilePath $OutputFile
        }
        #>
        
        # Read the file line by line
        Get-Content -Path $_.FullName | ForEach-Object {
            # Process each line
            # $_ is the current line
            # Write-Host $_

            $matches1 = Select-String -InputObject $_ -Pattern $SearchString
            foreach ($match in $matches1) {
                "$($_.FullName): $($match.Line)" | Out-File -Append -FilePath $OutputFile
            }
        } 
    }
}




# Example usage of the search function
$localFilePath = Join-Path -Path $TopLevelDir -ChildPath "searchManager.txt"
$search = "(software).*?(manager)|(manager).*?(software)"
Search-TextMatches -SearchString $search -OutputFile $localFilePath

$localFilePath = Join-Path -Path $TopLevelDir -ChildPath "searchDirector.txt"
$search = "(software).*?(director)|(director).*?(software)"
Search-TextMatches -SearchString $search -OutputFile $localFilePath

$localFilePath = Join-Path -Path $TopLevelDir -ChildPath "searchArchitect.txt"
$search = "(software).*?(architect)|(architect).*?(software)"
Search-TextMatches -SearchString $search -OutputFile $localFilePath

$localFilePath = Join-Path -Path $TopLevelDir -ChildPath "searchEngineer.txt"
$search = "(software).*?(engineer)|(engineer).*?(software)"
Search-TextMatches -SearchString $search -OutputFile $localFilePath
