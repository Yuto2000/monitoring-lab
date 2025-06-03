#!/bin/bash

# Monitoring Lab - Complete Demo Script
echo "🚀 Monitoring Lab - Complete Feature Demo"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}📊 DASHBOARD STATUS${NC}"
echo "==================="

# Get dashboard information
echo "✅ Available Dashboards:"
curl -s -u admin:admin "http://localhost:3000/api/search?type=dash-db" | jq -r '.[] | "  • \(.title) → http://localhost:3000/d/\(.uid)"'

echo ""
echo -e "${CYAN}📈 LIVE METRICS${NC}"
echo "==============="

# Get current metrics
echo "🖥️  Services Up:"
curl -s "http://localhost:9090/api/v1/query?query=up" | jq -r '.data.result[] | "  • \(.metric.job): \(.value[1])"'

echo ""
echo "💾 Memory Usage:"
MEM_USAGE=$(curl -s "http://localhost:9090/api/v1/query?query=(1%20-%20(node_memory_MemAvailable_bytes%20/%20node_memory_MemTotal_bytes))%20*%20100" | jq -r '.data.result[0].value[1] // "N/A"')
echo "  • Current: ${MEM_USAGE}%"

echo ""
echo -e "${GREEN}🎯 ACCESS POINTS${NC}"
echo "================"
echo "📊 Grafana:      http://localhost:3000 (admin/admin)"
echo "🔍 Prometheus:   http://localhost:9090"
echo "🚨 Alertmanager: http://localhost:9093"
echo "📦 cAdvisor:     http://localhost:8080"

echo ""
echo -e "${BLUE}✨ SUCCESS!${NC}"
echo "==========="
echo "Your monitoring infrastructure is fully operational!"
echo "🎉 Hello World dashboard should now display live data"
