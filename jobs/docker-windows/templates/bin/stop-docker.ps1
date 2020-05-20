# if docker process is running stop it 
$dockerd = Get-Process dockerd -ErrorAction SilentlyContinue
if ($dockerd) {
    $dockerd.Kill() -ErrorAction SilentlyContinue
    $dockerd.WaitForExit(30000) #30 seconds
}

# remove pid file if one is left over from the docker process we just killed
$DockerPidPath = "C:\ProgramData\docker\docker.pid"
if (Test-Path $DockerPidPath) {
    rm $DockerPidPath
}