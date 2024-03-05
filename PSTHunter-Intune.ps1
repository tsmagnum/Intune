#region Credits
# Author: Federico Lillacci - Coesione Srl - www.coesione.net
# GitHub: https://github.com/tsmagnum
# Version 1.1 - Path string splitted
# Date: 04/03/2024
# 
# The script searches for PST files in the computer
#
#endregion

#region TODO

#endregion

#creating an empty array for the results
$results = @()

#performing the search
$pstFiles = Get-Wmiobject -namespace "root\CIMV2" -Query "Select * from CIM_DataFile Where Extension = 'pst'"

#storing the results in PS Object
Foreach ($file in $PstFiles)
{
    $result = [PSCustomObject]@{
        Computer = $file.CSName
        Name = $file.Filename
        Path = $file.Description.Split("\")
        Size = ($file.FileSize)/1GB
        LastAccess = ($file.LastAccessed.Split("."))[0]
    }  

    $results += $result

}

#outputting the results, converted to JSON format
$results | ConvertTo-Json 