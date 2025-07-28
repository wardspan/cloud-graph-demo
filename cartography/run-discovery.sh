#!/bin/bash

echo "🗺️ Cartography Asset Discovery Simulation"
echo "=========================================="

# Wait for Neo4j to be ready
echo "⏳ Waiting for Neo4j connection..."
while ! python3 -c "
from neo4j import GraphDatabase
try:
    driver = GraphDatabase.driver('bolt://neo4j:7687', auth=('neo4j', 'cloudsecurity'))
    with driver.session() as session:
        result = session.run('RETURN 1')
        list(result)
    driver.close()
    print('✅ Connected to Neo4j')
    exit(0)
except Exception as e:
    print(f'❌ Neo4j not ready: {e}')
    exit(1)
"; do
    echo "⏳ Waiting for Neo4j..."
    sleep 5
done

# Wait for LocalStack to be ready
echo "⏳ Waiting for LocalStack AWS services..."
while ! curl -s http://localstack:4566/_localstack/health | jq -e '.services.ec2 == "running"' > /dev/null; do
    echo "⏳ Waiting for LocalStack services..."
    sleep 5
done
echo "✅ LocalStack services ready"

echo ""
echo "🚀 Starting simulated asset discovery..."
echo "This demonstrates how Cartography discovers cloud infrastructure"
echo ""

# Run the simulation
python3 /opt/cartography/simulate-discovery.py

echo ""
echo "✅ Asset discovery simulation complete!"
echo "🎯 Infrastructure mapped and available for analysis"
echo "📊 Use the dashboard to explore discovered assets"
echo ""

# Keep container running for manual discovery triggers
echo "🔄 Discovery service ready for manual triggers..."
echo "💡 POST to http://localhost:8080/discover to run discovery again"

# Simple HTTP server for manual discovery triggers
python3 -c "
import http.server
import socketserver
import subprocess
import json
from urllib.parse import urlparse, parse_qs

class DiscoveryHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/discover':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            # Run discovery simulation
            print('🔍 Manual discovery triggered...')
            result = subprocess.run(['python3', '/opt/cartography/simulate-discovery.py'], 
                                 capture_output=True, text=True)
            
            response = {
                'status': 'success' if result.returncode == 0 else 'error',
                'message': 'Discovery completed' if result.returncode == 0 else 'Discovery failed',
                'output': result.stdout,
                'error': result.stderr if result.returncode != 0 else None
            }
            
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

PORT = 8080
with socketserver.TCPServer(('', PORT), DiscoveryHandler) as httpd:
    print(f'🌐 Discovery API server running on port {PORT}')
    httpd.serve_forever()
"