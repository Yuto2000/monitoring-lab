#!/bin/bash

# Monitoring Stack Verification Script
# This script tests all components of the monitoring setup

echo "🚀 Monitoring Lab - Health Check"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check service health
check_service() {
    local service_name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $service_name... "
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected_status"; then
        echo -e "${GREEN}✓ PASS${NC}"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

# Function to check JSON endpoint
check_json_endpoint() {
    local service_name=$1
    local url=$2
    
    echo -n "Testing $service_name JSON... "
    
    if curl -s "$url" | jq . > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

# Function to check metrics endpoint
check_metrics() {
    local service_name=$1
    local url=$2
    
    echo -n "Testing $service_name metrics... "
    
    if curl -s "$url" | grep -q "# HELP"; then
        echo -e "${GREEN}✓ PASS${NC}"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

echo ""
echo "🔍 Checking Docker Containers..."
docker-compose ps

echo ""
echo "🌐 Testing Service Endpoints..."

# Test main services
check_service "Grafana" "http://localhost:3000/api/health"
check_service "Prometheus" "http://localhost:9090/-/ready"
check_service "Alertmanager" "http://localhost:9093/-/ready"
check_service "cAdvisor" "http://localhost:8080/containers/"

# Test metrics endpoints
echo ""
echo "📊 Testing Metrics Collection..."
check_metrics "Node Exporter" "http://localhost:9100/metrics"
check_metrics "Prometheus" "http://localhost:9090/metrics"
check_metrics "cAdvisor" "http://localhost:8080/metrics"

# Test JSON APIs
echo ""
echo "🔗 Testing API Endpoints..."
check_json_endpoint "Prometheus Targets" "http://localhost:9090/api/v1/targets"
check_json_endpoint "Prometheus Config" "http://localhost:9090/api/v1/status/config"
check_json_endpoint "Alertmanager Status" "http://localhost:9093/api/v1/status"

# Test Grafana dashboards
echo ""
echo "📈 Testing Grafana Dashboards..."
echo -n "Testing dashboard provisioning... "

# Check if our custom dashboard is loaded
if curl -s -u admin:admin "http://localhost:3000/api/dashboards/uid/hello-world" | jq -r '.dashboard.title' | grep -q "Hello World"; then
    echo -e "${GREEN}✓ PASS - Dashboard loaded${NC}"
else
    echo -e "${YELLOW}⚠ WARNING - Dashboard not fully loaded yet${NC}"
fi

# Test alert rules
echo ""
echo "🚨 Testing Alert Configuration..."
echo -n "Testing alert rules... "

if curl -s "http://localhost:9090/api/v1/rules" | jq -r '.data.groups[].rules[].name' | grep -q "HighCPUUsage"; then
    echo -e "${GREEN}✓ PASS - Alert rules loaded${NC}"
else
    echo -e "${RED}✗ FAIL - Alert rules not found${NC}"
fi

echo ""
echo "🎯 Access URLs:"
echo "  Grafana:     http://localhost:3000 (admin/admin)"
echo "  Prometheus:  http://localhost:9090"
echo "  Alertmanager: http://localhost:9093"
echo "  cAdvisor:    http://localhost:8080"
echo "  Node Exp:    http://localhost:9100/metrics"

echo ""
echo "📝 Quick Test Commands:"
echo "  docker-compose logs grafana     # Check Grafana logs"
echo "  docker-compose logs prometheus  # Check Prometheus logs"
echo "  docker-compose restart grafana  # Restart Grafana"

echo ""
echo -e "${GREEN}✅ Health check completed!${NC}"
echo "Open Grafana at http://localhost:3000 and login with admin/admin"
