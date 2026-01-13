#!/bin/bash
set -e

# Wait for Redis to be ready
until redis-cli ping; do
    echo "Waiting for Redis to be ready..."
    sleep 2
done

# Run the original Redis server
exec redis-server /etc/redis/redis.conf