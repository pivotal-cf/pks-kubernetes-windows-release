trap { $host.SetShouldExit(1) }

function kubelet_is_running() {
  curl.exe --fail http://localhost:10248/healthz
  return $?
}

function main() {
    retry "passed kubelet healthcheck" $function:kubelet_is_running
}

function retry($name, $func) {
  $attempt_number=1
  $max_attempts=10

  do {
    $result=$func.Invoke()
    if ($result) {
      Write-Output "Successfully $name"
      return $true
    }
    Write-Output ("[{0}] Unsuccessful {1}, retrying attempt {2} out of {3}" -f (Get-Date -UFormat %s), $name, $attempt_number, $max_attempts)
    $attempt_number=$attempt_number + 1
    sleep 1
  } while ($attempt_number -le $max_attempts)

  Write-Output "Failed all retry attempts for $name"
  return $false
}
