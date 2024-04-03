# Load the XML content from a file or a string
$xmlContent = Get-Content -Path "C:\Users\mcooper\Downloads\OneDrive_2023-12-21\Computer L1\{EF6E5516-C751-4F3B-A849-C57D772C1B83}\gpreport.xml" -Raw

# Convert XML to JSON
$jsonContent = [xml]$xmlContent | ConvertTo-Json -Depth 5

# Save the JSON content to a file or do something else with it
$jsonContent | Out-File -FilePath "C:\Users\mcooper\OneDrive - Bankers Healthcare Group Inc\Documents\Json FIles\newTestCIS.json" -Encoding UTF8
