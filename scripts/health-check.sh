#!/usr/bin/env bash

overall_status=0

echo "==========================="
echo "LAB Infrastructure Check"
echo "==========================="
echo

echo "Hostname: $(hostname)"
echo "Time: $(date)"

echo "Running checks..."

if ping -c 1 -W 2 10.10.10.1 >/dev/null 2>&1; then
	echo "[PASS] Gateway 10.10.10.1 is reachable"
else
	echo "[FAIL] Gateway 10.10.10.1 is unreachable"
	overall_status=1
fi

if getent hosts dc01.lab.local >/dev/null 2>&1; then
	echo "[PASS] DNS resolution for dc01.lab.local works"
else
	echo "[FAIL] DNS resolution for dc01.lab.local failed"
	overall_status=1
fi

if systemctl is-active --quiet nginx; then
	echo "[PASS] nginx service is working"
else
	echo "[FAIL] nginx service is not running"
	overall_status=1
fi

if curl -fsS --max-time 3 http://localhost >/dev/null 2>&1; then
	echo "[PASS] nginx HTTP service is responding"
else
	echo "[FAIL] nginx HTTP service is not responding"
	overall_status=1
fi

if curl -fsS --max-time 3 http://localhost:9100/metrics >/dev/null 2>&1; then
	echo "[PASS] Node exporter is responding on port 9100"
else
	echo "[FAIL] Node exporter is not responding on port 9100"
	overall_status=1
fi

if curl -fsS --max-time 3 http://localhost:9090/-/healthy >/dev/null 2>&1; then
	echo "[PASS] Prometheus is healthy on port 9090"
else
	echo "[FAIL] Prometheus health check failed"
	overall_status=1
fi

echo

if [ "$overall_status" -eq 0 ]; then
	echo "Overall Status: Healthy"
else
	echo "Overall St'atus: Unhealthy"
fi

exit "$overall_status"
