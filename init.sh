#!/bin/bash
# init.sh - n8n Queue Mode Initialization Script

set -e

echo "==================================="
echo "n8n Queue Mode Setup"
echo "==================================="

# Create necessary directories
echo "Creating data directories..."
mkdir -p ./data/postgres
mkdir -p ./data/redis
mkdir -p ./data/n8n

# Start services
echo "Starting services..."
sudo docker compose up -d

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 10

# Check service health
echo "Checking service status..."
sudo docker compose ps

echo ""
echo "==================================="
echo "Setup complete!"
echo "==================================="
echo "Access editor: https://${N8N_HOST}"
echo ""
echo "To view logs: docker compose logs -f"
echo "To stop: docker compose down"
echo ""