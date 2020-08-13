# turn the sanPolicy to OnlineAll so that pvc could work properly
Set-StorageSetting -NewDiskPolicy OnlineAll
# Reads file-arguments.json, decodes base64 encoded values
# and writes the output to a file named after the associated key.
$base_path = 'C:\var\vcap\jobs\kubelet-windows'
$file_args_dict = Get-Content "$base_path\config\file-arguments.json" | Out-String | ConvertFrom-Json

$properties = $file_args_dict | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name

foreach($property in $properties) {
    $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($file_args_dict."$property"))
    $decoded | Out-File -FilePath "$base_path\config\$property"
}
