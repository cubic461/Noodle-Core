#!/bin/bash
set -e

# Apply custom PostgreSQL configuration if it exists
if [ -f /etc/postgresql/postgresql.conf ]; then
    echo "Applying custom PostgreSQL configuration..."
    # The configuration will be automatically loaded by PostgreSQL
fi

# Wait for database to be ready
until pg_isready -U postgres; do
    echo "Waiting for PostgreSQL to be ready..."
    sleep 2
done

# Run the original entrypoint script
exec docker-entrypoint.sh "$@"