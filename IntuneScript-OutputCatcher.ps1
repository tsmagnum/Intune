#region Credits
# Author: Federico Lillacci - Coesione Srl - www.coesione.net
# GitHub: https://github.com/tsmagnum
# Version: 1.1
# Date: 06/03/2024
#
#
# Thanks to Micheal Griswold
# https://techcommunity.microsoft.com/t5/device-management-in-microsoft/how-to-collect-custom-inventory-from-azure-ad-joined-devices/ba-p/2280850
#endregion

#region TODO

#endregion

#scriptId variable - this needs to be set before running the script!
#$scriptId = "ddf14782-b75e-4479-afae-779e0b248e6f" WARNING: This is just an example
$scriptId = ""

#checking if $scriptId is present; exiting if it's null
if (!$scriptId) 
    {
        Write-Host -ForegroundColor Red 'Error: $scriptId variable is null, cannot proceed'
        Write-Host -ForegroundColor Yellow "Please set this variable before running the script again"
        exit
    }

#connecting to MS Graph
Update-MSGraphEnvironment -SchemaVersion 'beta'
Connect-MSGraph

#creating two empty arryas to store the results
$jsonArray = @()
$resultsArray = @()

#setting the Graph url
$graphUrl = "deviceManagement/deviceManagementScripts/$($scriptId)"+
    '/deviceRunStates?$expand=managedDevice($select=deviceName)&$select=lastStateUpdateDateTime,errorCode,resultMessage'

#making the Graph request and converting to a PS Object the JSON results contained in the resultMessage
$graphResult = Invoke-MSGraphRequest -HttpMethod GET -Url $graphUrl | Get-MSGraphAllPages

foreach ($result in $graphResult)
{
    $deserializedObj = $result.resultMessage | ConvertFrom-Json

    $jsonArray += $deserializedObj
}

#nested looping through the array of results converted from JSON:
#inside the main array, we have a nested array when a computer contains more than a PST file
for ($i = 0; $i -lt $jsonArray.Length; $i++)
{
    #creating the PstFilePath property from the filePath array
    #this step is needed to avoid the problem with the "\" character in the JSON response
    foreach ($item in $jsonArray[$i])
        {
                $filePath = $item.Path -join "\" 
                $item | Add-Member -Name PstFilePath -MemberType NoteProperty -Value $filePath -ErrorAction SilentlyContinue
                $item.PSObject.Properties.Remove("Path")

                #storing the final results in the results array
                $resultsArray += $item
        }
}

#final results output
#default format, console output
$resultsArray | Format-Table

#uncomment get the results in ogv
#$resultsArray | Out-GridView

#uncomment to export to CSV; modify the path accordingly
#$resultsArray | export-csv -NoTypeInformation -Path pstFiles.csv

#how many computer were processed
Write-Host -ForegroundColor Cyan "Script eseguito su $($graphResult.Count) computer"
