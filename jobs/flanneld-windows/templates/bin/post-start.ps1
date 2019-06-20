$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

<% if p("backend-type") == "win-overlay" %>
  <% name = "flannel.4096" %>
<% else %>
  <% name = "cbr0" %>
<% end %>

$timeout = 60 # seconds
$timer = [Diagnostics.Stopwatch]::StartNew()


while (!(Get-HNSNetwork | ? Name -Eq "<%= name %>") -and ($timer.Elapsed.TotalSeconds -lt $timeout))
{
    Write-Host "Waiting for overlay network to be enabled"
    Start-Sleep -sec 1
}
$timer.Stop()
if ($timer.Elapsed.TotalSeconds -gt $timeout) {
  throw 'timed out waiting for Flannel network to be created'
}

# add back GCP / AWS metadata server
route /p add 169.254.169.254 mask 255.255.255.255 0.0.0.0
