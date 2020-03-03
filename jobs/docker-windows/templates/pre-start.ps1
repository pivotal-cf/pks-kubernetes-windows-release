$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$mtx = New-Object System.Threading.Mutex($false, "PathMutex")

if (!$mtx.WaitOne(300000)) {
  throw "Could not acquire PATH mutex"
}

$AddedFolder= "C:\var\vcap\packages\docker-windows\docker\"

$OldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path

if (-not $OldPath.Contains($AddedFolder)) {
  $NewPath=$OldPath+';'+$AddedFolder
  Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
}

$mtx.ReleaseMutex()

# TODO for now, hardcode proxy settings for testing; get values from link

SetX HTTP_PROXY "10.87.30.201:8888" /m
SetX HTTPS_PROXY "10.87.30.201:8888" /m
SetX NO_PROXY ".internal,.svc,.svc.cluster.local,.svc.cluster,192.167.20.0/16,192.168.20.0/16,10.87.30.0/24" /m

C:\var\vcap\packages\docker-windows\docker\dockerd --register-service

Start-Service Docker
