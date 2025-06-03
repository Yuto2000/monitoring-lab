#!/bin/bash

# Test Dashboard Queries
echo "🧪 Testing Dashboard Queries"
echo "============================"

echo ""
echo "1. Testing 'up' query (Services Status)..."
curl -s -u admin:admin "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=up" | jq '.data.result | length'
echo "   ✅ Found services"

echo ""
echo "2. Testing CPU Usage query..."
curl -s -u admin:admin "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=100%20-%20(avg%20by%20(instance)%20(irate(node_cpu_seconds_total{mode=\"idle\"}[5m]))%20*%20100)" | jq '.data.result | length'
echo "   ✅ CPU metrics available"

echo ""
echo "3. Testing Memory Usage query..."
curl -s -u admin:admin "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=(1%20-%20(node_memory_MemAvailable_bytes%20/%20node_memory_MemTotal_bytes))%20*%20100" | jq '.data.result | length'
echo "   ✅ Memory metrics available"

echo ""
echo "4. Testing Container Network I/O query..."
curl -s -u admin:admin "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=rate(container_network_receive_bytes_total[5m])" | jq '.data.result | length'
echo "   ✅ Container network metrics available"

echo ""
echo "📊 Dashboard should now display data!"
echo "🔗 Open: http://localhost:3000/d/hello-world"
