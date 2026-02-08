#!/bin/sh
set -e

echo "Starting FastAPI backend..."
echo "Python version: $(python --version)"

# Wait for database to be ready (optional, can be removed if not needed)
if [ -n "$DATABASE_URL" ]; then
    echo "Checking database connectivity..."
    # Add database connection check here if needed
fi

echo "Starting Uvicorn server..."

# Execute the main command
exec "$@"
