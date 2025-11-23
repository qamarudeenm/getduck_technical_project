#!/bin/bash

# Fix Docker Restart Issues
# This script forcefully stops and recreates containers when normal restart fails

echo "========================================="
echo "Docker Container Restart Fix"
echo "========================================="
echo ""

CONTAINER_NAME=${1:-python-api-service}

echo "Fixing container: $CONTAINER_NAME"
echo ""

# Step 1: Try to kill the container process
echo "Step 1: Forcefully killing container process..."
sudo docker kill $CONTAINER_NAME 2>/dev/null || echo "Container not running or already killed"
sleep 2

# Step 2: Remove the container
echo "Step 2: Removing container..."
sudo docker rm -f $CONTAINER_NAME 2>/dev/null || echo "Container already removed"
sleep 1

# Step 3: Recreate the container using docker-compose
echo "Step 3: Recreating container with docker-compose..."
cd /home/blueberry/Desktop/get_duck_technical_project
sudo docker-compose up -d $CONTAINER_NAME

echo ""
echo "Step 4: Waiting for container to start (10 seconds)..."
sleep 10

# Step 5: Check container status
echo ""
echo "Step 5: Checking container status..."
sudo docker ps | grep $CONTAINER_NAME

echo ""
echo "Step 6: Checking logs..."
sudo docker logs $CONTAINER_NAME --tail 20

echo ""
echo "========================================="
echo "Container restart complete!"
echo "========================================="
echo ""
echo "Usage for other containers:"
echo "  ./fix_docker_restart.sh [container-name]"
echo ""
echo "Examples:"
echo "  ./fix_docker_restart.sh python-api-service"
echo "  ./fix_docker_restart.sh clickhouse-server"
echo "  ./fix_docker_restart.sh dbt-cli"
