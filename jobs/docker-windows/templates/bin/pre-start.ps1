$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

#remove pid file if one exists from previous running docker
#TODO check if dockerd proccess is running as well
$DockerPidPath = "C:\ProgramData\docker\docker.pid"
if (Test-Path $DockerPidPath) {
  rm $DockerPidPath 
}

# Add docker dir to the PATH using a Mutex
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

# Add docker root directory
$DockerRootDir="C:\var\vcap\jobs\docker-windows\docker"
if (!(Test-Path -Path $DockerRootDir)) {
  New-Item -ItemType directory -Path $DockerRootDir
}
