$overallStatus = 0

Write-Host "==================================="
Write-Host " Lab Infrastructure Health Check"
Write-Host "===================================="

Write-Host "Computer: $env:COMPUTERNAME"
Write-Host "Time: $(Get-Date)"
Write-Host ""
Write-Host "Running checks..."

if (Test-Connection -ComputerName 10.10.10.10 -Count 1 -Quiet) {
	Write-Host "[PASS] DC01 10.10.10.10 is reachable"
}
else {
	Write-Host "[FAIL] DC01 10.10.10.10 is unreachable"
	$overallStatus = 1
}

try {
	$dnsResult = resolve-DnsName app01.lab.local -ErrorAction Stop
	Write-Host "[PASS] DNS resoulution for app01.lab.local works"
}
catch {
	Write-Host "[FAIL] DNS resolution for app01.lab.local failed"
	$overallStatus = 1
}

$httpTest = Test-NetConnection app01.lab.local -Port 80 -WarningAction SilentlyContinue

if ($httpTest.TcpTestSucceeded) {
    Write-Host "[PASS] nginx is reachable on APP01 port 80"
}
else {
    Write-Host "[FAIL] nginx is unreachable on APP01 port 80"
	$overallStatus = 1
}

$prometheusTest = Test-NetConnection app01.lab.local -Port 9090 -WarningAction SilentlyContinue

if ($prometheusTest.TcpTestSucceeded) {
    Write-Host "[PASS] Prometheus is reachable on APP01 port 9090"
}
else {
    Write-Host "[FAIL] Prometheus is unreachable on APP01 port 9090"
	$overallStatus = 1
}

$exporterTest = Test-NetConnection app01.lab.local -Port 9100 -WarningAction SilentlyContinue

if ($exporterTest.TcpTestSucceeded) {
    Write-Host "[PASS] Node Exporter is reachable on APP01 port 9100"
}
else {
    Write-Host "[FAIL] Node Exporter is unreachable on APP01 port 9100"
	$overallStatus = 1
}

$sshTest = Test-NetConnection app01.lab.local -Port 22 -WarningAction SilentlyContinue

if ($sshtest.TcpTestSucceeded) {
	Write-Host "[PASS] SSH is reachable on APP01 port 22"
}
else {
	Write-Host "[FAIL] SSH is unreachable on APP01 port 22"
	$overallStatus = 1
}

Write-Host""

if ($overallStatus -eq 0) {
	Write-Host "Overall Status:HEALTHY"
}
else {
	Write-Host "Overall Status UNHEALTHY"
}

exit $overallStatus