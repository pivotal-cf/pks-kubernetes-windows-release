trap { $host.SetShouldExit(1) }

echo "Drain cluster"

if (Test-Path "/var/vcap/jobs/kubelet-windows/bin/drain.ps1") {
  /var/vcap/jobs/kubelet-windows/bin/drain.ps1
  rm /var/vcap/jobs/kubelet-windows/bin/drain.ps1
}
