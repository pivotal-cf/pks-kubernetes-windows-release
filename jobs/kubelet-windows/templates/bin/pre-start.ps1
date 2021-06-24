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

## Get disk info and store inside local file

$FolderPath = "/var/vcap/jobs/kubelet-windows/config/"
$FileName = "disk_info"
$Path = $FolderPath + $FileName
if (!(Test-Path $Path))
{
    New-Item -itemType File -Path $FolderPath -Name $FileName
    (Get-Disk | select Number).Number | Out-File -Append -Encoding ASCII $Path
}
else
{
    Write-Host "$FileName File already exists"
}

## Sign kubelet certificate

$SIGN_CMD = "C:\var\vcap\packages\local-sign-windows\bin\local-sign-windows.exe"
$CONFIG_DIR = "C:\var\vcap\jobs\kubelet-windows\config"
$CA_CONFIG_PATH ="${CONFIG_DIR}\kubelet_ca_config.yml"
$CERTIFICATE_TEMPLATE_PATH = "${CONFIG_DIR}\kubelet_certificate_template.yml"
$CERTIFICATE_OUTPUT_DIR = "${CONFIG_DIR}\out"
$KUBELET_CERT_PATH = "${CONFIG_DIR}\kubelet.pem"
$KUBELET_KEY_PATH = "${CONFIG_DIR}\kubelet-key.pem"

function do_kubelet_certificate_sign(){
    # hostname returns something like "WIN-0MM9BP33K43", not the name registered with kube-apiserver, so we read from bosh settings.
    $NODENAME = (Get-Content "C:\var\vcap\bosh\settings.json" | ConvertFrom-Json).agent_id
    (Get-Content ${CERTIFICATE_TEMPLATE_PATH}).replace('NODENAME', ${NODENAME}) | Set-Content ${CERTIFICATE_TEMPLATE_PATH}
    $kubelet_sign_cmd="${SIGN_CMD} certificate --config ${CA_CONFIG_PATH} --template ${CERTIFICATE_TEMPLATE_PATH} --out ${CERTIFICATE_OUTPUT_DIR}"
    Invoke-Expression ${kubelet_sign_cmd}
    Move-Item -Force -Path ${CERTIFICATE_OUTPUT_DIR}\certificate.pem -Destination ${KUBELET_CERT_PATH}
    Move-Item -Force -Path ${CERTIFICATE_OUTPUT_DIR}\key.pem -Destination ${KUBELET_KEY_PATH}
    rmdir ${CERTIFICATE_OUTPUT_DIR}
    echo "successfully prepared kubelet certificate."
}

$NOW = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
echo "${NOW}: Start to sign kubelet certificate..."
do_kubelet_certificate_sign
