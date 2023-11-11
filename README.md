# JobSearch

Tools for job hunting.

### Launch companies powershell script

The launchCompanies powershell script in the scripts directory is ready to use and helps to scan company career web pages. This script opens the companies.csv file and launches a Chrome browser tab for each row with a value in the Url column. A sample CSV is included. Populate the Url column by visiting company career pages, filtering to your liking and then copying the Url to the CSV file. The script pauses every 10 tabs. Evaluate and close the opened tabs. There are some parameters that can be edited in the script for more advanced filtering.

Execute with this command from a windoze cmd prompt -> powershell .\launchCompanies.ps1
