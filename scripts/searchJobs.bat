:: @echo off
setlocal enabledelayedexpansion

:: Set CSV file path and column headers
set CSV_FILE=companies.csv
set URL_COLUMN=Url
set COMPANY_COLUMN=Company

:: Use PowerShell to parse the CSV and extract required data
powershell -Command " 
{
    $data = Import-Csv -Path '%CSV_FILE%'
    foreach ($row in $data) {
        $url = $row.'%URL_COLUMN%'
        $company = $row.'%COMPANY_COLUMN%'
        Write-Output "$url, $company"
    } 
}" > temp_data.txt

:: Create top-level directory based on date
set TOP_LEVEL_DIR=%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%
md %TOP_LEVEL_DIR%

:: Read the temp data file and create directories
for /f "tokens=1,2 delims=," %%a in (temp_data.txt) do (
    set COMPANY_DIR=%TOP_LEVEL_DIR%\%%b
    if not exist "!COMPANY_DIR!" md "!COMPANY_DIR!"
)

:: Download webpage content using PowerShell
for /f "tokens=1,2 delims=," %%a in (temp_data.txt) do (
    set COMPANY_DIR=%TOP_LEVEL_DIR%\%%b
    powershell -Command "& {
        Invoke-WebRequest '%%a' -OutFile '!COMPANY_DIR!\page.html'
    }"
)

:: Function to search for matches
:searchFunction
setlocal
set SEARCH_STRING=%1
set OUTPUT_FILE=%2

powershell -Command "& {
    Get-ChildItem -Path '%TOP_LEVEL_DIR%' -Recurse -Filter '*.html' | ForEach-Object {
        $content = Get-Content $_.FullName
        $matches = $content | Select-String -Pattern '%SEARCH_STRING%'
        foreach ($match in $matches) {
            "$($_.FullName): $match" | Out-File -Append -FilePath '%OUTPUT_FILE%'
        }
    }
}"
endlocal
goto :eof

:: Example usage of the search function
call :searchFunction "your_search_term" "search_results.txt"